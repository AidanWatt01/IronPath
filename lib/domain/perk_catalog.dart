class PerkDefinition {
  const PerkDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
  });

  final String id;
  final String name;
  final String description;
  final int maxLevel;
}

class PerkCatalog {
  static const int respecCoinCost = 150;

  static const momentum = PerkDefinition(
    id: "momentum",
    name: "Momentum",
    description: "First workout of the day gains +10% XP per level.",
    maxLevel: 3,
  );

  static const specialist = PerkDefinition(
    id: "specialist",
    name: "Specialist",
    description: "Focused goal movement gains +5% XP per level.",
    maxLevel: 3,
  );

  static const collector = PerkDefinition(
    id: "collector",
    name: "Collector",
    description: "Gain +10% coins per level from workouts.",
    maxLevel: 3,
  );

  static const technician = PerkDefinition(
    id: "technician",
    name: "Technician",
    description: "High-form logs (8+) gain +5% XP per level.",
    maxLevel: 3,
  );

  static const volumeEngine = PerkDefinition(
    id: "volume_engine",
    name: "Volume Engine",
    description: "Logs with 3+ sets gain +4% XP per level.",
    maxLevel: 3,
  );

  static const finisher = PerkDefinition(
    id: "finisher",
    name: "Finisher",
    description: "Big sessions (80+ XP) gain +5% coins per level.",
    maxLevel: 3,
  );

  static const streakSurge = PerkDefinition(
    id: "streak_surge",
    name: "Streak Surge",
    description: "At 3+ day streak, gain +3% XP per level.",
    maxLevel: 3,
  );

  static const holdSpecialist = PerkDefinition(
    id: "hold_specialist",
    name: "Hold Specialist",
    description: "Timed/hold movements gain +6% XP per level.",
    maxLevel: 3,
  );

  static const masteryHunter = PerkDefinition(
    id: "mastery_hunter",
    name: "Mastery Hunter",
    description: "Non-mastered movements gain +4% XP per level.",
    maxLevel: 3,
  );

  static const timekeeper = PerkDefinition(
    id: "timekeeper",
    name: "Timekeeper",
    description: "Sessions lasting 90s+ gain +5% coins per level.",
    maxLevel: 3,
  );

  static const all = <PerkDefinition>[
    momentum,
    specialist,
    collector,
    technician,
    volumeEngine,
    finisher,
    streakSurge,
    holdSpecialist,
    masteryHunter,
    timekeeper,
  ];
}
