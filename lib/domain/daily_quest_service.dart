import "dart:async";

import "../data/db/app_db.dart";
import "daily_quest_catalog.dart";
import "unlock_service.dart";

class DailyQuestProgress {
  const DailyQuestProgress({
    required this.quest,
    required this.progress,
    required this.target,
    required this.rewardXp,
    required this.rewardCoins,
    required this.claimed,
    required this.isAvailable,
    required this.statusText,
  });

  final DailyQuestDefinition quest;
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

class DailyQuestService {
  DailyQuestService(this.db, {DateTime Function()? nowProvider})
    : _nowProvider = nowProvider ?? DateTime.now;

  final AppDb db;
  final DateTime Function() _nowProvider;

  DateTime _today() {
    final now = _nowProvider();
    return DateTime(now.year, now.month, now.day);
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

  int _sessionLikeTarget(DailyQuestDefinition quest, int level) {
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
        if (level >= 15) extra += 1;
        if (level >= 30) extra += 1;
        break;
    }

    return quest.target + extra;
  }

  int _scaledTarget(DailyQuestDefinition quest, int level) {
    if (quest.metric == DailyQuestMetric.workoutsCount ||
        quest.metric == DailyQuestMetric.goalMovementSessions) {
      return _sessionLikeTarget(quest, level);
    }

    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 35,
      DailyQuestRarity.rare => 45,
      DailyQuestRarity.epic => 55,
    };

    return _scaleByPercent(
      base: quest.target,
      level: level,
      perLevels: 2,
      maxPercent: maxPercent,
    );
  }

  int _scaledRewardXp(DailyQuestDefinition quest, int level) {
    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 40,
      DailyQuestRarity.rare => 55,
      DailyQuestRarity.epic => 70,
    };

    return _scaleByPercent(
      base: quest.rewardXp,
      level: level,
      perLevels: 3,
      maxPercent: maxPercent,
    );
  }

  int _scaledRewardCoins(DailyQuestDefinition quest, int level) {
    final maxPercent = switch (quest.rarity) {
      DailyQuestRarity.common => 38,
      DailyQuestRarity.rare => 52,
      DailyQuestRarity.epic => 65,
    };

    return _scaleByPercent(
      base: quest.rewardCoins,
      level: level,
      perLevels: 3,
      maxPercent: maxPercent,
    );
  }

  String _statusText({
    required DailyQuestDefinition quest,
    required int target,
    required bool available,
  }) {
    if (!available) {
      return "Set a Focus Goal in the Skill Tree to enable this quest.";
    }

    switch (quest.metric) {
      case DailyQuestMetric.workoutsCount:
        return "Complete $target workout${target == 1 ? "" : "s"} today.";
      case DailyQuestMetric.workoutXp:
        return "Earn $target workout XP today.";
      case DailyQuestMetric.goalMovementSessions:
        return "Log your focused goal movement $target time${target == 1 ? "" : "s"} today.";
      case DailyQuestMetric.totalSets:
        return "Log $target total sets today.";
      case DailyQuestMetric.trainingSeconds:
        final mins = (target / 60).round();
        return "Log $mins minutes of training today.";
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

  Stream<List<DailyQuestProgress>> watchTodayQuests({
    required String? goalMovementId,
  }) {
    final day = _today();

    return Stream<List<DailyQuestProgress>>.multi((controller) {
      int level = 1;
      int workoutCount = 0;
      int sessionXp = 0;
      int goalSessions = 0;
      int totalSets = 0;
      int trainingSeconds = 0;
      Set<String> claimedIds = <String>{};

      void emit() {
        if (controller.isClosed) return;

        final hasGoal = goalMovementId != null && goalMovementId.isNotEmpty;
        final quests = DailyQuestCatalog.rotationForDate(
          day: day,
          hasGoal: hasGoal,
          level: level,
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

          return DailyQuestProgress(
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
        db.watchUserStat().listen((stats) {
          level = stats.level;
          emit();
        }),
      );

      subs.add(
        db.watchWorkoutsCountOnDay(day: day).listen((count) {
          workoutCount = count;
          emit();
        }),
      );

      subs.add(
        db.watchSessionXpSumOnDay(day: day).listen((xp) {
          sessionXp = xp;
          emit();
        }),
      );

      subs.add(
        db.watchSessionSetSumOnDay(day: day).listen((sets) {
          totalSets = sets;
          emit();
        }),
      );

      subs.add(
        db.watchSessionDurationSumOnDay(day: day).listen((duration) {
          trainingSeconds = duration;
          emit();
        }),
      );

      if (goalMovementId != null && goalMovementId.isNotEmpty) {
        subs.add(
          db
              .watchSessionsCountForMovementOnDay(
                day: day,
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
        db.watchDailyQuestClaimsForDate(day).listen((rows) {
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

  Future<DailyQuestClaimResult> claimTodayQuest({
    required String questId,
    required String? goalMovementId,
  }) async {
    final day = _today();
    final quest = DailyQuestCatalog.byId(questId);

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
    final active = DailyQuestCatalog.rotationForDate(
      day: day,
      hasGoal: hasGoal,
      level: stats.level,
    );
    final isActiveToday = active.any((q) => q.id == quest.id);
    if (!isActiveToday) {
      return DailyQuestClaimResult.failed(
        questId: quest.id,
        reason: "Quest is not active today.",
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
      progress = await db.countSessionsForMovementOnDay(
        day: day,
        movementId: goalId,
      );
    } else {
      switch (quest.metric) {
        case DailyQuestMetric.workoutsCount:
          progress = await db.countWorkoutsOnDay(day: day);
          break;
        case DailyQuestMetric.workoutXp:
          progress = await db.sumSessionXpOnDay(day: day);
          break;
        case DailyQuestMetric.totalSets:
          progress = await db.sumSessionSetsOnDay(day: day);
          break;
        case DailyQuestMetric.trainingSeconds:
          progress = await db.sumSessionDurationOnDay(day: day);
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

    final result = await db.tryClaimDailyQuest(
      questId: quest.id,
      day: day,
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
    );

    if (result.claimed) {
      await UnlockService(db).recomputeAndApply(now: _nowProvider());
    }

    return result;
  }
}
