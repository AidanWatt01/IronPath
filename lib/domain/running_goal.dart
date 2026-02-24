import "dart:convert";

enum RunningGoalType { distanceByDate, getFaster }

RunningGoalType runningGoalTypeFromRaw(String? raw) {
  final value = (raw ?? "").trim().toLowerCase();
  if (value == "get_faster") {
    return RunningGoalType.getFaster;
  }
  return RunningGoalType.distanceByDate;
}

String runningGoalTypeToRaw(RunningGoalType type) {
  return switch (type) {
    RunningGoalType.distanceByDate => "distance_by_date",
    RunningGoalType.getFaster => "get_faster",
  };
}

class RunningGoalConfig {
  const RunningGoalConfig({
    required this.type,
    required this.targetDistanceKm,
    required this.targetDate,
    required this.baselineDistanceKm,
    required this.baselineDurationMinutes,
    this.targetDurationMinutes,
    this.notes,
    this.createdAt,
  });

  final RunningGoalType type;
  final double targetDistanceKm;
  final DateTime targetDate;
  final double baselineDistanceKm;
  final int baselineDurationMinutes;
  final int? targetDurationMinutes;
  final String? notes;
  final DateTime? createdAt;

  bool get isValid {
    if (targetDistanceKm <= 0 || baselineDistanceKm <= 0) {
      return false;
    }
    if (baselineDurationMinutes <= 0) {
      return false;
    }
    if (type == RunningGoalType.getFaster &&
        (targetDurationMinutes == null || targetDurationMinutes! <= 0)) {
      return false;
    }
    return true;
  }

  Map<String, Object?> toJsonMap() {
    return <String, Object?>{
      "type": runningGoalTypeToRaw(type),
      "targetDistanceKm": targetDistanceKm,
      "targetDate": targetDate.toIso8601String(),
      "baselineDistanceKm": baselineDistanceKm,
      "baselineDurationMinutes": baselineDurationMinutes,
      "targetDurationMinutes": targetDurationMinutes,
      "notes": notes,
      "createdAt": (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJsonMap());

  RunningGoalConfig copyWith({
    RunningGoalType? type,
    double? targetDistanceKm,
    DateTime? targetDate,
    double? baselineDistanceKm,
    int? baselineDurationMinutes,
    int? targetDurationMinutes,
    bool clearTargetDurationMinutes = false,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
  }) {
    return RunningGoalConfig(
      type: type ?? this.type,
      targetDistanceKm: targetDistanceKm ?? this.targetDistanceKm,
      targetDate: targetDate ?? this.targetDate,
      baselineDistanceKm: baselineDistanceKm ?? this.baselineDistanceKm,
      baselineDurationMinutes:
          baselineDurationMinutes ?? this.baselineDurationMinutes,
      targetDurationMinutes: clearTargetDurationMinutes
          ? null
          : (targetDurationMinutes ?? this.targetDurationMinutes),
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static RunningGoalConfig? fromJsonString(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return fromJsonMap(decoded);
    } catch (_) {
      return null;
    }
  }

  static RunningGoalConfig? fromJsonMap(Map<String, dynamic> map) {
    final targetDistance = _readDouble(map["targetDistanceKm"]);
    final baselineDistance = _readDouble(map["baselineDistanceKm"]);
    final baselineDuration = _readInt(map["baselineDurationMinutes"]);
    final targetDuration = _readIntNullable(map["targetDurationMinutes"]);
    final targetDate = _readDate(map["targetDate"]);

    if (targetDistance == null ||
        baselineDistance == null ||
        baselineDuration == null ||
        targetDate == null) {
      return null;
    }

    final config = RunningGoalConfig(
      type: runningGoalTypeFromRaw(map["type"]?.toString()),
      targetDistanceKm: targetDistance,
      targetDate: targetDate,
      baselineDistanceKm: baselineDistance,
      baselineDurationMinutes: baselineDuration,
      targetDurationMinutes: targetDuration,
      notes: map["notes"]?.toString(),
      createdAt: _readDate(map["createdAt"]),
    );

    if (!config.isValid) {
      return null;
    }

    return config;
  }

  static double? _readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static int? _readIntNullable(Object? value) {
    if (value == null) return null;
    return _readInt(value);
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
