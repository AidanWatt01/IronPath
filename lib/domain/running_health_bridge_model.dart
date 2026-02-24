import "running_activity.dart";

class RunningHealthImportResult {
  const RunningHealthImportResult({
    required this.success,
    required this.message,
    required this.activities,
  });

  final bool success;
  final String message;
  final List<RunningActivity> activities;
}
