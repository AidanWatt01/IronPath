import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

/// Optional: hand-picked, “best” links for some movements.
/// Anything not listed falls back to a YouTube search results URL.
const Map<String, String> kMovementYoutubeOverride = <String, String>{
  // Example overrides (add as you curate):
  // "pull_up": "https://www.youtube.com/watch?v=XXXXXXXXXXX",
  // "front_lever": "https://www.youtube.com/watch?v=YYYYYYYYYYY",
};

String youtubeUrlForMovement({
  required String movementId,
  required String movementName,
}) {
  final override = kMovementYoutubeOverride[movementId];
  if (override != null && override.trim().isNotEmpty) return override;

  // YouTube supports search via: /results?search_query=...
  // This reliably returns videos for the query. :contentReference[oaicite:1]{index=1}
  final q = Uri.encodeComponent("$movementName calisthenics tutorial");
  return "https://www.youtube.com/results?search_query=$q";
}

Future<void> openYoutubeForMovement(
  BuildContext context, {
  required String movementId,
  required String movementName,
}) async {
  final url = youtubeUrlForMovement(
    movementId: movementId,
    movementName: movementName,
  );
  final uri = Uri.parse(url);

  // External app mode usually opens the YouTube app if installed.
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!ok && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Could not open YouTube")));
  }
}
