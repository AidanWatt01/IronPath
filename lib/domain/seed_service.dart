import "package:drift/drift.dart";

import "../data/db/app_db.dart";
import "badge_catalog.dart";
import "movement_guide_catalog.dart";
import "skill_tree_catalog.dart";
import "unlock_service.dart";

class SeedService {
  SeedService(this.db);

  final AppDb db;

  Future<void> run() async {
    final now = DateTime.now();

    await db.transaction(() async {
      await _upsertMovements();
      await _upsertMovementGuides(); // v3
      await _replacePrereqs();
      await _upsertBadges();
      await _ensureUserStatsRow();
      await _ensureProgressRows();
      await _unlockStarters(now: now);

      // Deterministic, fixpoint recompute (XP + prereqs)
      final unlockService = UnlockService(db);
      await unlockService.recomputeAndApply(now: now);
    });
  }

  Future<void> _upsertMovements() async {
    final items = seedMovements.map((m) {
      return MovementsCompanion(
        id: Value(m.id),
        name: Value(m.name),
        category: Value(m.category),
        difficulty: Value(m.difficulty),
        description: Value(m.description),
        xpToUnlock: Value(m.xpToUnlock),
        baseXp: Value(m.baseXp),
        xpPerRep: Value(m.xpPerRep),
        xpPerSecond: Value(m.xpPerSecond),
        sortOrder: Value(m.sortOrder),
      );
    }).toList();

    for (final m in items) {
      await db.into(db.movements).insertOnConflictUpdate(m);
    }
  }

  Future<void> _upsertMovementGuides() async {
    String csv(List<String> items) =>
        items.map((e) => e.trim()).where((e) => e.isNotEmpty).join(", ");

    for (final g in seedMovementGuides) {
      await db
          .into(db.movementGuides)
          .insertOnConflictUpdate(
            MovementGuidesCompanion(
              movementId: Value(g.movementId),
              primaryMuscles: Value(csv(g.primaryMuscles)),
              secondaryMuscles: Value(csv(g.secondaryMuscles)),
              setup: Value(g.setup),
              execution: Value(g.execution),
              cues: Value(csv(g.cues)),
              commonMistakes: Value(csv(g.commonMistakes)),
              regressions: Value(csv(g.regressions)),
              progressions: Value(csv(g.progressions)),
              youtubeQuery: Value(g.youtubeQuery),
            ),
          );
    }
  }

  Future<void> _replacePrereqs() async {
    // NOTE: wipes ALL prereqs each run (your current behavior).
    await db.delete(db.movementPrereqs).go();

    await db.batch((batch) {
      batch.insertAll(
        db.movementPrereqs,
        seedPrereqs.map((p) {
          return MovementPrereqsCompanion(
            movementId: Value(p.movementId),
            prereqMovementId: Value(p.prereqMovementId),
            prereqType: Value(p.prereqType),
          );
        }).toList(),
      );
    });
  }

  Future<void> _upsertBadges() async {
    final allBadges = <SeedBadge>[...seedBadges, ..._generatedMovementBadges()];

    for (final b in allBadges) {
      await db
          .into(db.badges)
          .insertOnConflictUpdate(
            BadgesCompanion(
              id: Value(b.id),
              name: Value(b.name),
              description: Value(b.description),
              sortOrder: Value(b.sortOrder),
            ),
          );
    }
  }

  List<SeedBadge> _generatedMovementBadges() {
    final out = <SeedBadge>[];
    final existingIds = <String>{for (final b in seedBadges) b.id};

    int sort = 20000;

    for (final m in seedMovements) {
      final loggedId = "movement_${m.id}_logged";
      if (!existingIds.contains(loggedId)) {
        out.add(
          SeedBadge(
            id: loggedId,
            name: "${m.name} Logged",
            description: "Log your first ${m.name} session.",
            sortOrder: sort,
          ),
        );
      }
      sort += 1;

      final bronzeId = "movement_${m.id}_bronze";
      if (!existingIds.contains(bronzeId)) {
        out.add(
          SeedBadge(
            id: bronzeId,
            name: "${m.name} Bronze",
            description: "Reach Bronze tier in ${m.name}.",
            sortOrder: sort,
          ),
        );
      }
      sort += 1;

      final silverId = "movement_${m.id}_silver";
      if (!existingIds.contains(silverId)) {
        out.add(
          SeedBadge(
            id: silverId,
            name: "${m.name} Silver",
            description: "Reach Silver tier in ${m.name}.",
            sortOrder: sort,
          ),
        );
      }
      sort += 1;

      final goldId = "movement_${m.id}_gold";
      if (!existingIds.contains(goldId)) {
        out.add(
          SeedBadge(
            id: goldId,
            name: "${m.name} Gold",
            description: "Reach Gold tier in ${m.name}.",
            sortOrder: sort,
          ),
        );
      }
      sort += 1;

      final masteredId = "movement_${m.id}_mastered";
      if (!existingIds.contains(masteredId)) {
        out.add(
          SeedBadge(
            id: masteredId,
            name: "${m.name} Mastered",
            description: "Reach Master tier in ${m.name}.",
            sortOrder: sort,
          ),
        );
      }
      sort += 1;
    }

    return out;
  }

  Future<void> _ensureUserStatsRow() async {
    await db
        .into(db.userStats)
        .insert(
          const UserStatsCompanion(
            id: Value(1),
            totalXp: Value(0),
            level: Value(1),
            currentStreak: Value(0),
            bestStreak: Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _ensureProgressRows() async {
    final allMovements = await db.select(db.movements).get();

    final existingRows = await (db.selectOnly(
      db.movementProgresses,
    )..addColumns([db.movementProgresses.movementId])).get();

    final existing = <String>{
      for (final row in existingRows)
        row.read(db.movementProgresses.movementId)!,
    };

    final missing = <MovementProgressesCompanion>[];
    for (final m in allMovements) {
      if (existing.contains(m.id)) continue;

      missing.add(
        MovementProgressesCompanion(
          movementId: Value(m.id),
          state: const Value("locked"),
        ),
      );
    }

    if (missing.isEmpty) return;

    await db.batch((b) {
      b.insertAll(
        db.movementProgresses,
        missing,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> _unlockStarters({required DateTime now}) async {
    final starters = <String>[
      "incline_push_up",
      "australian_pull_up",
      "bodyweight_squat",
      "plank",
      "wrist_mobility",
      "shoulder_dislocates",
      "active_hang",
    ];

    // IMPORTANT: never downgrade mastered -> unlocked.
    // Only unlock rows that are currently locked.
    for (final id in starters) {
      await (db.update(db.movementProgresses)
            ..where((p) => p.movementId.equals(id) & p.state.equals("locked")))
          .write(
            MovementProgressesCompanion(
              state: const Value("unlocked"),
              unlockedAt: Value(now),
            ),
          );
    }
  }
}
