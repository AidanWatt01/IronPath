// lib/domain/unlock_service.dart
import "package:drift/drift.dart";

import "../data/db/app_db.dart";
import "prereq_rules.dart";

/// A UI-friendly explanation for why a movement is still locked.
class LockReason {
  LockReason(this.message, {this.current, this.required});

  final String message;
  final Object? current;
  final Object? required;

  @override
  String toString() => message;
}

class UnlockResult {
  UnlockResult({
    required this.unlockedMovementIds,
    required this.lockReasonsByMovementId,
  });

  /// Movements that transitioned locked -> unlocked during this run.
  final List<String> unlockedMovementIds;

  /// For movements that remain locked after recompute, explain why.
  final Map<String, List<LockReason>> lockReasonsByMovementId;
}

/// Deterministic unlock recomputation (XP + prereqs), with explainable lock reasons.
/// - Runs to a fixpoint so chains unlock in a single run.
/// - Never downgrades states (won't change tiers downward; won't relock).
class UnlockService {
  UnlockService(this.db);

  final AppDb db;

  Future<UnlockResult> recomputeAndApply({DateTime? now}) async {
    final snapshot = await _loadSnapshot();
    final result = _compute(snapshot, now: now ?? DateTime.now());
    await _apply(result, now: now ?? DateTime.now());
    return result;
  }

  // ---------------------------------------------------------------------------
  // Snapshot
  // ---------------------------------------------------------------------------

  Future<_Snapshot> _loadSnapshot() async {
    final stats = await (db.select(
      db.userStats,
    )..where((s) => s.id.equals(1))).getSingleOrNull();
    final totalXp = stats?.totalXp ?? 0;

    final movements = await db.select(db.movements).get();
    final prereqs = await db.select(db.movementPrereqs).get();
    final progresses = await db.select(db.movementProgresses).get();

    final movementById = <String, Movement>{for (final m in movements) m.id: m};
    final progressById = <String, MovementProgress>{
      for (final p in progresses) p.movementId: p,
    };

    final prereqsByMovementId = <String, List<MovementPrereq>>{};
    for (final p in prereqs) {
      prereqsByMovementId.putIfAbsent(p.movementId, () => []).add(p);
    }

    return _Snapshot(
      totalXp: totalXp,
      movements: movements,
      movementById: movementById,
      prereqsByMovementId: prereqsByMovementId,
      progressById: progressById,
    );
  }

  // ---------------------------------------------------------------------------
  // Compute
  // ---------------------------------------------------------------------------

  UnlockResult _compute(_Snapshot s, {required DateTime now}) {
    // In-memory state map used for fixpoint unlock propagation.
    // NOTE: this only changes locked -> unlocked during this recompute.
    final stateById = <String, String>{
      for (final m in s.movements)
        m.id: (s.progressById[m.id]?.state ?? "locked"),
    };

    final toUnlock = <String>{};

    bool changed = true;
    while (changed) {
      changed = false;

      for (final m in s.movements) {
        final curState = stateById[m.id] ?? "locked";
        if (curState != "locked") continue;

        // XP gate (user XP)
        if (s.totalXp < m.xpToUnlock) continue;

        // Prereq gate(s)
        final reqs = s.prereqsByMovementId[m.id] ?? const <MovementPrereq>[];
        if (!_prereqsSatisfied(reqs, stateById)) continue;

        // Unlock in-memory so downstream nodes can become eligible immediately.
        stateById[m.id] = "unlocked";
        toUnlock.add(m.id);
        changed = true;
      }
    }

    // Explain what's still locked (after fixpoint propagation).
    final lockReasons = <String, List<LockReason>>{};
    for (final m in s.movements) {
      final curState = stateById[m.id] ?? "locked";
      if (curState != "locked") continue;

      lockReasons[m.id] = _computeLockReasonsForMovement(
        movement: m,
        prereqs: s.prereqsByMovementId[m.id] ?? const <MovementPrereq>[],
        totalXp: s.totalXp,
        movementById: s.movementById,
        progressById: s.progressById,
        stateById: stateById,
      );
    }

    final unlocked = toUnlock.toList()..sort();
    return UnlockResult(
      unlockedMovementIds: unlocked,
      lockReasonsByMovementId: lockReasons,
    );
  }

  // Allowed prereqType values:
  // - "unlocked" (default)
  // - "progress" | "bronze" | "silver" | "gold" | "mastered"
  // Legacy accepted: "master"
  bool _prereqsSatisfied(
    List<MovementPrereq> reqs,
    Map<String, String> stateById,
  ) {
    for (final r in reqs) {
      final preState = stateById[r.prereqMovementId];
      if (preState == null) return false;

      final required = normalizePrereqType(r.prereqType);

      if (required == "unlocked") {
        // unlocked means "not locked"
        if (preState == "locked") return false;
        continue;
      }

      // Tier-based compare: progress/bronze/silver/gold/mastered
      if (!isPrereqSatisfied(prereqType: required, currentState: preState)) {
        return false;
      }
    }
    return true;
  }

  List<LockReason> _computeLockReasonsForMovement({
    required Movement movement,
    required List<MovementPrereq> prereqs,
    required int totalXp,
    required Map<String, Movement> movementById,
    required Map<String, MovementProgress> progressById,
    required Map<String, String> stateById,
  }) {
    final reasons = <LockReason>[];

    // XP requirement (user XP)
    if (totalXp < movement.xpToUnlock) {
      final missing = movement.xpToUnlock - totalXp;
      reasons.add(
        LockReason(
          "XP gate: $totalXp / ${movement.xpToUnlock} (need $missing more)",
          current: totalXp,
          required: movement.xpToUnlock,
        ),
      );
    }

    // Prereqs
    for (final r in prereqs) {
      final required = normalizePrereqType(r.prereqType);

      final preMove = movementById[r.prereqMovementId];
      final preName = preMove?.name ?? r.prereqMovementId;
      final preState = stateById[r.prereqMovementId];
      final preProg = progressById[r.prereqMovementId];

      if (preState == null) {
        reasons.add(LockReason("Missing prerequisite progress: $preName"));
        continue;
      }

      if (required == "unlocked") {
        if (preState == "locked") {
          reasons.add(LockReason("Prereq: unlock $preName"));
        }
        continue;
      }

      if (!isPrereqSatisfied(prereqType: required, currentState: preState)) {
        reasons.add(
          LockReason(
            _tierHint(
              prereqMovement: preMove,
              prereqName: preName,
              requiredTierState: required,
              prereqProgress: preProg,
            ),
          ),
        );
      }
    }

    if (reasons.isEmpty) {
      reasons.add(LockReason("Unknown lock reason (check rules)"));
    }

    return reasons;
  }

  String _tierHint({
    required Movement? prereqMovement,
    required String prereqName,
    required String requiredTierState, // progress/bronze/silver/gold/mastered
    required MovementProgress? prereqProgress,
  }) {
    final tierLabel = _prettyTier(requiredTierState);

    // If we can’t read progress or movement entity, still explain the rule.
    if (prereqProgress == null || prereqMovement == null) {
      return "Prereq: $prereqName must be $tierLabel";
    }

    final target = targetForPrereqTier(prereqMovement, requiredTierState);

    // Should never happen, but keep safe.
    if (target == null) {
      return "Prereq: $prereqName must be $tierLabel";
    }

    final bestReps = prereqProgress.bestReps;
    final bestHold = prereqProgress.bestHoldSeconds;
    final xp = prereqProgress.totalXp;

    final missing = <String>[];

    if (target.reps > 0 && bestReps < target.reps) {
      missing.add("reps $bestReps/${target.reps}");
    }
    if (target.holdSeconds > 0 && bestHold < target.holdSeconds) {
      missing.add("hold ${bestHold}s/${target.holdSeconds}s");
    }
    if (target.totalXp > 0 && xp < target.totalXp) {
      missing.add("XP $xp/${target.totalXp}");
    }

    if (missing.isEmpty) {
      // They meet the benchmark; state may not have updated yet.
      return "Prereq: $prereqName = $tierLabel • benchmark met (log once to update)";
    }

    return "Prereq: $prereqName = $tierLabel (missing: ${missing.join(", ")})";
  }

  String _prettyTier(String tierState) {
    switch (tierState) {
      case "progress":
        return "Progress";
      case "bronze":
        return "Bronze";
      case "silver":
        return "Silver";
      case "gold":
        return "Gold";
      case "mastered":
        return "Mastered";
      default:
        return tierState;
    }
  }

  // ---------------------------------------------------------------------------
  // Apply
  // ---------------------------------------------------------------------------

  Future<void> _apply(UnlockResult result, {required DateTime now}) async {
    if (result.unlockedMovementIds.isEmpty) return;

    await (db.update(db.movementProgresses)..where(
          (p) =>
              p.movementId.isIn(result.unlockedMovementIds) &
              p.state.equals("locked"),
        ))
        .write(
          MovementProgressesCompanion(
            state: const Value("unlocked"),
            unlockedAt: Value(now),
          ),
        );
  }
}

class _Snapshot {
  _Snapshot({
    required this.totalXp,
    required this.movements,
    required this.movementById,
    required this.prereqsByMovementId,
    required this.progressById,
  });

  final int totalXp;
  final List<Movement> movements;
  final Map<String, Movement> movementById;
  final Map<String, List<MovementPrereq>> prereqsByMovementId;
  final Map<String, MovementProgress> progressById;
}
