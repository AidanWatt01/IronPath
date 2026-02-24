// lib/ui/screens/dashboard_screen.dart
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../domain/cosmetic_catalog.dart";
import "../../domain/mastery_rules.dart";
import "../../domain/perk_catalog.dart";
import "../../domain/prereq_rules.dart";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";
import "../widgets/quick_log_sheet.dart";
import "movement_detail_screen.dart";

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // movementId > xpEarned (done state for this session/day inmemory)
  final Map<String, int> _doneXpByMovementId = {};

  static const _dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  int _nextLevelXp(int currentLevel) {
    return 100 * currentLevel * currentLevel;
  }

  int _prevLevelXp(int currentLevel) {
    final prev = currentLevel - 1;
    if (prev <= 0) return 0;
    return 100 * prev * prev;
  }

  _UnlockCandidate? _pickNextGoal({
    required List<MovementWithProgress> movements,
    required List<MovementPrereq> prereqs,
    required int totalXp,
  }) {
    final stateById = <String, String>{};
    final nameById = <String, String>{};

    for (final x in movements) {
      stateById[x.movement.id] = x.progress.state;
      nameById[x.movement.id] = x.movement.name;
    }

    final prereqsByMovement = <String, List<MovementPrereq>>{};
    for (final p in prereqs) {
      prereqsByMovement.putIfAbsent(p.movementId, () => []).add(p);
    }

    final candidates = <_UnlockCandidate>[];

    for (final x in movements) {
      if (x.progress.state != "locked") continue;

      final xpMissing = max(0, x.movement.xpToUnlock - totalXp);
      final reqs = prereqsByMovement[x.movement.id] ?? const <MovementPrereq>[];

      final missing = <_MissingPrereq>[];

      for (final r in reqs) {
        final preState = stateById[r.prereqMovementId] ?? "locked";
        final preName = nameById[r.prereqMovementId] ?? r.prereqMovementId;

        final ok = isPrereqSatisfied(
          prereqType: r.prereqType,
          currentState: preState,
        );

        if (!ok) {
          missing.add(
            _MissingPrereq(
              movementId: r.prereqMovementId,
              name: preName,
              prereqType: r.prereqType,
              currentState: preState,
            ),
          );
        }
      }

      candidates.add(
        _UnlockCandidate(
          target: x,
          xpMissing: xpMissing,
          missingPrereqs: missing,
        ),
      );
    }

    if (candidates.isEmpty) return null;

    candidates.sort((a, b) {
      final aMissing = a.missingPrereqs.length;
      final bMissing = b.missingPrereqs.length;

      if (aMissing != bMissing) return aMissing.compareTo(bMissing);
      return a.xpMissing.compareTo(b.xpMissing);
    });

    return candidates.first;
  }

  _UnlockCandidate? _candidateForGoal({
    required String? goalMovementId,
    required List<MovementWithProgress> movements,
    required List<MovementPrereq> prereqs,
    required int totalXp,
  }) {
    final goalId = goalMovementId?.trim();
    if (goalId == null || goalId.isEmpty) return null;

    final movementById = <String, MovementWithProgress>{
      for (final x in movements) x.movement.id: x,
    };
    final target = movementById[goalId];
    if (target == null) return null;

    final stateById = <String, String>{
      for (final x in movements) x.movement.id: x.progress.state,
    };
    final nameById = <String, String>{
      for (final x in movements) x.movement.id: x.movement.name,
    };

    final reqs = prereqs.where((p) => p.movementId == goalId).toList();
    final missing = <_MissingPrereq>[];

    for (final r in reqs) {
      final preState = stateById[r.prereqMovementId] ?? "locked";
      final preName = nameById[r.prereqMovementId] ?? r.prereqMovementId;

      final ok = isPrereqSatisfied(
        prereqType: r.prereqType,
        currentState: preState,
      );

      if (!ok) {
        missing.add(
          _MissingPrereq(
            movementId: r.prereqMovementId,
            name: preName,
            prereqType: r.prereqType,
            currentState: preState,
          ),
        );
      }
    }

    return _UnlockCandidate(
      target: target,
      xpMissing: max(0, target.movement.xpToUnlock - totalXp),
      missingPrereqs: missing,
    );
  }

  int _daysSince(DateTime? dt) {
    if (dt == null) return 9999;
    final now = DateTime.now();
    final a = DateTime(dt.year, dt.month, dt.day);
    final b = DateTime(now.year, now.month, now.day);
    return b.difference(a).inDays;
  }

  _PlanSuggestion _suggestForMovement({
    required Movement movement,
    required MovementProgress progress,
    required SessionWithMovement? last,
  }) {
    final d = movement.difficulty.clamp(1, 10);
    final lastSession = last?.session;
    final daysAway = _daysSince(lastSession?.startedAt);

    final isRepBased = movement.xpPerRep > 0 && movement.xpPerSecond == 0;
    final isHoldBased = movement.xpPerSecond > 0 && movement.xpPerRep == 0;

    // Next benchmark based on tier state
    final nextTarget = MasteryRules.nextTargetForState(
      movement: movement,
      state: progress.state,
    );

    int sets = 3;
    if (d >= 7) {
      sets = 5;
    } else if (d >= 4) {
      sets = 4;
    }

    // Recovery-aware set volume.
    if (daysAway == 0) {
      sets = max(2, sets - 2);
    } else if (daysAway <= 2) {
      sets = max(2, sets - 1);
    } else if (daysAway >= 6) {
      sets = max(2, sets - 1);
    }

    int goalReps = 0;
    int goalHold = 0;

    if (isRepBased) {
      final best = progress.bestReps;
      final lastReps = max(0, lastSession?.reps ?? 0);

      if (nextTarget.reps > 0) {
        final gap = max(0, nextTarget.reps - best);
        final shouldAttempt = gap <= 2 && daysAway >= 1;

        if (shouldAttempt) {
          sets = 1;
          goalReps = nextTarget.reps;
        } else {
          final base = (22 - d * 2).clamp(6, 20);
          final progressive = lastReps > 0
              ? lastReps + (daysAway >= 5 ? 0 : 1)
              : (best * 0.6).round();
          goalReps = max(base, progressive);
          goalReps = min(goalReps, max(1, nextTarget.reps - 1));
        }
      } else {
        final base = (20 - d).clamp(6, 18);
        final progressive = lastReps > 0
            ? lastReps + 1
            : max(base, (best * 0.6).round());
        goalReps = max(base, progressive);
      }
    }

    if (isHoldBased) {
      final best = progress.bestHoldSeconds;
      final lastHold = max(0, lastSession?.holdSeconds ?? 0);

      if (nextTarget.holdSeconds > 0) {
        final gap = max(0, nextTarget.holdSeconds - best);
        final shouldAttempt = gap <= 5 && daysAway >= 1;

        if (shouldAttempt) {
          sets = 1;
          goalHold = nextTarget.holdSeconds;
        } else {
          final base = (65 - d * 4).clamp(15, 60);
          final progressive = lastHold > 0
              ? lastHold + (daysAway >= 5 ? 1 : 3)
              : (best * 0.6).round();
          goalHold = max(base, progressive);
          goalHold = min(goalHold, max(5, nextTarget.holdSeconds - 2));
        }
      } else {
        final base = (50 - d * 3).clamp(15, 45);
        final progressive = lastHold > 0 ? lastHold + 3 : best;
        goalHold = max(base, progressive);
      }
    }

    // if movement is misconfigured (both 0), fallback
    if (!isRepBased && !isHoldBased) {
      goalReps = 10;
      sets = 3;
    }

    final estimatedRepDuration = max(60, sets * 45);
    final goalDurationSeconds = isHoldBased
        ? max(goalHold * sets, lastSession?.durationSeconds ?? 0)
        : max(lastSession?.durationSeconds ?? 0, estimatedRepDuration);

    return _PlanSuggestion(
      sets: sets,
      reps: goalReps,
      holdSeconds: goalHold,
      durationSeconds: goalDurationSeconds,
      formScore: d >= 8 ? 9 : 8,
      isBenchmarkAttempt:
          sets == 1 &&
          ((isRepBased && goalReps == nextTarget.reps && nextTarget.reps > 0) ||
              (isHoldBased &&
                  goalHold == nextTarget.holdSeconds &&
                  nextTarget.holdSeconds > 0)),
    );
  }

  List<String> _categoriesForDay(int weekday) {
    // Simple weekly split with builtin mobility touch points.
    switch (weekday) {
      case DateTime.monday:
        return const ["push", "core"];
      case DateTime.tuesday:
        return const ["pull", "core"];
      case DateTime.wednesday:
        return const ["legs", "mobility"];
      case DateTime.thursday:
        return const ["push", "skill"];
      case DateTime.friday:
        return const ["pull", "rings"];
      case DateTime.saturday:
        return const ["legs", "core"];
      case DateTime.sunday:
        return const ["mobility", "core"];
      default:
        return const ["push", "pull", "legs", "core"];
    }
  }

  List<_PlanItemData> _buildTodayPlan({
    required List<MovementWithProgress> movements,
    required List<MovementPrereq> prereqs,
    required List<SessionWithMovement> recent,
    required int totalXp,
    required int limit,
    required _UnlockCandidate? nextGoal,
    required String? focusMovementId,
    required DateTime now,
  }) {
    final progressById = <String, MovementProgress>{};
    final movementById = <String, Movement>{};

    for (final x in movements) {
      progressById[x.movement.id] = x.progress;
      movementById[x.movement.id] = x.movement;
    }

    // last session map
    final lastSessionByMovementId = <String, SessionWithMovement>{};
    for (final x in recent) {
      lastSessionByMovementId.putIfAbsent(x.movement.id, () => x);
    }

    final todayCats = _categoriesForDay(now.weekday).toSet();
    final goalBlockerIds = <String>{
      for (final m in nextGoal?.missingPrereqs ?? const <_MissingPrereq>[])
        m.movementId,
    };

    bool isTrainable(MovementWithProgress x) {
      final st = x.progress.state;
      return st != "locked" &&
          st != "mastered" &&
          !_doneXpByMovementId.containsKey(x.movement.id);
    }

    int daysSinceById(String id) {
      return _daysSince(lastSessionByMovementId[id]?.session.startedAt);
    }

    double progressFraction(MovementWithProgress x) {
      final target = MasteryRules.nextTargetForState(
        movement: x.movement,
        state: x.progress.state,
      );

      final parts = <double>[];
      if (target.reps > 0) {
        parts.add(x.progress.bestReps / max(1, target.reps));
      }
      if (target.holdSeconds > 0) {
        parts.add(x.progress.bestHoldSeconds / target.holdSeconds);
      }
      if (target.totalXp > 0) {
        parts.add(x.progress.totalXp / target.totalXp);
      }

      if (parts.isEmpty) return 0.0;
      final avg = parts.reduce((a, b) => a + b) / parts.length;
      return avg.clamp(0.0, 1.2);
    }

    final trainable = movements.where(isTrainable).toList();
    final trainableById = <String, MovementWithProgress>{
      for (final x in trainable) x.movement.id: x,
    };

    double scoreCandidate(MovementWithProgress x) {
      final id = x.movement.id;
      final days = daysSinceById(id);
      final progress = progressFraction(x);
      final nearBenchmark = (1 - ((progress - 0.9).abs() / 0.35)).clamp(
        0.0,
        1.0,
      );
      final undertrained = (1 - progress.clamp(0.0, 1.0)).clamp(0.0, 1.0);

      var score = min(days.toDouble(), 6.0) * 3.0; // 0..18
      score += nearBenchmark * 14.0;
      score += undertrained * 6.0;

      if (todayCats.contains(x.movement.category)) score += 11.0;
      if (focusMovementId != null && id == focusMovementId) score += 26.0;
      if (goalBlockerIds.contains(id)) score += 16.0;

      if (days == 0) score -= 20.0;
      if (days == 1) score -= 6.0;
      if (x.movement.difficulty >= 8 && days <= 1) score -= 8.0;

      if (x.movement.category == "mobility" && days >= 2) score += 4.0;
      return score;
    }

    int compareByScore(MovementWithProgress a, MovementWithProgress b) {
      final sa = scoreCandidate(a);
      final sb = scoreCandidate(b);
      if (sa != sb) return sb.compareTo(sa);

      final da = daysSinceById(a.movement.id);
      final db = daysSinceById(b.movement.id);
      if (da != db) return db.compareTo(da);

      return a.movement.difficulty.compareTo(b.movement.difficulty);
    }

    final planIds = <String>[];
    final catCounts = <String, int>{};
    var hardCount = 0;

    bool canAdd(MovementWithProgress x) {
      final cat = x.movement.category;
      final current = catCounts[cat] ?? 0;
      final maxPerCat = cat == "mobility" ? 1 : 2;
      if (current >= maxPerCat) return false;
      if (x.movement.difficulty >= 8 && hardCount >= 2) return false;
      return true;
    }

    void addMovement(String id) {
      if (planIds.length >= limit) return;
      if (planIds.contains(id)) return;

      final x = trainableById[id];
      if (x == null) return;
      if (!canAdd(x)) return;

      planIds.add(id);
      catCounts[x.movement.category] =
          (catCounts[x.movement.category] ?? 0) + 1;
      if (x.movement.difficulty >= 8) hardCount += 1;
    }

    // 1) Always respect explicit focus when trainable.
    if (focusMovementId != null) {
      addMovement(focusMovementId);
    }

    // 2) Include one goal blocker if possible.
    if (planIds.length < limit) {
      final blockers =
          trainable
              .where((x) => goalBlockerIds.contains(x.movement.id))
              .toList()
            ..sort(compareByScore);
      if (blockers.isNotEmpty) {
        addMovement(blockers.first.movement.id);
      }
    }

    // 3) Keep at least one movement aligned with today's split.
    if (planIds.length < limit) {
      final dayAligned =
          trainable
              .where((x) => todayCats.contains(x.movement.category))
              .toList()
            ..sort(compareByScore);
      if (dayAligned.isNotEmpty) {
        addMovement(dayAligned.first.movement.id);
      }
    }

    // 4) Add mobility if it has been neglected.
    final hasRecentMobility = recent.any((x) {
      return x.movement.category == "mobility" &&
          _daysSince(x.session.startedAt) <= 1;
    });
    if (limit >= 3 && !hasRecentMobility && planIds.length < limit) {
      final mobility =
          trainable.where((x) => x.movement.category == "mobility").toList()
            ..sort(compareByScore);
      if (mobility.isNotEmpty) {
        addMovement(mobility.first.movement.id);
      }
    }

    // 5) Fill remaining slots by global score.
    final ranked = [...trainable]..sort(compareByScore);
    for (final x in ranked) {
      if (planIds.length >= limit) break;
      addMovement(x.movement.id);
    }

    // 6) Safety: if none from today's categories made it in, replace last non-critical pick.
    final hasTodayCategory = planIds.any((id) {
      final m = movementById[id];
      return m != null && todayCats.contains(m.category);
    });
    if (!hasTodayCategory && planIds.isNotEmpty) {
      final replacement = ranked.firstWhere(
        (x) =>
            todayCats.contains(x.movement.category) &&
            !planIds.contains(x.movement.id),
        orElse: () => trainable.first,
      );

      var replaceIndex = -1;
      for (var i = planIds.length - 1; i >= 0; i--) {
        final id = planIds[i];
        final isCritical = id == focusMovementId || goalBlockerIds.contains(id);
        if (!isCritical) {
          replaceIndex = i;
          break;
        }
      }

      if (replaceIndex >= 0) {
        final oldId = planIds.removeAt(replaceIndex);
        final oldMovement = movementById[oldId];
        if (oldMovement != null) {
          catCounts[oldMovement.category] = max(
            0,
            (catCounts[oldMovement.category] ?? 1) - 1,
          );
          if (oldMovement.difficulty >= 8) {
            hardCount = max(0, hardCount - 1);
          }
        }
        addMovement(replacement.movement.id);
      }
    }

    final items = <_PlanItemData>[];

    for (final id in planIds) {
      final m = movementById[id];
      final p = progressById[id];
      if (m == null || p == null) continue;

      final last = lastSessionByMovementId[id];
      final suggestion = _suggestForMovement(
        movement: m,
        progress: p,
        last: last,
      );

      items.add(
        _PlanItemData(
          movement: m,
          progress: p,
          last: last,
          suggestion: suggestion,
        ),
      );
    }

    return items;
  }

  Map<String, List<MovementWithProgress>> _buildWeeklyPlan({
    required List<MovementWithProgress> movements,
    required List<SessionWithMovement> recent,
    required DateTime now,
    int perDay = 3,
  }) {
    final lastById = <String, SessionWithMovement>{};
    for (final r in recent) {
      lastById.putIfAbsent(r.movement.id, () => r);
    }

    bool trainable(MovementWithProgress x) =>
        x.progress.state != "locked" && x.progress.state != "mastered";

    int compare(MovementWithProgress a, MovementWithProgress b) {
      final la = _daysSince(lastById[a.movement.id]?.session.startedAt);
      final lb = _daysSince(lastById[b.movement.id]?.session.startedAt);
      if (la != lb) return lb.compareTo(la);

      final na = MasteryRules.nextTargetForState(
        movement: a.movement,
        state: a.progress.state,
      );
      final nb = MasteryRules.nextTargetForState(
        movement: b.movement,
        state: b.progress.state,
      );

      double prog(MovementWithProgress x, MasteryTarget n) {
        if (n.reps > 0)
          return (x.progress.bestReps / max(1, n.reps)).clamp(0.0, 1.0);
        if (n.holdSeconds > 0)
          return (x.progress.bestHoldSeconds / max(1, n.holdSeconds)).clamp(
            0.0,
            1.0,
          );
        return 0.0;
      }

      final pa = prog(a, na);
      final pb = prog(b, nb);
      if (pa != pb) return pb.compareTo(pa);

      return a.movement.difficulty.compareTo(b.movement.difficulty);
    }

    final plan = <String, List<MovementWithProgress>>{};
    final used = <String>{};
    Set<String> prevCats = {};

    for (int weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      final cats = _categoriesForDay(weekday);
      final label = _dayNames[(weekday - 1) % 7];

      final candidates = movements.where((x) {
        if (!trainable(x)) return false;
        if (used.contains(x.movement.id)) return false;
        return cats.contains(x.movement.category);
      }).toList()..sort(compare);

      // Prefer avoiding samecategory as yesterday
      final nonRepeat = candidates
          .where((x) => !prevCats.contains(x.movement.category))
          .toList();

      final picks = <MovementWithProgress>[];

      for (final c in (nonRepeat.isNotEmpty ? nonRepeat : candidates)) {
        if (picks.length >= perDay) break;
        picks.add(c);
        used.add(c.movement.id);
      }

      // If not enough matches, fill with any remaining trainable not yet used.
      if (picks.length < perDay) {
        final fill = movements.where((x) {
          if (!trainable(x)) return false;
          if (used.contains(x.movement.id)) return false;
          return true;
        }).toList()..sort(compare);

        for (final f in fill) {
          if (picks.length >= perDay) break;
          picks.add(f);
          used.add(f.movement.id);
        }
      }

      plan[label] = picks;
      prevCats = picks.map((p) => p.movement.category).toSet();
    }

    return plan;
  }

  Future<void> _openQuickLogFromPlan({
    required BuildContext context,
    required _PlanItemData item,
  }) async {
    final xp = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickLogSheet(
        movementId: item.movement.id,
        movementName: item.movement.name,
        xpPerRep: item.movement.xpPerRep,
        xpPerSecond: item.movement.xpPerSecond,
        category: item.movement.category,

        initialSets: item.suggestion.sets,
        initialReps: item.suggestion.reps,
        initialHoldSeconds: item.suggestion.holdSeconds,
        initialDurationSeconds: item.suggestion.durationSeconds,
        initialFormScore: item.suggestion.formScore.toDouble(),
        showSnackOnSave: false,
      ),
    );

    if (!context.mounted) return;

    if (xp != null) {
      setState(() {
        _doneXpByMovementId[item.movement.id] = xp;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nice! +$xp XP"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openPerksSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _PerksSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seed = ref.watch(seedProvider);
    final stats = ref.watch(userStatProvider);
    final movements = ref.watch(movementsWithProgressProvider);
    final prereqs = ref.watch(prereqsProvider);
    final recent = ref.watch(recentSessionsProvider);
    final badges = ref.watch(badgesProvider);
    final cosmeticStatus = ref.watch(cosmeticStatusProvider);
    final goalMovementId = ref
        .watch(skillGoalProvider)
        .maybeWhen(data: (id) => id, orElse: () => null);

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 980;
    final planLimit = width >= 1200 ? 6 : (width >= 980 ? 5 : 3);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: seed.when(
        data: (_) {
          return stats.when(
            data: (s) {
              return movements.when(
                data: (movementItems) {
                  final movementById = <String, Movement>{};
                  final progressById = <String, MovementProgress>{};

                  for (final x in movementItems) {
                    movementById[x.movement.id] = x.movement;
                    progressById[x.movement.id] = x.progress;
                  }

                  return prereqs.when(
                    data: (prereqItems) {
                      final currentLevel = max(1, s.level);
                      final nextLevelAt = _nextLevelXp(currentLevel);
                      final prevLevelAt = _prevLevelXp(currentLevel);

                      final denom = max(1, (nextLevelAt - prevLevelAt));
                      final levelProgress = ((s.totalXp - prevLevelAt) / denom)
                          .clamp(0.0, 1.0);

                      final autoNextGoal = _pickNextGoal(
                        movements: movementItems,
                        prereqs: prereqItems,
                        totalXp: s.totalXp,
                      );
                      final pinnedGoal = _candidateForGoal(
                        goalMovementId: goalMovementId,
                        movements: movementItems,
                        prereqs: prereqItems,
                        totalXp: s.totalXp,
                      );
                      final nextGoal = pinnedGoal ?? autoNextGoal;
                      final isPinnedGoal = pinnedGoal != null;

                      return recent.when(
                        data: (recentItems) {
                          final now = DateTime.now();

                          final plan = _buildTodayPlan(
                            movements: movementItems,
                            prereqs: prereqItems,
                            recent: recentItems,
                            totalXp: s.totalXp,
                            limit: planLimit,
                            nextGoal: nextGoal,
                            focusMovementId: goalMovementId,
                            now: now,
                          );

                          final weeklyPlan = _buildWeeklyPlan(
                            movements: movementItems,
                            recent: recentItems,
                            now: now,
                          );

                          final content = _DashboardContent(
                            isWide: isWide,
                            statsCard: _StatsCard(
                              totalXp: s.totalXp,
                              level: currentLevel,
                              perkPoints: s.perkPoints,
                              coins: s.coins,
                              currentStreak: s.currentStreak,
                              bestStreak: s.bestStreak,
                              nextLevelAt: nextLevelAt,
                              prevLevelAt: prevLevelAt,
                              levelProgress: levelProgress,
                              equippedCosmeticId: cosmeticStatus.maybeWhen(
                                data: (v) => v.equippedCosmeticId,
                                orElse: () => null,
                              ),
                              onOpenPerks: () => _openPerksSheet(context),
                            ),
                            todayPlanCard: _TodayPlanCard(
                              items: plan,
                              doneXpByMovementId: _doneXpByMovementId,
                              onOpenMovement: (id) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MovementDetailScreen(movementId: id),
                                  ),
                                );
                              },
                              onDo: (item) async {
                                await _openQuickLogFromPlan(
                                  context: context,
                                  item: item,
                                );
                              },
                            ),
                            weeklyPlanCard: _WeeklyPlanCard(
                              planByDay: weeklyPlan,
                              onOpenMovement: (id) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MovementDetailScreen(movementId: id),
                                  ),
                                );
                              },
                            ),
                            nextGoalCard: _NextGoalCard(
                              title: isPinnedGoal ? "Goal Focus" : "Next Goal",
                              isPinned: isPinnedGoal,
                              candidate: nextGoal,
                              onOpenTarget: nextGoal == null
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => MovementDetailScreen(
                                            movementId:
                                                nextGoal.target.movement.id,
                                          ),
                                        ),
                                      );
                                    },
                              onClearPinnedGoal: !isPinnedGoal
                                  ? null
                                  : () async {
                                      await ref
                                          .read(skillGoalProvider.notifier)
                                          .setGoal(null);
                                    },
                            ),
                            recentCard: _RecentSessionsCard(
                              items: recentItems,
                              canQuickLog: (movementId) {
                                final p = progressById[movementId];
                                return p != null && p.state != "locked";
                              },
                              onQuickLog: (movementId) async {
                                final m = movementById[movementId];
                                if (m == null) return;

                                final xp = await showModalBottomSheet<int>(
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

                                if (!context.mounted) return;
                                if (xp != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("+$xp XP"),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                            badgesCard: badges.when(
                              data: (items) {
                                final earned = items
                                    .where((b) => b.isEarned)
                                    .length;
                                return _BadgesSummaryCard(
                                  earned: earned,
                                  total: items.length,
                                );
                              },
                              loading: () =>
                                  const _LoadingCard(title: "Badges"),
                              error: (e, _) =>
                                  _ErrorCard(title: "Badges", error: "$e"),
                            ),
                          );

                          return Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: content,
                              ),
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text("Recent sessions error: $e")),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text("Prereqs error: $e")),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Movements error: $e")),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Stats error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Seed error: $e")),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.isWide,
    required this.statsCard,
    required this.todayPlanCard,
    required this.weeklyPlanCard,
    required this.nextGoalCard,
    required this.recentCard,
    required this.badgesCard,
  });

  final bool isWide;
  final Widget statsCard;
  final Widget todayPlanCard;
  final Widget weeklyPlanCard;
  final Widget nextGoalCard;
  final Widget recentCard;
  final Widget badgesCard;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return ListView(
        children: [
          statsCard,
          const SizedBox(height: 12),
          todayPlanCard,
          const SizedBox(height: 12),
          nextGoalCard,
          const SizedBox(height: 12),
          recentCard,
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: const Text(
                "More",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                weeklyPlanCard,
                const SizedBox(height: 10),
                badgesCard,
              ],
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statsCard,
                const SizedBox(height: 12),
                todayPlanCard,
                const SizedBox(height: 12),
                weeklyPlanCard,
                const SizedBox(height: 12),
                recentCard,
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [nextGoalCard, const SizedBox(height: 12), badgesCard],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalXp,
    required this.level,
    required this.perkPoints,
    required this.coins,
    required this.currentStreak,
    required this.bestStreak,
    required this.nextLevelAt,
    required this.prevLevelAt,
    required this.levelProgress,
    required this.equippedCosmeticId,
    required this.onOpenPerks,
  });

  final int totalXp;
  final int level;
  final int perkPoints;
  final int coins;
  final int currentStreak;
  final int bestStreak;
  final int nextLevelAt;
  final int prevLevelAt;
  final double levelProgress;
  final String? equippedCosmeticId;
  final VoidCallback onOpenPerks;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final toNext = max(0, nextLevelAt - totalXp);
    final levelPct = (levelProgress * 100).round();
    final perksLabel = perkPoints > 0 ? "Perks ($perkPoints)" : "Perks";
    final scheme = Theme.of(context).colorScheme;
    final visual = cosmeticVisualForId(
      equippedCosmeticId,
      fallbackColor: scheme.outlineVariant,
    );
    final accent = visual.color;
    final cosmeticName =
        CosmeticCatalog.byId(equippedCosmeticId)?.name ?? "Default";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(visual.icon, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Your Progress",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (cosmeticName != "Default") ...[
              const SizedBox(height: 4),
              Text(
                "Style: $cosmeticName",
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: isCompact ? 8 : 10,
              runSpacing: isCompact ? 8 : 10,
              children: [
                _KpiChip(icon: Icons.star, label: "Level", value: "$level"),
                _KpiChip(
                  icon: Icons.bolt,
                  label: "XP",
                  value: _fmtInt(totalXp),
                ),
                _KpiChip(
                  icon: Icons.monetization_on,
                  label: "Coins",
                  value: _fmtInt(coins),
                ),
                _KpiChip(
                  icon: Icons.local_fire_department,
                  label: "Streak",
                  value: "$currentStreak d",
                ),
              ],
            ),
            if (bestStreak > 0) ...[
              const SizedBox(height: 6),
              Text(
                "Best streak: $bestStreak d",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "Level progress",
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "$levelPct%",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: levelProgress,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "To next level: ${_fmtInt(toNext)} XP",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: isCompact ? double.infinity : null,
              child: FilledButton.tonalIcon(
                onPressed: onOpenPerks,
                icon: const Icon(Icons.upgrade),
                label: Text(perksLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PerksSheet extends ConsumerStatefulWidget {
  const _PerksSheet();

  @override
  ConsumerState<_PerksSheet> createState() => _PerksSheetState();
}

class _PerksSheetState extends ConsumerState<_PerksSheet> {
  final Set<String> _busyPerkIds = <String>{};

  String _bonusText(PerkDefinition perk, int level) {
    if (perk.id == PerkCatalog.momentum.id) {
      return "+${(level * 10)}% first-workout XP";
    }
    if (perk.id == PerkCatalog.specialist.id) {
      return "+${(level * 5)}% goal-movement XP";
    }
    if (perk.id == PerkCatalog.collector.id) {
      return "+${(level * 10)}% coins earned";
    }
    if (perk.id == PerkCatalog.technician.id) {
      return "+${(level * 5)}% XP on high-form logs";
    }
    if (perk.id == PerkCatalog.volumeEngine.id) {
      return "+${(level * 4)}% XP on 3+ set logs";
    }
    if (perk.id == PerkCatalog.finisher.id) {
      return "+${(level * 5)}% coins on 80+ XP logs";
    }
    if (perk.id == PerkCatalog.streakSurge.id) {
      return "+${(level * 3)}% XP at 3+ day streak";
    }
    if (perk.id == PerkCatalog.holdSpecialist.id) {
      return "+${(level * 6)}% XP on hold movements";
    }
    if (perk.id == PerkCatalog.masteryHunter.id) {
      return "+${(level * 4)}% XP on non-mastered movements";
    }
    if (perk.id == PerkCatalog.timekeeper.id) {
      return "+${(level * 5)}% coins on 90s+ sessions";
    }
    return "Level $level";
  }

  String _nextBonusText(PerkDefinition perk, int level) {
    if (level >= perk.maxLevel) return "Max level reached";
    final next = level + 1;
    if (perk.id == PerkCatalog.momentum.id) {
      return "Next: +${(next * 10)}% first-workout XP";
    }
    if (perk.id == PerkCatalog.specialist.id) {
      return "Next: +${(next * 5)}% goal-movement XP";
    }
    if (perk.id == PerkCatalog.collector.id) {
      return "Next: +${(next * 10)}% coins earned";
    }
    if (perk.id == PerkCatalog.technician.id) {
      return "Next: +${(next * 5)}% XP on high-form logs";
    }
    if (perk.id == PerkCatalog.volumeEngine.id) {
      return "Next: +${(next * 4)}% XP on 3+ set logs";
    }
    if (perk.id == PerkCatalog.finisher.id) {
      return "Next: +${(next * 5)}% coins on 80+ XP logs";
    }
    if (perk.id == PerkCatalog.streakSurge.id) {
      return "Next: +${(next * 3)}% XP at 3+ day streak";
    }
    if (perk.id == PerkCatalog.holdSpecialist.id) {
      return "Next: +${(next * 6)}% XP on hold movements";
    }
    if (perk.id == PerkCatalog.masteryHunter.id) {
      return "Next: +${(next * 4)}% XP on non-mastered movements";
    }
    if (perk.id == PerkCatalog.timekeeper.id) {
      return "Next: +${(next * 5)}% coins on 90s+ sessions";
    }
    return "Next level: $next";
  }

  Future<void> _upgrade(PerkDefinition perk) async {
    if (_busyPerkIds.contains(perk.id)) return;
    setState(() => _busyPerkIds.add(perk.id));

    try {
      final db = ref.read(appDbProvider);
      final ok = await db.tryUpgradePerk(
        perkId: perk.id,
        maxLevel: perk.maxLevel,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? "${perk.name} upgraded!"
                : "Cannot upgrade ${perk.name} right now.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyPerkIds.remove(perk.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(userStatProvider);
    final perks = ref.watch(userPerksProvider);
    final scheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 430;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: stats.when(
          data: (s) => perks.when(
            data: (rows) {
              final levelById = <String, int>{
                for (final p in rows) p.perkId: p.level,
              };

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Perks",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Spend perk points to unlock permanent bonuses.",
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _KpiChip(
                              icon: Icons.auto_awesome,
                              label: "Perk Pts",
                              value: "${s.perkPoints}",
                            ),
                            _KpiChip(
                              icon: Icons.monetization_on,
                              label: "Coins",
                              value: _fmtInt(s.coins),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...([...PerkCatalog.all]..sort((a, b) {
                          final aLevel = levelById[a.id] ?? 0;
                          final bLevel = levelById[b.id] ?? 0;
                          final aAtMax = aLevel >= a.maxLevel;
                          final bAtMax = bLevel >= b.maxLevel;
                          final aRank = aAtMax ? 2 : (s.perkPoints > 0 ? 0 : 1);
                          final bRank = bAtMax ? 2 : (s.perkPoints > 0 ? 0 : 1);
                          if (aRank != bRank) return aRank.compareTo(bRank);
                          if (aLevel != bLevel) return aLevel.compareTo(bLevel);
                          return a.name.compareTo(b.name);
                        }))
                        .map((perk) {
                          final level = levelById[perk.id] ?? 0;
                          final atMax = level >= perk.maxLevel;
                          final busy = _busyPerkIds.contains(perk.id);
                          final canUpgrade =
                              !atMax && s.perkPoints > 0 && !busy;
                          final progress = perk.maxLevel <= 0
                              ? 1.0
                              : (level / perk.maxLevel).clamp(0.0, 1.0);
                          final currentText = _bonusText(perk, level);
                          final nextText = atMax
                              ? "Max level reached"
                              : _nextBonusText(perk, level);
                          final upgradeButton = FilledButton.tonal(
                            onPressed: canUpgrade ? () => _upgrade(perk) : null,
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: const Size(0, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: busy
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(atMax ? "Maxed" : "Upgrade (1 pt)"),
                          );

                          return Card(
                            child: Padding(
                              padding: EdgeInsets.all(isCompact ? 10 : 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          perk.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: scheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: scheme.outlineVariant,
                                          ),
                                        ),
                                        child: Text(
                                          "Lv $level/${perk.maxLevel}",
                                          style: TextStyle(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    perk.description,
                                    maxLines: isCompact ? 2 : 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Current: $currentText",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  if (!atMax) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      nextText,
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: isCompact ? double.infinity : null,
                                    child: upgradeButton,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Perks error: $e"),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Stats error: $e"),
        ),
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({
    required this.items,
    required this.doneXpByMovementId,
    required this.onOpenMovement,
    required this.onDo,
  });

  final List<_PlanItemData> items;
  final Map<String, int> doneXpByMovementId;
  final void Function(String movementId) onOpenMovement;
  final Future<void> Function(_PlanItemData item) onDo;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final maxItems = isCompact ? 3 : 5;
    final visibleItems = items.take(maxItems).toList();
    final hiddenCount = max(0, items.length - visibleItems.length);
    final doneCount = items
        .where((x) => doneXpByMovementId.containsKey(x.movement.id))
        .length;
    final completion = items.isEmpty ? 0.0 : (doneCount / items.length);
    _PlanItemData? nextUp;
    for (final x in items) {
      if (!doneXpByMovementId.containsKey(x.movement.id)) {
        nextUp = x;
        break;
      }
    }
    final showHeaderProgress = !isCompact || doneCount > 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Today's Plan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                if (items.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 8 : 10,
                      vertical: isCompact ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Text(
                      "$doneCount/${items.length} done",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isCompact ? 8 : 10),

            if (items.isEmpty)
              const Text("No plan yet. Add or unlock more movements."),
            if (items.isNotEmpty && showHeaderProgress) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: completion.clamp(0.0, 1.0),
                  minHeight: isCompact ? 6 : 8,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (items.isNotEmpty) ...[
              Text(
                nextUp == null
                    ? "Plan complete. Nice work."
                    : "Next up: ${nextUp.movement.name}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isCompact ? FontWeight.w600 : FontWeight.w700,
                  fontSize: isCompact ? 13 : null,
                ),
              ),
              SizedBox(height: isCompact ? 8 : 10),
            ],

            if (items.isNotEmpty)
              Column(
                children: visibleItems.map((x) {
                  final doneXp = doneXpByMovementId[x.movement.id];
                  final isDone = doneXp != null;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isCompact ? 8 : 10),
                    child: _PlanTile(
                      item: x,
                      isDone: isDone,
                      doneXp: doneXp,
                      onOpen: () => onOpenMovement(x.movement.id),
                      onDo: () => onDo(x),
                    ),
                  );
                }).toList(),
              ),
            if (hiddenCount > 0)
              Text(
                "+$hiddenCount more in Movements",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: isCompact ? 12 : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyPlanCard extends StatelessWidget {
  const _WeeklyPlanCard({
    required this.planByDay,
    required this.onOpenMovement,
  });

  final Map<String, List<MovementWithProgress>> planByDay;
  final void Function(String movementId) onOpenMovement;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Week at a Glance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            ...planByDay.entries.map((e) {
              final items = e.value;
              final isRest = items.isEmpty;
              final previewItems = items.take(2).toList();
              final remaining = (items.length - previewItems.length).clamp(
                0,
                99,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e.key} - ${isRest ? "Rest / mobility" : "${items.length} movements"}",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (!isRest) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...previewItems.map((m) {
                            return ActionChip(
                              label: Text(m.movement.name),
                              onPressed: () => onOpenMovement(m.movement.id),
                            );
                          }),
                          if (remaining > 0)
                            Chip(label: Text("+$remaining more")),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.item,
    required this.isDone,
    required this.doneXp,
    required this.onOpen,
    required this.onDo,
  });

  final _PlanItemData item;
  final bool isDone;
  final int? doneXp;
  final VoidCallback onOpen;
  final VoidCallback onDo;

  String _nextTierState(String state) {
    switch (state) {
      case "progress":
        return "bronze";
      case "bronze":
        return "silver";
      case "silver":
        return "gold";
      case "gold":
        return "mastered";
      case "mastered":
        return "mastered";
      default:
        return "progress";
    }
  }

  String _prettyTier(String tierState) {
    if (tierState.isEmpty) return tierState;
    return tierState[0].toUpperCase() + tierState.substring(1);
  }

  double _nextTierProgress() {
    final cur = item.progress.state;
    final target = MasteryRules.nextTargetForState(
      movement: item.movement,
      state: cur,
    );

    final parts = <double>[];
    if (target.reps > 0)
      parts.add(item.progress.bestReps / max(1, target.reps));
    if (target.holdSeconds > 0)
      parts.add(item.progress.bestHoldSeconds / max(1, target.holdSeconds));
    if (target.totalXp > 0)
      parts.add(item.progress.totalXp / max(1, target.totalXp));

    if (parts.isEmpty) return 0;
    final avg = parts.reduce((a, b) => a + b) / parts.length;
    return avg.clamp(0.0, 1.0);
  }

  String _nextTierProgressLine() {
    final pct = (_nextTierProgress() * 100).round();
    final next = _prettyTier(_nextTierState(item.progress.state));
    return "To $next: $pct%";
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final tierProgress = _nextTierProgress();

    final sug = item.suggestion;
    final setText = sug.isBenchmarkAttempt ? "Test set" : "${sug.sets} sets";
    final compactMainGoal = sug.reps > 0
        ? (sug.isBenchmarkAttempt
              ? "Test ${sug.reps} reps"
              : "${sug.sets}x ${sug.reps} reps")
        : (sug.holdSeconds > 0
              ? (sug.isBenchmarkAttempt
                    ? "Test ${sug.holdSeconds}s"
                    : "${sug.sets}x ${sug.holdSeconds}s")
              : setText);
    final regularMainGoal = sug.reps > 0
        ? "$setText - ${sug.reps} reps"
        : (sug.holdSeconds > 0 ? "$setText - ${sug.holdSeconds}s" : setText);
    final lastAt = item.last?.session.startedAt;
    final lastDays = lastAt == null
        ? null
        : DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).difference(DateTime(lastAt.year, lastAt.month, lastAt.day)).inDays;
    final recencyShort = lastDays == null
        ? "New"
        : (lastDays == 0 ? "Today" : "${lastDays}d ago");
    final recencyLabel = lastDays == null
        ? "New in your routine"
        : (lastDays == 0
              ? "Already trained today"
              : "Last trained ${lastDays}d ago");
    final mainGoal = isCompact
        ? "$compactMainGoal | $recencyShort"
        : regularMainGoal;

    final actionWidget = !isDone
        ? FilledButton.tonal(
            onPressed: onDo,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size(0, isCompact ? 30 : 32),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 10 : 12,
                vertical: isCompact ? 6 : 8,
              ),
            ),
            child: const Text("Log"),
          )
        : Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 10,
              vertical: isCompact ? 5 : 6,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              doneXp == null ? "Done" : "+$doneXp XP",
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: isCompact ? 12 : null,
              ),
            ),
          );
    final statusIcon = Icon(
      isDone ? Icons.check_circle : Icons.radio_button_unchecked,
      color: isDone ? scheme.tertiary : scheme.onSurfaceVariant,
      size: 22,
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 9 : 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: isCompact ? 8 : 10),
                  child: statusIcon,
                ),
                Expanded(
                  child: InkWell(
                    onTap: onOpen,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isCompact ? 2 : 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.movement.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: isCompact ? 15 : null,
                            ),
                          ),
                          SizedBox(height: isCompact ? 1 : 2),
                          if (sug.isBenchmarkAttempt && !isCompact) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                "Benchmark attempt",
                                style: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            mainGoal,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: isCompact ? 13 : null,
                            ),
                          ),
                          if (!isCompact) ...[
                            const SizedBox(height: 2),
                            Text(
                              recencyLabel,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                actionWidget,
              ],
            ),

            if (!isDone && (!isCompact || tierProgress > 0.25)) ...[
              SizedBox(height: isCompact ? 4 : 5),
              LinearProgressIndicator(
                value: tierProgress,
                minHeight: isCompact ? 4 : 7,
                borderRadius: BorderRadius.circular(999),
              ),
              if (!isCompact) ...[
                const SizedBox(height: 6),
                Text(
                  _nextTierProgressLine(),
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _NextGoalCard extends StatelessWidget {
  const _NextGoalCard({
    required this.title,
    required this.isPinned,
    required this.candidate,
    required this.onOpenTarget,
    required this.onClearPinnedGoal,
  });

  final String title;
  final bool isPinned;
  final _UnlockCandidate? candidate;
  final VoidCallback? onOpenTarget;
  final Future<void> Function()? onClearPinnedGoal;

  String _prettyState(String state) {
    if (state.isEmpty) return state;
    return state[0].toUpperCase() + state.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final c = candidate;

    if (c == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text("Everything is unlocked."),
            ],
          ),
        ),
      );
    }

    final x = c.target;
    final missing = c.missingPrereqs;
    final xpMissing = c.xpMissing;
    final state = x.progress.state;

    final subtitle = state == "locked"
        ? (missing.isEmpty
              ? (xpMissing > 0 ? "Need $xpMissing XP" : "Ready to unlock")
              : "${missing.length} prereq${missing.length == 1 ? "" : "s"} pending")
        : state == "mastered"
        ? "Mastered"
        : "Tier: ${_prettyState(state)}";

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                if (isPinned && onClearPinnedGoal != null)
                  IconButton(
                    tooltip: "Clear goal focus",
                    onPressed: () async => onClearPinnedGoal!(),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            if (isPinned)
              Text(
                "Pinned goal",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 430;
                final info = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      x.movement.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flag),
                          const SizedBox(width: 10),
                          Expanded(child: info),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: onOpenTarget,
                          child: const Text("Open"),
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Icon(Icons.flag),
                    const SizedBox(width: 10),
                    Expanded(child: info),
                    FilledButton.tonal(
                      onPressed: onOpenTarget,
                      child: const Text("Open"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({
    required this.items,
    required this.canQuickLog,
    required this.onQuickLog,
  });

  final List<SessionWithMovement> items;
  final bool Function(String movementId) canQuickLog;
  final Future<void> Function(String movementId) onQuickLog;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final maxItems = isCompact ? 2 : 5;
    final visibleItems = items.take(maxItems).toList();
    final hiddenCount = max(0, items.length - visibleItems.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recent Sessions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            if (items.isEmpty)
              const Text(
                "No sessions yet. Log your first one from Movements or the Tree.",
              ),

            if (items.isNotEmpty)
              Column(
                children: visibleItems.map((x) {
                  final can = canQuickLog(x.movement.id);
                  final s = x.session;

                  final setLabel = (s.sets <= 1) ? "" : "${s.sets}x ";
                  final repLabel = (s.reps > 0)
                      ? "${setLabel}${s.reps} reps"
                      : "";
                  final holdLabel = (s.holdSeconds > 0)
                      ? "${setLabel}${s.holdSeconds}s"
                      : "";
                  final summary = [
                    repLabel,
                    holdLabel,
                    "+${s.xpEarned} XP",
                  ].where((t) => t.isNotEmpty).join(" - ");

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: isCompact,
                    visualDensity: isCompact
                        ? const VisualDensity(vertical: -2)
                        : VisualDensity.standard,
                    title: Text(x.movement.name),
                    subtitle: Text(summary),
                    trailing: IconButton(
                      tooltip: "Log again",
                      onPressed: can
                          ? () async {
                              await onQuickLog(x.movement.id);
                            }
                          : null,
                      icon: const Icon(Icons.add),
                    ),
                  );
                }).toList(),
              ),
            if (hiddenCount > 0)
              Text(
                "+$hiddenCount more in History",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgesSummaryCard extends StatelessWidget {
  const _BadgesSummaryCard({required this.earned, required this.total});

  final int earned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((earned / total) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.emoji_events),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Badges",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$earned/$total ($pct%)",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.title, required this.error});

  final String title;
  final String error;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(error),
          ],
        ),
      ),
    );
  }
}

class _UnlockCandidate {
  _UnlockCandidate({
    required this.target,
    required this.xpMissing,
    required this.missingPrereqs,
  });

  final MovementWithProgress target;
  final int xpMissing;
  final List<_MissingPrereq> missingPrereqs;
}

class _MissingPrereq {
  _MissingPrereq({
    required this.movementId,
    required this.name,
    required this.prereqType,
    required this.currentState,
  });

  final String movementId;
  final String name;
  final String prereqType;
  final String currentState;
}

class _PlanSuggestion {
  const _PlanSuggestion({
    required this.sets,
    required this.reps,
    required this.holdSeconds,
    required this.durationSeconds,
    required this.formScore,
    required this.isBenchmarkAttempt,
  });

  final int sets;
  final int reps;
  final int holdSeconds;
  final int durationSeconds;
  final int formScore;
  final bool isBenchmarkAttempt;
}

class _PlanItemData {
  const _PlanItemData({
    required this.movement,
    required this.progress,
    required this.last,
    required this.suggestion,
  });

  final Movement movement;
  final MovementProgress progress;
  final SessionWithMovement? last;
  final _PlanSuggestion suggestion;
}

String _fmtInt(int n) {
  final s = n.toString();
  return s.replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]},");
}
