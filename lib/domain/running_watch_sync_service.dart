import "dart:math";

import "running_activity.dart";
import "running_connector_credentials.dart";
import "running_goal.dart";
import "running_health_bridge_model.dart";
import "running_health_bridge_stub.dart"
    if (dart.library.io) "running_health_bridge_mobile.dart"
    as health_bridge;
import "running_strava_bridge.dart";

class WatchSyncResult {
  const WatchSyncResult({
    required this.success,
    required this.message,
    required this.importedActivities,
  });

  final bool success;
  final String message;
  final List<RunningActivity> importedActivities;
}

class RunningWatchSyncService {
  const RunningWatchSyncService._();

  /// Connector stub:
  /// This is a local simulator until provider-specific APIs are wired
  /// (Apple Health, Health Connect, Garmin, COROS, Strava).
  static Future<WatchSyncResult> syncRecentRuns({
    required RunningWatchProvider provider,
    required RunningGoalConfig? goal,
    required Set<RunningWatchProvider> connectedProviders,
    required Map<RunningWatchProvider, RunningConnectorCredential> credentials,
    required List<RunningActivity> existingActivities,
    DateTime? providerLastSyncedAt,
    DateTime? now,
  }) async {
    if (!connectedProviders.contains(provider)) {
      return const WatchSyncResult(
        success: false,
        message: "Provider is not connected yet.",
        importedActivities: <RunningActivity>[],
      );
    }

    final today = now ?? DateTime.now();
    final importAfter = _deriveImportAfter(
      provider: provider,
      providerLastSyncedAt: providerLastSyncedAt,
      existingActivities: existingActivities,
      now: today,
    );
    final imported = await _loadProviderRuns(
      provider: provider,
      goal: goal,
      credentials: credentials,
      importAfter: importAfter,
      now: today,
    );
    if (!imported.success) {
      return WatchSyncResult(
        success: false,
        message: imported.message,
        importedActivities: const <RunningActivity>[],
      );
    }

    final existingIds = existingActivities.map((x) => x.id).toSet();
    final newRuns =
        imported.activities.where((x) => !existingIds.contains(x.id)).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final message = newRuns.isEmpty
        ? "No new runs found from ${runningWatchProviderLabel(provider)}."
        : "Synced ${newRuns.length} run${newRuns.length == 1 ? "" : "s"} from ${runningWatchProviderLabel(provider)}.";

    return WatchSyncResult(
      success: true,
      message: message,
      importedActivities: newRuns,
    );
  }

  static Future<RunningHealthImportResult> _loadProviderRuns({
    required RunningWatchProvider provider,
    required RunningGoalConfig? goal,
    required Map<RunningWatchProvider, RunningConnectorCredential> credentials,
    required DateTime? importAfter,
    required DateTime now,
  }) async {
    if (provider == RunningWatchProvider.appleHealth ||
        provider == RunningWatchProvider.healthConnect) {
      return health_bridge.importRunsFromNativeHealth(
        provider: provider,
        goal: goal,
        now: now,
        after: importAfter,
      );
    }

    if (provider == RunningWatchProvider.strava) {
      final cred = credentials[RunningWatchProvider.strava];
      if (cred == null || !cred.hasAccessToken) {
        return const RunningHealthImportResult(
          success: false,
          message: "Connect Strava before syncing.",
          activities: <RunningActivity>[],
        );
      }
      return RunningStravaBridge.importRuns(
        credential: cred,
        now: now,
        after: importAfter,
      );
    }

    if (provider == RunningWatchProvider.manual) {
      return const RunningHealthImportResult(
        success: false,
        message: "Manual runs are entered directly with 'Log manual run'.",
        activities: <RunningActivity>[],
      );
    }

    if (provider == RunningWatchProvider.garmin ||
        provider == RunningWatchProvider.coros) {
      return RunningHealthImportResult(
        success: false,
        message:
            "${runningWatchProviderLabel(provider)} connector is not wired yet. Use manual run logging for now.",
        activities: const <RunningActivity>[],
      );
    }

    return RunningHealthImportResult(
      success: true,
      message: "Imported simulated runs.",
      activities: _generateSyntheticRuns(
        provider: provider,
        goal: goal,
        now: now,
      ),
    );
  }

  static DateTime? _deriveImportAfter({
    required RunningWatchProvider provider,
    required DateTime? providerLastSyncedAt,
    required List<RunningActivity> existingActivities,
    required DateTime now,
  }) {
    DateTime? latestForProvider;
    for (final run in existingActivities) {
      if (run.provider != provider) {
        continue;
      }
      if (latestForProvider == null ||
          run.startedAt.isAfter(latestForProvider)) {
        latestForProvider = run.startedAt;
      }
    }

    var candidate = latestForProvider ?? providerLastSyncedAt;
    if (candidate == null) {
      return null;
    }

    // Small overlap window helps catch edited runs and clock skew.
    candidate = candidate.subtract(const Duration(days: 2));
    if (!candidate.isBefore(now)) {
      return null;
    }
    return candidate;
  }

  static List<RunningActivity> _generateSyntheticRuns({
    required RunningWatchProvider provider,
    required RunningGoalConfig? goal,
    required DateTime now,
  }) {
    final baselineDistance = max(3.0, goal?.baselineDistanceKm ?? 5.0);
    final baselineDurationMinutes = max(
      18.0,
      (goal?.baselineDurationMinutes ?? 35).toDouble(),
    );
    final baselinePace = baselineDurationMinutes / baselineDistance;

    final distances = <double>[
      baselineDistance * 0.70,
      baselineDistance * 0.55,
      baselineDistance * 0.82,
      baselineDistance * 0.66,
      baselineDistance * 0.95,
      baselineDistance * 0.60,
    ];

    final offsetDays = <int>[2, 5, 8, 11, 14, 18];
    final paceModifiers = <double>[1.02, 1.08, 0.98, 1.04, 0.97, 1.10];

    final activities = <RunningActivity>[];
    for (var i = 0; i < distances.length; i += 1) {
      final startedAt = now.subtract(Duration(days: offsetDays[i]));
      final distanceKm = max(2.0, distances[i]);
      final minutes = baselinePace * paceModifiers[i] * distanceKm;
      final durationSeconds = max(600, (minutes * 60).round());
      final providerRaw = runningWatchProviderToRaw(provider);
      final id =
          "sync_${providerRaw}_${startedAt.year}${startedAt.month.toString().padLeft(2, "0")}${startedAt.day.toString().padLeft(2, "0")}_$i";

      activities.add(
        RunningActivity(
          id: id,
          provider: provider,
          startedAt: DateTime(
            startedAt.year,
            startedAt.month,
            startedAt.day,
            7 + (i % 4),
            10,
          ),
          distanceKm: distanceKm,
          durationSeconds: durationSeconds,
          avgHeartRate: 132 + (i * 3),
          elevationGainMeters: 22 + (i * 6),
        ),
      );
    }

    return activities;
  }
}
