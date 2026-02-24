import "dart:math";

enum DailyQuestMetric {
  workoutsCount,
  workoutXp,
  goalMovementSessions,
  totalSets,
  trainingSeconds,
}

enum DailyQuestRarity { common, rare, epic }

class DailyQuestDefinition {
  const DailyQuestDefinition({
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

class DailyQuestCatalog {
  static const all = <DailyQuestDefinition>[
    // Common
    DailyQuestDefinition(
      id: "daily_workout_1",
      title: "Warm Up",
      description: "Complete 1 workout today.",
      metric: DailyQuestMetric.workoutsCount,
      target: 1,
      rewardXp: 80,
      rewardCoins: 35,
      rarity: DailyQuestRarity.common,
    ),
    DailyQuestDefinition(
      id: "daily_xp_250",
      title: "XP Grind",
      description: "Earn 250 workout XP today.",
      metric: DailyQuestMetric.workoutXp,
      target: 250,
      rewardXp: 110,
      rewardCoins: 40,
      rarity: DailyQuestRarity.common,
    ),
    DailyQuestDefinition(
      id: "daily_sets_12",
      title: "Volume Starter",
      description: "Log 12 total sets today.",
      metric: DailyQuestMetric.totalSets,
      target: 12,
      rewardXp: 100,
      rewardCoins: 40,
      rarity: DailyQuestRarity.common,
    ),
    DailyQuestDefinition(
      id: "daily_time_900",
      title: "Time Under Tension",
      description: "Log 15 minutes of training today.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 900,
      rewardXp: 95,
      rewardCoins: 38,
      rarity: DailyQuestRarity.common,
    ),
    DailyQuestDefinition(
      id: "daily_goal_1",
      title: "Focused Work",
      description: "Log your focused goal movement once today.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 1,
      rewardXp: 95,
      rewardCoins: 38,
      rarity: DailyQuestRarity.common,
    ),

    // Rare
    DailyQuestDefinition(
      id: "daily_workout_2",
      title: "Double Session",
      description: "Complete 2 workouts today.",
      metric: DailyQuestMetric.workoutsCount,
      target: 2,
      rewardXp: 170,
      rewardCoins: 65,
      rarity: DailyQuestRarity.rare,
    ),
    DailyQuestDefinition(
      id: "daily_xp_500",
      title: "Heavy XP Day",
      description: "Earn 500 workout XP today.",
      metric: DailyQuestMetric.workoutXp,
      target: 500,
      rewardXp: 190,
      rewardCoins: 72,
      rarity: DailyQuestRarity.rare,
    ),
    DailyQuestDefinition(
      id: "daily_sets_24",
      title: "Volume Builder",
      description: "Log 24 total sets today.",
      metric: DailyQuestMetric.totalSets,
      target: 24,
      rewardXp: 180,
      rewardCoins: 68,
      rarity: DailyQuestRarity.rare,
    ),
    DailyQuestDefinition(
      id: "daily_time_1800",
      title: "Long Session",
      description: "Log 30 minutes of training today.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 1800,
      rewardXp: 175,
      rewardCoins: 65,
      rarity: DailyQuestRarity.rare,
    ),
    DailyQuestDefinition(
      id: "daily_goal_2",
      title: "Locked In",
      description: "Log your focused goal movement twice today.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 2,
      rewardXp: 185,
      rewardCoins: 70,
      rarity: DailyQuestRarity.rare,
    ),

    // Epic
    DailyQuestDefinition(
      id: "daily_workout_3",
      title: "Triple Threat",
      description: "Complete 3 workouts today.",
      metric: DailyQuestMetric.workoutsCount,
      target: 3,
      rewardXp: 300,
      rewardCoins: 120,
      rarity: DailyQuestRarity.epic,
    ),
    DailyQuestDefinition(
      id: "daily_xp_900",
      title: "Heroic XP",
      description: "Earn 900 workout XP today.",
      metric: DailyQuestMetric.workoutXp,
      target: 900,
      rewardXp: 330,
      rewardCoins: 125,
      rarity: DailyQuestRarity.epic,
    ),
    DailyQuestDefinition(
      id: "daily_sets_40",
      title: "Volume Monster",
      description: "Log 40 total sets today.",
      metric: DailyQuestMetric.totalSets,
      target: 40,
      rewardXp: 315,
      rewardCoins: 118,
      rarity: DailyQuestRarity.epic,
    ),
    DailyQuestDefinition(
      id: "daily_time_2700",
      title: "Endurance Shift",
      description: "Log 45 minutes of training today.",
      metric: DailyQuestMetric.trainingSeconds,
      target: 2700,
      rewardXp: 305,
      rewardCoins: 115,
      rarity: DailyQuestRarity.epic,
    ),
    DailyQuestDefinition(
      id: "daily_goal_3",
      title: "Path to Mastery",
      description: "Log your focused goal movement 3 times today.",
      metric: DailyQuestMetric.goalMovementSessions,
      target: 3,
      rewardXp: 325,
      rewardCoins: 122,
      rarity: DailyQuestRarity.epic,
    ),
  ];

  static DailyQuestDefinition? byId(String id) {
    for (final quest in all) {
      if (quest.id == id) {
        return quest;
      }
    }
    return null;
  }

  static List<DailyQuestDefinition> rotationForDate({
    required DateTime day,
    required bool hasGoal,
    required int level,
  }) {
    final pool = all.where((q) => hasGoal || !q.requiresGoal).toList();
    if (pool.length <= 3) {
      return pool;
    }

    final seed = day.year * 10000 + day.month * 100 + day.day;
    final random = Random(seed);

    List<DailyQuestDefinition> pickFrom(DailyQuestRarity rarity) {
      return pool.where((q) => q.rarity == rarity).toList();
    }

    DailyQuestDefinition pickOne(
      List<DailyQuestDefinition> source,
      Set<String> taken,
    ) {
      final candidates = source.where((q) => !taken.contains(q.id)).toList();
      if (candidates.isEmpty) {
        final fallback = pool.where((q) => !taken.contains(q.id)).toList();
        return fallback[random.nextInt(fallback.length)];
      }
      return candidates[random.nextInt(candidates.length)];
    }

    final common = pickFrom(DailyQuestRarity.common);
    final rare = pickFrom(DailyQuestRarity.rare);
    final epic = pickFrom(DailyQuestRarity.epic);

    final result = <DailyQuestDefinition>[];
    final taken = <String>{};

    final first = pickOne(common, taken);
    result.add(first);
    taken.add(first.id);

    final preferRareSecond = level >= 5;
    final secondPool = preferRareSecond && rare.isNotEmpty ? rare : common;
    final second = pickOne(secondPool, taken);
    result.add(second);
    taken.add(second.id);

    int epicChancePercent() {
      if (level < 10) return 0;
      if (level < 20) return 8;
      if (level < 30) return 18;
      if (level < 40) return 30;
      return 42;
    }

    final weekendBonus =
        (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday)
        ? 8
        : 0;
    final chance = (epicChancePercent() + weekendBonus).clamp(0, 100);
    final roll = random.nextInt(100);
    final includeEpic = roll < chance;

    final thirdPool = includeEpic && epic.isNotEmpty ? epic : rare + common;
    final third = pickOne(thirdPool, taken);
    result.add(third);

    return result;
  }
}
