import "package:flutter_riverpod/flutter_riverpod.dart";
import "../data/db/app_db.dart";
import "../domain/cosmetic_catalog.dart";
import "../domain/seed_service.dart";
import "../domain/log_session_service.dart";
import "../domain/daily_quest_service.dart";
import "../domain/weekly_quest_service.dart";
import "../domain/training_mode.dart";
import "../domain/running_goal.dart";
import "../domain/running_activity.dart";
import "../domain/running_connector_credentials.dart";
import "../domain/running_adaptation_service.dart";
import "../domain/running_plan_service.dart";
import "../domain/running_strava_oauth_config.dart";
import "../domain/running_strava_oauth_service.dart";
import "../domain/running_watch_sync_service.dart";
import "dart:async";
import "../domain/prereq_rules.dart";

final appDbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(() => db.close());
  return db;
});

const _trainingModeMetaKey = "training_mode";
const _runningGoalMetaKey = "running_goal_v1";
const _runningActivitiesMetaKey = "running_activities_v1";
const _runningWatchSyncMetaKey = "running_watch_sync_v1";
const _runningConnectorCredentialsMetaKey = "running_connector_credentials_v1";

class TrainingModeController extends AsyncNotifier<TrainingMode> {
  @override
  Future<TrainingMode> build() async {
    final db = ref.watch(appDbProvider);
    final raw = await db.getAppMetaValue(_trainingModeMetaKey);
    return trainingModeFromRaw(raw);
  }

  Future<void> setMode(TrainingMode mode) async {
    final db = ref.read(appDbProvider);
    await db.setAppMetaValue(
      key: _trainingModeMetaKey,
      value: trainingModeToRaw(mode),
    );
    state = AsyncData(mode);
  }

  Future<void> refreshMode() async {
    final db = ref.read(appDbProvider);
    final raw = await db.getAppMetaValue(_trainingModeMetaKey);
    state = AsyncData(trainingModeFromRaw(raw));
  }
}

final trainingModeProvider =
    AsyncNotifierProvider<TrainingModeController, TrainingMode>(
      TrainingModeController.new,
    );

class RunningGoalController extends AsyncNotifier<RunningGoalConfig?> {
  @override
  Future<RunningGoalConfig?> build() async {
    final db = ref.watch(appDbProvider);
    final raw = await db.getAppMetaValue(_runningGoalMetaKey);
    return RunningGoalConfig.fromJsonString(raw);
  }

  Future<void> saveGoal(RunningGoalConfig goal) async {
    final db = ref.read(appDbProvider);
    await db.setAppMetaValue(
      key: _runningGoalMetaKey,
      value: goal.toJsonString(),
    );
    state = AsyncData(goal);
  }

  Future<void> clearGoal() async {
    final db = ref.read(appDbProvider);
    await db.deleteAppMetaValue(_runningGoalMetaKey);
    state = const AsyncData(null);
  }

  Future<void> refreshGoal() async {
    final db = ref.read(appDbProvider);
    final raw = await db.getAppMetaValue(_runningGoalMetaKey);
    state = AsyncData(RunningGoalConfig.fromJsonString(raw));
  }
}

final runningGoalProvider =
    AsyncNotifierProvider<RunningGoalController, RunningGoalConfig?>(
      RunningGoalController.new,
    );

class RunningActivitiesController extends AsyncNotifier<List<RunningActivity>> {
  @override
  Future<List<RunningActivity>> build() async {
    final db = ref.watch(appDbProvider);
    final raw = await db.getAppMetaValue(_runningActivitiesMetaKey);
    return RunningActivity.listFromJsonString(raw);
  }

  Future<void> _write(List<RunningActivity> values) async {
    final db = ref.read(appDbProvider);
    final clipped = values.where((x) => x.isValid).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final trimmed = clipped.take(500).toList();
    await db.setAppMetaValue(
      key: _runningActivitiesMetaKey,
      value: RunningActivity.listToJsonString(trimmed),
    );
    state = AsyncData(trimmed);
  }

  Future<void> addImportedRuns(List<RunningActivity> imported) async {
    if (imported.isEmpty) return;
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const <RunningActivity>[],
    );
    final byId = <String, RunningActivity>{for (final a in current) a.id: a};
    final fingerprintToId = <String, String>{};
    for (final run in current) {
      fingerprintToId[_activityFingerprint(run)] = run.id;
    }

    for (final run in imported) {
      final existingById = byId[run.id];
      if (existingById != null) {
        byId[run.id] = _preferActivity(existingById, run);
        fingerprintToId[_activityFingerprint(byId[run.id]!)] = run.id;
        continue;
      }

      final fingerprint = _activityFingerprint(run);
      final existingDuplicateId = fingerprintToId[fingerprint];
      if (existingDuplicateId != null) {
        final existingDuplicate = byId[existingDuplicateId];
        if (existingDuplicate != null) {
          final preferred = _preferActivity(existingDuplicate, run);
          if (preferred.id != existingDuplicate.id) {
            byId.remove(existingDuplicateId);
            byId[preferred.id] = preferred;
            fingerprintToId[fingerprint] = preferred.id;
          }
        }
        continue;
      }

      byId[run.id] = run;
      fingerprintToId[fingerprint] = run.id;
    }
    await _write(byId.values.toList());
  }

  Future<void> addManualRun({
    required DateTime startedAt,
    required double distanceKm,
    required int durationSeconds,
    int? avgHeartRate,
    int? elevationGainMeters,
  }) async {
    if (distanceKm <= 0 || durationSeconds <= 0) {
      return;
    }

    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const <RunningActivity>[],
    );
    final id =
        "manual_${startedAt.millisecondsSinceEpoch}_${distanceKm.toStringAsFixed(2)}_$durationSeconds";
    final next = <RunningActivity>[
      RunningActivity(
        id: id,
        provider: RunningWatchProvider.manual,
        startedAt: startedAt,
        distanceKm: distanceKm,
        durationSeconds: durationSeconds,
        avgHeartRate: avgHeartRate,
        elevationGainMeters: elevationGainMeters,
      ),
      ...current,
    ];
    await _write(next);
  }

  Future<void> clearAll() async {
    final db = ref.read(appDbProvider);
    await db.deleteAppMetaValue(_runningActivitiesMetaKey);
    state = const AsyncData(<RunningActivity>[]);
  }

  Future<void> refresh() async {
    final db = ref.read(appDbProvider);
    final raw = await db.getAppMetaValue(_runningActivitiesMetaKey);
    state = AsyncData(RunningActivity.listFromJsonString(raw));
  }

  String _activityFingerprint(RunningActivity run) {
    final minuteBucket =
        run.startedAt.toUtc().millisecondsSinceEpoch ~/
        const Duration(minutes: 2).inMilliseconds;
    final distanceBucket = (run.distanceKm * 20).round();
    final durationBucket = (run.durationSeconds / 30).round();
    return "$minuteBucket:$distanceBucket:$durationBucket";
  }

  RunningActivity _preferActivity(
    RunningActivity existing,
    RunningActivity candidate,
  ) {
    if (existing.provider == RunningWatchProvider.manual &&
        candidate.provider != RunningWatchProvider.manual) {
      return existing;
    }
    if (existing.provider != RunningWatchProvider.manual &&
        candidate.provider == RunningWatchProvider.manual) {
      return candidate;
    }

    final existingScore = _qualityScore(existing);
    final candidateScore = _qualityScore(candidate);
    if (candidateScore > existingScore) {
      return candidate;
    }
    if (candidateScore < existingScore) {
      return existing;
    }

    if (candidate.startedAt.isAfter(existing.startedAt)) {
      return candidate;
    }
    return existing;
  }

  int _qualityScore(RunningActivity run) {
    var score = 0;
    if (run.avgHeartRate != null && run.avgHeartRate! > 0) {
      score += 2;
    }
    if (run.elevationGainMeters != null && run.elevationGainMeters! > 0) {
      score += 1;
    }

    score += switch (run.provider) {
      RunningWatchProvider.manual => 4,
      RunningWatchProvider.strava => 2,
      RunningWatchProvider.appleHealth => 2,
      RunningWatchProvider.healthConnect => 2,
      RunningWatchProvider.garmin => 1,
      RunningWatchProvider.coros => 1,
    };

    return score;
  }
}

final runningActivitiesProvider =
    AsyncNotifierProvider<RunningActivitiesController, List<RunningActivity>>(
      RunningActivitiesController.new,
    );

class RunningConnectorCredentialsController
    extends
        AsyncNotifier<Map<RunningWatchProvider, RunningConnectorCredential>> {
  @override
  Future<Map<RunningWatchProvider, RunningConnectorCredential>> build() async {
    final db = ref.watch(appDbProvider);
    final raw = await db.getAppMetaValue(_runningConnectorCredentialsMetaKey);
    return decodeConnectorCredentialMap(raw);
  }

  Future<void> _write(
    Map<RunningWatchProvider, RunningConnectorCredential> values,
  ) async {
    final db = ref.read(appDbProvider);
    await db.setAppMetaValue(
      key: _runningConnectorCredentialsMetaKey,
      value: encodeConnectorCredentialMap(values),
    );
    state = AsyncData(values);
  }

  Future<void> setCredential(RunningConnectorCredential credential) async {
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const <RunningWatchProvider, RunningConnectorCredential>{},
    );
    final next = <RunningWatchProvider, RunningConnectorCredential>{
      ...current,
      credential.provider: credential.copyWith(updatedAt: DateTime.now()),
    };
    await _write(next);
  }

  Future<void> clearCredential(RunningWatchProvider provider) async {
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const <RunningWatchProvider, RunningConnectorCredential>{},
    );
    final next = <RunningWatchProvider, RunningConnectorCredential>{...current}
      ..remove(provider);
    await _write(next);
  }

  Future<void> refresh() async {
    final db = ref.read(appDbProvider);
    final raw = await db.getAppMetaValue(_runningConnectorCredentialsMetaKey);
    state = AsyncData(decodeConnectorCredentialMap(raw));
  }
}

final runningConnectorCredentialsProvider =
    AsyncNotifierProvider<
      RunningConnectorCredentialsController,
      Map<RunningWatchProvider, RunningConnectorCredential>
    >(RunningConnectorCredentialsController.new);

class RunningWatchSyncController extends AsyncNotifier<RunningWatchSyncState> {
  @override
  Future<RunningWatchSyncState> build() async {
    final db = ref.watch(appDbProvider);
    final raw = await db.getAppMetaValue(_runningWatchSyncMetaKey);
    return RunningWatchSyncState.fromJsonString(raw);
  }

  Future<void> _write(RunningWatchSyncState next) async {
    final db = ref.read(appDbProvider);
    await db.setAppMetaValue(
      key: _runningWatchSyncMetaKey,
      value: next.toJsonString(),
    );
    state = AsyncData(next);
  }

  Future<void> connectProvider(RunningWatchProvider provider) async {
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const RunningWatchSyncState(
        connectedProviders: <RunningWatchProvider>{},
        totalImportedRuns: 0,
      ),
    );
    final nextProviders = <RunningWatchProvider>{
      ...current.connectedProviders,
      provider,
    };
    await _write(current.copyWith(connectedProviders: nextProviders));
  }

  Future<void> disconnectProvider(RunningWatchProvider provider) async {
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const RunningWatchSyncState(
        connectedProviders: <RunningWatchProvider>{},
        totalImportedRuns: 0,
      ),
    );
    final nextProviders = <RunningWatchProvider>{...current.connectedProviders}
      ..remove(provider);
    await _write(current.copyWith(connectedProviders: nextProviders));
  }

  Future<WatchSyncResult> syncFromProvider(
    RunningWatchProvider provider,
  ) async {
    final current = state.maybeWhen(
      data: (x) => x,
      orElse: () => const RunningWatchSyncState(
        connectedProviders: <RunningWatchProvider>{},
        totalImportedRuns: 0,
      ),
    );
    final existingActivities = ref
        .read(runningActivitiesProvider)
        .maybeWhen(data: (x) => x, orElse: () => const <RunningActivity>[]);
    var credentials = ref
        .read(runningConnectorCredentialsProvider)
        .maybeWhen(
          data: (x) => x,
          orElse: () =>
              const <RunningWatchProvider, RunningConnectorCredential>{},
        );
    final goal = ref
        .read(runningGoalProvider)
        .maybeWhen(data: (x) => x, orElse: () => null);

    final now = DateTime.now();
    if (provider == RunningWatchProvider.strava) {
      final stravaCredential = credentials[RunningWatchProvider.strava];
      if (stravaCredential != null &&
          RunningStravaOAuthService.shouldRefreshCredential(
            stravaCredential,
            now: now,
          )) {
        final config = RunningStravaOAuthConfig.fromEnvironment();
        if (config.isConfigured) {
          try {
            final refreshed = await RunningStravaOAuthService.refreshCredential(
              config: config,
              existing: stravaCredential,
              now: now,
            );
            await ref
                .read(runningConnectorCredentialsProvider.notifier)
                .setCredential(refreshed);
            credentials = <RunningWatchProvider, RunningConnectorCredential>{
              ...credentials,
              RunningWatchProvider.strava: refreshed,
            };
          } on RunningStravaOAuthException catch (e) {
            final failure = WatchSyncResult(
              success: false,
              message: e.message,
              importedActivities: const <RunningActivity>[],
            );
            await _write(
              current.copyWith(
                lastSyncMessage: failure.message,
                lastSyncedAt: now,
              ),
            );
            return failure;
          }
        }
      }
    }

    var result = await RunningWatchSyncService.syncRecentRuns(
      provider: provider,
      goal: goal,
      connectedProviders: current.connectedProviders,
      credentials: credentials,
      existingActivities: existingActivities,
      providerLastSyncedAt: current.lastSyncedForProvider(provider),
    );

    if (!result.success && provider == RunningWatchProvider.strava) {
      final likelyAuthFailure = result.message.toLowerCase().contains(
        "authorization failed",
      );
      final currentCredential = credentials[RunningWatchProvider.strava];
      final config = RunningStravaOAuthConfig.fromEnvironment();
      if (likelyAuthFailure &&
          currentCredential != null &&
          (currentCredential.refreshToken ?? "").trim().isNotEmpty &&
          config.isConfigured) {
        try {
          final refreshed = await RunningStravaOAuthService.refreshCredential(
            config: config,
            existing: currentCredential,
            now: now,
          );
          await ref
              .read(runningConnectorCredentialsProvider.notifier)
              .setCredential(refreshed);
          credentials = <RunningWatchProvider, RunningConnectorCredential>{
            ...credentials,
            RunningWatchProvider.strava: refreshed,
          };
          result = await RunningWatchSyncService.syncRecentRuns(
            provider: provider,
            goal: goal,
            connectedProviders: current.connectedProviders,
            credentials: credentials,
            existingActivities: existingActivities,
            providerLastSyncedAt: current.lastSyncedForProvider(provider),
          );
        } on RunningStravaOAuthException catch (e) {
          result = WatchSyncResult(
            success: false,
            message: e.message,
            importedActivities: const <RunningActivity>[],
          );
        }
      }
    }

    if (result.importedActivities.isNotEmpty) {
      await ref
          .read(runningActivitiesProvider.notifier)
          .addImportedRuns(result.importedActivities);
    }

    final refreshedActivities = ref
        .read(runningActivitiesProvider)
        .maybeWhen(data: (x) => x, orElse: () => existingActivities);

    final providerSyncMap = <RunningWatchProvider, DateTime>{
      ...current.lastSyncedAtByProvider,
    };
    if (result.success) {
      providerSyncMap[provider] = now;
    }
    final next = current.copyWith(
      totalImportedRuns: refreshedActivities.length,
      lastSyncedAt: now,
      lastSyncMessage: result.message,
      lastSyncedAtByProvider: providerSyncMap,
    );
    await _write(next);
    return result;
  }

  Future<void> refresh() async {
    final db = ref.read(appDbProvider);
    final raw = await db.getAppMetaValue(_runningWatchSyncMetaKey);
    state = AsyncData(RunningWatchSyncState.fromJsonString(raw));
  }
}

final runningWatchSyncProvider =
    AsyncNotifierProvider<RunningWatchSyncController, RunningWatchSyncState>(
      RunningWatchSyncController.new,
    );

final runningAdaptationProvider = Provider<RunningPlanAdaptation?>((ref) {
  final goal = ref
      .watch(runningGoalProvider)
      .maybeWhen(data: (value) => value, orElse: () => null);
  if (goal == null) {
    return null;
  }

  final activities = ref
      .watch(runningActivitiesProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <RunningActivity>[],
      );

  return RunningAdaptationService.fromRecentActivities(
    goal: goal,
    allActivities: activities,
  );
});

final runningPlanProvider = Provider<RunningPlan?>((ref) {
  final goal = ref
      .watch(runningGoalProvider)
      .maybeWhen(data: (value) => value, orElse: () => null);

  if (goal == null) {
    return null;
  }

  final adaptation = ref.watch(runningAdaptationProvider);
  return RunningPlanService.buildPlan(goal: goal, adaptation: adaptation);
});

final seedServiceProvider = Provider<SeedService>((ref) {
  final db = ref.watch(appDbProvider);
  return SeedService(db);
});

final seedProvider = FutureProvider<void>((ref) async {
  final seeder = ref.watch(seedServiceProvider);
  await seeder.run();
});

final logSessionServiceProvider = Provider<LogSessionService>((ref) {
  final db = ref.watch(appDbProvider);
  return LogSessionService(db);
});

final dailyQuestServiceProvider = Provider<DailyQuestService>((ref) {
  final db = ref.watch(appDbProvider);
  return DailyQuestService(db);
});

final weeklyQuestServiceProvider = Provider<WeeklyQuestService>((ref) {
  final db = ref.watch(appDbProvider);
  return WeeklyQuestService(db);
});

class WeeklyQuestRefreshController extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

final weeklyQuestRefreshProvider =
    NotifierProvider<WeeklyQuestRefreshController, int>(
      WeeklyQuestRefreshController.new,
    );

class CoinBoostRefreshController extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

final coinBoostRefreshProvider =
    NotifierProvider<CoinBoostRefreshController, int>(
      CoinBoostRefreshController.new,
    );

class SkillGoalController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final db = ref.watch(appDbProvider);
    return db.getGoalMovementId();
  }

  Future<void> setGoal(String? movementId) async {
    final db = ref.read(appDbProvider);
    await db.setGoalMovementId(movementId);
    state = AsyncData(movementId);
  }

  Future<void> refreshGoal() async {
    final db = ref.read(appDbProvider);
    final id = await db.getGoalMovementId();
    state = AsyncData(id);
  }
}

final skillGoalProvider = AsyncNotifierProvider<SkillGoalController, String?>(
  SkillGoalController.new,
);

final questRefreshTickProvider = StreamProvider<int>((ref) {
  return Stream<int>.multi((controller) {
    var tick = 0;
    controller.add(tick);

    final timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (controller.isClosed) return;
      tick += 1;
      controller.add(tick);
    });

    controller.onCancel = timer.cancel;
  });
});

final dailyQuestsProvider = StreamProvider<List<DailyQuestProgress>>((ref) {
  ref.watch(questRefreshTickProvider);
  final service = ref.watch(dailyQuestServiceProvider);
  final goalMovementId = ref
      .watch(skillGoalProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  return service.watchTodayQuests(goalMovementId: goalMovementId);
});

final weeklyQuestsProvider = StreamProvider<List<WeeklyQuestProgress>>((ref) {
  ref.watch(questRefreshTickProvider);
  ref.watch(weeklyQuestRefreshProvider);
  final service = ref.watch(weeklyQuestServiceProvider);
  final goalMovementId = ref
      .watch(skillGoalProvider)
      .maybeWhen(data: (id) => id, orElse: () => null);

  return service.watchThisWeekQuests(goalMovementId: goalMovementId);
});

final weeklyQuestRerollInfoProvider = FutureProvider<WeeklyRerollInfo>((ref) {
  ref.watch(questRefreshTickProvider);
  ref.watch(weeklyQuestRefreshProvider);
  final service = ref.watch(weeklyQuestServiceProvider);
  return service.getRerollInfo();
});

final coinBoostStatusProvider = FutureProvider<CoinBoostStatus>((ref) async {
  ref.watch(coinBoostRefreshProvider);
  ref.watch(userStatProvider);
  final db = ref.watch(appDbProvider);
  return db.getCoinBoostStatus();
});

class CosmeticRefreshController extends Notifier<int> {
  @override
  int build() => 0;

  void bump() {
    state = state + 1;
  }
}

final cosmeticRefreshProvider =
    NotifierProvider<CosmeticRefreshController, int>(
      CosmeticRefreshController.new,
    );

final cosmeticStatusProvider = FutureProvider<CosmeticStatus>((ref) async {
  ref.watch(cosmeticRefreshProvider);
  ref.watch(userStatProvider);
  final db = ref.watch(appDbProvider);
  final raw = await db.getCosmeticStatus();

  final validIds = {for (final c in CosmeticCatalog.all) c.id};
  final owned = raw.ownedCosmeticIds.where(validIds.contains).toSet();
  final equipped = owned.contains(raw.equippedCosmeticId)
      ? raw.equippedCosmeticId
      : null;

  return CosmeticStatus(ownedCosmeticIds: owned, equippedCosmeticId: equipped);
});

final userStatProvider = StreamProvider<UserStat>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchUserStat();
});

final userPerksProvider = StreamProvider<List<UserPerk>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchUserPerks();
});

final movementsWithProgressProvider =
    StreamProvider<List<MovementWithProgress>>((ref) {
      final db = ref.watch(appDbProvider);
      return db.watchMovementsWithProgress();
    });

final prereqsProvider = StreamProvider<List<MovementPrereq>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchAllPrereqs();
});

final recentSessionsProvider = StreamProvider<List<SessionWithMovement>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchRecentSessions(20);
});

final workoutHistoryProvider = StreamProvider<List<WorkoutSummary>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchWorkoutSummaries(80);
});

final workoutEntriesProvider =
    StreamProvider.family<List<SessionWithMovement>, int>((ref, workoutId) {
      final db = ref.watch(appDbProvider);
      return db.watchSessionsForWorkout(workoutId);
    });

final legacySessionsProvider = StreamProvider<List<SessionWithMovement>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchRecentSessionsWithoutWorkout(80);
});

final badgesProvider = StreamProvider<List<BadgeWithEarned>>((ref) {
  final db = ref.watch(appDbProvider);
  return db.watchBadgesWithEarned();
});

// Detail providers
final movementDetailProvider =
    StreamProvider.family<MovementWithProgress, String>((ref, movementId) {
      final db = ref.watch(appDbProvider);
      return db.watchMovementWithProgressById(movementId);
    });

final movementDetailPrereqsProvider =
    StreamProvider.family<List<MovementPrereq>, String>((ref, movementId) {
      final db = ref.watch(appDbProvider);
      return db.watchPrereqsForMovement(movementId);
    });

final movementDetailSessionsProvider =
    StreamProvider.family<List<Session>, String>((ref, movementId) {
      final db = ref.watch(appDbProvider);
      return db.watchSessionsForMovement(movementId, 30);
    });

class BadgeMetrics {
  BadgeMetrics({
    required this.stats,
    required this.sessionsCount,
    required this.totalDurationSeconds,
    required this.pullUpTotalReps,
    required this.pushUpTotalReps,
    required this.squatTotalReps,
    required this.plankTotalHoldSeconds,
    required this.progressById,
    required this.unlockedCount,
    required this.masteredCount,
  });

  final UserStat stats;

  final int sessionsCount;
  final int totalDurationSeconds;

  final int pullUpTotalReps;
  final int pushUpTotalReps;
  final int squatTotalReps;
  final int plankTotalHoldSeconds;

  final Map<String, MovementProgress> progressById;

  final int unlockedCount;
  final int masteredCount;
}

final badgeMetricsProvider = StreamProvider<BadgeMetrics>((ref) {
  final db = ref.watch(appDbProvider);

  return Stream<BadgeMetrics>.multi((controller) {
    var stats = UserStat(
      id: 1,
      totalXp: 0,
      level: 1,
      perkPoints: 0,
      coins: 0,
      currentStreak: 0,
      bestStreak: 0,
      lastActiveDate: null,
    );

    int sessionsCount = 0;
    int totalDurationSeconds = 0;

    int pullUpTotalReps = 0;
    int pushUpTotalReps = 0;
    int squatTotalReps = 0;
    int plankTotalHoldSeconds = 0;

    Map<String, MovementProgress> progressById = <String, MovementProgress>{};
    int unlockedCount = 0;
    int masteredCount = 0;

    void emit() {
      if (controller.isClosed) {
        return;
      }

      controller.add(
        BadgeMetrics(
          stats: stats,
          sessionsCount: sessionsCount,
          totalDurationSeconds: totalDurationSeconds,
          pullUpTotalReps: pullUpTotalReps,
          pushUpTotalReps: pushUpTotalReps,
          squatTotalReps: squatTotalReps,
          plankTotalHoldSeconds: plankTotalHoldSeconds,
          progressById: progressById,
          unlockedCount: unlockedCount,
          masteredCount: masteredCount,
        ),
      );
    }

    final subs = <StreamSubscription<dynamic>>[];

    subs.add(
      db.watchUserStat().listen((v) {
        stats = v;
        emit();
      }),
    );

    subs.add(
      db.watchSessionsCount().listen((v) {
        sessionsCount = v;
        emit();
      }),
    );

    subs.add(
      db.watchSessionsDurationSumSeconds().listen((v) {
        totalDurationSeconds = v;
        emit();
      }),
    );

    subs.add(
      db.watchRepsSumForMovement("pull_up").listen((v) {
        pullUpTotalReps = v;
        emit();
      }),
    );

    subs.add(
      db.watchRepsSumForMovement("push_up").listen((v) {
        pushUpTotalReps = v;
        emit();
      }),
    );

    subs.add(
      db.watchRepsSumForMovement("bodyweight_squat").listen((v) {
        squatTotalReps = v;
        emit();
      }),
    );

    subs.add(
      db.watchHoldSumForMovement("plank").listen((v) {
        plankTotalHoldSeconds = v;
        emit();
      }),
    );

    subs.add(
      db.watchAllProgresses().listen((rows) {
        final map = <String, MovementProgress>{};
        int u = 0;
        int m = 0;

        for (final p in rows) {
          map[p.movementId] = p;

          if (p.state != "locked") {
            u += 1;
          }
          if (p.state == "mastered") {
            m += 1;
          }
        }

        progressById = map;
        unlockedCount = u;
        masteredCount = m;

        emit();
      }),
    );

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
  });
});

// -----------------------------------------------------------------------------
// Rich lock reasons (typed + includes mastery deficits for prereqs)
// -----------------------------------------------------------------------------

final movementLockReasonsProvider = StreamProvider.family<List<String>, String>((
  ref,
  movementId,
) {
  final db = ref.watch(appDbProvider);

  return Stream<List<String>>.multi((controller) {
    UserStat stats = UserStat(
      id: 1,
      totalXp: 0,
      level: 1,
      perkPoints: 0,
      coins: 0,
      currentStreak: 0,
      bestStreak: 0,
      lastActiveDate: null,
    );

    List<MovementWithProgress> all = const <MovementWithProgress>[];
    List<MovementPrereq> prereqs = const <MovementPrereq>[];

    void emit() {
      if (controller.isClosed) return;
      if (all.isEmpty) return;

      final movementById = <String, Movement>{};
      final progressById = <String, MovementProgress>{};
      final stateById = <String, String>{};

      for (final x in all) {
        movementById[x.movement.id] = x.movement;
        progressById[x.movement.id] = x.progress;
        stateById[x.movement.id] = x.progress.state;
      }

      final movement = movementById[movementId];
      if (movement == null) {
        controller.add(<String>["Movement not found."]);
        return;
      }

      // Run an in-memory fixpoint unlock propagation (same spirit as UnlockService)
      bool prereqsSatisfied(List<MovementPrereq> reqs) {
        for (final r in reqs) {
          final preState = stateById[r.prereqMovementId];
          if (preState == null) return false;
          if (!isPrereqSatisfied(
            prereqType: r.prereqType,
            currentState: preState,
          )) {
            return false;
          }
        }
        return true;
      }

      final prereqsByMovement = <String, List<MovementPrereq>>{};
      for (final p in prereqs) {
        prereqsByMovement.putIfAbsent(p.movementId, () => []).add(p);
      }

      bool changed = true;
      while (changed) {
        changed = false;

        for (final m in movementById.values) {
          final curState = stateById[m.id] ?? "locked";
          if (curState != "locked") continue;

          if (stats.totalXp < m.xpToUnlock) continue;

          final reqs = prereqsByMovement[m.id] ?? const <MovementPrereq>[];
          if (!prereqsSatisfied(reqs)) continue;

          stateById[m.id] = "unlocked";
          changed = true;
        }
      }

      // If the movement isn't locked after propagation, no lock reasons needed.
      final curState = stateById[movementId] ?? "locked";
      if (curState != "locked") {
        controller.add(const <String>[]);
        return;
      }

      // Compute rich reasons
      final reasons = <String>[];

      if (stats.totalXp < movement.xpToUnlock) {
        final remaining = movement.xpToUnlock - stats.totalXp;
        reasons.add(
          "XP gate: ${stats.totalXp} / ${movement.xpToUnlock} (need $remaining more)",
        );
      }

      final reqs = prereqsByMovement[movementId] ?? const <MovementPrereq>[];
      for (final r in reqs) {
        final preMove = movementById[r.prereqMovementId];
        final preName = preMove?.name ?? r.prereqMovementId;
        final preState = stateById[r.prereqMovementId] ?? "locked";
        final required = normalizePrereqType(r.prereqType);

        if (isPrereqSatisfied(prereqType: required, currentState: preState)) {
          continue;
        }

        if (required == "unlocked") {
          reasons.add("Prereq: unlock $preName");
          continue;
        }

        final prog = progressById[r.prereqMovementId];
        final target = preMove == null
            ? null
            : targetForPrereqTier(preMove, required);

        if (target == null) {
          reasons.add("Prereq: ${prereqLabel(required)} $preName");
          continue;
        }

        final parts = <String>[];
        if (target.reps > 0) {
          parts.add("reps ${(prog?.bestReps ?? 0)}/${target.reps}");
        }
        if (target.holdSeconds > 0) {
          parts.add(
            "hold ${(prog?.bestHoldSeconds ?? 0)}/${target.holdSeconds}s",
          );
        }
        if (target.totalXp > 0) {
          parts.add("XP ${(prog?.totalXp ?? 0)}/${target.totalXp}");
        }

        final suffix = parts.isEmpty ? "" : " (${parts.join(", ")})";
        reasons.add("Prereq: ${prereqLabel(required)} $preName$suffix");
      }

      if (reasons.isEmpty) {
        reasons.add("Unknown lock reason (check rules)");
      }

      controller.add(reasons);
    }

    final subs = <StreamSubscription<dynamic>>[];

    subs.add(
      db.watchUserStat().listen((v) {
        stats = v;
        emit();
      }),
    );

    subs.add(
      db.watchMovementsWithProgress().listen((rows) {
        all = rows;
        emit();
      }),
    );

    subs.add(
      db.watchAllPrereqs().listen((rows) {
        prereqs = rows;
        emit();
      }),
    );

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
  });
});
