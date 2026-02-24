import "dart:math";

import "package:drift/drift.dart";

import "app_db_connection.dart";

part "app_db.g.dart";

class Movements extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category =>
      text()(); // push/pull/legs/core/skill/compound/rings/mobility
  IntColumn get difficulty => integer()(); // 1..10
  TextColumn get description => text().withDefault(const Constant(""))();

  IntColumn get xpToUnlock => integer().withDefault(const Constant(0))();
  IntColumn get baseXp => integer().withDefault(const Constant(5))();
  IntColumn get xpPerRep => integer().withDefault(const Constant(1))();
  IntColumn get xpPerSecond => integer().withDefault(const Constant(1))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class MovementPrereqs extends Table {
  TextColumn get movementId => text().references(Movements, #id)();
  TextColumn get prereqMovementId => text().references(Movements, #id)();
  TextColumn get prereqType => text().withDefault(
    const Constant("unlocked"),
  )(); // unlocked/progress/bronze/silver/gold/mastered

  @override
  Set<Column> get primaryKey => {movementId, prereqMovementId};
}

@DataClassName("MovementProgress")
class MovementProgresses extends Table {
  TextColumn get movementId => text().references(Movements, #id)();

  TextColumn get state => text().withDefault(
    const Constant("locked"),
  )(); // locked/unlocked/progress/bronze/silver/gold/mastered
  IntColumn get totalXp => integer().withDefault(const Constant(0))();

  DateTimeColumn get unlockedAt => dateTime().nullable()();
  DateTimeColumn get masteredAt => dateTime().nullable()();

  IntColumn get bestReps => integer().withDefault(const Constant(0))();
  IntColumn get bestHoldSeconds => integer().withDefault(const Constant(0))();
  IntColumn get bestFormScore => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {movementId};
}

// --------------------
// NEW (v4): Workouts (groups multiple set-rows in Sessions)
// --------------------

class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();

  TextColumn get notes => text().nullable()();
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get movementId => text().references(Movements, #id)();

  // NEW (v4)
  IntColumn get workoutId => integer().nullable().references(Workouts, #id)();
  IntColumn get setIndex =>
      integer().withDefault(const Constant(0))(); // 0..N-1
  IntColumn get sets => integer().withDefault(
    const Constant(1),
  )(); // total sets logged for this entry

  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();

  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get holdSeconds => integer().withDefault(const Constant(0))();
  IntColumn get formScore =>
      integer().withDefault(const Constant(7))(); // 0..10

  TextColumn get notes => text().nullable()();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
}

class UserStats extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get perkPoints => integer().withDefault(const Constant(0))();
  IntColumn get coins => integer().withDefault(const Constant(0))();

  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserPerks extends Table {
  TextColumn get perkId => text()();
  IntColumn get level => integer().withDefault(const Constant(0))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {perkId};
}

class DailyQuestClaims extends Table {
  TextColumn get questId => text()();
  TextColumn get claimDate => text()(); // YYYY-MM-DD (local)
  DateTimeColumn get claimedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {questId, claimDate};
}

class Badges extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserBadges extends Table {
  TextColumn get badgeId => text().references(Badges, #id)();
  DateTimeColumn get earnedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {badgeId};
}

// --------------------
// Movement guides (muscles + form)
// --------------------

@DataClassName("MovementGuide")
class MovementGuides extends Table {
  TextColumn get movementId => text().references(Movements, #id)();

  TextColumn get primaryMuscles => text().withDefault(const Constant(""))();
  TextColumn get secondaryMuscles => text().withDefault(const Constant(""))();

  TextColumn get setup => text().withDefault(const Constant(""))();
  TextColumn get execution => text().withDefault(const Constant(""))();
  TextColumn get cues => text().withDefault(const Constant(""))();
  TextColumn get commonMistakes => text().withDefault(const Constant(""))();

  TextColumn get regressions => text().withDefault(const Constant(""))();
  TextColumn get progressions => text().withDefault(const Constant(""))();

  TextColumn get youtubeQuery => text().withDefault(const Constant(""))();

  @override
  Set<Column> get primaryKey => {movementId};
}

// --------------------
// Helper classes for joined results
// --------------------

class MovementWithProgress {
  MovementWithProgress(this.movement, this.progress);

  final Movement movement;
  final MovementProgress progress;
}

class SessionWithMovement {
  SessionWithMovement(this.session, this.movement);

  final Session session;
  final Movement movement;
}

class WorkoutSummary {
  WorkoutSummary({
    required this.workoutId,
    required this.startedAt,
    required this.durationSeconds,
    required this.notes,
    required this.totalXp,
    required this.entryCount,
    required this.totalSets,
    required this.movementCount,
  });

  final int workoutId;
  final DateTime startedAt;
  final int durationSeconds;
  final String? notes;
  final int totalXp;
  final int entryCount;
  final int totalSets;
  final int movementCount;
}

class BadgeWithEarned {
  BadgeWithEarned(this.badge, this.userBadge);

  final Badge badge;
  final UserBadge? userBadge;

  bool get isEarned => userBadge != null;
}

class PerkRespecResult {
  const PerkRespecResult({
    required this.success,
    required this.refundedPoints,
    required this.coinsSpent,
    required this.newPerkPoints,
    required this.newCoins,
    this.message,
  });

  final bool success;
  final int refundedPoints;
  final int coinsSpent;
  final int newPerkPoints;
  final int newCoins;
  final String? message;
}

class DailyQuestClaimResult {
  const DailyQuestClaimResult({
    required this.claimed,
    required this.questId,
    required this.xpEarned,
    required this.coinsEarned,
    required this.perkPointsEarned,
    required this.levelsGained,
    required this.newTotalXp,
    required this.newLevel,
    required this.newCoins,
    required this.newPerkPoints,
    this.failureReason,
  });

  factory DailyQuestClaimResult.failed({
    required String questId,
    required String reason,
  }) {
    return DailyQuestClaimResult(
      claimed: false,
      questId: questId,
      xpEarned: 0,
      coinsEarned: 0,
      perkPointsEarned: 0,
      levelsGained: 0,
      newTotalXp: 0,
      newLevel: 0,
      newCoins: 0,
      newPerkPoints: 0,
      failureReason: reason,
    );
  }

  final bool claimed;
  final String questId;
  final int xpEarned;
  final int coinsEarned;
  final int perkPointsEarned;
  final int levelsGained;
  final int newTotalXp;
  final int newLevel;
  final int newCoins;
  final int newPerkPoints;
  final String? failureReason;
}

class CoinBoostStatus {
  const CoinBoostStatus({
    required this.xpBoostUses,
    required this.coinBoostUses,
  });

  final int xpBoostUses;
  final int coinBoostUses;
}

class BoosterPurchaseResult {
  const BoosterPurchaseResult({
    required this.success,
    required this.message,
    required this.newCoins,
    required this.newUses,
  });

  final bool success;
  final String message;
  final int newCoins;
  final int newUses;
}

class CosmeticStatus {
  const CosmeticStatus({
    required this.ownedCosmeticIds,
    required this.equippedCosmeticId,
  });

  final Set<String> ownedCosmeticIds;
  final String? equippedCosmeticId;
}

class CosmeticPurchaseResult {
  const CosmeticPurchaseResult({
    required this.success,
    required this.message,
    required this.newCoins,
    required this.ownedCosmeticIds,
  });

  final bool success;
  final String message;
  final int newCoins;
  final Set<String> ownedCosmeticIds;
}

@DriftDatabase(
  tables: [
    Movements,
    MovementPrereqs,
    MovementProgresses,
    Workouts, // v4
    Sessions,
    UserStats,
    UserPerks,
    DailyQuestClaims,
    Badges,
    UserBadges,
    MovementGuides, // v3
  ],
)
class AppDb extends _$AppDb {
  AppDb() : super(openAppDbConnection());

  AppDb.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // v2 migration
      if (from < 2) {
        await m.addColumn(movements, movements.description);
        await m.addColumn(movements, movements.baseXp);
        await m.addColumn(movements, movements.xpPerRep);
        await m.addColumn(movements, movements.xpPerSecond);
        await m.addColumn(movements, movements.sortOrder);

        await m.createTable(movementPrereqs);
        await m.createTable(movementProgresses);
        await m.createTable(sessions);
        await m.createTable(userStats);
        await m.createTable(badges);
        await m.createTable(userBadges);
      }

      // v3 migration
      if (from < 3) {
        await m.createTable(movementGuides);
      }

      // v4 migration (workouts + set grouping)
      if (from < 4) {
        await m.createTable(workouts);
        await m.addColumn(sessions, sessions.workoutId);
        await m.addColumn(sessions, sessions.setIndex);
      }

      // v5 migration (add sets column to sessions)
      if (from < 5) {
        await m.addColumn(sessions, sessions.sets);
      }

      // v6 migration (game loop economy/perks)
      if (from < 6) {
        await m.addColumn(userStats, userStats.perkPoints);
        await m.addColumn(userStats, userStats.coins);
        await m.createTable(userPerks);
      }

      // v7 migration (daily quest claims)
      if (from < 7) {
        await m.createTable(dailyQuestClaims);
      }
    },
  );

  int _levelFromXp(int totalXp) {
    return max(1, (sqrt(totalXp / 100.0).floor() + 1));
  }

  DateTime _dayStart(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  DateTime _dayEnd(DateTime day) {
    return _dayStart(day).add(const Duration(days: 1));
  }

  String _dayKey(DateTime day) {
    final d = _dayStart(day);
    final y = d.year.toString().padLeft(4, "0");
    final m = d.month.toString().padLeft(2, "0");
    final dd = d.day.toString().padLeft(2, "0");
    return "$y-$m-$dd";
  }

  // --------------------
  // Watchers
  // --------------------

  Stream<UserStat> watchUserStat() {
    final query = (select(userStats)..where((s) => s.id.equals(1)));
    return query.watchSingleOrNull().map((row) {
      return row ??
          UserStat(
            id: 1,
            totalXp: 0,
            level: 1,
            perkPoints: 0,
            coins: 0,
            currentStreak: 0,
            bestStreak: 0,
            lastActiveDate: null,
          );
    });
  }

  Stream<List<MovementPrereq>> watchAllPrereqs() {
    return select(movementPrereqs).watch();
  }

  Stream<List<MovementWithProgress>> watchMovementsWithProgress() {
    final query =
        select(movements).join([
          leftOuterJoin(
            movementProgresses,
            movementProgresses.movementId.equalsExp(movements.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(movements.sortOrder),
          OrderingTerm.asc(movements.name),
        ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        final m = r.readTable(movements);
        final p =
            r.readTableOrNull(movementProgresses) ??
            MovementProgress(
              movementId: m.id,
              state: "locked",
              totalXp: 0,
              unlockedAt: null,
              masteredAt: null,
              bestReps: 0,
              bestHoldSeconds: 0,
              bestFormScore: 0,
            );

        return MovementWithProgress(m, p);
      }).toList();
    });
  }

  Stream<List<SessionWithMovement>> watchRecentSessions(int limit) {
    final query =
        select(sessions).join([
            innerJoin(movements, movements.id.equalsExp(sessions.movementId)),
          ])
          ..orderBy([
            OrderingTerm.desc(sessions.startedAt),
            OrderingTerm.asc(sessions.setIndex),
          ])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((r) {
        return SessionWithMovement(
          r.readTable(sessions),
          r.readTable(movements),
        );
      }).toList();
    });
  }

  Stream<List<WorkoutSummary>> watchWorkoutSummaries(int limit) {
    final q = customSelect(
      """
      SELECT
        w.id AS workout_id,
        w.started_at AS started_at,
        w.duration_seconds AS duration_seconds,
        w.notes AS notes,
        COALESCE(SUM(s.xp_earned), 0) AS total_xp,
        COALESCE(COUNT(s.id), 0) AS entry_count,
        COALESCE(SUM(s.sets), 0) AS total_sets,
        COALESCE(COUNT(DISTINCT s.movement_id), 0) AS movement_count
      FROM workouts w
      LEFT JOIN sessions s ON s.workout_id = w.id
      GROUP BY w.id, w.started_at, w.duration_seconds, w.notes
      ORDER BY w.started_at DESC
      LIMIT ?
      """,
      variables: [Variable.withInt(limit)],
      readsFrom: {workouts, sessions},
    );

    return q.watch().map((rows) {
      return rows.map((r) {
        final rawStarted = r.data["started_at"];
        final startedAt = _coerceDateTime(rawStarted);

        return WorkoutSummary(
          workoutId: (r.data["workout_id"] as int?) ?? 0,
          startedAt: startedAt,
          durationSeconds: (r.data["duration_seconds"] as int?) ?? 0,
          notes: r.data["notes"] as String?,
          totalXp: (r.data["total_xp"] as int?) ?? 0,
          entryCount: (r.data["entry_count"] as int?) ?? 0,
          totalSets: (r.data["total_sets"] as int?) ?? 0,
          movementCount: (r.data["movement_count"] as int?) ?? 0,
        );
      }).toList();
    });
  }

  DateTime _coerceDateTime(Object? raw) {
    if (raw is DateTime) return raw;

    if (raw is int) {
      final ms = raw > 1000000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    final text = raw?.toString() ?? "";
    final asInt = int.tryParse(text);
    if (asInt != null) {
      final ms = asInt > 1000000000000 ? asInt : asInt * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }

    return DateTime.tryParse(text) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  Stream<List<SessionWithMovement>> watchSessionsForWorkout(int workoutId) {
    final query =
        select(sessions).join([
            innerJoin(movements, movements.id.equalsExp(sessions.movementId)),
          ])
          ..where(sessions.workoutId.equals(workoutId))
          ..orderBy([
            OrderingTerm.asc(sessions.setIndex),
            OrderingTerm.asc(sessions.startedAt),
            OrderingTerm.asc(sessions.id),
          ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return SessionWithMovement(
          r.readTable(sessions),
          r.readTable(movements),
        );
      }).toList();
    });
  }

  Stream<List<SessionWithMovement>> watchRecentSessionsWithoutWorkout(
    int limit,
  ) {
    final query =
        select(sessions).join([
            innerJoin(movements, movements.id.equalsExp(sessions.movementId)),
          ])
          ..where(sessions.workoutId.isNull())
          ..orderBy([
            OrderingTerm.desc(sessions.startedAt),
            OrderingTerm.asc(sessions.setIndex),
          ])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((r) {
        return SessionWithMovement(
          r.readTable(sessions),
          r.readTable(movements),
        );
      }).toList();
    });
  }

  Stream<List<BadgeWithEarned>> watchBadgesWithEarned() {
    final query =
        select(badges).join([
          leftOuterJoin(userBadges, userBadges.badgeId.equalsExp(badges.id)),
        ])..orderBy([
          OrderingTerm.asc(badges.sortOrder),
          OrderingTerm.asc(badges.name),
        ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        return BadgeWithEarned(
          r.readTable(badges),
          r.readTableOrNull(userBadges),
        );
      }).toList();
    });
  }

  Stream<List<UserPerk>> watchUserPerks() {
    final q = select(userPerks)..orderBy([(t) => OrderingTerm.asc(t.perkId)]);
    return q.watch();
  }

  Stream<List<DailyQuestClaim>> watchQuestClaimsForKey(String claimKey) {
    final q =
        (select(dailyQuestClaims)..where((c) => c.claimDate.equals(claimKey)))
          ..orderBy([(c) => OrderingTerm.asc(c.questId)]);
    return q.watch();
  }

  Stream<List<DailyQuestClaim>> watchDailyQuestClaimsForDate(DateTime day) {
    final key = _dayKey(day);
    return watchQuestClaimsForKey(key);
  }

  Future<bool> isQuestClaimedForKey({
    required String questId,
    required String claimKey,
  }) async {
    final row =
        await (select(dailyQuestClaims)..where(
              (c) => c.questId.equals(questId) & c.claimDate.equals(claimKey),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Future<bool> isDailyQuestClaimed({
    required String questId,
    required DateTime day,
  }) async {
    return isQuestClaimedForKey(questId: questId, claimKey: _dayKey(day));
  }

  Future<Map<String, int>> getPerkLevels() async {
    final rows = await select(userPerks).get();
    return <String, int>{for (final p in rows) p.perkId: p.level};
  }

  Future<bool> tryUpgradePerk({
    required String perkId,
    required int maxLevel,
  }) async {
    return transaction(() async {
      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      if (stats.perkPoints <= 0) return false;

      final current = await (select(
        userPerks,
      )..where((p) => p.perkId.equals(perkId))).getSingleOrNull();

      final curLevel = current?.level ?? 0;
      if (curLevel >= maxLevel) return false;

      final nextLevel = curLevel + 1;

      await into(userPerks).insertOnConflictUpdate(
        UserPerksCompanion(
          perkId: Value(perkId),
          level: Value(nextLevel),
          unlockedAt: current == null
              ? Value(DateTime.now())
              : const Value.absent(),
        ),
      );

      await (update(userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(perkPoints: Value(stats.perkPoints - 1)),
      );

      return true;
    });
  }

  Future<PerkRespecResult> tryRespecPerks({required int coinCost}) async {
    return transaction(() async {
      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      final perks = await select(userPerks).get();
      final spentPoints = perks.fold<int>(0, (sum, p) => sum + p.level);

      if (spentPoints <= 0) {
        return const PerkRespecResult(
          success: false,
          refundedPoints: 0,
          coinsSpent: 0,
          newPerkPoints: 0,
          newCoins: 0,
          message: "No spent perk points to respec.",
        );
      }

      if (stats.coins < coinCost) {
        return PerkRespecResult(
          success: false,
          refundedPoints: 0,
          coinsSpent: 0,
          newPerkPoints: stats.perkPoints,
          newCoins: stats.coins,
          message: "Need $coinCost coins to respec.",
        );
      }

      await delete(userPerks).go();

      final newPerkPoints = stats.perkPoints + spentPoints;
      final newCoins = stats.coins - coinCost;

      await (update(userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(
          perkPoints: Value(newPerkPoints),
          coins: Value(newCoins),
        ),
      );

      return PerkRespecResult(
        success: true,
        refundedPoints: spentPoints,
        coinsSpent: coinCost,
        newPerkPoints: newPerkPoints,
        newCoins: newCoins,
      );
    });
  }

  Future<DailyQuestClaimResult> tryClaimQuestReward({
    required String questId,
    required String claimKey,
    required int rewardXp,
    required int rewardCoins,
    required String alreadyClaimedReason,
  }) async {
    return transaction(() async {
      final existing =
          await (select(dailyQuestClaims)..where(
                (c) => c.questId.equals(questId) & c.claimDate.equals(claimKey),
              ))
              .getSingleOrNull();

      if (existing != null) {
        return DailyQuestClaimResult.failed(
          questId: questId,
          reason: alreadyClaimedReason,
        );
      }

      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      final totalXp = stats.totalXp + rewardXp;
      final newLevel = _levelFromXp(totalXp);
      final levelsGained = max(0, newLevel - stats.level);
      final perkPointsEarned = levelsGained;
      final levelUpCoins = levelsGained * 25;
      final totalCoinsEarned = rewardCoins + levelUpCoins;
      final newCoins = stats.coins + totalCoinsEarned;
      final newPerkPoints = stats.perkPoints + perkPointsEarned;

      await into(dailyQuestClaims).insert(
        DailyQuestClaimsCompanion.insert(
          questId: questId,
          claimDate: claimKey,
          claimedAt: DateTime.now(),
        ),
      );

      await (update(userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(
          totalXp: Value(totalXp),
          level: Value(newLevel),
          perkPoints: Value(newPerkPoints),
          coins: Value(newCoins),
        ),
      );

      return DailyQuestClaimResult(
        claimed: true,
        questId: questId,
        xpEarned: rewardXp,
        coinsEarned: totalCoinsEarned,
        perkPointsEarned: perkPointsEarned,
        levelsGained: levelsGained,
        newTotalXp: totalXp,
        newLevel: newLevel,
        newCoins: newCoins,
        newPerkPoints: newPerkPoints,
      );
    });
  }

  Future<DailyQuestClaimResult> tryClaimDailyQuest({
    required String questId,
    required DateTime day,
    required int rewardXp,
    required int rewardCoins,
  }) async {
    return tryClaimQuestReward(
      questId: questId,
      claimKey: _dayKey(day),
      rewardXp: rewardXp,
      rewardCoins: rewardCoins,
      alreadyClaimedReason: "Already claimed today.",
    );
  }

  Future<int> countWorkoutsOnDay({
    required DateTime day,
    int? excludingWorkoutId,
  }) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(workouts)
      ..addColumns([workouts.id.count()])
      ..where(workouts.startedAt.isBiggerOrEqualValue(start))
      ..where(workouts.startedAt.isSmallerThanValue(end));

    if (excludingWorkoutId != null) {
      q.where(workouts.id.isNotValue(excludingWorkoutId));
    }

    final row = await q.getSingle();
    return row.read(workouts.id.count()) ?? 0;
  }

  Future<int> countSessionsOnDay({required DateTime day}) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.id.count()) ?? 0;
  }

  Future<int> countSessionsForMovementOnDay({
    required DateTime day,
    required String movementId,
  }) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end))
      ..where(sessions.movementId.equals(movementId));

    final row = await q.getSingle();
    return row.read(sessions.id.count()) ?? 0;
  }

  Future<int> sumSessionXpOnDay({required DateTime day}) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.xpEarned.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.xpEarned.sum()) ?? 0;
  }

  Future<int> sumSessionSetsOnDay({required DateTime day}) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.sets.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.sets.sum()) ?? 0;
  }

  Future<int> sumSessionDurationOnDay({required DateTime day}) async {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.durationSeconds.sum()) ?? 0;
  }

  Stream<int> watchWorkoutsCountOnDay({required DateTime day}) {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(workouts)
      ..addColumns([workouts.id.count()])
      ..where(workouts.startedAt.isBiggerOrEqualValue(start))
      ..where(workouts.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(workouts.id.count()) ?? 0;
    });
  }

  Stream<int> watchSessionXpSumOnDay({required DateTime day}) {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.xpEarned.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.xpEarned.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionSetSumOnDay({required DateTime day}) {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.sets.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.sets.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionDurationSumOnDay({required DateTime day}) {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.durationSeconds.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionsCountForMovementOnDay({
    required DateTime day,
    required String movementId,
  }) {
    final start = _dayStart(day);
    final end = _dayEnd(day);

    final q = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end))
      ..where(sessions.movementId.equals(movementId));

    return q.watchSingle().map((row) {
      return row.read(sessions.id.count()) ?? 0;
    });
  }

  Future<int> countWorkoutsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final q = selectOnly(workouts)
      ..addColumns([workouts.id.count()])
      ..where(workouts.startedAt.isBiggerOrEqualValue(start))
      ..where(workouts.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(workouts.id.count()) ?? 0;
  }

  Future<int> countSessionsForMovementInRange({
    required DateTime start,
    required DateTime end,
    required String movementId,
  }) async {
    final q = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end))
      ..where(sessions.movementId.equals(movementId));

    final row = await q.getSingle();
    return row.read(sessions.id.count()) ?? 0;
  }

  Future<int> sumSessionXpInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final q = selectOnly(sessions)
      ..addColumns([sessions.xpEarned.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.xpEarned.sum()) ?? 0;
  }

  Future<int> sumSessionSetsInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final q = selectOnly(sessions)
      ..addColumns([sessions.sets.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.sets.sum()) ?? 0;
  }

  Future<int> sumSessionDurationInRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final q = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    final row = await q.getSingle();
    return row.read(sessions.durationSeconds.sum()) ?? 0;
  }

  Stream<int> watchWorkoutsCountInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final q = selectOnly(workouts)
      ..addColumns([workouts.id.count()])
      ..where(workouts.startedAt.isBiggerOrEqualValue(start))
      ..where(workouts.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(workouts.id.count()) ?? 0;
    });
  }

  Stream<int> watchSessionXpSumInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.xpEarned.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.xpEarned.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionSetSumInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.sets.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.sets.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionDurationSumInRange({
    required DateTime start,
    required DateTime end,
  }) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end));

    return q.watchSingle().map((row) {
      return row.read(sessions.durationSeconds.sum()) ?? 0;
    });
  }

  Stream<int> watchSessionsCountForMovementInRange({
    required DateTime start,
    required DateTime end,
    required String movementId,
  }) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.id.count()])
      ..where(sessions.startedAt.isBiggerOrEqualValue(start))
      ..where(sessions.startedAt.isSmallerThanValue(end))
      ..where(sessions.movementId.equals(movementId));

    return q.watchSingle().map((row) {
      return row.read(sessions.id.count()) ?? 0;
    });
  }

  // --------------------
  // Detail watchers
  // --------------------

  Stream<MovementWithProgress> watchMovementWithProgressById(
    String movementId,
  ) {
    final query = select(movements).join([
      leftOuterJoin(
        movementProgresses,
        movementProgresses.movementId.equalsExp(movements.id),
      ),
    ])..where(movements.id.equals(movementId));

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        throw Exception("Movement not found: $movementId");
      }

      final r = rows.first;
      final m = r.readTable(movements);
      final p =
          r.readTableOrNull(movementProgresses) ??
          MovementProgress(
            movementId: m.id,
            state: "locked",
            totalXp: 0,
            unlockedAt: null,
            masteredAt: null,
            bestReps: 0,
            bestHoldSeconds: 0,
            bestFormScore: 0,
          );

      return MovementWithProgress(m, p);
    });
  }

  Stream<List<MovementPrereq>> watchPrereqsForMovement(String movementId) {
    return (select(
      movementPrereqs,
    )..where((p) => p.movementId.equals(movementId))).watch();
  }

  Stream<List<Session>> watchSessionsForMovement(String movementId, int limit) {
    final q = select(sessions)
      ..where((s) => s.movementId.equals(movementId))
      ..orderBy([
        (s) => OrderingTerm.desc(s.startedAt),
        (s) => OrderingTerm.asc(s.setIndex),
      ])
      ..limit(limit);

    return q.watch();
  }

  Stream<List<MovementProgress>> watchAllProgresses() {
    return select(movementProgresses).watch();
  }

  Stream<MovementGuide?> watchMovementGuideById(String movementId) {
    final q = (select(movementGuides)
      ..where((g) => g.movementId.equals(movementId)));
    return q.watchSingleOrNull();
  }

  Stream<int> watchSessionsCount() {
    final q = selectOnly(sessions)..addColumns([sessions.id.count()]);
    return q.watchSingle().map((row) {
      return row.read(sessions.id.count()) ?? 0;
    });
  }

  // NEW: “workouts count” (what you actually want if sets exist)
  Stream<int> watchWorkoutsCount() {
    final q = selectOnly(workouts)..addColumns([workouts.id.count()]);
    return q.watchSingle().map((row) {
      return row.read(workouts.id.count()) ?? 0;
    });
  }

  Stream<int> watchSessionsDurationSumSeconds() {
    final q = selectOnly(sessions)
      ..addColumns([sessions.durationSeconds.sum()]);
    return q.watchSingle().map((row) {
      return row.read(sessions.durationSeconds.sum()) ?? 0;
    });
  }

  Stream<int> watchRepsSumForMovement(String movementId) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.reps.sum()])
      ..where(sessions.movementId.equals(movementId));

    return q.watchSingle().map((row) {
      return row.read(sessions.reps.sum()) ?? 0;
    });
  }

  Stream<int> watchHoldSumForMovement(String movementId) {
    final q = selectOnly(sessions)
      ..addColumns([sessions.holdSeconds.sum()])
      ..where(sessions.movementId.equals(movementId));

    return q.watchSingle().map((row) {
      return row.read(sessions.holdSeconds.sum()) ?? 0;
    });
  }

  // --------------------
  // App meta (lightweight key/value)
  // --------------------

  static const String xpBoostUsesMetaKey = "shop_xp_boost_uses";
  static const String coinBoostUsesMetaKey = "shop_coin_boost_uses";
  static const String ownedCosmeticsMetaKey = "shop_owned_cosmetics";
  static const String equippedCosmeticMetaKey = "shop_equipped_cosmetic";

  Future<void> _ensureAppMetaTable() async {
    await customStatement(
      "CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT)",
    );
  }

  Future<String?> getAppMetaValue(String key) async {
    await _ensureAppMetaTable();

    final rows = await customSelect(
      "SELECT value FROM app_meta WHERE key = ?",
      variables: [Variable.withString(key)],
    ).get();

    if (rows.isEmpty) return null;
    return rows.first.data["value"] as String?;
  }

  Future<void> setAppMetaValue({
    required String key,
    required String value,
  }) async {
    await _ensureAppMetaTable();

    await customStatement(
      "INSERT INTO app_meta(key, value) VALUES(?, ?) "
      "ON CONFLICT(key) DO UPDATE SET value = excluded.value",
      [key, value],
    );
  }

  Future<void> deleteAppMetaValue(String key) async {
    await _ensureAppMetaTable();
    await customStatement("DELETE FROM app_meta WHERE key = ?", [key]);
  }

  int _parseMetaInt(String? raw) {
    return int.tryParse(raw ?? "") ?? 0;
  }

  Set<String> _parseMetaCsvSet(String? raw) {
    final values = (raw ?? "")
        .split(",")
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty);
    return values.toSet();
  }

  String _encodeMetaCsvSet(Set<String> ids) {
    final ordered = ids.toList()..sort();
    return ordered.join(",");
  }

  Future<int> getXpBoostUses() async {
    return _parseMetaInt(await getAppMetaValue(xpBoostUsesMetaKey));
  }

  Future<int> getCoinBoostUses() async {
    return _parseMetaInt(await getAppMetaValue(coinBoostUsesMetaKey));
  }

  Future<CoinBoostStatus> getCoinBoostStatus() async {
    final xpUses = await getXpBoostUses();
    final coinUses = await getCoinBoostUses();

    return CoinBoostStatus(
      xpBoostUses: xpUses.clamp(0, 9999),
      coinBoostUses: coinUses.clamp(0, 9999),
    );
  }

  Future<BoosterPurchaseResult> tryBuyBoostPack({
    required String metaKey,
    required int costCoins,
    required int addUses,
    int maxUses = 99,
  }) async {
    return transaction(() async {
      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();

      if (stats.coins < costCoins) {
        final current = _parseMetaInt(await getAppMetaValue(metaKey));
        return BoosterPurchaseResult(
          success: false,
          message: "Need $costCoins coins.",
          newCoins: stats.coins,
          newUses: current.clamp(0, maxUses),
        );
      }

      final current = _parseMetaInt(await getAppMetaValue(metaKey));
      final nextUses = (current + addUses).clamp(0, maxUses);

      await setAppMetaValue(key: metaKey, value: "$nextUses");
      await (update(userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(coins: Value(stats.coins - costCoins)),
      );

      return BoosterPurchaseResult(
        success: true,
        message: "Purchased.",
        newCoins: stats.coins - costCoins,
        newUses: nextUses,
      );
    });
  }

  Future<void> consumeCoinBoostUses({
    required bool consumeXpBoost,
    required bool consumeCoinBoost,
  }) async {
    if (!consumeXpBoost && !consumeCoinBoost) return;

    if (consumeXpBoost) {
      final current = await getXpBoostUses();
      final next = max(0, current - 1);
      await setAppMetaValue(key: xpBoostUsesMetaKey, value: "$next");
    }

    if (consumeCoinBoost) {
      final current = await getCoinBoostUses();
      final next = max(0, current - 1);
      await setAppMetaValue(key: coinBoostUsesMetaKey, value: "$next");
    }
  }

  Future<Set<String>> getOwnedCosmeticIds() async {
    return _parseMetaCsvSet(await getAppMetaValue(ownedCosmeticsMetaKey));
  }

  Future<String?> getEquippedCosmeticId() async {
    final raw = await getAppMetaValue(equippedCosmeticMetaKey);
    final clean = raw?.trim();
    if (clean == null || clean.isEmpty) {
      return null;
    }
    return clean;
  }

  Future<CosmeticStatus> getCosmeticStatus() async {
    final owned = await getOwnedCosmeticIds();
    final equipped = await getEquippedCosmeticId();
    return CosmeticStatus(
      ownedCosmeticIds: owned,
      equippedCosmeticId: equipped,
    );
  }

  Future<CosmeticPurchaseResult> tryBuyCosmetic({
    required String cosmeticId,
    required int costCoins,
  }) async {
    final cleanId = cosmeticId.trim();
    if (cleanId.isEmpty) {
      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();
      return CosmeticPurchaseResult(
        success: false,
        message: "Invalid cosmetic id.",
        newCoins: stats.coins,
        ownedCosmeticIds: await getOwnedCosmeticIds(),
      );
    }

    return transaction(() async {
      final stats = await (select(
        userStats,
      )..where((s) => s.id.equals(1))).getSingle();
      final owned = await getOwnedCosmeticIds();

      if (owned.contains(cleanId)) {
        return CosmeticPurchaseResult(
          success: false,
          message: "Cosmetic already owned.",
          newCoins: stats.coins,
          ownedCosmeticIds: owned,
        );
      }

      if (stats.coins < costCoins) {
        return CosmeticPurchaseResult(
          success: false,
          message: "Need $costCoins coins.",
          newCoins: stats.coins,
          ownedCosmeticIds: owned,
        );
      }

      final nextOwned = <String>{...owned, cleanId};
      await setAppMetaValue(
        key: ownedCosmeticsMetaKey,
        value: _encodeMetaCsvSet(nextOwned),
      );
      await (update(userStats)..where((s) => s.id.equals(1))).write(
        UserStatsCompanion(coins: Value(stats.coins - costCoins)),
      );

      return CosmeticPurchaseResult(
        success: true,
        message: "Purchased.",
        newCoins: stats.coins - costCoins,
        ownedCosmeticIds: nextOwned,
      );
    });
  }

  Future<bool> trySetEquippedCosmeticId(String? cosmeticId) async {
    final clean = cosmeticId?.trim();
    if (clean == null || clean.isEmpty) {
      await deleteAppMetaValue(equippedCosmeticMetaKey);
      return true;
    }

    final owned = await getOwnedCosmeticIds();
    if (!owned.contains(clean)) {
      return false;
    }

    await setAppMetaValue(key: equippedCosmeticMetaKey, value: clean);
    return true;
  }

  Future<String?> getGoalMovementId() async {
    return getAppMetaValue("goal_movement_id");
  }

  Future<void> setGoalMovementId(String? movementId) async {
    final clean = movementId?.trim();
    if (clean == null || clean.isEmpty) {
      await deleteAppMetaValue("goal_movement_id");
      return;
    }

    await setAppMetaValue(key: "goal_movement_id", value: clean);
  }
}
