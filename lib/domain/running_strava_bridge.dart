import "dart:convert";

import "package:http/http.dart" as http;

import "running_activity.dart";
import "running_connector_credentials.dart";
import "running_health_bridge_model.dart";

class RunningStravaBridge {
  const RunningStravaBridge._();

  static Future<RunningHealthImportResult> importRuns({
    required RunningConnectorCredential credential,
    required DateTime now,
    DateTime? after,
    http.Client? client,
  }) async {
    final token = credential.accessToken.trim();
    if (token.isEmpty) {
      return const RunningHealthImportResult(
        success: false,
        message: "Missing Strava access token.",
        activities: <RunningActivity>[],
      );
    }

    final httpClient = client ?? http.Client();
    final shouldClose = client == null;

    try {
      final all = <RunningActivity>[];
      final fallbackStart = now.subtract(const Duration(days: 120));
      var effectiveAfter = after ?? fallbackStart;
      if (!effectiveAfter.isBefore(now)) {
        effectiveAfter = fallbackStart;
      }
      final maxLookback = now.subtract(const Duration(days: 365));
      if (effectiveAfter.isBefore(maxLookback)) {
        effectiveAfter = maxLookback;
      }
      final afterEpoch = effectiveAfter.millisecondsSinceEpoch ~/ 1000;
      var page = 1;
      const perPage = 100;

      while (page <= 5) {
        final uri = Uri.https("www.strava.com", "/api/v3/athlete/activities", {
          "after": "$afterEpoch",
          "per_page": "$perPage",
          "page": "$page",
        });

        final response = await httpClient
            .get(
              uri,
              headers: <String, String>{
                "Authorization": "Bearer $token",
                "Accept": "application/json",
              },
            )
            .timeout(const Duration(seconds: 18));

        if (response.statusCode == 401 || response.statusCode == 403) {
          return const RunningHealthImportResult(
            success: false,
            message: "Strava authorization failed. Refresh your access token.",
            activities: <RunningActivity>[],
          );
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          return RunningHealthImportResult(
            success: false,
            message:
                "Strava sync failed (${response.statusCode}). Try again later.",
            activities: const <RunningActivity>[],
          );
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          return const RunningHealthImportResult(
            success: false,
            message: "Unexpected Strava response payload.",
            activities: <RunningActivity>[],
          );
        }

        if (decoded.isEmpty) {
          break;
        }

        for (final item in decoded) {
          if (item is! Map) {
            continue;
          }
          final activity = _toActivity(item.cast<String, dynamic>());
          if (activity != null) {
            all.add(activity);
          }
        }

        if (decoded.length < perPage) {
          break;
        }
        page += 1;
      }

      all.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return RunningHealthImportResult(
        success: true,
        message: all.isEmpty
            ? "No running activities found on Strava."
            : "Imported ${all.length} runs from Strava.",
        activities: all,
      );
    } catch (_) {
      return const RunningHealthImportResult(
        success: false,
        message: "Failed to reach Strava API. Check network and token.",
        activities: <RunningActivity>[],
      );
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }

  static RunningActivity? _toActivity(Map<String, dynamic> raw) {
    final type = raw["type"]?.toString() ?? "";
    final sportType = raw["sport_type"]?.toString() ?? "";
    final isRun =
        type == "Run" || sportType == "Run" || sportType == "TrailRun";
    if (!isRun) {
      return null;
    }

    final id = raw["id"]?.toString().trim() ?? "";
    if (id.isEmpty) {
      return null;
    }

    final distanceMeters = _readDouble(raw["distance"]);
    final movingSeconds = _readInt(raw["moving_time"]);
    if (distanceMeters == null ||
        distanceMeters <= 0 ||
        movingSeconds == null ||
        movingSeconds <= 0) {
      return null;
    }

    final start =
        DateTime.tryParse(raw["start_date"]?.toString() ?? "") ??
        DateTime.tryParse(raw["start_date_local"]?.toString() ?? "");
    if (start == null) {
      return null;
    }

    return RunningActivity(
      id: "strava_$id",
      provider: RunningWatchProvider.strava,
      startedAt: start,
      distanceKm: distanceMeters / 1000.0,
      durationSeconds: movingSeconds,
      avgHeartRate: _readIntNullable(raw["average_heartrate"]),
      elevationGainMeters: _readIntNullable(raw["total_elevation_gain"]),
    );
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
