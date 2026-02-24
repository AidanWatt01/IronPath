// lib/domain/mastery_rules.dart
import "dart:math";

import "../data/db/app_db.dart";

/// Legacy support (some parts of your code still reference this).
/// You said you don’t want OR mastery — so all targets default to [all].
/// [any] is kept only so old code compiles.
enum MasteryMode { all, any }

class MasteryTarget {
  const MasteryTarget({
    this.reps = 0,
    this.holdSeconds = 0,
    this.totalXp = 0,
    this.mode = MasteryMode.all,
  });

  final int reps;
  final int holdSeconds;
  final int totalXp;

  /// Kept for backwards compatibility.
  final MasteryMode mode;

  /// AND semantics by default.
  /// If mode == any, it becomes OR across non-zero requirements
  /// (kept only for compatibility; you can ignore and never use it).
  bool isMet({
    required int bestReps,
    required int bestHoldSeconds,
    required int movementTotalXp,
  }) {
    final checks = <bool>[];

    if (reps > 0) checks.add(bestReps >= reps);
    if (holdSeconds > 0) checks.add(bestHoldSeconds >= holdSeconds);
    if (totalXp > 0) checks.add(movementTotalXp >= totalXp);

    if (checks.isEmpty) return true;

    if (mode == MasteryMode.any) {
      // Compatibility path (not recommended for your design).
      return checks.any((x) => x);
    }

    // Your desired behavior: strict AND.
    return checks.every((x) => x);
  }
}

// Represents all tier targets for a movement.
// Used by legacy UIs that expect per-tier benchmarks.
class MasteryTiers {
  const MasteryTiers({
    required this.progress,
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.mastered,
  });

  final MasteryTarget progress;
  final MasteryTarget bronze;
  final MasteryTarget silver;
  final MasteryTarget gold;
  final MasteryTarget mastered;
}

class MasteryRules {
  // ---------------------------------------------------------------------------
  // Hand-tuned benchmarks
  // Every entry includes BOTH: (performance) + (practice XP)
  // ---------------------------------------------------------------------------
  static const Map<String, MasteryTarget> overrides = {
    // =========================
    // MOBILITY / PREHAB
    // =========================
    "wrist_mobility": MasteryTarget(holdSeconds: 50, totalXp: 240),
    "shoulder_dislocates": MasteryTarget(reps: 35, totalXp: 260),
    "thoracic_extension": MasteryTarget(holdSeconds: 55, totalXp: 300),
    "hamstring_mobility": MasteryTarget(holdSeconds: 65, totalXp: 340),
    "ankle_mobility": MasteryTarget(holdSeconds: 55, totalXp: 300),
    "hip_flexor_mobility": MasteryTarget(holdSeconds: 60, totalXp: 320),
    "pancake_stretch": MasteryTarget(holdSeconds: 75, totalXp: 880),
    "couch_stretch": MasteryTarget(holdSeconds: 70, totalXp: 820),
    "bridge_prep": MasteryTarget(holdSeconds: 40, totalXp: 760),
    "cossack_squat_mobility": MasteryTarget(reps: 16, totalXp: 1080),
    "bridge": MasteryTarget(holdSeconds: 30, totalXp: 1180),

    // =========================
    // CORE / FOUNDATION
    // =========================
    "plank": MasteryTarget(holdSeconds: 70, totalXp: 420),
    "side_plank": MasteryTarget(holdSeconds: 52, totalXp: 480),
    "hollow_hold": MasteryTarget(holdSeconds: 45, totalXp: 540),
    "arch_hold": MasteryTarget(holdSeconds: 48, totalXp: 620),

    "hanging_knee_raise": MasteryTarget(reps: 14, totalXp: 760),
    "hanging_leg_raise": MasteryTarget(reps: 11, totalXp: 1040),
    "toes_to_bar": MasteryTarget(reps: 9, totalXp: 1380),

    "tuck_l_sit": MasteryTarget(holdSeconds: 18, totalXp: 880),
    "l_sit": MasteryTarget(holdSeconds: 14, totalXp: 1160),
    "v_sit": MasteryTarget(holdSeconds: 8, totalXp: 1840),

    "hanging_oblique_raise": MasteryTarget(reps: 13, totalXp: 1520),
    "hanging_windshield_wiper": MasteryTarget(reps: 6, totalXp: 2360),

    // Dragon flag line
    "tuck_dragon_flag": MasteryTarget(reps: 4, totalXp: 1960),
    "dragon_flag_negative": MasteryTarget(reps: 3, totalXp: 2180),
    "dragon_flag": MasteryTarget(reps: 4, totalXp: 2820),

    // Press handstand compression line
    "pike_compression": MasteryTarget(reps: 19, totalXp: 980),
    "seated_pike_lift": MasteryTarget(reps: 13, totalXp: 1230),
    "straddle_compression": MasteryTarget(reps: 11, totalXp: 1910),

    // =========================
    // PUSH
    // =========================
    "incline_push_up": MasteryTarget(reps: 24, totalXp: 260),
    "knee_push_up": MasteryTarget(reps: 22, totalXp: 360),
    "push_up": MasteryTarget(reps: 20, totalXp: 680),
    "diamond_push_up": MasteryTarget(reps: 17, totalXp: 940),
    "decline_push_up": MasteryTarget(reps: 16, totalXp: 1010),
    "archer_push_up": MasteryTarget(reps: 9, totalXp: 1480),
    "pseudo_planche_push_up": MasteryTarget(reps: 7, totalXp: 1820),

    "support_hold": MasteryTarget(holdSeconds: 24, totalXp: 860),
    "parallel_dip": MasteryTarget(reps: 13, totalXp: 1520),

    "pike_push_up": MasteryTarget(reps: 18, totalXp: 980),
    "elevated_pike_push_up": MasteryTarget(reps: 12, totalXp: 1560),

    // =========================
    // PULL
    // =========================
    "active_hang": MasteryTarget(holdSeconds: 50, totalXp: 280),
    "scap_pull_up": MasteryTarget(reps: 24, totalXp: 340),
    "australian_pull_up": MasteryTarget(reps: 18, totalXp: 460),

    "negative_pull_up": MasteryTarget(reps: 7, totalXp: 980),
    "chin_up": MasteryTarget(reps: 11, totalXp: 1120),
    "pull_up": MasteryTarget(reps: 10, totalXp: 1480),
    "explosive_pull_up": MasteryTarget(reps: 6, totalXp: 2050),

    // One-arm pull-up progression
    "archer_pull_up": MasteryTarget(reps: 5, totalXp: 2380),
    "typewriter_pull_up": MasteryTarget(reps: 4, totalXp: 2760),
    "uneven_pull_up": MasteryTarget(reps: 4, totalXp: 2610),

    "one_arm_hang": MasteryTarget(holdSeconds: 18, totalXp: 2920),
    "one_arm_lockoff": MasteryTarget(holdSeconds: 12, totalXp: 3720),
    "one_arm_negative_pull_up": MasteryTarget(reps: 3, totalXp: 4550),
    "one_arm_pull_up": MasteryTarget(reps: 2, totalXp: 5600),

    // =========================
    // LEGS
    // =========================
    "bodyweight_squat": MasteryTarget(reps: 34, totalXp: 320),
    "split_squat": MasteryTarget(reps: 24, totalXp: 760),
    "reverse_lunge": MasteryTarget(reps: 22, totalXp: 820),
    "bulgarian_split_squat": MasteryTarget(reps: 18, totalXp: 980),
    "cossack_squat": MasteryTarget(reps: 14, totalXp: 1260),
    "shrimp_squat": MasteryTarget(reps: 9, totalXp: 1460),
    "jump_squat": MasteryTarget(reps: 16, totalXp: 1320),
    "shrimp_squat_negative": MasteryTarget(reps: 7, totalXp: 1540),
    "assisted_pistol_squat": MasteryTarget(reps: 10, totalXp: 1540),
    "pistol_squat": MasteryTarget(reps: 6, totalXp: 1980),

    // =========================
    // SKILLS
    // =========================
    "wall_handstand": MasteryTarget(holdSeconds: 36, totalXp: 1280),
    "freestanding_handstand": MasteryTarget(holdSeconds: 24, totalXp: 1920),

    "wall_hspu_negative": MasteryTarget(reps: 6, totalXp: 2480),
    "wall_hspu": MasteryTarget(reps: 5, totalXp: 2860),

    // Press handstand progression
    "tuck_press_handstand": MasteryTarget(reps: 4, totalXp: 3220),
    "straddle_press_handstand": MasteryTarget(reps: 3, totalXp: 4180),
    "press_handstand": MasteryTarget(reps: 2, totalXp: 5360),
    "l_sit_to_tuck_handstand": MasteryTarget(reps: 6, totalXp: 4800),
    "l_sit_to_handstand": MasteryTarget(reps: 4, totalXp: 6800),
    "v_sit_to_handstand": MasteryTarget(reps: 3, totalXp: 9200),
    "l_sit_to_tuck_planche": MasteryTarget(reps: 4, totalXp: 7200),
    "tuck_planche_to_handstand": MasteryTarget(reps: 2, totalXp: 11800),
    "l_sit_to_muscle_up_transition": MasteryTarget(reps: 4, totalXp: 9800),
    "front_lever_to_muscle_up": MasteryTarget(reps: 3, totalXp: 12600),
    "bar_muscle_up_to_handstand_negative": MasteryTarget(
      holdSeconds: 10,
      totalXp: 14800,
    ),

    // Front lever holds + raises
    "tuck_front_lever": MasteryTarget(holdSeconds: 12, totalXp: 2240),
    "adv_tuck_front_lever": MasteryTarget(holdSeconds: 9, totalXp: 2980),
    "straddle_front_lever": MasteryTarget(holdSeconds: 7, totalXp: 3860),
    "front_lever": MasteryTarget(holdSeconds: 6, totalXp: 5120),

    "tuck_front_lever_raises": MasteryTarget(reps: 6, totalXp: 2860),
    "adv_tuck_front_lever_raises": MasteryTarget(reps: 5, totalXp: 3640),
    "front_lever_raises": MasteryTarget(reps: 4, totalXp: 5980),

    // Back lever line
    "german_hang": MasteryTarget(holdSeconds: 24, totalXp: 2180),
    "skin_the_cat": MasteryTarget(reps: 6, totalXp: 2620),
    "tuck_back_lever": MasteryTarget(holdSeconds: 12, totalXp: 3140),
    "back_lever": MasteryTarget(holdSeconds: 9, totalXp: 4020),

    // Muscle-up line (bar)
    "muscle_up_transition": MasteryTarget(reps: 6, totalXp: 3360),
    "bar_muscle_up": MasteryTarget(reps: 4, totalXp: 4720),

    // Human flag progression
    "flag_pole_support": MasteryTarget(holdSeconds: 24, totalXp: 3380),
    "tucked_human_flag": MasteryTarget(holdSeconds: 9, totalXp: 4860),
    "adv_tuck_human_flag": MasteryTarget(holdSeconds: 7, totalXp: 5820),
    "straddle_human_flag": MasteryTarget(holdSeconds: 6, totalXp: 6920),
    "human_flag": MasteryTarget(holdSeconds: 6, totalXp: 8120),

    // Planche progression
    "planche_lean": MasteryTarget(holdSeconds: 26, totalXp: 3560),
    "frog_stand": MasteryTarget(holdSeconds: 22, totalXp: 3320),
    "tuck_planche": MasteryTarget(holdSeconds: 9, totalXp: 5340),
    "adv_tuck_planche": MasteryTarget(holdSeconds: 7, totalXp: 6540),
    "straddle_planche": MasteryTarget(holdSeconds: 6, totalXp: 7960),
    "planche": MasteryTarget(holdSeconds: 5, totalXp: 10800),

    // =========================
    // RINGS
    // =========================
    "ring_support_assisted": MasteryTarget(holdSeconds: 32, totalXp: 860),
    "ring_support_scap_shrugs": MasteryTarget(reps: 18, totalXp: 980),
    "ring_support_hold": MasteryTarget(holdSeconds: 24, totalXp: 1860),

    "ring_row": MasteryTarget(reps: 14, totalXp: 1080),
    "ring_face_pull": MasteryTarget(reps: 16, totalXp: 1240),
    "ring_push_up": MasteryTarget(reps: 15, totalXp: 1320),
    "ring_pull_up": MasteryTarget(reps: 9, totalXp: 3040),

    "false_grip_hang": MasteryTarget(holdSeconds: 24, totalXp: 2180),
    "false_grip_row": MasteryTarget(reps: 12, totalXp: 2680),

    "ring_l_sit_support": MasteryTarget(holdSeconds: 18, totalXp: 4620),

    "ring_support_turnout_assisted": MasteryTarget(
      holdSeconds: 18,
      totalXp: 3280,
    ),
    "ring_support_rto": MasteryTarget(holdSeconds: 14, totalXp: 5480),

    "ring_dip_negative": MasteryTarget(reps: 6, totalXp: 3360),
    "ring_dip": MasteryTarget(reps: 9, totalXp: 4120),
    "ring_turnout_dip": MasteryTarget(reps: 7, totalXp: 5360),

    "ring_transition_low": MasteryTarget(reps: 6, totalXp: 4680),
    "ring_muscle_up": MasteryTarget(reps: 3, totalXp: 7820),

    "ring_inverted_hang": MasteryTarget(holdSeconds: 24, totalXp: 5480),
    "ring_tuck_back_lever": MasteryTarget(holdSeconds: 12, totalXp: 6420),
    "ring_back_lever": MasteryTarget(holdSeconds: 9, totalXp: 8040),

    "ring_cross_lean": MasteryTarget(holdSeconds: 12, totalXp: 9620),
    "ring_assisted_iron_cross": MasteryTarget(holdSeconds: 9, totalXp: 13800),
    "iron_cross": MasteryTarget(holdSeconds: 6, totalXp: 18600),

    "assisted_maltese": MasteryTarget(holdSeconds: 6, totalXp: 22400),
    "maltese": MasteryTarget(holdSeconds: 4, totalXp: 29200),

    // Rings accessories
    "ring_biceps_curl": MasteryTarget(reps: 14, totalXp: 1480),
    "ring_triceps_extension": MasteryTarget(reps: 13, totalXp: 1540),
    "ring_fly": MasteryTarget(reps: 11, totalXp: 1860),
    "ring_support_swings": MasteryTarget(holdSeconds: 36, totalXp: 1720),
    "ring_external_rotation": MasteryTarget(reps: 24, totalXp: 1120),
  };

  // ---------------------------------------------------------------------------
  // Smart fallback for anything not explicitly listed above.
  // Uses Movement difficulty/category + rep/hold nature from xpPerRep/xpPerSecond.
  // ---------------------------------------------------------------------------
  static const Map<int, int> _xpByDifficulty = {
    1: 200,
    2: 300,
    3: 450,
    4: 600,
    5: 800,
    6: 1000,
    7: 1300,
    8: 1600,
    9: 2000,
    10: 2400,
  };

  static const Map<int, int> _repsByDifficulty = {
    1: 20,
    2: 20,
    3: 15,
    4: 12,
    5: 10,
    6: 8,
    7: 6,
    8: 5,
    9: 3,
    10: 2,
  };

  static const Map<int, int> _holdByDifficulty = {
    1: 60,
    2: 45,
    3: 30,
    4: 25,
    5: 20,
    6: 15,
    7: 12,
    8: 10,
    9: 8,
    10: 6,
  };

  // ---------------------------------------------------------------------------
  // BACKWARDS-COMPAT API (fixes your build errors)
  // ---------------------------------------------------------------------------

  /// Old call sites expect this exact method name/signature.
  /// If you can provide a [movement], it will produce a smarter target.
  static MasteryTarget forMovement(String movementId, {Movement? movement}) {
    final ov = overrides[movementId];
    if (ov != null) return ov;

    if (movement != null) return forMovementEntity(movement);

    // Safe fallback when we only have an id.
    // (Services/widgets should prefer passing Movement for more accurate targets.)
    return const MasteryTarget(reps: 10, totalXp: 600);
  }

  static MasteryTarget forMovementEntity(Movement m) {
    // Prefer explicit override
    final ov = overrides[m.id];
    if (ov != null) return ov;

    final totalXp = _practiceXpFor(m);

    // Hybrid: require reps + hold (AND)
    if (_isHybrid(m)) {
      return MasteryTarget(
        reps: _repTargetFor(m),
        holdSeconds: _holdTargetFor(m),
        totalXp: totalXp,
      );
    }

    // Holds
    if (_isHold(m)) {
      return MasteryTarget(holdSeconds: _holdTargetFor(m), totalXp: totalXp);
    }

    // Default reps
    return MasteryTarget(reps: _repTargetFor(m), totalXp: totalXp);
  }

  static bool _isHold(Movement m) => m.xpPerSecond > 0 && m.xpPerRep == 0;
  static bool _isHybrid(Movement m) => m.xpPerSecond > 0 && m.xpPerRep > 0;

  static int _practiceXpFor(Movement m) {
    int xp = _xpByDifficulty[m.difficulty] ?? 600;

    // Category flavor
    if (m.category == "mobility") xp = max(200, (xp * 0.8).round());
    if (m.category == "skill" || m.category == "rings") xp = (xp * 1.1).round();
    if (m.category == "rings" && m.difficulty >= 9) xp = (xp * 1.25).round();

    return max(200, xp);
  }

  static int _repTargetFor(Movement m) {
    int r = _repsByDifficulty[m.difficulty] ?? 10;

    // Legs trend higher reps
    if (m.category == "legs") r = max(5, (r * 1.5).round());

    // Mobility rep drills trend higher volume
    if (m.category == "mobility") r = max(10, (r * 1.5).round());

    return max(2, r);
  }

  static int _holdTargetFor(Movement m) {
    int h = _holdByDifficulty[m.difficulty] ?? 20;

    if (m.category == "mobility") h = max(45, (h * 2).round());
    if (m.category == "rings") h = max(5, (h * 0.8).round());
    if (m.category == "skill") h = max(5, (h * 0.85).round());

    return max(5, h);
  }

  // ---------------------------------------------------------------------------
  // Tier helpers (backwards compat with older UI/services)
  // ---------------------------------------------------------------------------

  // Tier multipliers applied to each movement's base benchmark.
  // Example: push_up base reps 20 -> progress 20, bronze 25, silver 50, gold 100, mastered 200.
  static const double _progressMult = 1.0;
  static const double _bronzeMult = 1.25;
  static const double _silverMult = 2.5;
  static const double _goldMult = 5.0;
  static const double _masteredMult = 10.0;

  static MasteryTarget _scaleTarget(MasteryTarget base, double mult) {
    int scale(int v) => v == 0 ? 0 : max(1, (v * mult).ceil());

    return MasteryTarget(
      reps: scale(base.reps),
      holdSeconds: scale(base.holdSeconds),
      totalXp: scale(base.totalXp),
      mode: base.mode,
    );
  }

  /// Returns tiered targets derived from the base target.
  /// Base target is treated as the "Progress" gate, then scaled up.
  static MasteryTiers tiersForMovementEntity(Movement m) {
    final base = forMovementEntity(m);

    return MasteryTiers(
      progress: _scaleTarget(base, _progressMult),
      bronze: _scaleTarget(base, _bronzeMult),
      silver: _scaleTarget(base, _silverMult),
      gold: _scaleTarget(base, _goldMult),
      mastered: _scaleTarget(base, _masteredMult),
    );
  }

  /// Next target given the current state.
  /// States: locked/unlocked/progress/bronze/silver/gold/mastered
  static MasteryTarget nextTargetForState({
    required Movement movement,
    required String state,
  }) {
    final t = tiersForMovementEntity(movement);

    switch (state) {
      case "mastered":
        return t.mastered;
      case "gold":
        return t.mastered;
      case "silver":
        return t.gold;
      case "bronze":
        return t.silver;
      case "progress":
        return t.bronze;
      case "unlocked":
      case "locked":
      default:
        return t.progress;
    }
  }

  /// Highest tier whose requirements are fully met.
  static String highestTierStateMet({
    required Movement movement,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementTotalXp,
  }) {
    final t = tiersForMovementEntity(movement);

    bool ok(MasteryTarget target) => target.isMet(
      bestReps: bestReps,
      bestHoldSeconds: bestHoldSeconds,
      movementTotalXp: movementTotalXp,
    );

    if (ok(t.mastered)) return "mastered";
    if (ok(t.gold)) return "gold";
    if (ok(t.silver)) return "silver";
    if (ok(t.bronze)) return "bronze";
    if (ok(t.progress)) return "progress";
    return "unlocked";
  }
}
