import "package:drift/drift.dart";
import "package:drift/native.dart";

import "package:cali_skill_tree/data/db/app_db.dart";

class MutableClock {
  MutableClock(DateTime initial) : _now = initial;

  DateTime _now;

  DateTime now() => _now;

  void set(DateTime value) {
    _now = value;
  }
}

AppDb createTestDb() {
  return AppDb.forTesting(NativeDatabase.memory());
}

Future<void> ensureUserStats(
  AppDb db, {
  int totalXp = 0,
  int level = 1,
  int perkPoints = 0,
  int coins = 0,
}) async {
  await db
      .into(db.userStats)
      .insert(
        UserStatsCompanion.insert(
          id: const Value(1),
          totalXp: Value(totalXp),
          level: Value(level),
          perkPoints: Value(perkPoints),
          coins: Value(coins),
        ),
        mode: InsertMode.insertOrReplace,
      );
}
