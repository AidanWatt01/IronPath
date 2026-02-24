import "package:flutter_test/flutter_test.dart";
import "package:drift/drift.dart";

import "package:cali_skill_tree/domain/daily_quest_catalog.dart";
import "package:cali_skill_tree/domain/daily_quest_service.dart";
import "package:cali_skill_tree/domain/weekly_quest_service.dart";
import "package:cali_skill_tree/domain/log_session_service.dart";
import "package:cali_skill_tree/data/db/app_db.dart";

import "helpers/test_utils.dart";

DateTime _weekStart(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  return d.subtract(Duration(days: d.weekday - DateTime.monday));
}

Future<void> _ensureMetricMovement(
  AppDb db, {
  required String movementId,
}) async {
  await db
      .into(db.movements)
      .insert(
        MovementsCompanion.insert(
          id: movementId,
          name: "Quest Metric Movement",
          category: "push",
          difficulty: 1,
          xpToUnlock: const Value(0),
          baseXp: const Value(5),
          xpPerRep: const Value(1),
          xpPerSecond: const Value(0),
          sortOrder: const Value(1),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

Future<void> _insertUnlockCandidate(
  AppDb db, {
  required String movementId,
}) async {
  await db
      .into(db.movements)
      .insert(
        MovementsCompanion.insert(
          id: movementId,
          name: "Unlock Candidate",
          category: "skill",
          difficulty: 2,
          xpToUnlock: const Value(1),
          baseXp: const Value(5),
          xpPerRep: const Value(1),
          xpPerSecond: const Value(0),
          sortOrder: const Value(2),
        ),
        mode: InsertMode.insertOrIgnore,
      );

  await db
      .into(db.movementProgresses)
      .insert(
        MovementProgressesCompanion.insert(
          movementId: movementId,
          state: const Value("locked"),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}

Future<void> _satisfyDailyMetric({
  required AppDb db,
  required DailyQuestMetric metric,
  required int target,
  required DateTime day,
  required String movementId,
}) async {
  final startedAt = DateTime(day.year, day.month, day.day, 12, 0, 0);

  switch (metric) {
    case DailyQuestMetric.workoutsCount:
      for (var i = 0; i < target; i++) {
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                startedAt: startedAt.add(Duration(minutes: i)),
                durationSeconds: const Value(60),
              ),
            );
      }
      break;
    case DailyQuestMetric.workoutXp:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: const Value(60),
              sets: const Value(1),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: Value(target),
            ),
          );
      break;
    case DailyQuestMetric.totalSets:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: const Value(60),
              sets: Value(target),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: const Value(10),
            ),
          );
      break;
    case DailyQuestMetric.trainingSeconds:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: Value(target),
              sets: const Value(1),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: const Value(10),
            ),
          );
      break;
    case DailyQuestMetric.goalMovementSessions:
      throw StateError("Goal metric not used in this test helper.");
  }
}

Future<void> _satisfyWeeklyMetric({
  required AppDb db,
  required DailyQuestMetric metric,
  required int target,
  required DateTime weekStart,
  required String movementId,
}) async {
  final startedAt = DateTime(
    weekStart.year,
    weekStart.month,
    weekStart.day,
    12,
    0,
    0,
  );

  switch (metric) {
    case DailyQuestMetric.workoutsCount:
      for (var i = 0; i < target; i++) {
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                startedAt: startedAt.add(Duration(hours: i)),
                durationSeconds: const Value(60),
              ),
            );
      }
      break;
    case DailyQuestMetric.workoutXp:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: const Value(60),
              sets: const Value(1),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: Value(target),
            ),
          );
      break;
    case DailyQuestMetric.totalSets:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: const Value(60),
              sets: Value(target),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: const Value(10),
            ),
          );
      break;
    case DailyQuestMetric.trainingSeconds:
      await _ensureMetricMovement(db, movementId: movementId);
      await db
          .into(db.sessions)
          .insert(
            SessionsCompanion.insert(
              movementId: movementId,
              startedAt: startedAt,
              durationSeconds: Value(target),
              sets: const Value(1),
              reps: const Value(1),
              holdSeconds: const Value(0),
              formScore: const Value(8),
              xpEarned: const Value(10),
            ),
          );
      break;
    case DailyQuestMetric.goalMovementSessions:
      throw StateError("Goal metric not used in this test helper.");
  }
}

void main() {
  group("phase 2.1 game loop hardening", () {
    late AppDb db;

    setUp(() async {
      db = createTestDb();
      await ensureUserStats(db, coins: 2000);
    });

    tearDown(() async {
      await db.close();
    });

    test("daily claims are one-time per date and reset next day", () async {
      final day = DateTime(2026, 3, 10);

      final first = await db.tryClaimDailyQuest(
        questId: "daily_test_claim",
        day: day,
        rewardXp: 100,
        rewardCoins: 40,
      );
      expect(first.claimed, isTrue);

      final second = await db.tryClaimDailyQuest(
        questId: "daily_test_claim",
        day: day,
        rewardXp: 100,
        rewardCoins: 40,
      );
      expect(second.claimed, isFalse);
      expect(second.failureReason, contains("Already claimed today"));

      final nextDay = day.add(const Duration(days: 1));
      final third = await db.tryClaimDailyQuest(
        questId: "daily_test_claim",
        day: nextDay,
        rewardXp: 100,
        rewardCoins: 40,
      );
      expect(third.claimed, isTrue);
    });

    test(
      "weekly claims are one-time per week key and reset next week",
      () async {
        final first = await db.tryClaimQuestReward(
          questId: "weekly_test_claim",
          claimKey: "week:2026-03-09",
          rewardXp: 300,
          rewardCoins: 120,
          alreadyClaimedReason: "Already claimed this week.",
        );
        expect(first.claimed, isTrue);

        final second = await db.tryClaimQuestReward(
          questId: "weekly_test_claim",
          claimKey: "week:2026-03-09",
          rewardXp: 300,
          rewardCoins: 120,
          alreadyClaimedReason: "Already claimed this week.",
        );
        expect(second.claimed, isFalse);
        expect(second.failureReason, contains("Already claimed this week"));

        final nextWeek = await db.tryClaimQuestReward(
          questId: "weekly_test_claim",
          claimKey: "week:2026-03-16",
          rewardXp: 300,
          rewardCoins: 120,
          alreadyClaimedReason: "Already claimed this week.",
        );
        expect(nextWeek.claimed, isTrue);
      },
    );

    test(
      "weekly reroll uses one free roll then escalating coin costs",
      () async {
        final clock = MutableClock(DateTime(2026, 3, 11, 9));
        final service = WeeklyQuestService(db, nowProvider: clock.now);

        final info0 = await service.getRerollInfo();
        expect(info0.freeRerollAvailable, isTrue);
        expect(info0.nextCoinCost, 0);

        final r1 = await service.rerollThisWeek();
        expect(r1.success, isTrue);

        final after1 = await (db.select(
          db.userStats,
        )..where((s) => s.id.equals(1))).getSingle();
        expect(after1.coins, 2000);

        final info1 = await service.getRerollInfo();
        expect(info1.freeRerollAvailable, isFalse);
        expect(info1.nextCoinCost, 100);

        final r2 = await service.rerollThisWeek();
        expect(r2.success, isTrue);

        final after2 = await (db.select(
          db.userStats,
        )..where((s) => s.id.equals(1))).getSingle();
        expect(after2.coins, 1900);

        final info2 = await service.getRerollInfo();
        expect(info2.nextCoinCost, 150);

        final r3 = await service.rerollThisWeek();
        expect(r3.success, isTrue);

        final after3 = await (db.select(
          db.userStats,
        )..where((s) => s.id.equals(1))).getSingle();
        expect(after3.coins, 1750);
      },
    );

    test(
      "coin booster pack can be bought and consumes one use per log",
      () async {
        await ensureUserStats(db, coins: 500);

        final purchase = await db.tryBuyBoostPack(
          metaKey: AppDb.xpBoostUsesMetaKey,
          costCoins: 120,
          addUses: 3,
        );
        expect(purchase.success, isTrue);

        await db
            .into(db.movements)
            .insert(
              MovementsCompanion.insert(
                id: "test_movement",
                name: "Test Movement",
                category: "push",
                difficulty: 3,
                xpToUnlock: const Value(0),
                baseXp: const Value(10),
                xpPerRep: const Value(1),
                xpPerSecond: const Value(0),
                sortOrder: const Value(1),
              ),
              mode: InsertMode.insertOrReplace,
            );

        await db
            .into(db.movementProgresses)
            .insert(
              MovementProgressesCompanion.insert(
                movementId: "test_movement",
                state: const Value("unlocked"),
              ),
              mode: InsertMode.insertOrReplace,
            );

        final log = await LogSessionService(db).log(
          movementId: "test_movement",
          sets: 1,
          reps: 10,
          holdSeconds: 0,
          durationSeconds: 30,
          formScore: 10,
          startedAt: DateTime(2026, 3, 12, 10),
        );

        expect(log.xpEarned, 35);

        final status = await db.getCoinBoostStatus();
        expect(status.xpBoostUses, 2);

        final stats = await (db.select(
          db.userStats,
        )..where((s) => s.id.equals(1))).getSingle();
        expect(stats.coins, greaterThan(380));
      },
    );

    test("cosmetic purchase deducts coins and can be equipped", () async {
      await ensureUserStats(db, coins: 500);

      final purchase = await db.tryBuyCosmetic(
        cosmeticId: "ember_frame",
        costCoins: 140,
      );
      expect(purchase.success, isTrue);
      expect(purchase.newCoins, 360);
      expect(purchase.ownedCosmeticIds.contains("ember_frame"), isTrue);

      final equippedOk = await db.trySetEquippedCosmeticId("ember_frame");
      expect(equippedOk, isTrue);

      final status = await db.getCosmeticStatus();
      expect(status.ownedCosmeticIds.contains("ember_frame"), isTrue);
      expect(status.equippedCosmeticId, "ember_frame");
    });

    test("daily quest claim recomputes unlocks immediately", () async {
      final day = DateTime(2026, 3, 10, 9, 0, 0);
      final service = DailyQuestService(db, nowProvider: () => day);

      await _insertUnlockCandidate(db, movementId: "daily_unlock_target");

      final before = await (db.select(
        db.movementProgresses,
      )..where((p) => p.movementId.equals("daily_unlock_target"))).getSingle();
      expect(before.state, "locked");

      final quests = await service.watchTodayQuests(goalMovementId: null).first;
      final quest = quests.firstWhere((q) => !q.quest.requiresGoal);

      await _satisfyDailyMetric(
        db: db,
        metric: quest.quest.metric,
        target: quest.target,
        day: day,
        movementId: "daily_metric_probe",
      );

      final result = await service.claimTodayQuest(
        questId: quest.quest.id,
        goalMovementId: null,
      );
      expect(result.claimed, isTrue);

      final after = await (db.select(
        db.movementProgresses,
      )..where((p) => p.movementId.equals("daily_unlock_target"))).getSingle();
      expect(after.state, "unlocked");
    });

    test("weekly quest claim recomputes unlocks immediately", () async {
      final now = DateTime(2026, 3, 11, 9, 0, 0);
      final service = WeeklyQuestService(db, nowProvider: () => now);

      await _insertUnlockCandidate(db, movementId: "weekly_unlock_target");

      final before = await (db.select(
        db.movementProgresses,
      )..where((p) => p.movementId.equals("weekly_unlock_target"))).getSingle();
      expect(before.state, "locked");

      final quests = await service
          .watchThisWeekQuests(goalMovementId: null)
          .first;
      final quest = quests.firstWhere((q) => !q.quest.requiresGoal);

      await _satisfyWeeklyMetric(
        db: db,
        metric: quest.quest.metric,
        target: quest.target,
        weekStart: _weekStart(now),
        movementId: "weekly_metric_probe",
      );

      final result = await service.claimThisWeekQuest(
        questId: quest.quest.id,
        goalMovementId: null,
      );
      expect(result.claimed, isTrue);

      final after = await (db.select(
        db.movementProgresses,
      )..where((p) => p.movementId.equals("weekly_unlock_target"))).getSingle();
      expect(after.state, "unlocked");
    });
  });
}
