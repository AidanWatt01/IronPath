import "running_activity.dart";
import "running_goal.dart";
import "running_health_bridge_model.dart";

Future<RunningHealthImportResult> importRunsFromNativeHealth({
  required RunningWatchProvider provider,
  required RunningGoalConfig? goal,
  required DateTime now,
  DateTime? after,
}) async {
  return RunningHealthImportResult(
    success: false,
    message:
        "${runningWatchProviderLabel(provider)} native sync is not available on this platform.",
    activities: const <RunningActivity>[],
  );
}
