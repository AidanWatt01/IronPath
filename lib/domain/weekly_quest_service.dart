import "dart:async";

import "package:drift/drift.dart";

import "../data/db/app_db.dart";
import "daily_quest_catalog.dart";
import "weekly_quest_catalog.dart";
import "unlock_service.dart";

class WeeklyQuestProgress {
  const WeeklyQuestProgress({
    required this.quest,
    required this.progress,
    required this.target,
    required this.rewardXp,
    required this.rewardCoins,
    required this.claimed,
    required this.isAvailable,
    required this.statusText,
  });

  final WeeklyQuestDefinition quest;
  final int progress;
  final int target;
  final int rewardXp;
  final int rewardCoins;
  final bool claimed;
  final bool isAvailable;
  final String statusText;

  bool get isComplete => progress >= target;
  bool get canClaim => isAvailable && isComplete && !claimed;
}

class WeeklyRerollInfo {
  const WeeklyRerollInfo({
    required this.rerollsUsed,
    required this.rotationOffset,
    required this.freeRerollAvailable,
    required this.nextCoinCost,
  });

  final int rerollsUsed;
  final int rotationOffset;
  final bool freeRerollAvailable;
  final int nextCoinCost;
}

class WeeklyRerollResult {
  const WeeklyRerollResult({
    required this.success,
    required this.message,
    required this.info,
  });

  final bool success;
  final String message;
  final WeeklyRerollInfo info;
}

class WeeklyQuestService {
  WeeklyQuestService(this.db, {DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  final AppDb db;
  final DateTime Function() _nowProvider;

  static const int _baseRerollCoinCost = 100;
  static const int _rerollStepCoinCost = 50;

  DateTime _weekStart(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  DateTime _weekEnd(DateTime weekStart) {
    return weekStart.add(const Duration(days: 7));
  }

  String _weekKey(DateTime weekStart) {
    final y = weekStart.year.toString().padLeft(4, "0");
    final m = weekStart.month.toString().padLeft(2, "0");
    final d = weekStart.day.toString().padLeft(2, "0");
    return "week:$y-$m-$d";
  }

  String _rotationOffsetMetaKey(String weekKey) =>
      "weekly_rotation_offset_$weekKey";

  String _rerollCountMetaKey(String weekKey) => "weekly_reroll_count_$weekKey";

  int _parseIntOrZero(String? raw) => int.tryParse(raw ?? "") ?? 0;

  int _nextRerollCostFromCount(int rerollsUsed) {
    if (rerollsUsed <= 0) return 0;
    final paidRerolls = rerollsUsed;
    return _baseRerollCoinCost + ((paidRerolls - 1) * _rerollStepCoinCost);
  }

  Future<int> _rotationOffsetForWeek(String weekKey) async {
    final raw = await db.getAppMetaValue(_rotationOffsetMetaKey(weekKey));
    return _parseIntOrZero(raw).clamp(0, 9999);
  }

  Future<int> _rerollCountForWeek(String weekKey) async {
    final raw = await db.getAppMetaValue(_rerollCountMetaKey(weekKey));
    return _parseIntOrZero(raw).clamp(0, 9999);
  }

  Future<WeeklyRerollInfo> getRerollInfo() async {
    final weekKey = _weekKey(_weekStart(_nowProvider()));
    final rerollsUsed = await _rerollCountForWeek(weekKey);
    final rotationOffset = await _rotationOffsetForWeek(weekKey);
    final free = rerollsUsed == 0;

    return WeeklyRerollInfo(
      rerollsUsed: rerollsUsed,
      rotationOffset: rotationOffset,
      freeRerollAvailable: free,
      nextCoinCost: free ? 0 : _nextRerollCostFromCount(rerollsUsed),
    );
  }

  Future<WeeklyRerollResult> rerollThisWeek() async {
    final weekKey = _weekKey(_weekStart(_nowProvider()));

    return db.transaction(() async {
      final rerollsUsed = await _rerollCountForWeek(weekKey);
      final rotationOffset = await _rotationOffsetForWeek(weekKey);

      final free = rerollsUsed == 0;
      final cost = free ? 0 : _nextRerollCostFromCount(rerollsUsed);

      final stats = await (db.select(
        db.userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      if (cost > 0 && stats.coins < cost) {
        final info = WeeklyRerollInfo(
          rerollsUsed: rerollsUsed,
          rotationOffset: rotationOffset,
          freeRerollAvailable: free,
          nextCoinCost: cost,
        );
        return WeeklyRerollResult(
          success: false,
          message: "Need $cost coins for the next reroll.",
          info: info,
        );
      }

      if (cost > 0) {
        await (db.update(db.userStats)..where((s) => s.id.equals(1))).write(
          UserStatsCompanion(coins: Value(stats.coins - cost)),
        );
      }

      final newRerollsUsed = rerollsUsed + 1;
      final newOffset = rotationOffset + 1;

      await db.setAppMetaValue(
        key: _rerollCountMetaKey(weekKey),
        value: "$newRerollsUsed",
      );
      await db.setAppMetaValue(
        key: _rotationOffsetMetaKey(weekKey),
        value: "$newOffset",
      );

      final nextFree = false;
      final nextCost = _nextRerollCostFromCount(newRerollsUsed);

      final info = WeeklyRerollInfo(
        rerollsUsed: newRerollsUsed,
        rotationOffset: newOffset,
        freeRerollAvailable: nextFree,
        nextCoinCost: nextCost,
      );

      return WeeklyRerollResult(
        success: true,
        message: cost == 0
            ? "Weekly quests rerolled (free)."
            : "Weekly quests rerolled for $cost coins.",
        info: info,
      );
    });
  }

  int _scaleByPercent({
    required int base,
    required int level,
    required int perLevels,
    required int maxPercent,
  }) {
    final percent = ((level - 1) ~/ perLevels).clamp(0, maxPercent);
    return ((base * (100 + percent)) / 100).round();
  }

  int _sessionLikeTarget(WeeklyQuestDefinition quest, int level) {
    if (quest.metric != DailyQuestMetric.workoutsCount &&
        quest.metric != DailyQuestMetric.goalMovementSessions) {
      return quest.target;
    }

    int extra = 0;
    switch (quest.rarity) {
      case DailyQuestRarity.common:
        if (level >= 25) extra += 1;
        if (level >= 45) extra += 1;
        break;
      case DailyQuestRarity.rare:
        if (level >= 20) extra += 1;
        if (level >= 35) extra += 1;
        break;
      case DailyQuestRarity.epic:
        if (level >= 18) extra += 1;
        if (level >= 30) extra += 1;
        if (level >= 45) extra += 1;
        break;
    }

    return quest.target + extra;
  }

  int _scaledTarget(WeeklyQuestDefinition quest, int level) {
    if (quest.metric == DailyQuestMetric.workoutsCount ||
        quest.metric == DailyQuestMetric.goalMovementSessions) {
      return _sessionLikeTarget(quest, level);
    }

    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 30,
      DailyQuestRarity.rare => 38,
      DailyQuestRarity.epic => 48,
    };

    return _scaleByPercent(
      base: quest.target,
      level: level,
      perLevels: 3,
      maxPercent: maxPercent,
    );
  }

  int _scaledRewardXp(WeeklyQuestDefinition quest, int level) {
    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 35,
      DailyQuestRarity.rare => 45,
      DailyQuestRarity.epic => 55,
    };

    return _scaleByPercent(
      base: quest.rewardXp,
      level: level,
      perLevels: 4,
      maxPercent: maxPercent,
    );
  }

  int _scaledRewardCoins(WeeklyQuestDefinition quest, int level) {
    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 32,
      DailyQuestRarity.rare => 42,
      DailyQuestRarity.epic => 52,
    };

    return _scaleByPercent(
      base: quest.rewardCoins,
      level: level,
      perLevels: 4,
      maxPercent: maxPercent,
    );
  }

  String _statusText({
    required WeeklyQuestDefinition quest,
    required int target,
    required bool available,
  }) {
    if (!available) {
      return "Set a Focus Goal in the Skill Tree to enable this quest.";
    }

    switch (quest.metric) {
      case DailyQuestMetric.workoutsCount:
        return "Complete $target workout${target == 1 ? "" : "s"} this week.";
      case DailyQuestMetric.workoutXp:
        return "Earn $target workout XP this week.";
      case DailyQuestMetric.goalMovementSessions:
        return "Log your focused goal movement $target time${target == 1 ? "" : "s"} this week.";
      case DailyQuestMetric.totalSets:
        return "Log $target total sets this week.";
      case DailyQuestMetric.trainingSeconds:
        final mins = (target / 60).round();
        return "Log $mins minutes of training this week.";
    }
  }

  int _metricProgress({
    required DailyQuestMetric metric,
    required int workoutCount,
    required int sessionXp,
    required int goalSessions,
    required int totalSets,
    required int trainingSeconds,
  }) {
    switch (metric) {
      case DailyQuestMetric.workoutsCount:
        return workoutCount;
      case DailyQuestMetric.workoutXp:
        return sessionXp;
      case DailyQuestMetric.goalMovementSessions:
        return goalSessions;
      case DailyQuestMetric.totalSets:
        return totalSets;
      case DailyQuestMetric.trainingSeconds:
        return trainingSeconds;
    }
  }

  Stream<List<WeeklyQuestProgress>> watchThisWeekQuests({
    required String? goalMovementId,
  }) {
    final now = _nowProvider();
    final start = _weekStart(now);
    final end = _weekEnd(start);
    final key = _weekKey(start);

    return Stream<List<WeeklyQuestProgress>>.multi((controller) {
      int level = 1;
      int rotationOffset = 0;
      int workoutCount = 0;
      int sessionXp = 0;
      int goalSessions = 0;
      int totalSets = 0;
      int trainingSeconds = 0;
      Set<String> claimedIds = <String>{};

      void emit() {
        if (controller.isClosed) return;

        final hasGoal = goalMovementId != null && goalMovementId.isNotEmpty;
        final quests = WeeklyQuestCatalog.rotationForWeek(
          weekStart: start,
          hasGoal: hasGoal,
          level: level,
          rotationOffset: rotationOffset,
        );

        final items = quests.map((quest) {
          final available = !quest.requiresGoal || hasGoal;
          final target = _scaledTarget(quest, level);
          final progress = available
              ? _metricProgress(
                  metric: quest.metric,
                  workoutCount: workoutCount,
                  sessionXp: sessionXp,
                  goalSessions: goalSessions,
                  totalSets: totalSets,
                  trainingSeconds: trainingSeconds,
                )
              : 0;

          return WeeklyQuestProgress(
            quest: quest,
            progress: progress,
            target: target,
            rewardXp: _scaledRewardXp(quest, level),
            rewardCoins: _scaledRewardCoins(quest, level),
            claimed: claimedIds.contains(quest.id),
            isAvailable: available,
            statusText: _statusText(
              quest: quest,
              target: target,
              available: available,
            ),
          );
        }).toList();

        controller.add(items);
      }

      final subs = <StreamSubscription<dynamic>>[];

      subs.add(
        Stream.fromFuture(_rotationOffsetForWeek(key)).listen((offset) {
          rotationOffset = offset;
          emit();
        }),
      );

      subs.add(
        db.watchUserStat().listen((stats) {
          level = stats.level;
          emit();
        }),
      );

      subs.add(
        db.watchWorkoutsCountInRange(start: start, end: end).listen((count) {
          workoutCount = count;
          emit();
        }),
      );

      subs.add(
        db.watchSessionXpSumInRange(start: start, end: end).listen((xp) {
          sessionXp = xp;
          emit();
        }),
      );

      subs.add(
        db.watchSessionSetSumInRange(start: start, end: end).listen((sets) {
          totalSets = sets;
          emit();
        }),
      );

      subs.add(
        db.watchSessionDurationSumInRange(start: start, end: end).listen((
          duration,
        ) {
          trainingSeconds = duration;
          emit();
        }),
      );

      if (goalMovementId != null && goalMovementId.isNotEmpty) {
        subs.add(
          db
              .watchSessionsCountForMovementInRange(
                start: start,
                end: end,
                movementId: goalMovementId,
              )
              .listen((count) {
                goalSessions = count;
                emit();
              }),
        );
      } else {
        goalSessions = 0;
      }

      subs.add(
        db.watchQuestClaimsForKey(key).listen((rows) {
          claimedIds = {for (final row in rows) row.questId};
          emit();
        }),
      );

      controller.onCancel = () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      };
    });
  }

  Future<DailyQuestClaimResult> claimThisWeekQuest({
    required String questId,
    required String? goalMovementId,
  }) async {
    final now = _nowProvider();
    final start = _weekStart(now);
    final end = _weekEnd(start);
    final key = _weekKey(start);

    final quest = WeeklyQuestCatalog.byId(questId);
    if (quest == null) {
      return DailyQuestClaimResult.failed(
        questId: questId,
        reason: "Unknown quest.",
      );
    }

    final stats = await (db.select(
      db.userStats,
    )..where((s) => s.id.equals(1))).getSingle();
    final hasGoal = goalMovementId != null && goalMovementId.trim().isNotEmpty;
    final rotationOffset = await _rotationOffsetForWeek(key);

    final active = WeeklyQuestCatalog.rotationForWeek(
      weekStart: start,
      hasGoal: hasGoal,
      level: stats.level,
      rotationOffset: rotationOffset,
    );
    final isActiveThisWeek = active.any((q) => q.id == quest.id);
    if (!isActiveThisWeek) {
      return DailyQuestClaimResult.failed(
        questId: quest.id,
        reason: "Quest is not active this week.",
      );
    }

    final target = _scaledTarget(quest, stats.level);
    final rewardXp = _scaledRewardXp(quest, stats.level);
    final rewardCoins = _scaledRewardCoins(quest, stats.level);

    int progress;
    if (quest.metric == DailyQuestMetric.goalMovementSessions) {
      final goalId = goalMovementId?.trim();
      if (goalId == null || goalId.isEmpty) {
        return DailyQuestClaimResult.failed(
          questId: quest.id,
          reason: "Set a Focus Goal first.",
        );
      }
      progress = await db.countSessionsForMovementInRange(
        start: start,
        end: end,
        movementId: goalId,
      );
    } else {
      switch (quest.metric) {
        case DailyQuestMetric.workoutsCount:
          progress = await db.countWorkoutsInRange(start: start, end: end);
          break;
        case DailyQuestMetric.workoutXp:
          progress = await db.sumSessionXpInRange(start: start, end: end);
          break;
        case DailyQuestMetric.totalSets:
          progress = await db.sumSessionSetsInRange(start: start, end: end);
          break;
        case DailyQuestMetric.trainingSeconds:
          progress = await db.sumSessionDurationInRange(start: start, end: end);
          break;
        case DailyQuestMetric.goalMovementSessions:
          progress = 0;
          break;
      }
    }

    if (progress < target) {
      return DailyQuestClaimResult.failed(
        questId: quest.id,
        reason: "Quest not complete yet ($progress/$target).",
      );
    }

    final result = await db.tryClaimQuestReward(
      questId: quest.id,
      claimKey: key,
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
      alreadyClaimedReason: "Already claimed this week.",
    );

    if (result.claimed) {
      await UnlockService(db).recomputeAndApply(now: _nowProvider());
    }

    return result;
  }
}
