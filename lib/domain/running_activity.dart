import "dart:convert";

enum RunningWatchProvider {
  appleHealth,
  healthConnect,
  garmin,
  coros,
  strava,
  manual,
}

String runningWatchProviderToRaw(RunningWatchProvider provider) {
  return switch (provider) {
    RunningWatchProvider.appleHealth => "apple_health",
    RunningWatchProvider.healthConnect => "health_connect",
    RunningWatchProvider.garmin => "garmin",
    RunningWatchProvider.coros => "coros",
    RunningWatchProvider.strava => "strava",
    RunningWatchProvider.manual => "manual",
  };
}

RunningWatchProvider runningWatchProviderFromRaw(String? raw) {
  final value = (raw ?? "").trim().toLowerCase();
  return switch (value) {
    "apple_health" => RunningWatchProvider.appleHealth,
    "health_connect" => RunningWatchProvider.healthConnect,
    "garmin" => RunningWatchProvider.garmin,
    "coros" => RunningWatchProvider.coros,
    "strava" => RunningWatchProvider.strava,
    "manual" => RunningWatchProvider.manual,
    _ => RunningWatchProvider.manual,
  };
}

String runningWatchProviderLabel(RunningWatchProvider provider) {
  return switch (provider) {
    RunningWatchProvider.appleHealth => "Apple Health",
    RunningWatchProvider.healthConnect => "Health Connect",
    RunningWatchProvider.garmin => "Garmin",
    RunningWatchProvider.coros => "COROS",
    RunningWatchProvider.strava => "Strava",
    RunningWatchProvider.manual => "Manual",
  };
}

class RunningActivity {
  const RunningActivity({
    required this.id,
    required this.provider,
    required this.startedAt,
    required this.distanceKm,
    required this.durationSeconds,
    this.avgHeartRate,
    this.elevationGainMeters,
  });

  final String id;
  final RunningWatchProvider provider;
  final DateTime startedAt;
  final double distanceKm;
  final int durationSeconds;
  final int? avgHeartRate;
  final int? elevationGainMeters;

  bool get isValid {
    if (distanceKm <= 0) return false;
    if (durationSeconds <= 0) return false;
    return true;
  }

  double get paceMinutesPerKm {
    if (distanceKm <= 0) return 0;
    return (durationSeconds / 60.0) / distanceKm;
  }

  Map<String, Object?> toJsonMap() {
    return <String, Object?>{
      "id": id,
      "provider": runningWatchProviderToRaw(provider),
      "startedAt": startedAt.toIso8601String(),
      "distanceKm": distanceKm,
      "durationSeconds": durationSeconds,
      "avgHeartRate": avgHeartRate,
      "elevationGainMeters": elevationGainMeters,
    };
  }

  static RunningActivity? fromJsonMap(Map<String, dynamic> map) {
    final id = map["id"]?.toString().trim() ?? "";
    final startedAt = DateTime.tryParse(map["startedAt"]?.toString() ?? "");
    final distanceKm = _readDouble(map["distanceKm"]);
    final durationSeconds = _readInt(map["durationSeconds"]);
    if (id.isEmpty ||
        startedAt == null ||
        distanceKm == null ||
        durationSeconds == null) {
      return null;
    }

    final activity = RunningActivity(
      id: id,
      provider: runningWatchProviderFromRaw(map["provider"]?.toString()),
      startedAt: startedAt,
      distanceKm: distanceKm,
      durationSeconds: durationSeconds,
      avgHeartRate: _readIntNullable(map["avgHeartRate"]),
      elevationGainMeters: _readIntNullable(map["elevationGainMeters"]),
    );
    return activity.isValid ? activity : null;
  }

  static List<RunningActivity> listFromJsonString(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) {
      return const <RunningActivity>[];
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) {
        return const <RunningActivity>[];
      }

      final out = <RunningActivity>[];
      for (final item in decoded) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final x = RunningActivity.fromJsonMap(item);
        if (x != null) {
          out.add(x);
        }
      }
      out.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return out;
    } catch (_) {
      return const <RunningActivity>[];
    }
  }

  static String listToJsonString(List<RunningActivity> activities) {
    final values = activities.map((x) => x.toJsonMap()).toList();
    return jsonEncode(values);
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
}

class RunningWatchSyncState {
  const RunningWatchSyncState({
    required this.connectedProviders,
    required this.totalImportedRuns,
    this.lastSyncedAt,
    this.lastSyncMessage,
    this.lastSyncedAtByProvider = const <RunningWatchProvider, DateTime>{},
  });

  final Set<RunningWatchProvider> connectedProviders;
  final int totalImportedRuns;
  final DateTime? lastSyncedAt;
  final String? lastSyncMessage;
  final Map<RunningWatchProvider, DateTime> lastSyncedAtByProvider;

  RunningWatchSyncState copyWith({
    Set<RunningWatchProvider>? connectedProviders,
    int? totalImportedRuns,
    DateTime? lastSyncedAt,
    bool clearLastSyncedAt = false,
    String? lastSyncMessage,
    bool clearLastSyncMessage = false,
    Map<RunningWatchProvider, DateTime>? lastSyncedAtByProvider,
  }) {
    return RunningWatchSyncState(
      connectedProviders: connectedProviders ?? this.connectedProviders,
      totalImportedRuns: totalImportedRuns ?? this.totalImportedRuns,
      lastSyncedAt: clearLastSyncedAt
          ? null
          : (lastSyncedAt ?? this.lastSyncedAt),
      lastSyncMessage: clearLastSyncMessage
          ? null
          : (lastSyncMessage ?? this.lastSyncMessage),
      lastSyncedAtByProvider:
          lastSyncedAtByProvider ?? this.lastSyncedAtByProvider,
    );
  }

  DateTime? lastSyncedForProvider(RunningWatchProvider provider) {
    return lastSyncedAtByProvider[provider];
  }

  Map<String, Object?> toJsonMap() {
    final providerSyncMap = <String, String>{};
    for (final entry in lastSyncedAtByProvider.entries) {
      providerSyncMap[runningWatchProviderToRaw(entry.key)] = entry.value
          .toIso8601String();
    }

    return <String, Object?>{
      "connectedProviders": connectedProviders
          .map(runningWatchProviderToRaw)
          .toList(),
      "totalImportedRuns": totalImportedRuns,
      "lastSyncedAt": lastSyncedAt?.toIso8601String(),
      "lastSyncMessage": lastSyncMessage,
      "lastSyncedAtByProvider": providerSyncMap,
    };
  }

  String toJsonString() => jsonEncode(toJsonMap());

  static RunningWatchSyncState fromJsonString(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) {
      return const RunningWatchSyncState(
        connectedProviders: <RunningWatchProvider>{},
        totalImportedRuns: 0,
      );
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return const RunningWatchSyncState(
          connectedProviders: <RunningWatchProvider>{},
          totalImportedRuns: 0,
        );
      }

      final providers = <RunningWatchProvider>{};
      final rawProviders = decoded["connectedProviders"];
      if (rawProviders is List) {
        for (final item in rawProviders) {
          providers.add(runningWatchProviderFromRaw(item?.toString()));
        }
      }

      final providerSyncMap = <RunningWatchProvider, DateTime>{};
      final rawProviderSync = decoded["lastSyncedAtByProvider"];
      if (rawProviderSync is Map<String, dynamic>) {
        for (final entry in rawProviderSync.entries) {
          final provider = runningWatchProviderFromRaw(entry.key);
          final parsed = DateTime.tryParse(entry.value?.toString() ?? "");
          if (parsed == null) {
            continue;
          }
          providerSyncMap[provider] = parsed;
        }
      }

      return RunningWatchSyncState(
        connectedProviders: providers,
        totalImportedRuns: _readInt(decoded["totalImportedRuns"]) ?? 0,
        lastSyncedAt: DateTime.tryParse(
          decoded["lastSyncedAt"]?.toString() ?? "",
        ),
        lastSyncMessage: decoded["lastSyncMessage"]?.toString(),
        lastSyncedAtByProvider: providerSyncMap,
      );
    } catch (_) {
      return const RunningWatchSyncState(
        connectedProviders: <RunningWatchProvider>{},
        totalImportedRuns: 0,
      );
    }
  }

  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}
