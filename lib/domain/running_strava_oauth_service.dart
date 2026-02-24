import "dart:convert";
import "dart:math";

import "package:http/http.dart" as http;

import "running_activity.dart";
import "running_connector_credentials.dart";
import "running_strava_oauth_config.dart";

class RunningStravaOAuthCallback {
  const RunningStravaOAuthCallback({
    required this.code,
    required this.state,
    required this.error,
    required this.scope,
  });

  final String? code;
  final String? state;
  final String? error;
  final String? scope;
}

class RunningStravaOAuthException implements Exception {
  const RunningStravaOAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RunningStravaOAuthService {
  const RunningStravaOAuthService._();

  static Uri authorizationUri({
    required RunningStravaOAuthConfig config,
    required String state,
    bool forceApproval = false,
  }) {
    return Uri.https("www.strava.com", "/oauth/mobile/authorize", {
      "client_id": config.clientId,
      "redirect_uri": config.redirectUri.toString(),
      "response_type": "code",
      "approval_prompt": forceApproval ? "force" : "auto",
      "scope": config.scope,
      "state": state,
    });
  }

  static RunningStravaOAuthCallback parseCallback(Uri uri) {
    return RunningStravaOAuthCallback(
      code: _normalize(uri.queryParameters["code"]),
      state: _normalize(uri.queryParameters["state"]),
      error: _normalize(uri.queryParameters["error"]),
      scope: _normalize(uri.queryParameters["scope"]),
    );
  }

  static bool isMatchingRedirect({
    required Uri incomingUri,
    required Uri redirectUri,
  }) {
    if (incomingUri.scheme.toLowerCase() != redirectUri.scheme.toLowerCase()) {
      return false;
    }

    final expectedHost = redirectUri.host.toLowerCase();
    if (expectedHost.isNotEmpty &&
        incomingUri.host.toLowerCase() != expectedHost) {
      return false;
    }

    final expectedPath = redirectUri.path;
    if (expectedPath.isNotEmpty &&
        expectedPath != "/" &&
        incomingUri.path != expectedPath) {
      return false;
    }

    return true;
  }

  static bool hasActivityReadScope(String? scope) {
    final text = (scope ?? "").trim();
    if (text.isEmpty) {
      return false;
    }
    final scopes = text
        .split(",")
        .map((x) => x.trim().toLowerCase())
        .where((x) => x.isNotEmpty)
        .toSet();
    return scopes.contains("activity:read") ||
        scopes.contains("activity:read_all");
  }

  static String generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll("=", "");
  }

  static bool shouldRefreshCredential(
    RunningConnectorCredential credential, {
    DateTime? now,
    Duration refreshWindow = const Duration(minutes: 45),
  }) {
    final expiry = credential.expiresAt;
    if (expiry == null) {
      return false;
    }
    final clock = now ?? DateTime.now();
    return !expiry.isAfter(clock.add(refreshWindow));
  }

  static Future<RunningConnectorCredential> exchangeCode({
    required RunningStravaOAuthConfig config,
    required String code,
    DateTime? now,
    http.Client? client,
  }) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      throw const RunningStravaOAuthException(
        "Missing Strava authorization code.",
      );
    }
    _assertConfigured(config);
    return _requestToken(
      config: config,
      payload: <String, String>{
        "client_id": config.clientId,
        "client_secret": config.clientSecret,
        "code": cleanCode,
        "grant_type": "authorization_code",
      },
      now: now,
      existing: null,
      client: client,
    );
  }

  static Future<RunningConnectorCredential> refreshCredential({
    required RunningStravaOAuthConfig config,
    required RunningConnectorCredential existing,
    DateTime? now,
    http.Client? client,
  }) async {
    final refreshToken = (existing.refreshToken ?? "").trim();
    if (refreshToken.isEmpty) {
      throw const RunningStravaOAuthException(
        "Strava refresh token is missing. Reconnect Strava.",
      );
    }
    _assertConfigured(config);

    return _requestToken(
      config: config,
      payload: <String, String>{
        "client_id": config.clientId,
        "client_secret": config.clientSecret,
        "grant_type": "refresh_token",
        "refresh_token": refreshToken,
      },
      now: now,
      existing: existing,
      client: client,
    );
  }

  static Future<RunningConnectorCredential> _requestToken({
    required RunningStravaOAuthConfig config,
    required Map<String, String> payload,
    required DateTime? now,
    required RunningConnectorCredential? existing,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final shouldClose = client == null;

    try {
      final response = await httpClient
          .post(
            Uri.https("www.strava.com", "/api/v3/oauth/token"),
            body: payload,
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decoded = _decodeMap(response.body);
        final message = _normalize(decoded?["message"]?.toString());
        final errors = decoded?["errors"];
        final extra = errors is List && errors.isNotEmpty
            ? errors.first.toString()
            : null;
        throw RunningStravaOAuthException(
          message ??
              extra ??
              "Strava OAuth failed (${response.statusCode}). Check app credentials and callback URL.",
        );
      }

      final decoded = _decodeMap(response.body);
      if (decoded == null) {
        throw const RunningStravaOAuthException(
          "Unexpected Strava OAuth response payload.",
        );
      }

      final accessToken = _normalize(decoded["access_token"]?.toString()) ?? "";
      if (accessToken.isEmpty) {
        throw const RunningStravaOAuthException(
          "Strava OAuth did not return an access token.",
        );
      }

      final refreshToken =
          _normalize(decoded["refresh_token"]?.toString()) ??
          (existing?.refreshToken ?? "");
      final expiresAt = _parseEpochSeconds(decoded["expires_at"]);
      final athleteId =
          _parseAthleteId(decoded["athlete"]) ?? existing?.athleteId;

      return RunningConnectorCredential(
        provider: RunningWatchProvider.strava,
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
        athleteId: athleteId,
        updatedAt: now ?? DateTime.now(),
      );
    } on RunningStravaOAuthException {
      rethrow;
    } catch (_) {
      throw const RunningStravaOAuthException(
        "Strava OAuth request failed. Check network and try again.",
      );
    } finally {
      if (shouldClose) {
        httpClient.close();
      }
    }
  }

  static void _assertConfigured(RunningStravaOAuthConfig config) {
    if (config.isConfigured) {
      return;
    }
    final missing = config.missingSettingsLabel;
    throw RunningStravaOAuthException(
      missing.isEmpty
          ? "Strava OAuth is not configured."
          : "Strava OAuth missing: $missing.",
    );
  }

  static Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseEpochSeconds(Object? raw) {
    if (raw == null) {
      return null;
    }
    int? epochSeconds;
    if (raw is int) {
      epochSeconds = raw;
    } else if (raw is num) {
      epochSeconds = raw.round();
    } else {
      epochSeconds = int.tryParse(raw.toString());
    }
    if (epochSeconds == null || epochSeconds <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      epochSeconds * 1000,
      isUtc: true,
    ).toLocal();
  }

  static String? _parseAthleteId(Object? rawAthlete) {
    if (rawAthlete is! Map) {
      return null;
    }
    final id = rawAthlete["id"];
    if (id == null) {
      return null;
    }
    return id.toString();
  }

  static String? _normalize(String? value) {
    final trimmed = (value ?? "").trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
