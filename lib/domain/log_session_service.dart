import "dart:math";

import "package:drift/drift.dart";

import "../data/db/app_db.dart";
import "mastery_rules.dart";
import "unlock_service.dart";
import "movement_tier.dart";
import "perk_catalog.dart";

class LogResult {
  const LogResult({
    required this.xpEarned,
    required this.coinsEarned,
    required this.perkPointsEarned,
    required this.levelsGained,
    required this.becameMastered,
    required this.newlyUnlockedMovementIds,
    required this.newTotalXp,
    required this.newLevel,
    required this.newCoins,
    required this.newPerkPoints,
  });

  final int xpEarned;
  final int coinsEarned;
  final int perkPointsEarned;
  final int levelsGained;
  final bool becameMastered;
  final List<String> newlyUnlockedMovementIds;
  final int newTotalXp;
  final int newLevel;
  final int newCoins;
  final int newPerkPoints;
}

class LogSessionService {
  LogSessionService(this.db);

  final AppDb db;

  int _levelFromXp(int totalXp) {
    return max(1, (sqrt(totalXp / 100.0).floor() + 1));
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isYesterday(DateTime today, DateTime last) {
    final y = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 1));
    final l = DateTime(last.year, last.month, last.day);
    return _sameDay(y, l);
  }

  // XP is for the whole “work” you did: sets * reps/hold.
  // Best reps/hold are still tracked as best single-set (your input reps/hold).
  int _xpForSession({
    required Movement m,
    required int sets,
    required int repsPerSet,
    required int holdSecondsPerSet,
    required int formScore,
  }) {
    final base = m.baseXp;

    final repsTotal = repsPerSet * sets;
    final holdTotal = holdSecondsPerSet * sets;

    final work = repsTotal * m.xpPerRep + holdTotal * m.xpPerSecond;

    final t = (formScore.clamp(0, 10)) / 10.0;
    final mult = 0.6 + (1.4 - 0.6) * t; // 0.6 + 0.8*t

    return max(0, ((base + work) * mult).round());
  }

  Future<LogResult> log({
    required String movementId,

    // NEW: Sets. Defaults to 1 so older call sites won’t break.
    int sets = 1,

    // These are PER-SET values.
    required int reps,
    required int holdSeconds,

    // durationSeconds is total duration for this “session log”.
    // For holds, you probably pass holdSeconds*sets.
    required int durationSeconds,

    required int formScore,
    int? workoutId,
    int setIndex = 0,
    DateTime? startedAt,
    String? notes,
  }) async {
    return await db.transaction(() async {
      final now = startedAt ?? DateTime.now();

      final m = await (db.select(
        db.movements,
      )..where((x) => x.id.equals(movementId))).getSingle();

      final prog = await (db.select(
        db.movementProgresses,
      )..where((p) => p.movementId.equals(movementId))).getSingle();

      if (prog.state == "locked") {
        throw Exception("Movement is locked.");
      }

      final preStats = await (db.select(
        db.userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      final safeSets = sets.clamp(1, 99);
      final repsPerSet = reps.clamp(0, 999);
      final holdPerSet = holdSeconds.clamp(0, 9999);
      final safeDuration = durationSeconds.clamp(0, 99999);
      final safeForm = formScore.clamp(0, 10);

      final baseXp = _xpForSession(
        m: m,
        sets: safeSets,
        repsPerSet: repsPerSet,
        holdSecondsPerSet: holdPerSet,
        formScore: safeForm,
      );

      final perkLevels = await db.getPerkLevels();
      final momentumLv = perkLevels[PerkCatalog.momentum.id] ?? 0;
      final specialistLv = perkLevels[PerkCatalog.specialist.id] ?? 0;
      final collectorLv = perkLevels[PerkCatalog.collector.id] ?? 0;
      final technicianLv = perkLevels[PerkCatalog.technician.id] ?? 0;
      final volumeEngineLv = perkLevels[PerkCatalog.volumeEngine.id] ?? 0;
      final finisherLv = perkLevels[PerkCatalog.finisher.id] ?? 0;
      final streakSurgeLv = perkLevels[PerkCatalog.streakSurge.id] ?? 0;
      final holdSpecialistLv = perkLevels[PerkCatalog.holdSpecialist.id] ?? 0;
      final masteryHunterLv = perkLevels[PerkCatalog.masteryHunter.id] ?? 0;
      final timekeeperLv = perkLevels[PerkCatalog.timekeeper.id] ?? 0;

      bool firstWorkoutOfDay = false;
      if (workoutId != null) {
        final priorWorkouts = await db.countWorkoutsOnDay(
          day: now,
          excludingWorkoutId: workoutId,
        );
        firstWorkoutOfDay = priorWorkouts == 0;
      } else {
        final priorSessions = await db.countSessionsOnDay(day: now);
        firstWorkoutOfDay = priorSessions == 0;
      }

      final goalMovementId = await db.getGoalMovementId();
      final isGoalMovement = goalMovementId == movementId;
      final isHoldMovement = m.xpPerSecond > 0;
      final isNonMasteredMovement = prog.state != "mastered";
      final boostStatus = await db.getCoinBoostStatus();
      final hasXpBoost = boostStatus.xpBoostUses > 0;
      final hasCoinBoost = boostStatus.coinBoostUses > 0;

      var xpMult = 1.0;
      if (firstWorkoutOfDay && momentumLv > 0) {
        xpMult += (0.10 * momentumLv);
      }
      if (isGoalMovement && specialistLv > 0) {
        xpMult += (0.05 * specialistLv);
      }
      if (safeForm >= 8 && technicianLv > 0) {
        xpMult += (0.05 * technicianLv);
      }
      if (safeSets >= 3 && volumeEngineLv > 0) {
        xpMult += (0.04 * volumeEngineLv);
      }
      if (preStats.currentStreak >= 3 && streakSurgeLv > 0) {
        xpMult += (0.03 * streakSurgeLv);
      }
      if (isHoldMovement && holdSpecialistLv > 0) {
        xpMult += (0.06 * holdSpecialistLv);
      }
      if (isNonMasteredMovement && masteryHunterLv > 0) {
        xpMult += (0.04 * masteryHunterLv);
      }
      if (hasXpBoost) {
        xpMult += 0.25;
      }

      final xp = max(0, (baseXp * xpMult).round());
      final baseCoins = max(1, (xp / 10.0).round());
      var coinMult = 1.0 + (0.10 * collectorLv);
      if (xp >= 80 && finisherLv > 0) {
        coinMult += (0.05 * finisherLv);
      }
      if (safeDuration >= 90 && timekeeperLv > 0) {
        coinMult += (0.05 * timekeeperLv);
      }
      final boostedCoinMult = hasCoinBoost ? (coinMult + 0.35) : coinMult;
      final sessionCoins = max(1, (baseCoins * boostedCoinMult).round());

      // 1) Insert session (single row represents: sets x reps/hold)
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              workoutId: Value(workoutId),
              setIndex: Value(max(0, setIndex)),
              startedAt: now,
              durationSeconds: Value(safeDuration),
              sets: Value(safeSets), // ✅ requires Sessions.sets column
              reps: Value(repsPerSet),
              holdSeconds: Value(holdPerSet),
              formScore: Value(safeForm),
              notes: Value(notes),
              xpEarned: Value(xp),
            ),
          );

      // 2) Update movement progress (XP + best single-set + tier)
      final newTotalXpForMovement = prog.totalXp + xp;
      final newBestReps = max(prog.bestReps, repsPerSet); // best set
      final newBestHoldSeconds = max(
        prog.bestHoldSeconds,
        holdPerSet,
      ); // best set
      final newBestFormScore = max(prog.bestFormScore, safeForm);

      // Compute highest tier met (unlocked/progress/bronze/silver/gold/mastered)
      final computedTier = MasteryRules.highestTierStateMet(
        movement: m,
        bestReps: newBestReps,
        bestHoldSeconds: newBestHoldSeconds,
        movementTotalXp: newTotalXpForMovement,
      );

      // Never downgrade
      final oldRank = tierRankFromState(prog.state);
      final newRank = tierRankFromState(computedTier);
      final upgradedState = (newRank > oldRank) ? computedTier : prog.state;

      final becameMastered =
          (tierRankFromState(prog.state) < tierRankFromState("mastered")) &&
          (tierRankFromState(upgradedState) == tierRankFromState("mastered"));

      final update = MovementProgressesCompanion(
        totalXp: Value(newTotalXpForMovement),
        bestReps: Value(newBestReps),
        bestHoldSeconds: Value(newBestHoldSeconds),
        bestFormScore: Value(newBestFormScore),
        state: Value(upgradedState),
      );

      await (db.update(
        db.movementProgresses,
      )..where((p) => p.movementId.equals(movementId))).write(
        (upgradedState == "mastered" && prog.masteredAt == null)
            ? update.copyWith(masteredAt: Value(now))
            : update,
      );

      // 3) Update user stats (XP + streak + level)
      final stats = await (db.select(
        db.userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      final nowDay = DateTime(now.year, now.month, now.day);

      int streak = stats.currentStreak;
      final last = stats.lastActiveDate;

      if (last == null) {
        streak = 1;
      } else {
        final lastDay = DateTime(last.year, last.month, last.day);

        if (_sameDay(nowDay, lastDay)) {
          // keep streak
        } else if (_isYesterday(nowDay, lastDay)) {
          streak += 1;
        } else {
          streak = 1;
        }
      }

      final totalXp = stats.totalXp + xp;
      final level = _levelFromXp(totalXp);
      final levelsGained = max(0, level - stats.level);
      final perkPointsEarned = levelsGained;
      final levelUpCoins = levelsGained * 25;
      final coinsEarned = sessionCoins + levelUpCoins;
      final newCoins = stats.coins + coinsEarned;
      final newPerkPoints = stats.perkPoints + perkPointsEarned;
      final bestStreak = max(stats.bestStreak, streak);

      await (db.update(db.userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(
          totalXp: Value(totalXp),
          level: Value(level),
          perkPoints: Value(newPerkPoints),
          coins: Value(newCoins),
          currentStreak: Value(streak),
          bestStreak: Value(bestStreak),
          lastActiveDate: Value(now),
        ),
      );

      await db.consumeCoinBoostUses(
        consumeXpBoost: hasXpBoost,
        consumeCoinBoost: hasCoinBoost,
      );

      // 4) Badges
      await _awardBadges();

      // 5) Deterministic unlock recompute (fixpoint)
      final unlockResult = await UnlockService(db).recomputeAndApply(now: now);

      return LogResult(
        xpEarned: xp,
        coinsEarned: coinsEarned,
        perkPointsEarned: perkPointsEarned,
        levelsGained: levelsGained,
        becameMastered: becameMastered,
        newlyUnlockedMovementIds: unlockResult.unlockedMovementIds,
        newTotalXp: totalXp,
        newLevel: level,
        newCoins: newCoins,
        newPerkPoints: newPerkPoints,
      );
    });
  }

  Future<void> _awardBadges() async {
    final stats = await (db.select(
      db.userStats,
    )..where((s) => s.id.equals(1))).getSingle();

    // Load earned badge ids once (avoid N queries)
    final earnedRows = await db.select(db.userBadges).get();
    final earned = earnedRows.map((x) => x.badgeId).toSet();

    Future<void> give(String id) async {
      if (earned.contains(id)) return;

      await db
          .into(db.userBadges)
          .insert(
            UserBadgesCompanion.insert(badgeId: id, earnedAt: DateTime.now()),
            mode: InsertMode.insertOrIgnore,
          );

      earned.add(id);
    }

    Future<void> giveIf(String id, bool condition) async {
      if (condition) await give(id);
    }

    Future<int> _countSessions() async {
      final q = db.selectOnly(db.sessions)
        ..addColumns([db.sessions.id.count()]);
      final row = await q.getSingle();
      return row.read(db.sessions.id.count()) ?? 0;
    }

    Future<int> _sumDurationSecondsAll() async {
      final q = db.selectOnly(db.sessions)
        ..addColumns([db.sessions.durationSeconds.sum()]);
      final row = await q.getSingle();
      return row.read(db.sessions.durationSeconds.sum()) ?? 0;
    }

    // ✅ Volume-aware reps sum: reps * sets
    Future<int> _sumRepsFor(String movementId) async {
      final volumeExpr = db.sessions.reps * db.sessions.sets;
      final sumExpr = volumeExpr.sum();

      final q = db.selectOnly(db.sessions)
        ..addColumns([sumExpr])
        ..where(db.sessions.movementId.equals(movementId));

      final row = await q.getSingle();
      return row.read(sumExpr) ?? 0;
    }

    // ✅ Volume-aware hold sum: holdSeconds * sets
    Future<int> _sumHoldFor(String movementId) async {
      final volumeExpr = db.sessions.holdSeconds * db.sessions.sets;
      final sumExpr = volumeExpr.sum();

      final q = db.selectOnly(db.sessions)
        ..addColumns([sumExpr])
        ..where(db.sessions.movementId.equals(movementId));

      final row = await q.getSingle();
      return row.read(sumExpr) ?? 0;
    }

    // Pull movement progresses (small table, cheap)
    final progresses = await db.select(db.movementProgresses).get();
    final progressById = <String, MovementProgress>{
      for (final p in progresses) p.movementId: p,
    };

    int masteredCount = 0;
    int unlockedCount = 0;
    int goldCount = 0;
    for (final p in progresses) {
      final rank = tierRankFromState(p.state);
      if (p.state != "locked") unlockedCount += 1;
      if (p.state == "mastered") masteredCount += 1;
      if (rank >= tierRankFromState("gold")) goldCount += 1;
    }

    // -------------------------
    // Aggregate stats
    // -------------------------
    final sessionsCount = await _countSessions();
    final totalDurationSec = await _sumDurationSecondsAll();
    final totalHours = totalDurationSec / 3600.0;

    // -------------------------
    // ONBOARDING
    // -------------------------
    await giveIf("first_session", sessionsCount >= 1);
    await giveIf("first_unlocked", unlockedCount >= 1);
    await giveIf("first_mastery", masteredCount >= 1);

    // -------------------------
    // SESSIONS
    // -------------------------
    await giveIf("ten_sessions", sessionsCount >= 10);
    await giveIf("sessions_25", sessionsCount >= 25);
    await giveIf("sessions_50", sessionsCount >= 50);
    await giveIf("sessions_100", sessionsCount >= 100);
    await giveIf("sessions_250", sessionsCount >= 250);
    await giveIf("sessions_500", sessionsCount >= 500);
    await giveIf("sessions_1000", sessionsCount >= 1000);

    // -------------------------
    // STREAKS
    // -------------------------
    await giveIf("streak_3", stats.currentStreak >= 3);
    await giveIf("streak_7", stats.currentStreak >= 7);
    await giveIf("streak_14", stats.currentStreak >= 14);
    await giveIf("streak_30", stats.currentStreak >= 30);
    await giveIf("streak_60", stats.currentStreak >= 60);
    await giveIf("streak_100", stats.currentStreak >= 100);

    // -------------------------
    // XP + LEVEL
    // -------------------------
    await giveIf("xp_100", stats.totalXp >= 100);
    await giveIf("xp_500", stats.totalXp >= 500);
    await giveIf("xp_1000", stats.totalXp >= 1000);
    await giveIf("xp_2500", stats.totalXp >= 2500);
    await giveIf("xp_5000", stats.totalXp >= 5000);
    await giveIf("xp_10000", stats.totalXp >= 10000);
    await giveIf("xp_20000", stats.totalXp >= 20000);
    await giveIf("xp_50000", stats.totalXp >= 50000);

    await giveIf("level_5", stats.level >= 5);
    await giveIf("level_10", stats.level >= 10);
    await giveIf("level_20", stats.level >= 20);
    await giveIf("level_30", stats.level >= 30);
    await giveIf("level_40", stats.level >= 40);

    // -------------------------
    // UNLOCK / MASTERY COUNTS
    // -------------------------
    await giveIf("unlocked_10", unlockedCount >= 10);
    await giveIf("unlocked_25", unlockedCount >= 25);
    await giveIf("unlocked_50", unlockedCount >= 50);
    await giveIf("unlocked_75", unlockedCount >= 75);

    await giveIf("mastered_1", masteredCount >= 1);
    await giveIf("mastered_3", masteredCount >= 3);
    await giveIf("mastered_5", masteredCount >= 5);
    await giveIf("mastered_10", masteredCount >= 10);
    await giveIf("mastered_20", masteredCount >= 20);
    await giveIf("mastered_30", masteredCount >= 30);

    // -------------------------
    // TRAINING TIME
    // -------------------------
    await giveIf("time_1h", totalHours >= 1);
    await giveIf("time_10h", totalHours >= 10);
    await giveIf("time_50h", totalHours >= 50);
    await giveIf("time_100h", totalHours >= 100);

    // -------------------------
    // PULL-UP: totals + best
    // -------------------------
    final pullUpTotal = await _sumRepsFor("pull_up");
    final pullUpBest = progressById["pull_up"]?.bestReps ?? 0;

    await giveIf("first_pull_up", pullUpBest >= 1);
    await giveIf("pullup_total_10", pullUpTotal >= 10);
    await giveIf("pullup_total_100", pullUpTotal >= 100);
    await giveIf("pullup_total_500", pullUpTotal >= 500);
    await giveIf("pullup_total_1000", pullUpTotal >= 1000);
    await giveIf("pullup_total_5000", pullUpTotal >= 5000);
    await giveIf("pullup_total_10000", pullUpTotal >= 10000);

    await giveIf("pullup_best_5", pullUpBest >= 5);
    await giveIf("pullup_best_10", pullUpBest >= 10);
    await giveIf("pullup_best_15", pullUpBest >= 15);
    await giveIf("pullup_best_20", pullUpBest >= 20);

    // -------------------------
    // PUSH-UP: totals + best
    // -------------------------
    final pushUpTotal = await _sumRepsFor("push_up");
    final pushUpBest = progressById["push_up"]?.bestReps ?? 0;

    await giveIf("pushup_total_100", pushUpTotal >= 100);
    await giveIf("pushup_total_500", pushUpTotal >= 500);
    await giveIf("pushup_total_1000", pushUpTotal >= 1000);
    await giveIf("pushup_total_5000", pushUpTotal >= 5000);
    await giveIf("pushup_total_10000", pushUpTotal >= 10000);

    await giveIf("pushup_best_25", pushUpBest >= 25);
    await giveIf("pushup_best_50", pushUpBest >= 50);
    await giveIf("pushup_best_75", pushUpBest >= 75);
    await giveIf("pushup_best_100", pushUpBest >= 100);

    // -------------------------
    // SQUAT: totals (bodyweight_squat)
    // -------------------------
    final squatTotal = await _sumRepsFor("bodyweight_squat");
    await giveIf("squat_total_200", squatTotal >= 200);
    await giveIf("squat_total_500", squatTotal >= 500);
    await giveIf("squat_total_1000", squatTotal >= 1000);
    await giveIf("squat_total_5000", squatTotal >= 5000);
    await giveIf("squat_total_10000", squatTotal >= 10000);

    // -------------------------
    // PLANK: best + total hold seconds
    // -------------------------
    final plankBest = progressById["plank"]?.bestHoldSeconds ?? 0;
    final plankTotalHold = await _sumHoldFor("plank");

    await giveIf("plank_best_60", plankBest >= 60);
    await giveIf("plank_best_120", plankBest >= 120);
    await giveIf("plank_best_300", plankBest >= 300);
    await giveIf("plank_best_600", plankBest >= 600);

    await giveIf("plank_total_600", plankTotalHold >= 600);
    await giveIf("plank_total_3600", plankTotalHold >= 3600);
    await giveIf("plank_total_10800", plankTotalHold >= 10800);

    // -------------------------
    // WALL HANDSTAND: best hold seconds
    // -------------------------
    final whBest = progressById["wall_handstand"]?.bestHoldSeconds ?? 0;
    await giveIf("wall_handstand_best_30", whBest >= 30);
    await giveIf("wall_handstand_best_60", whBest >= 60);
    await giveIf("wall_handstand_best_120", whBest >= 120);

    // -------------------------
    // SKILL MILESTONES (logged/mastered)
    // -------------------------
    final freeHsXp = progressById["freestanding_handstand"]?.totalXp ?? 0;
    await giveIf("first_free_handstand", freeHsXp > 0);

    final barMuBest = progressById["bar_muscle_up"]?.bestReps ?? 0;
    await giveIf("first_bar_muscle_up", barMuBest >= 1);

    final ringMuBest = progressById["ring_muscle_up"]?.bestReps ?? 0;
    await giveIf("first_ring_muscle_up", ringMuBest >= 1);

    final frontLeverMastered =
        (progressById["front_lever"]?.state ?? "locked") == "mastered";
    final plancheMastered =
        (progressById["planche"]?.state ?? "locked") == "mastered";

    await giveIf("front_lever_mastered", frontLeverMastered);
    await giveIf("planche_mastered", plancheMastered);

    // -------------------------
    // UNIQUE CHALLENGES
    // -------------------------
    await giveIf(
      "challenge_upper_balance",
      pullUpTotal >= 100 && pushUpTotal >= 1000,
    );
    await giveIf(
      "challenge_core_legs",
      squatTotal >= 2000 && plankTotalHold >= 3600,
    );
    await giveIf("challenge_static_control", plankBest >= 240 && whBest >= 90);
    await giveIf(
      "challenge_skill_trio",
      freeHsXp > 0 && barMuBest >= 1 && ringMuBest >= 1,
    );
    await giveIf(
      "challenge_all_rounder",
      pullUpBest >= 10 &&
          pushUpBest >= 50 &&
          squatTotal >= 1000 &&
          plankBest >= 120,
    );
    await giveIf(
      "challenge_engine_room",
      sessionsCount >= 200 && totalHours >= 100,
    );
    await giveIf("challenge_gold_collector_20", goldCount >= 20);
    await giveIf("challenge_elite_duo", frontLeverMastered && plancheMastered);

    // -------------------------
    // PER-MOVEMENT BADGES (all exercises)
    // -------------------------
    for (final p in progresses) {
      final rank = tierRankFromState(p.state);
      await giveIf("movement_${p.movementId}_logged", p.totalXp > 0);
      await giveIf(
        "movement_${p.movementId}_bronze",
        rank >= tierRankFromState("bronze"),
      );
      await giveIf(
        "movement_${p.movementId}_silver",
        rank >= tierRankFromState("silver"),
      );
      await giveIf(
        "movement_${p.movementId}_gold",
        rank >= tierRankFromState("gold"),
      );
      await giveIf("movement_${p.movementId}_mastered", p.state == "mastered");
    }
  }
}
