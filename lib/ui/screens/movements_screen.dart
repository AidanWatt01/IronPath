import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../domain/prereq_rules.dart";
import "../../state/providers.dart";
import "../theme/tier_visuals.dart";
import "../widgets/movement_card.dart";
import "../widgets/quick_log_sheet.dart";
import "movement_detail_screen.dart";

enum _MovementStateFilter { all, unlocked, mastered, locked }

enum _MovementSort { recommended, name, difficulty, progress }

class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key});

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  String category = "all";
  _MovementStateFilter stateFilter = _MovementStateFilter.all;
  _MovementSort sort = _MovementSort.recommended;
  String query = "";

  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    if (_queryController.text.isNotEmpty) {
      _queryController.clear();
    }

    setState(() {
      query = "";
      category = "all";
      stateFilter = _MovementStateFilter.all;
      sort = _MovementSort.recommended;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(movementsWithProgressProvider);
    final prereqs = ref.watch(prereqsProvider);
    final stats = ref.watch(userStatProvider);
    final recentSessions = ref.watch(recentSessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Movements")),
      body: movements.when(
        data: (items) {
          return prereqs.when(
            data: (reqs) {
              return stats.when(
                data: (s) {
                  return recentSessions.when(
                    data: (recent) {
                      // Build prereq map
                      final byMovement = <String, List<MovementPrereq>>{};
                      for (final r in reqs) {
                        byMovement.putIfAbsent(r.movementId, () => []).add(r);
                      }

                      // Name + state map (for MovementCard prereq display)
                      final nameMap = <String, String>{};
                      final stateMap = <String, String>{};
                      for (final x in items) {
                        nameMap[x.movement.id] = x.movement.name;
                        stateMap[x.movement.id] = x.progress.state;
                      }

                      final filtered = _applyFilters(items);
                      final sorted = _applySort(filtered);
                      final entries = _buildSectionedEntries(sorted);

                      final counts = _computeCounts(items);
                      final pct = counts.total == 0
                          ? 0.0
                          : ((counts.unlocked + counts.mastered) /
                                counts.total);

                      final recModel = _buildRecommendedModel(
                        items: items,
                        byMovement: byMovement,
                        stateById: stateMap,
                        userTotalXp: s.totalXp,
                        recent: recent,
                        goalMovementId: ref
                            .watch(skillGoalProvider)
                            .maybeWhen(data: (id) => id, orElse: () => null),
                      );

                      Future<void> quickLog(
                        String movementId,
                        String movementName,
                      ) async {
                        final movement = items
                            .where((x) => x.movement.id == movementId)
                            .map((x) => x.movement)
                            .cast<Movement?>()
                            .firstOrNull;

                        if (movement == null) return;
                        final m = movement;

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => QuickLogSheet(
                            movementId: m.id,
                            movementName: m.name,
                            xpPerRep: m.xpPerRep,
                            xpPerSecond: m.xpPerSecond,
                            category: m.category,
                          ),
                        );
                      }

                      void openDetail(String movementId) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                MovementDetailScreen(movementId: movementId),
                          ),
                        );
                      }

                      // Single scrollable surface = no Column overflow on mobile.
                      return CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _MovementsHeader(
                                    totalXp: s.totalXp,
                                    total: counts.total,
                                    unlocked: counts.unlocked,
                                    mastered: counts.mastered,
                                    locked: counts.locked,
                                    pct: pct,
                                  ),

                                  if (recModel != null &&
                                      recModel.recs.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    _RecommendedNextPanel(
                                      model: recModel,
                                      onOpen: openDetail,
                                      onQuickLog: (id, name) =>
                                          quickLog(id, name),
                                    ),
                                  ],

                                  const SizedBox(height: 12),

                                  _Controls(
                                    queryController: _queryController,
                                    category: category,
                                    stateFilter: stateFilter,
                                    sort: sort,
                                    onQuery: (v) => setState(() => query = v),
                                    onCategory: (v) =>
                                        setState(() => category = v),
                                    onState: (v) =>
                                        setState(() => stateFilter = v),
                                    onSort: (v) => setState(() => sort = v),
                                    onClear: _hasActiveFilters()
                                        ? _resetFilters
                                        : null,
                                  ),

                                  const SizedBox(height: 12),

                                  Row(
                                    children: [
                                      Text(
                                        "${sorted.length} movement${sorted.length == 1 ? "" : "s"}",
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          if (entries.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: _EmptyState(
                                  title: "No movements match your filters",
                                  subtitle:
                                      "Try clearing search or switching filters.",
                                  onClear: _resetFilters,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  // separator pattern: item, gap, item, gap...
                                  final isGap = index.isOdd;
                                  if (isGap) return const SizedBox(height: 10);

                                  final i = index ~/ 2;
                                  final e = entries[i];

                                  if (e.isHeader) {
                                    return _SectionHeader(
                                      title: e.headerTitle!,
                                    );
                                  }

                                  final x = e.item!;
                                  final reqList =
                                      byMovement[x.movement.id] ??
                                      const <MovementPrereq>[];
                                  final canQuickLog =
                                      x.progress.state != "locked";

                                  return MovementCard(
                                    movement: x.movement,
                                    progress: x.progress,
                                    prereqs: reqList,
                                    movementNamesById: nameMap,
                                    movementStateById: stateMap,
                                    userTotalXp: s.totalXp,
                                    onQuickLog: canQuickLog
                                        ? () async => quickLog(
                                            x.movement.id,
                                            x.movement.name,
                                          )
                                        : null,
                                    onTap: () => openDetail(x.movement.id),
                                  );
                                }, childCount: entries.length * 2 - 1),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text("Recent sessions error: $e")),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Stats error: $e")),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Prereqs error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Movements error: $e")),
      ),
    );
  }

  bool _hasActiveFilters() {
    return query.trim().isNotEmpty ||
        category != "all" ||
        stateFilter != _MovementStateFilter.all ||
        sort != _MovementSort.recommended;
  }

  List<MovementWithProgress> _applyFilters(List<MovementWithProgress> items) {
    final q = query.trim().toLowerCase();

    return items.where((x) {
      final matchesCategory =
          category == "all" || x.movement.category == category;

      final st = x.progress.state;
      final matchesState = switch (stateFilter) {
        _MovementStateFilter.all => true,
        _MovementStateFilter.locked => st == "locked",
        _MovementStateFilter.unlocked => TierVisuals.isUnlockedGroup(st),
        _MovementStateFilter.mastered => st == "mastered",
      };

      final name = x.movement.name.toLowerCase();
      final desc = x.movement.description.toLowerCase();
      final matchesQuery = q.isEmpty || name.contains(q) || desc.contains(q);

      return matchesCategory && matchesState && matchesQuery;
    }).toList();
  }

  List<MovementWithProgress> _applySort(List<MovementWithProgress> items) {
    final out = [...items];

    int stateBucket(String st) {
      if (TierVisuals.isUnlockedGroup(st)) return 0;
      if (TierVisuals.isMastered(st)) return 1;
      return 2; // locked
    }

    int safeCompare(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    out.sort((a, b) {
      if (sort == _MovementSort.recommended) {
        final ra = stateBucket(a.progress.state);
        final rb = stateBucket(b.progress.state);
        if (ra != rb) return ra.compareTo(rb);

        if (ra == 0) {
          final ta = TierVisuals.progressionRank(a.progress.state);
          final tb = TierVisuals.progressionRank(b.progress.state);
          if (ta != tb) return tb.compareTo(ta);
        }

        final da = a.movement.difficulty;
        final db = b.movement.difficulty;
        if (da != db) return da.compareTo(db);

        return safeCompare(a.movement.name, b.movement.name);
      }

      if (sort == _MovementSort.name) {
        return safeCompare(a.movement.name, b.movement.name);
      }

      if (sort == _MovementSort.difficulty) {
        final da = a.movement.difficulty;
        final db = b.movement.difficulty;
        if (da != db) return da.compareTo(db);
        return safeCompare(a.movement.name, b.movement.name);
      }

      final ra = stateBucket(a.progress.state);
      final rb = stateBucket(b.progress.state);
      if (ra != rb) return ra.compareTo(rb);

      if (ra == 0) {
        final ta = TierVisuals.progressionRank(a.progress.state);
        final tb = TierVisuals.progressionRank(b.progress.state);
        if (ta != tb) return tb.compareTo(ta);
      }

      final xa = a.progress.totalXp;
      final xb = b.progress.totalXp;
      if (xa != xb) return xb.compareTo(xa);

      return safeCompare(a.movement.name, b.movement.name);
    });

    return out;
  }

  List<_Entry> _buildSectionedEntries(List<MovementWithProgress> sorted) {
    if (sorted.isEmpty) return const <_Entry>[];

    String headerForState(String st) {
      if (TierVisuals.isLocked(st)) return "Locked";
      if (TierVisuals.isMastered(st)) return "Master";
      return TierVisuals.labelForState(st);
    }

    final entries = <_Entry>[];
    String? lastHeader;

    for (final x in sorted) {
      final h = headerForState(x.progress.state);
      if (h != lastHeader) {
        entries.add(_Entry.header(h));
        lastHeader = h;
      }
      entries.add(_Entry.item(x));
    }

    return entries;
  }

  _Counts _computeCounts(List<MovementWithProgress> items) {
    int locked = 0;
    int unlocked = 0;
    int mastered = 0;

    for (final x in items) {
      final st = x.progress.state;
      if (st == "locked") {
        locked++;
      } else if (st == "mastered") {
        mastered++;
      } else {
        unlocked++;
      }
    }

    return _Counts(
      total: items.length,
      locked: locked,
      unlocked: unlocked,
      mastered: mastered,
    );
  }
}

/// -------------------- Recommended Next (smarter w/ recent sessions) --------------------

class _RecModel {
  const _RecModel({required this.recs, this.lastLabel, this.subLabel});

  final List<_RecItem> recs;
  final String? lastLabel;
  final String? subLabel;
}

class _RecItem {
  const _RecItem({
    required this.movementId,
    required this.movementName,
    required this.category,
    required this.state,
    required this.headline,
    required this.reason,
    required this.ctaLabel,
    required this.canQuickLog,
    this.progressLabel,
    this.progressPct,
  });

  final String movementId;
  final String movementName;
  final String category;
  final String state; // locked/unlocked/progress/bronze/silver/gold/mastered
  final String headline;
  final String reason;
  final String ctaLabel;
  final bool canQuickLog;

  final String? progressLabel;
  final double? progressPct;
}

_RecModel? _buildRecommendedModel({
  required List<MovementWithProgress> items,
  required Map<String, List<MovementPrereq>> byMovement,
  required Map<String, String> stateById,
  required int userTotalXp,
  required List<SessionWithMovement> recent,
  required String? goalMovementId,
}) {
  if (items.isEmpty) return null;

  final byId = <String, MovementWithProgress>{};
  for (final x in items) {
    byId[x.movement.id] = x;
  }

  String? lastMovementId;
  String? lastCategory;
  if (recent.isNotEmpty) {
    lastMovementId = recent.first.movement.id;
    lastCategory = recent.first.movement.category;
  }

  final recentCounts = <String, int>{};
  for (final s in recent) {
    recentCounts[s.movement.id] = (recentCounts[s.movement.id] ?? 0) + 1;
  }

  final goalId = goalMovementId?.trim();
  final goal = (goalId == null || goalId.isEmpty) ? null : byId[goalId];

  final dependentCounts = <String, int>{};
  for (final entry in byMovement.entries) {
    final target = byId[entry.key];
    if (target == null) continue;
    if (TierVisuals.isMastered(target.progress.state)) continue;

    for (final r in entry.value) {
      dependentCounts[r.prereqMovementId] =
          (dependentCounts[r.prereqMovementId] ?? 0) + 1;
    }
  }

  bool prereqsOk(String movementId) {
    final reqs = byMovement[movementId] ?? const <MovementPrereq>[];
    for (final r in reqs) {
      final st = stateById[r.prereqMovementId] ?? "locked";
      final ok = isPrereqSatisfied(prereqType: r.prereqType, currentState: st);
      if (!ok) return false;
    }
    return true;
  }

  final recs = <_RecItem>[];
  final added = <String>{};

  void addRec(_RecItem item) {
    if (added.contains(item.movementId)) return;
    added.add(item.movementId);
    recs.add(item);
  }

  final goalBlockerIds = <String>{};
  if (goal != null && goal.progress.state == "locked") {
    final reqs = byMovement[goal.movement.id] ?? const <MovementPrereq>[];
    for (final r in reqs) {
      final st = stateById[r.prereqMovementId] ?? "locked";
      final ok = isPrereqSatisfied(prereqType: r.prereqType, currentState: st);
      if (ok) continue;

      final pre = byId[r.prereqMovementId];
      if (pre == null) continue;
      if (pre.progress.state == "locked") continue;
      goalBlockerIds.add(pre.movement.id);
    }
  }

  double scoreTrainable(MovementWithProgress x) {
    final id = x.movement.id;
    final repeats = (recentCounts[id] ?? 0).toDouble();
    final tierRank = TierVisuals.progressionRank(x.progress.state).toDouble();
    final invested = math.log(x.progress.totalXp + 1) / math.ln10;
    final dependents = (dependentCounts[id] ?? 0).clamp(0, 6).toDouble();

    var score = 0.0;
    if (goal != null && id == goal.movement.id) score += 5.0;
    if (goalBlockerIds.contains(id)) score += 3.2;
    if (id == lastMovementId) score += 1.5;
    if (lastCategory != null && x.movement.category == lastCategory) {
      score += 0.8;
    }

    score += tierRank * 0.35;
    score += invested * 0.70;
    score += dependents * 0.30;
    score -= repeats * 1.15;
    score -= x.movement.difficulty * 0.08;
    return score;
  }

  if (goal != null && TierVisuals.isUnlockedGroup(goal.progress.state)) {
    addRec(
      _RecItem(
        movementId: goal.movement.id,
        movementName: goal.movement.name,
        category: goal.movement.category,
        state: goal.progress.state,
        headline: "Goal focus",
        reason:
            "This is your pinned goal and it's trainable now. Logging here is the fastest direct progress.",
        ctaLabel: "Log",
        canQuickLog: true,
        progressLabel: "Movement XP ${_fmtInt(goal.progress.totalXp)}",
      ),
    );
  }

  if (goal != null &&
      goal.progress.state == "locked" &&
      goalBlockerIds.isNotEmpty) {
    final blockers =
        goalBlockerIds
            .map((id) => byId[id])
            .whereType<MovementWithProgress>()
            .toList()
          ..sort((a, b) => scoreTrainable(b).compareTo(scoreTrainable(a)));

    final top = blockers.first;
    addRec(
      _RecItem(
        movementId: top.movement.id,
        movementName: top.movement.name,
        category: top.movement.category,
        state: top.progress.state,
        headline: "Goal prerequisite",
        reason:
            "This prerequisite is currently blocking your goal. Train it first to unlock the next step.",
        ctaLabel: "Log",
        canQuickLog: true,
        progressLabel: "Movement XP ${_fmtInt(top.progress.totalXp)}",
      ),
    );
  }

  if (lastMovementId != null) {
    final x = byId[lastMovementId];
    final repeats = recentCounts[lastMovementId] ?? 0;
    if (x != null && x.progress.state != "locked" && repeats <= 3) {
      addRec(
        _RecItem(
          movementId: x.movement.id,
          movementName: x.movement.name,
          category: x.movement.category,
          state: x.progress.state,
          headline: "Continue",
          reason:
              "You trained this most recently. Add another quality session to stack XP and tighten form.",
          ctaLabel: "Log",
          canQuickLog: true,
          progressLabel: "Movement XP ${_fmtInt(x.progress.totalXp)}",
        ),
      );
    }
  }

  final unlockedNotMastered =
      items
          .where((x) => TierVisuals.isUnlockedGroup(x.progress.state))
          .where((x) => !added.contains(x.movement.id))
          .toList()
        ..sort((a, b) => scoreTrainable(b).compareTo(scoreTrainable(a)));

  for (final x in unlockedNotMastered) {
    if (added.contains(x.movement.id)) continue;

    final rank = TierVisuals.progressionRank(x.progress.state);
    final headline = goalBlockerIds.contains(x.movement.id)
        ? "Goal prerequisite"
        : rank >= 4
        ? "Push to mastery"
        : "Build consistency";

    final reason = goalBlockerIds.contains(x.movement.id)
        ? "This movement opens progress toward your goal."
        : rank >= 4
        ? "You already invested XP here. A focused session can move this to the next tier."
        : "Good balance of momentum, unlock impact, and freshness from your recent training.";

    addRec(
      _RecItem(
        movementId: x.movement.id,
        movementName: x.movement.name,
        category: x.movement.category,
        state: x.progress.state,
        headline: headline,
        reason: reason,
        ctaLabel: "Log",
        canQuickLog: true,
        progressLabel: "Movement XP ${_fmtInt(x.progress.totalXp)}",
      ),
    );

    if (recs.length >= 2) break;
  }

  if (recs.isNotEmpty) {
    final primaryCategory = recs.first.category;
    final variety = unlockedNotMastered.where(
      (x) =>
          !added.contains(x.movement.id) &&
          x.movement.category != primaryCategory,
    );

    final pick = variety.isNotEmpty ? variety.first : null;
    if (pick != null && recs.length < 3) {
      addRec(
        _RecItem(
          movementId: pick.movement.id,
          movementName: pick.movement.name,
          category: pick.movement.category,
          state: pick.progress.state,
          headline: "Good next session",
          reason: "Strong option that adds variety without losing progression.",
          ctaLabel: "Log",
          canQuickLog: true,
          progressLabel: "Movement XP ${_fmtInt(pick.progress.totalXp)}",
        ),
      );
    }
  }

  final lockCandidates = items.where((x) {
    if (x.progress.state != "locked") return false;
    if (added.contains(x.movement.id)) return false;
    if (!prereqsOk(x.movement.id)) return false;
    return true;
  }).toList();

  lockCandidates.sort((a, b) {
    final ra = math.max(0, a.movement.xpToUnlock - userTotalXp);
    final rb = math.max(0, b.movement.xpToUnlock - userTotalXp);
    if (ra != rb) return ra.compareTo(rb);
    return a.movement.difficulty.compareTo(b.movement.difficulty);
  });

  for (final x in lockCandidates.take(1)) {
    final remaining = math.max(0, x.movement.xpToUnlock - userTotalXp);
    final pct = x.movement.xpToUnlock <= 0
        ? 0.0
        : (userTotalXp / x.movement.xpToUnlock).clamp(0.0, 1.0);

    addRec(
      _RecItem(
        movementId: x.movement.id,
        movementName: x.movement.name,
        category: x.movement.category,
        state: x.progress.state,
        headline: goal != null && x.movement.id == goal.movement.id
            ? "Unlock your goal"
            : "Unlock next",
        reason: remaining <= 0
            ? "You meet the XP requirement - open it and start logging."
            : "Prereqs are done. You're close on XP - keep logging and unlock this soon.",
        ctaLabel: "View",
        canQuickLog: false,
        progressLabel: remaining <= 0
            ? "Ready to unlock"
            : "${_fmtInt(userTotalXp)} / ${_fmtInt(x.movement.xpToUnlock)} XP",
        progressPct: pct,
      ),
    );
  }

  if (recs.isEmpty) {
    final fallback = items.firstWhere(
      (x) => x.progress.state != "locked",
      orElse: () => items.first,
    );
    addRec(
      _RecItem(
        movementId: fallback.movement.id,
        movementName: fallback.movement.name,
        category: fallback.movement.category,
        state: fallback.progress.state,
        headline: "Start here",
        reason: "Solid baseline option to keep your training streak moving.",
        ctaLabel: fallback.progress.state == "locked" ? "View" : "Log",
        canQuickLog: fallback.progress.state != "locked",
        progressLabel: "Movement XP ${_fmtInt(fallback.progress.totalXp)}",
      ),
    );
  }

  final lastLabel = lastMovementId == null
      ? null
      : "Last: ${byId[lastMovementId]?.movement.name ?? ""}".trim();
  final goalLabel = goal == null ? null : "Goal: ${goal.movement.name}";

  return _RecModel(
    recs: recs.take(4).toList(),
    lastLabel: (lastLabel != null && lastLabel != "Last:") ? lastLabel : null,
    subLabel:
        goalLabel ??
        (lastCategory == null
            ? null
            : "Focus: ${_prettyCategory(lastCategory)}"),
  );
}

class _RecommendedNextPanel extends StatelessWidget {
  const _RecommendedNextPanel({
    required this.model,
    required this.onOpen,
    required this.onQuickLog,
  });

  final _RecModel model;
  final void Function(String movementId) onOpen;
  final Future<void> Function(String movementId, String movementName)
  onQuickLog;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 680;
        final displayRecs = isCompact
            ? model.recs.take(3).toList()
            : model.recs;
        final listHeight =
            (isCompact ? 166.0 : 184.0) * textScale.clamp(1.0, 1.2).toDouble();
        final compactWidth = (constraints.maxWidth - 24).clamp(252.0, 360.0);
        final cardWidth = isCompact ? compactWidth.toDouble() : 330.0;
        final metaLine = [
          if (model.lastLabel != null) model.lastLabel!,
          if (model.subLabel != null) model.subLabel!,
        ].join(" | ");

        Widget buildRecCard(_RecItem r) {
          final isLocked = r.state == "locked";
          final tier = TierVisuals.forState(r.state, scheme);

          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: cardWidth),
            child: InkWell(
              onTap: () => onOpen(r.movementId),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(isCompact ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isCompact)
                            Text(
                              r.headline,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            )
                          else
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  r.headline,
                                  style: TextStyle(
                                    color: scheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          const Spacer(),
                          if (!isCompact)
                            Icon(
                              Icons.chevron_right,
                              color: scheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        r.movementName,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${_prettyCategory(r.category)} - ${tier.label}",
                        style: TextStyle(
                          color: isLocked
                              ? scheme.onSurfaceVariant
                              : tier.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isCompact ? 4 : 6),
                      Expanded(
                        child: Text(
                          r.reason,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                          maxLines: isCompact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (r.progressPct != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: r.progressPct!.clamp(0.0, 1.0),
                            minHeight: isCompact ? 6 : 8,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (!isCompact)
                            Expanded(
                              child: Text(
                                r.progressLabel ??
                                    (isLocked ? "Locked" : "Unlocked"),
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(width: 10),
                          if (!isLocked && r.canQuickLog)
                            FilledButton.tonal(
                              onPressed: () =>
                                  onQuickLog(r.movementId, r.movementName),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: const Size(0, 36),
                              ),
                              child: Text(r.ctaLabel),
                            )
                          else
                            OutlinedButton(
                              onPressed: () => onOpen(r.movementId),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: const Size(0, 36),
                              ),
                              child: const Text("View"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(isCompact ? 12 : 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: scheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      "Recommended next",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (!isCompact && metaLine.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    if (model.lastLabel != null)
                      _MiniPill(text: model.lastLabel!),
                    if (model.subLabel != null)
                      _MiniPill(text: model.subLabel!),
                  ],
                ),
              ],
              const SizedBox(height: 10),

              SizedBox(
                height: listHeight,
                child: isCompact
                    ? PageView.builder(
                        itemCount: displayRecs.length,
                        padEnds: false,
                        itemBuilder: (context, i) {
                          final right = i == displayRecs.length - 1
                              ? 0.0
                              : 10.0;
                          return Padding(
                            padding: EdgeInsets.only(right: right),
                            child: buildRecCard(displayRecs[i]),
                          );
                        },
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayRecs.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, i) =>
                            buildRecCard(displayRecs[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// -------------------- Controls & UI --------------------

class _Controls extends StatelessWidget {
  const _Controls({
    required this.queryController,
    required this.category,
    required this.stateFilter,
    required this.sort,
    required this.onQuery,
    required this.onCategory,
    required this.onState,
    required this.onSort,
    required this.onClear,
  });

  final TextEditingController queryController;
  final String category;
  final _MovementStateFilter stateFilter;
  final _MovementSort sort;

  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final ValueChanged<_MovementStateFilter> onState;
  final ValueChanged<_MovementSort> onSort;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;
        final statePills = [
          _Pill(
            label: "All",
            selected: stateFilter == _MovementStateFilter.all,
            onTap: () => onState(_MovementStateFilter.all),
          ),
          _Pill(
            label: "Unlocked",
            selected: stateFilter == _MovementStateFilter.unlocked,
            onTap: () => onState(_MovementStateFilter.unlocked),
          ),
          _Pill(
            label: "Mastered",
            selected: stateFilter == _MovementStateFilter.mastered,
            onTap: () => onState(_MovementStateFilter.mastered),
          ),
          _Pill(
            label: "Locked",
            selected: stateFilter == _MovementStateFilter.locked,
            onTap: () => onState(_MovementStateFilter.locked),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: queryController,
              onChanged: onQuery,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search movements...",
                isDense: true,
                suffixIcon: onClear == null
                    ? null
                    : IconButton(
                        tooltip: "Clear",
                        onPressed: onClear,
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            _CategoryRow(selected: category, onSelected: onCategory),
            const SizedBox(height: 10),
            if (isCompact) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < statePills.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      statePills[i],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _SortDropdown(value: sort, onChanged: onSort),
              ),
            ] else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...statePills,
                  const SizedBox(width: 6),
                  _SortDropdown(value: sort, onChanged: onSort),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _MovementSort value;
  final ValueChanged<_MovementSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<_MovementSort>(
      value: value,
      borderRadius: BorderRadius.circular(12),
      underline: const SizedBox.shrink(),
      items: const [
        DropdownMenuItem(
          value: _MovementSort.recommended,
          child: Text("Sort: Recommended"),
        ),
        DropdownMenuItem(value: _MovementSort.name, child: Text("Sort: Name")),
        DropdownMenuItem(
          value: _MovementSort.difficulty,
          child: Text("Sort: Difficulty"),
        ),
        DropdownMenuItem(
          value: _MovementSort.progress,
          child: Text("Sort: Progress"),
        ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MovementsHeader extends StatelessWidget {
  const _MovementsHeader({
    required this.totalXp,
    required this.total,
    required this.unlocked,
    required this.mastered,
    required this.locked,
    required this.pct,
  });

  final int totalXp;
  final int total;
  final int unlocked;
  final int mastered;
  final int locked;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 620;
    final percent = (pct * 100).round();
    final visibleStats = isCompact
        ? <Widget>[
            _StatChip(
              icon: Icons.lock_open,
              label: "Unlocked",
              value: unlocked,
            ),
            _StatChip(icon: Icons.lock_outline, label: "Locked", value: locked),
          ]
        : <Widget>[
            _StatChip(
              icon: Icons.lock_open,
              label: "Unlocked",
              value: unlocked,
            ),
            _StatChip(
              icon: Icons.emoji_events,
              label: "Mastered",
              value: mastered,
            ),
            _StatChip(icon: Icons.lock_outline, label: "Locked", value: locked),
            _StatChip(icon: Icons.grid_view, label: "Total", value: total),
          ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_list, color: scheme.primary),
              const SizedBox(width: 10),
              const Text(
                "Library",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "XP ${_fmtInt(totalXp)}",
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(spacing: 10, runSpacing: 10, children: visibleStats),

          if (!isCompact) ...[
            const SizedBox(height: 8),
            Text(
              total == 0
                  ? "Add movements to get started."
                  : "$percent% accessible (unlocked + mastered).",
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            "$label ${_fmtInt(value)}",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: onClear,
              child: const Text("Clear filters"),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.selected, required this.onSelected});

  final String selected;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <String, String>{
      "all": "All",
      "push": "Push",
      "pull": "Pull",
      "legs": "Legs",
      "core": "Core",
      "skill": "Skill",
      "compound": "Compound",
      "rings": "Rings",
      "mobility": "Mobility",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.entries.map((e) {
          final isSelected = selected == e.key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (_) => onSelected(e.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Entry {
  const _Entry._({this.item, this.headerTitle});

  final MovementWithProgress? item;
  final String? headerTitle;

  bool get isHeader => headerTitle != null;

  factory _Entry.item(MovementWithProgress x) => _Entry._(item: x);
  factory _Entry.header(String title) => _Entry._(headerTitle: title);
}

class _Counts {
  const _Counts({
    required this.total,
    required this.locked,
    required this.unlocked,
    required this.mastered,
  });

  final int total;
  final int locked;
  final int unlocked;
  final int mastered;
}

String _fmtInt(int n) {
  final s = n.toString();
  return s.replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]},");
}

String _prettyCategory(String c) {
  return switch (c) {
    "push" => "Push",
    "pull" => "Pull",
    "legs" => "Legs",
    "core" => "Core",
    "skill" => "Skill",
    "compound" => "Compound",
    "rings" => "Rings",
    "mobility" => "Mobility",
    _ => "General",
  };
}
