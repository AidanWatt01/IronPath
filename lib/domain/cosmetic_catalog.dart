class CosmeticDefinition {
  const CosmeticDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.costCoins,
  });

  final String id;
  final String name;
  final String description;
  final int costCoins;
}

class CosmeticCatalog {
  static const obsidianFrame = CosmeticDefinition(
    id: "obsidian_frame",
    name: "Obsidian Frame",
    description: "Matte black frame for a minimalist elite style.",
    costCoins: 90,
  );

  static const emberFrame = CosmeticDefinition(
    id: "ember_frame",
    name: "Ember Frame",
    description: "Warm bronze frame around your progress card.",
    costCoins: 140,
  );

  static const sunriseFrame = CosmeticDefinition(
    id: "sunrise_frame",
    name: "Sunrise Frame",
    description: "Orange-gold style inspired by morning training.",
    costCoins: 190,
  );

  static const azureFrame = CosmeticDefinition(
    id: "azure_frame",
    name: "Azure Frame",
    description: "Cool steel-blue frame for a focused look.",
    costCoins: 240,
  );

  static const forestFrame = CosmeticDefinition(
    id: "forest_frame",
    name: "Forest Frame",
    description: "Deep green accent for outdoor training energy.",
    costCoins: 290,
  );

  static const crimsonFrame = CosmeticDefinition(
    id: "crimson_frame",
    name: "Crimson Frame",
    description: "Aggressive red style for max-intensity sessions.",
    costCoins: 330,
  );

  static const neonFrame = CosmeticDefinition(
    id: "neon_frame",
    name: "Neon Frame",
    description: "Electric green glow for high-intensity sessions.",
    costCoins: 360,
  );

  static const glacierFrame = CosmeticDefinition(
    id: "glacier_frame",
    name: "Glacier Frame",
    description: "Icy blue-white frame with a clean sharp finish.",
    costCoins: 420,
  );

  static const stormFrame = CosmeticDefinition(
    id: "storm_frame",
    name: "Storm Frame",
    description: "Slate and steel palette for disciplined consistency.",
    costCoins: 480,
  );

  static const royalFrame = CosmeticDefinition(
    id: "royal_frame",
    name: "Royal Frame",
    description: "Purple-gold frame for late-game prestige.",
    costCoins: 520,
  );

  static const auroraFrame = CosmeticDefinition(
    id: "aurora_frame",
    name: "Aurora Frame",
    description: "Vibrant dual-tone frame for standout progression.",
    costCoins: 650,
  );

  static const sandstormFrame = CosmeticDefinition(
    id: "sandstorm_frame",
    name: "Sandstorm Frame",
    description: "Dust-gold style inspired by desert conditioning blocks.",
    costCoins: 720,
  );

  static const cobaltFrame = CosmeticDefinition(
    id: "cobalt_frame",
    name: "Cobalt Frame",
    description: "Bold deep-blue frame for technical training days.",
    costCoins: 760,
  );

  static const titanFrame = CosmeticDefinition(
    id: "titan_frame",
    name: "Titan Frame",
    description: "Industrial steel look for heavy strength progressions.",
    costCoins: 800,
  );

  static const plasmaFrame = CosmeticDefinition(
    id: "plasma_frame",
    name: "Plasma Frame",
    description: "Hot pink-orange energy style for high-output sessions.",
    costCoins: 840,
  );

  static const carbonFrame = CosmeticDefinition(
    id: "carbon_frame",
    name: "Carbon Frame",
    description: "Dark graphite frame with a no-distraction finish.",
    costCoins: 880,
  );

  static const legendFrame = CosmeticDefinition(
    id: "legend_frame",
    name: "Legend Frame",
    description: "Top-tier premium frame for long-term mastery.",
    costCoins: 900,
  );

  static const moonlightFrame = CosmeticDefinition(
    id: "moonlight_frame",
    name: "Moonlight Frame",
    description: "Cold silver style for late-night grinders.",
    costCoins: 980,
  );

  static const eclipseFrame = CosmeticDefinition(
    id: "eclipse_frame",
    name: "Eclipse Frame",
    description: "Black-violet prestige frame for advanced athletes.",
    costCoins: 1050,
  );

  static const infernoFrame = CosmeticDefinition(
    id: "inferno_frame",
    name: "Inferno Frame",
    description: "Aggressive ember-red style for all-out effort days.",
    costCoins: 1120,
  );

  static const zenithFrame = CosmeticDefinition(
    id: "zenith_frame",
    name: "Zenith Frame",
    description: "Clean white-gold frame for polished top-end progress.",
    costCoins: 1200,
  );

  static const mythicFrame = CosmeticDefinition(
    id: "mythic_frame",
    name: "Mythic Frame",
    description: "Ultra-premium cosmetic for long-term completionists.",
    costCoins: 1400,
  );

  static const all = <CosmeticDefinition>[
    obsidianFrame,
    emberFrame,
    sunriseFrame,
    azureFrame,
    forestFrame,
    crimsonFrame,
    neonFrame,
    glacierFrame,
    stormFrame,
    royalFrame,
    auroraFrame,
    sandstormFrame,
    cobaltFrame,
    titanFrame,
    plasmaFrame,
    carbonFrame,
    legendFrame,
    moonlightFrame,
    eclipseFrame,
    infernoFrame,
    zenithFrame,
    mythicFrame,
  ];

  static CosmeticDefinition? byId(String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }

    for (final item in all) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }
}
