class RunningStravaOAuthConfig {
  const RunningStravaOAuthConfig({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.scope,
  });

  final String clientId;
  final String clientSecret;
  final Uri redirectUri;
  final String scope;

  bool get hasClientId => clientId.trim().isNotEmpty;
  bool get hasClientSecret => clientSecret.trim().isNotEmpty;
  bool get isConfigured => hasClientId && hasClientSecret;

  String get missingSettingsLabel {
    final missing = <String>[];
    if (!hasClientId) {
      missing.add("STRAVA_CLIENT_ID");
    }
    if (!hasClientSecret) {
      missing.add("STRAVA_CLIENT_SECRET");
    }
    return missing.join(", ");
  }

  static RunningStravaOAuthConfig fromEnvironment() {
    final redirectRaw = const String.fromEnvironment(
      "STRAVA_REDIRECT_URI",
      defaultValue: "caliskilltree://strava-oauth/callback",
    );
    final redirectUri =
        Uri.tryParse(redirectRaw) ??
        Uri.parse("caliskilltree://strava-oauth/callback");

    return RunningStravaOAuthConfig(
      clientId: const String.fromEnvironment("STRAVA_CLIENT_ID"),
      clientSecret: const String.fromEnvironment("STRAVA_CLIENT_SECRET"),
      redirectUri: redirectUri,
      scope: const String.fromEnvironment(
        "STRAVA_SCOPE",
        defaultValue: "activity:read_all",
      ),
    );
  }
}
