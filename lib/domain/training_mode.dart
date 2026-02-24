enum TrainingMode { calisthenics, running }

TrainingMode trainingModeFromRaw(String? raw) {
  final value = (raw ?? "").trim().toLowerCase();
  if (value == "running") {
    return TrainingMode.running;
  }
  return TrainingMode.calisthenics;
}

String trainingModeToRaw(TrainingMode mode) {
  return switch (mode) {
    TrainingMode.calisthenics => "calisthenics",
    TrainingMode.running => "running",
  };
}
