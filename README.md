# Cali Skill Tree

Calisthenics progression tracker with:
- Skill tree progression and prerequisite gates
- Movement mastery tiers (progress/bronze/silver/gold/mastered)
- Quick logging and workout history
- Badge/achievement tracking

## Development

- Install deps: `flutter pub get`
- Analyze: `dart analyze`
- Test: `flutter test`
- Run: `flutter run`

### Strava OAuth (Running Mode)

Set Strava app credentials via `--dart-define`:

- `STRAVA_CLIENT_ID`
- `STRAVA_CLIENT_SECRET`
- optional `STRAVA_REDIRECT_URI` (default: `caliskilltree://strava-oauth/callback`)
- optional `STRAVA_SCOPE` (default: `activity:read_all`)

Example:

`flutter run --dart-define=STRAVA_CLIENT_ID=12345 --dart-define=STRAVA_CLIENT_SECRET=xxxx`

In your Strava API app settings, configure the callback URL to match the redirect URI.

## Web Database Assets (Drift WASM)

The web build expects these files in `web/`:
- `sqlite3.wasm`
- `drift_worker.js`

Regenerate worker after Drift upgrades:
- `dart compile js web/drift_worker.dart -O4 -o web/drift_worker.js`

## Android Release Signing

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Fill in your real keystore values.
3. Build release: `flutter build appbundle` or `flutter build apk --release`.

If `android/key.properties` is missing, release builds fall back to debug signing for local/dev only.
