import "package:flutter/material.dart";

class CosmeticVisual {
  const CosmeticVisual({required this.color, required this.icon});

  final Color color;
  final IconData icon;
}

const Map<String, CosmeticVisual>
_knownCosmeticVisuals = <String, CosmeticVisual>{
  "obsidian_frame": CosmeticVisual(
    color: Color(0xFF2B2D31),
    icon: Icons.dark_mode,
  ),
  "ember_frame": CosmeticVisual(
    color: Color(0xFFB87333),
    icon: Icons.local_fire_department,
  ),
  "sunrise_frame": CosmeticVisual(
    color: Color(0xFFFF9800),
    icon: Icons.wb_sunny,
  ),
  "azure_frame": CosmeticVisual(
    color: Color(0xFF2A7FFF),
    icon: Icons.water_drop,
  ),
  "forest_frame": CosmeticVisual(color: Color(0xFF2E7D32), icon: Icons.park),
  "crimson_frame": CosmeticVisual(
    color: Color(0xFFC62828),
    icon: Icons.whatshot,
  ),
  "neon_frame": CosmeticVisual(color: Color(0xFF00C853), icon: Icons.bolt),
  "glacier_frame": CosmeticVisual(
    color: Color(0xFF4FC3F7),
    icon: Icons.ac_unit,
  ),
  "storm_frame": CosmeticVisual(
    color: Color(0xFF546E7A),
    icon: Icons.thunderstorm,
  ),
  "royal_frame": CosmeticVisual(
    color: Color(0xFF8E24AA),
    icon: Icons.auto_awesome,
  ),
  "aurora_frame": CosmeticVisual(color: Color(0xFF26A69A), icon: Icons.blur_on),
  "sandstorm_frame": CosmeticVisual(
    color: Color(0xFFCD9B5B),
    icon: Icons.waves,
  ),
  "cobalt_frame": CosmeticVisual(color: Color(0xFF1E4FBF), icon: Icons.science),
  "titan_frame": CosmeticVisual(
    color: Color(0xFF757575),
    icon: Icons.fitness_center,
  ),
  "plasma_frame": CosmeticVisual(
    color: Color(0xFFFF5C8A),
    icon: Icons.flash_on,
  ),
  "carbon_frame": CosmeticVisual(color: Color(0xFF37474F), icon: Icons.hexagon),
  "legend_frame": CosmeticVisual(
    color: Color(0xFFFFD54F),
    icon: Icons.workspace_premium,
  ),
  "moonlight_frame": CosmeticVisual(
    color: Color(0xFFB0BEC5),
    icon: Icons.nightlight_round,
  ),
  "eclipse_frame": CosmeticVisual(
    color: Color(0xFF5E35B1),
    icon: Icons.dark_mode,
  ),
  "inferno_frame": CosmeticVisual(
    color: Color(0xFFE53935),
    icon: Icons.whatshot,
  ),
  "zenith_frame": CosmeticVisual(
    color: Color(0xFFFFEE58),
    icon: Icons.emoji_events,
  ),
  "mythic_frame": CosmeticVisual(
    color: Color(0xFFFFB300),
    icon: Icons.auto_awesome,
  ),
};

const List<Color> _generatedColors = <Color>[
  Color(0xFFEF5350),
  Color(0xFFAB47BC),
  Color(0xFF5C6BC0),
  Color(0xFF29B6F6),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFFFFCA28),
  Color(0xFFFF7043),
];

const List<IconData> _generatedIcons = <IconData>[
  Icons.stars,
  Icons.auto_graph,
  Icons.bolt,
  Icons.rocket_launch,
  Icons.public,
  Icons.flare,
  Icons.nights_stay,
  Icons.brightness_5,
];

CosmeticVisual cosmeticVisualForId(String? id, {required Color fallbackColor}) {
  final clean = id?.trim();
  if (clean == null || clean.isEmpty) {
    return CosmeticVisual(color: fallbackColor, icon: Icons.style);
  }

  final known = _knownCosmeticVisuals[clean];
  if (known != null) {
    return known;
  }

  // Deterministic fallback for newly added IDs so UI still looks intentional.
  final hash = clean.codeUnits.fold<int>(
    0,
    (acc, n) => (acc * 31 + n) & 0x7fffffff,
  );
  final color = _generatedColors[hash % _generatedColors.length];
  final icon =
      _generatedIcons[(hash ~/ _generatedColors.length) %
          _generatedIcons.length];
  return CosmeticVisual(color: color, icon: icon);
}
