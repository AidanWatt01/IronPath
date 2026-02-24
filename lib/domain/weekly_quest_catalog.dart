import "dart:math";

import "daily_quest_catalog.dart";

class WeeklyQuestDefinition {
  const WeeklyQuestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.rewardXp,
    required this.rewardCoins,
    required this.rarity,
  });

  final String id;
  final String title;
  final String description;
  final DailyQuestMetric metric;
  final int target;
  final int rewardXp;
  final int rewardCoins;
  final DailyQuestRarity rarity;

  bool get requiresGoal => metric == DailyQuestMetric.goalMovementSessions;
}

class WeeklyQuestCatalog {
  static const all = <WeeklyQuestDefinition>[
    WeeklyQuestDefinition(
      id: "weekly_workout_5",
      title: "Weekly Foundation",
      description: "Complete 5 workouts this week.",
      metric: DailyQuestMetric.workoutsCount,
      target: 5,
      rewardXp: 420,
      rewardCoins: 150,
      rarity: DailyQuestRarity.common,
    ),
    WeeklyQuestDefinition(
      id: "weekly_xp_1800",
      title: "Weekly XP Builder",
      description: "Earn 1800 workout XP this week.",
      metric: DailyQuestMetric.workoutXp,
      target: 1800,
      rewardXp: 460,
      rewardCoins: 160,
      rarity: DailyQuestRarity.common,
    ),
    WeeklyQuestDefinition(
      id: "weekly_sets_70",
      title: "Weekly Volume",
      description: "Log 70 total sets this week.",
      metric: DailyQuestMetric.totalSets,
      target: 70,
      rewardXp: 440,
      rewardCoins: 155,
      rarity: DailyQuestRarity.common,
    ),
    WeeklyQuestDefinition(
      id: "weekly_time_7200",
      title: "Weekly Hours",
      description: "Log 2 hours of training this week.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 7200,
      rewardXp: 430,
      rewardCoins: 152,
      rarity: DailyQuestRarity.common,
    ),
    WeeklyQuestDefinition(
      id: "weekly_goal_4",
      title: "Goal Lock-In",
      description: "Log your focused goal movement 4 times this week.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 4,
      rewardXp: 450,
      rewardCoins: 158,
      rarity: DailyQuestRarity.common,
    ),
    WeeklyQuestDefinition(
      id: "weekly_workout_8",
      title: "Relentless Week",
      description: "Complete 8 workouts this week.",
      metric: DailyQuestMetric.workoutsCount,
      target: 8,
      rewardXp: 760,
      rewardCoins: 280,
      rarity: DailyQuestRarity.rare,
    ),
    WeeklyQuestDefinition(
      id: "weekly_xp_3000",
      title: "Weekly XP Push",
      description: "Earn 3000 workout XP this week.",
      metric: DailyQuestMetric.workoutXp,
      target: 3000,
      rewardXp: 810,
      rewardCoins: 300,
      rarity: DailyQuestRarity.rare,
    ),
    WeeklyQuestDefinition(
      id: "weekly_sets_120",
      title: "Volume Marathon",
      description: "Log 120 total sets this week.",
      metric: DailyQuestMetric.totalSets,
      target: 120,
      rewardXp: 790,
      rewardCoins: 292,
      rarity: DailyQuestRarity.rare,
    ),
    WeeklyQuestDefinition(
      id: "weekly_time_12600",
      title: "Time Commitment",
      description: "Log 3.5 hours of training this week.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 12600,
      rewardXp: 770,
      rewardCoins: 288,
      rarity: DailyQuestRarity.rare,
    ),
    WeeklyQuestDefinition(
      id: "weekly_goal_8",
      title: "Focused Progression",
      description: "Log your focused goal movement 8 times this week.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 8,
      rewardXp: 805,
      rewardCoins: 298,
      rarity: DailyQuestRarity.rare,
    ),
    WeeklyQuestDefinition(
      id: "weekly_workout_12",
      title: "No Days Wasted",
      description: "Complete 12 workouts this week.",
      metric: DailyQuestMetric.workoutsCount,
      target: 12,
      rewardXp: 1300,
      rewardCoins: 500,
      rarity: DailyQuestRarity.epic,
    ),
    WeeklyQuestDefinition(
      id: "weekly_xp_5000",
      title: "Elite XP Week",
      description: "Earn 5000 workout XP this week.",
      metric: DailyQuestMetric.workoutXp,
      target: 5000,
      rewardXp: 1380,
      rewardCoins: 525,
      rarity: DailyQuestRarity.epic,
    ),
    WeeklyQuestDefinition(
      id: "weekly_sets_180",
      title: "Volume Titan",
      description: "Log 180 total sets this week.",
      metric: DailyQuestMetric.totalSets,
      target: 180,
      rewardXp: 1350,
      rewardCoins: 515,
      rarity: DailyQuestRarity.epic,
    ),
    WeeklyQuestDefinition(
      id: "weekly_time_18000",
      title: "Engine Room",
      description: "Log 5 hours of training this week.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 18000,
      rewardXp: 1330,
      rewardCoins: 508,
      rarity: DailyQuestRarity.epic,
    ),
    WeeklyQuestDefinition(
      id: "weekly_goal_12",
      title: "Mastery Campaign",
      description: "Log your focused goal movement 12 times this week.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 12,
      rewardXp: 1365,
      rewardCoins: 520,
      rarity: DailyQuestRarity.epic,
    ),
  ];

  static WeeklyQuestDefinition? byId(String id) {
    for (final quest in all) {
      if (quest.id == id) {
        return quest;
      }
    }
    return null;
  }

  static List<WeeklyQuestDefinition> rotationForWeek({
    required DateTime weekStart,
    required bool hasGoal,
    required int level,
    int rotationOffset = 0,
  }) {
    final pool = all.where((q) => hasGoal || !q.requiresGoal).toList();
    if (pool.length <= 3) return pool;

    final seed =
        (weekStart.year * 1000000) +
        (weekStart.month * 10000) +
        (weekStart.day * 100) +
        7 +
        (rotationOffset * 9973);
    final random = Random(seed);

    List<WeeklyQuestDefinition> byRarity(DailyQuestRarity rarity) {
      return pool.where((q) => q.rarity == rarity).toList();
    }

    WeeklyQuestDefinition pickOne(
      List<WeeklyQuestDefinition> source,
      Set<String> taken,
    ) {
      final candidates = source.where((q) => !taken.contains(q.id)).toList();
      if (candidates.isEmpty) {
        final fallback = pool.where((q) => !taken.contains(q.id)).toList();
        return fallback[random.nextInt(fallback.length)];
      }
      return candidates[random.nextInt(candidates.length)];
    }

    int epicChancePercent() {
      if (level < 15) return 0;
      if (level < 30) return 15;
      if (level < 45) return 35;
      return 55;
    }

    final common = byRarity(DailyQuestRarity.common);
    final rare = byRarity(DailyQuestRarity.rare);
    final epic = byRarity(DailyQuestRarity.epic);

    final result = <WeeklyQuestDefinition>[];
    final taken = <String>{};

    final first = pickOne(common, taken);
    result.add(first);
    taken.add(first.id);

    final secondPool = level >= 8 && rare.isNotEmpty ? rare : common;
    final second = pickOne(secondPool, taken);
    result.add(second);
    taken.add(second.id);

    final includeEpic = random.nextInt(100) < epicChancePercent();
    final thirdPool = includeEpic && epic.isNotEmpty ? epic : (rare + common);
    final third = pickOne(thirdPool, taken);
    result.add(third);

    return result;
  }
}
