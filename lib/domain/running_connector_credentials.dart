import "dart:convert";

import "running_activity.dart";

class RunningConnectorCredential {
  const RunningConnectorCredential({
    required this.provider,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.athleteId,
    this.updatedAt,
  });

  final RunningWatchProvider provider;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String? athleteId;
  final DateTime? updatedAt;

  bool get hasAccessToken => accessToken.trim().isNotEmpty;

  RunningConnectorCredential copyWith({
    RunningWatchProvider? provider,
    String? accessToken,
    String? refreshToken,
    bool clearRefreshToken = false,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    String? athleteId,
    bool clearAthleteId = false,
    DateTime? updatedAt,
  }) {
    return RunningConnectorCredential(
      provider: provider ?? this.provider,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: clearRefreshToken
          ? null
          : (refreshToken ?? this.refreshToken),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      athleteId: clearAthleteId ? null : (athleteId ?? this.athleteId),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJsonMap() {
    return <String, Object?>{
      "provider": runningWatchProviderToRaw(provider),
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "expiresAt": expiresAt?.toIso8601String(),
      "athleteId": athleteId,
      "updatedAt": (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  static RunningConnectorCredential? fromJsonMap(Map<String, dynamic> map) {
    final provider = runningWatchProviderFromRaw(map["provider"]?.toString());
    final accessToken = map["accessToken"]?.toString().trim() ?? "";
    if (accessToken.isEmpty) {
      return null;
    }

    return RunningConnectorCredential(
      provider: provider,
      accessToken: accessToken,
      refreshToken: map["refreshToken"]?.toString(),
      expiresAt: DateTime.tryParse(map["expiresAt"]?.toString() ?? ""),
      athleteId: map["athleteId"]?.toString(),
      updatedAt: DateTime.tryParse(map["updatedAt"]?.toString() ?? ""),
    );
  }
}

String encodeConnectorCredentialMap(
  Map<RunningWatchProvider, RunningConnectorCredential> values,
) {
  final map = <String, Object?>{};
  for (final entry in values.entries) {
    map[runningWatchProviderToRaw(entry.key)] = entry.value.toJsonMap();
  }
  return jsonEncode(map);
}

Map<RunningWatchProvider, RunningConnectorCredential>
decodeConnectorCredentialMap(String? raw) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) {
    return const <RunningWatchProvider, RunningConnectorCredential>{};
  }

  try {
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      return const <RunningWatchProvider, RunningConnectorCredential>{};
    }

    final out = <RunningWatchProvider, RunningConnectorCredential>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        continue;
      }
      final cred = RunningConnectorCredential.fromJsonMap(value);
      if (cred == null) {
        continue;
      }
      out[cred.provider] = cred;
    }
    return out;
  } catch (_) {
    return const <RunningWatchProvider, RunningConnectorCredential>{};
  }
}
