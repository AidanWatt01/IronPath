class SeedBadge {
  const SeedBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String description;
  final int sortOrder;
}

const List<SeedBadge> seedBadges = [
  // =========================
  // ONBOARDING
  // =========================
  SeedBadge(
    id: "first_session",
    name: "First Session",
    description: "Log your first session.",
    sortOrder: 10,
  ),
  SeedBadge(
    id: "first_unlocked",
    name: "First Unlock",
    description: "Unlock your first movement.",
    sortOrder: 20,
  ),
  SeedBadge(
    id: "first_mastery",
    name: "First Mastery",
    description: "Master your first movement.",
    sortOrder: 30,
  ),

  // =========================
  // SESSIONS (volume)
  // =========================
  SeedBadge(
    id: "ten_sessions",
    name: "Consistency",
    description: "Log 10 sessions.",
    sortOrder: 110,
  ),
  SeedBadge(
    id: "sessions_25",
    name: "Habit Builder",
    description: "Log 25 sessions.",
    sortOrder: 120,
  ),
  SeedBadge(
    id: "sessions_50",
    name: "Momentum",
    description: "Log 50 sessions.",
    sortOrder: 130,
  ),
  SeedBadge(
    id: "sessions_100",
    name: "Committed",
    description: "Log 100 sessions.",
    sortOrder: 140,
  ),
  SeedBadge(
    id: "sessions_250",
    name: "Relentless",
    description: "Log 250 sessions.",
    sortOrder: 150,
  ),
  SeedBadge(
    id: "sessions_500",
    name: "Workhorse",
    description: "Log 500 sessions.",
    sortOrder: 160,
  ),
  SeedBadge(
    id: "sessions_1000",
    name: "Legendary Logger",
    description: "Log 1000 sessions.",
    sortOrder: 170,
  ),

  // =========================
  // STREAKS
  // =========================
  SeedBadge(
    id: "streak_3",
    name: "3-Day Streak",
    description: "Train 3 days in a row.",
    sortOrder: 210,
  ),
  SeedBadge(
    id: "streak_7",
    name: "7-Day Streak",
    description: "Train 7 days in a row.",
    sortOrder: 220,
  ),
  SeedBadge(
    id: "streak_14",
    name: "14-Day Streak",
    description: "Train 14 days in a row.",
    sortOrder: 230,
  ),
  SeedBadge(
    id: "streak_30",
    name: "30-Day Streak",
    description: "Train 30 days in a row.",
    sortOrder: 240,
  ),
  SeedBadge(
    id: "streak_60",
    name: "60-Day Streak",
    description: "Train 60 days in a row.",
    sortOrder: 250,
  ),
  SeedBadge(
    id: "streak_100",
    name: "100-Day Streak",
    description: "Train 100 days in a row.",
    sortOrder: 260,
  ),

  // =========================
  // XP MILESTONES
  // =========================
  SeedBadge(
    id: "xp_100",
    name: "XP 100",
    description: "Reach 100 total XP.",
    sortOrder: 310,
  ),
  SeedBadge(
    id: "xp_500",
    name: "XP 500",
    description: "Reach 500 total XP.",
    sortOrder: 320,
  ),
  SeedBadge(
    id: "xp_1000",
    name: "XP 1000",
    description: "Reach 1000 total XP.",
    sortOrder: 330,
  ),
  SeedBadge(
    id: "xp_2500",
    name: "XP 2500",
    description: "Reach 2500 total XP.",
    sortOrder: 340,
  ),
  SeedBadge(
    id: "xp_5000",
    name: "XP 5000",
    description: "Reach 5000 total XP.",
    sortOrder: 350,
  ),
  SeedBadge(
    id: "xp_10000",
    name: "XP 10000",
    description: "Reach 10,000 total XP.",
    sortOrder: 360,
  ),
  SeedBadge(
    id: "xp_20000",
    name: "XP 20000",
    description: "Reach 20,000 total XP.",
    sortOrder: 370,
  ),
  SeedBadge(
    id: "xp_50000",
    name: "XP 50000",
    description: "Reach 50,000 total XP.",
    sortOrder: 380,
  ),

  // =========================
  // LEVEL MILESTONES
  // =========================
  SeedBadge(
    id: "level_5",
    name: "Level 5",
    description: "Reach level 5.",
    sortOrder: 410,
  ),
  SeedBadge(
    id: "level_10",
    name: "Level 10",
    description: "Reach level 10.",
    sortOrder: 420,
  ),
  SeedBadge(
    id: "level_20",
    name: "Level 20",
    description: "Reach level 20.",
    sortOrder: 430,
  ),
  SeedBadge(
    id: "level_30",
    name: "Level 30",
    description: "Reach level 30.",
    sortOrder: 440,
  ),
  SeedBadge(
    id: "level_40",
    name: "Level 40",
    description: "Reach level 40.",
    sortOrder: 450,
  ),

  // =========================
  // UNLOCK / MASTERY COUNTS
  // =========================
  SeedBadge(
    id: "unlocked_10",
    name: "Explorer",
    description: "Unlock 10 movements.",
    sortOrder: 510,
  ),
  SeedBadge(
    id: "unlocked_25",
    name: "Pathfinder",
    description: "Unlock 25 movements.",
    sortOrder: 520,
  ),
  SeedBadge(
    id: "unlocked_50",
    name: "Trailblazer",
    description: "Unlock 50 movements.",
    sortOrder: 530,
  ),
  SeedBadge(
    id: "unlocked_75",
    name: "Cartographer",
    description: "Unlock 75 movements.",
    sortOrder: 540,
  ),

  SeedBadge(
    id: "mastered_1",
    name: "First Mastery",
    description: "Master 1 movement.",
    sortOrder: 560,
  ),
  SeedBadge(
    id: "mastered_3",
    name: "Triple Threat",
    description: "Master 3 movements.",
    sortOrder: 570,
  ),
  SeedBadge(
    id: "mastered_5",
    name: "Five-Star Form",
    description: "Master 5 movements.",
    sortOrder: 580,
  ),
  SeedBadge(
    id: "mastered_10",
    name: "Tenured",
    description: "Master 10 movements.",
    sortOrder: 590,
  ),
  SeedBadge(
    id: "mastered_20",
    name: "Crafted",
    description: "Master 20 movements.",
    sortOrder: 600,
  ),
  SeedBadge(
    id: "mastered_30",
    name: "Artisan",
    description: "Master 30 movements.",
    sortOrder: 610,
  ),

  // =========================
  // TRAINING TIME
  // =========================
  SeedBadge(
    id: "time_1h",
    name: "One Hour In",
    description: "Accumulate 1 hour of logged training time.",
    sortOrder: 710,
  ),
  SeedBadge(
    id: "time_10h",
    name: "Ten Hours In",
    description: "Accumulate 10 hours of logged training time.",
    sortOrder: 720,
  ),
  SeedBadge(
    id: "time_50h",
    name: "Fifty Hours In",
    description: "Accumulate 50 hours of logged training time.",
    sortOrder: 730,
  ),
  SeedBadge(
    id: "time_100h",
    name: "Hundred Hours In",
    description: "Accumulate 100 hours of logged training time.",
    sortOrder: 740,
  ),

  // =========================
  // PULL-UP PROGRESSION (total reps)
  // =========================
  SeedBadge(
    id: "first_pull_up",
    name: "First Pull-up",
    description: "Log your first pull-up rep.",
    sortOrder: 800,
  ),
  SeedBadge(
    id: "pullup_total_10",
    name: "Pull-up x10",
    description: "Accumulate 10 pull-up reps.",
    sortOrder: 810,
  ),
  SeedBadge(
    id: "pullup_total_100",
    name: "Pull-up x100",
    description: "Accumulate 100 pull-up reps.",
    sortOrder: 820,
  ),
  SeedBadge(
    id: "pullup_total_500",
    name: "Pull-up x500",
    description: "Accumulate 500 pull-up reps.",
    sortOrder: 830,
  ),
  SeedBadge(
    id: "pullup_total_1000",
    name: "Pull-up x1000",
    description: "Accumulate 1000 pull-up reps.",
    sortOrder: 840,
  ),
  SeedBadge(
    id: "pullup_total_5000",
    name: "Pull-up x5000",
    description: "Accumulate 5000 pull-up reps.",
    sortOrder: 850,
  ),
  SeedBadge(
    id: "pullup_total_10000",
    name: "Pull-up x10000",
    description: "Accumulate 10,000 pull-up reps.",
    sortOrder: 860,
  ),

  // PULL-UP (best reps)
  SeedBadge(
    id: "pullup_best_5",
    name: "5 Strict Pull-ups",
    description: "Hit 5 best pull-up reps in a session.",
    sortOrder: 870,
  ),
  SeedBadge(
    id: "pullup_best_10",
    name: "10 Strict Pull-ups",
    description: "Hit 10 best pull-up reps in a session.",
    sortOrder: 880,
  ),
  SeedBadge(
    id: "pullup_best_15",
    name: "15 Strict Pull-ups",
    description: "Hit 15 best pull-up reps in a session.",
    sortOrder: 890,
  ),
  SeedBadge(
    id: "pullup_best_20",
    name: "20 Strict Pull-ups",
    description: "Hit 20 best pull-up reps in a session.",
    sortOrder: 900,
  ),

  // =========================
  // PUSH-UP PROGRESSION
  // =========================
  SeedBadge(
    id: "pushup_total_100",
    name: "Push-up x100",
    description: "Accumulate 100 push-up reps.",
    sortOrder: 1000,
  ),
  SeedBadge(
    id: "pushup_total_500",
    name: "Push-up x500",
    description: "Accumulate 500 push-up reps.",
    sortOrder: 1010,
  ),
  SeedBadge(
    id: "pushup_total_1000",
    name: "Push-up x1000",
    description: "Accumulate 1000 push-up reps.",
    sortOrder: 1020,
  ),
  SeedBadge(
    id: "pushup_total_5000",
    name: "Push-up x5000",
    description: "Accumulate 5000 push-up reps.",
    sortOrder: 1030,
  ),
  SeedBadge(
    id: "pushup_total_10000",
    name: "Push-up x10000",
    description: "Accumulate 10,000 push-up reps.",
    sortOrder: 1040,
  ),

  SeedBadge(
    id: "pushup_best_25",
    name: "25 Push-ups",
    description: "Hit 25 best push-up reps in a session.",
    sortOrder: 1050,
  ),
  SeedBadge(
    id: "pushup_best_50",
    name: "50 Push-ups",
    description: "Hit 50 best push-up reps in a session.",
    sortOrder: 1060,
  ),
  SeedBadge(
    id: "pushup_best_75",
    name: "75 Push-ups",
    description: "Hit 75 best push-up reps in a session.",
    sortOrder: 1070,
  ),
  SeedBadge(
    id: "pushup_best_100",
    name: "100 Push-ups",
    description: "Hit 100 best push-up reps in a session.",
    sortOrder: 1080,
  ),

  // =========================
  // SQUAT PROGRESSION (bodyweight_squat)
  // =========================
  SeedBadge(
    id: "squat_total_200",
    name: "Squat x200",
    description: "Accumulate 200 bodyweight squat reps.",
    sortOrder: 1200,
  ),
  SeedBadge(
    id: "squat_total_500",
    name: "Squat x500",
    description: "Accumulate 500 bodyweight squat reps.",
    sortOrder: 1210,
  ),
  SeedBadge(
    id: "squat_total_1000",
    name: "Squat x1000",
    description: "Accumulate 1000 bodyweight squat reps.",
    sortOrder: 1220,
  ),
  SeedBadge(
    id: "squat_total_5000",
    name: "Squat x5000",
    description: "Accumulate 5000 bodyweight squat reps.",
    sortOrder: 1230,
  ),
  SeedBadge(
    id: "squat_total_10000",
    name: "Squat x10000",
    description: "Accumulate 10,000 bodyweight squat reps.",
    sortOrder: 1240,
  ),

  // =========================
  // PLANK PROGRESSION (best + total hold)
  // =========================
  SeedBadge(
    id: "plank_best_60",
    name: "1-Minute Plank",
    description: "Hold a plank for 60s (best hold).",
    sortOrder: 1300,
  ),
  SeedBadge(
    id: "plank_best_120",
    name: "2-Minute Plank",
    description: "Hold a plank for 120s (best hold).",
    sortOrder: 1310,
  ),
  SeedBadge(
    id: "plank_best_300",
    name: "5-Minute Plank",
    description: "Hold a plank for 300s (best hold).",
    sortOrder: 1320,
  ),
  SeedBadge(
    id: "plank_best_600",
    name: "10-Minute Plank",
    description: "Hold a plank for 600s (best hold).",
    sortOrder: 1330,
  ),

  SeedBadge(
    id: "plank_total_600",
    name: "Plank 10 Minutes Total",
    description: "Accumulate 10 minutes of plank hold time.",
    sortOrder: 1340,
  ),
  SeedBadge(
    id: "plank_total_3600",
    name: "Plank 1 Hour Total",
    description: "Accumulate 1 hour of plank hold time.",
    sortOrder: 1350,
  ),
  SeedBadge(
    id: "plank_total_10800",
    name: "Plank 3 Hours Total",
    description: "Accumulate 3 hours of plank hold time.",
    sortOrder: 1360,
  ),

  // =========================
  // HANDSTAND PROGRESSION (wall_handstand)
  // =========================
  SeedBadge(
    id: "wall_handstand_best_30",
    name: "30s Wall Handstand",
    description: "Hold a wall handstand for 30s (best hold).",
    sortOrder: 1400,
  ),
  SeedBadge(
    id: "wall_handstand_best_60",
    name: "60s Wall Handstand",
    description: "Hold a wall handstand for 60s (best hold).",
    sortOrder: 1410,
  ),
  SeedBadge(
    id: "wall_handstand_best_120",
    name: "2-Minute Wall Handstand",
    description: "Hold a wall handstand for 120s (best hold).",
    sortOrder: 1420,
  ),

  // =========================
  // SKILL MILESTONES (logged or mastered)
  // =========================
  SeedBadge(
    id: "first_free_handstand",
    name: "First Freestanding Handstand",
    description: "Log a freestanding handstand session.",
    sortOrder: 1500,
  ),
  SeedBadge(
    id: "first_bar_muscle_up",
    name: "First Bar Muscle-up",
    description: "Log a bar muscle-up rep.",
    sortOrder: 1510,
  ),
  SeedBadge(
    id: "first_ring_muscle_up",
    name: "First Ring Muscle-up",
    description: "Log a ring muscle-up rep.",
    sortOrder: 1520,
  ),
  SeedBadge(
    id: "front_lever_mastered",
    name: "Front Lever Mastered",
    description: "Master the front lever hold.",
    sortOrder: 1530,
  ),
  SeedBadge(
    id: "planche_mastered",
    name: "Planche Mastered",
    description: "Master the planche hold.",
    sortOrder: 1540,
  ),

  // =========================
  // UNIQUE CHALLENGES (combo conditions)
  // =========================
  SeedBadge(
    id: "challenge_upper_balance",
    name: "Balanced Upper Body",
    description: "Accumulate 100 pull-up reps and 1,000 push-up reps.",
    sortOrder: 1600,
  ),
  SeedBadge(
    id: "challenge_core_legs",
    name: "Core + Legs Engine",
    description: "Accumulate 2,000 squat reps and 1 hour of total plank hold.",
    sortOrder: 1610,
  ),
  SeedBadge(
    id: "challenge_static_control",
    name: "Static Control",
    description: "Hit a 4-minute plank and a 90-second wall handstand hold.",
    sortOrder: 1620,
  ),
  SeedBadge(
    id: "challenge_skill_trio",
    name: "Skill Sampler",
    description:
        "Log Freestanding Handstand, Bar Muscle-up, and Ring Muscle-up.",
    sortOrder: 1630,
  ),
  SeedBadge(
    id: "challenge_all_rounder",
    name: "All-Rounder",
    description:
        "10 pull-ups best, 50 push-ups best, 1,000 squats total, and 2-minute plank.",
    sortOrder: 1640,
  ),
  SeedBadge(
    id: "challenge_engine_room",
    name: "Engine Room",
    description: "Log 200 sessions and 100 total training hours.",
    sortOrder: 1650,
  ),
  SeedBadge(
    id: "challenge_gold_collector_20",
    name: "Gold Collector",
    description: "Reach Gold tier (or higher) in 20 movements.",
    sortOrder: 1660,
  ),
  SeedBadge(
    id: "challenge_elite_duo",
    name: "Elite Duo",
    description: "Master both Front Lever and Planche.",
    sortOrder: 1670,
  ),
];
