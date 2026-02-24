import "dart:io";

import "package:health/health.dart";

import "running_activity.dart";
import "running_goal.dart";
import "running_health_bridge_model.dart";

Future<RunningHealthImportResult> importRunsFromNativeHealth({
  required RunningWatchProvider provider,
  required RunningGoalConfig? goal,
  required DateTime now,
  DateTime? after,
}) async {
  if (provider == RunningWatchProvider.appleHealth && !Platform.isIOS) {
    return const RunningHealthImportResult(
      success: false,
      message: "Apple Health sync requires iOS.",
      activities: <RunningActivity>[],
    );
  }

  if (provider == RunningWatchProvider.healthConnect && !Platform.isAndroid) {
    return const RunningHealthImportResult(
      success: false,
      message: "Health Connect sync requires Android.",
      activities: <RunningActivity>[],
    );
  }

  if (!Platform.isAndroid && !Platform.isIOS) {
    return const RunningHealthImportResult(
      success: false,
      message: "Native health sync is only supported on Android/iOS devices.",
      activities: <RunningActivity>[],
    );
  }

  final health = Health();
  await health.configure();

  if (Platform.isAndroid) {
    final status = await health.getHealthConnectSdkStatus();
    if (status != HealthConnectSdkStatus.sdkAvailable) {
      return const RunningHealthImportResult(
        success: false,
        message:
            "Health Connect is unavailable. Install/enable Health Connect and retry.",
        activities: <RunningActivity>[],
      );
    }
  }

  final authorized = await health.requestAuthorization(
    const [HealthDataType.WORKOUT],
    permissions: const [HealthDataAccess.READ],
  );
  if (!authorized) {
    return RunningHealthImportResult(
      success: false,
      message:
          "Permission denied for ${runningWatchProviderLabel(provider)} workout data.",
      activities: const <RunningActivity>[],
    );
  }

  final fallbackStart = now.subtract(const Duration(days: 60));
  var start = after ?? fallbackStart;
  if (!start.isBefore(now)) {
    start = fallbackStart;
  }
  final maxLookback = now.subtract(const Duration(days: 365));
  if (start.isBefore(maxLookback)) {
    start = maxLookback;
  }
  final workouts = await health.getHealthDataFromTypes(
    types: const [HealthDataType.WORKOUT],
    startTime: start,
    endTime: now,
  );

  final activities = <RunningActivity>[];
  for (final point in workouts) {
    if (point.type != HealthDataType.WORKOUT) continue;
    final value = point.value;
    if (value is! WorkoutHealthValue) continue;
    if (!_isRunWorkout(value.workoutActivityType)) continue;

    final distanceKm = _distanceKm(
      value.totalDistance,
      value.totalDistanceUnit,
    );
    if (distanceKm <= 0) continue;

    final durationSeconds = point.dateTo.difference(point.dateFrom).inSeconds;
    if (durationSeconds <= 0) continue;

    final rawId = point.uuid.trim();
    final id = rawId.isEmpty
        ? "native_${runningWatchProviderToRaw(provider)}_${point.dateFrom.millisecondsSinceEpoch}_$durationSeconds"
        : rawId;

    activities.add(
      RunningActivity(
        id: id,
        provider: provider,
        startedAt: point.dateFrom,
        distanceKm: distanceKm,
        durationSeconds: durationSeconds,
      ),
    );
  }

  activities.sort((a, b) => b.startedAt.compareTo(a.startedAt));

  return RunningHealthImportResult(
    success: true,
    message: activities.isEmpty
        ? "No running workouts found in ${runningWatchProviderLabel(provider)}."
        : "Imported ${activities.length} run${activities.length == 1 ? "" : "s"} from ${runningWatchProviderLabel(provider)}.",
    activities: activities,
  );
}

bool _isRunWorkout(HealthWorkoutActivityType workoutType) {
  return workoutType == HealthWorkoutActivityType.RUNNING ||
      workoutType == HealthWorkoutActivityType.RUNNING_TREADMILL;
}

double _distanceKm(int? value, HealthDataUnit? unit) {
  if (value == null || value <= 0) {
    return 0;
  }
  switch (unit) {
    case HealthDataUnit.METER:
      return value / 1000.0;
    case HealthDataUnit.MILE:
      return value * 1.609344;
    case HealthDataUnit.YARD:
      return value * 0.0009144;
    case HealthDataUnit.FOOT:
      return value * 0.0003048;
    case HealthDataUnit.CENTIMETER:
      return value / 100000.0;
    default:
      // Health workout distance is generally meters on iOS/Android.
      return value / 1000.0;
  }
}
