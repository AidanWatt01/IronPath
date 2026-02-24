import "package:flutter/material.dart";

class TierVisual {
  const TierVisual({
    required this.state,
    required this.label,
    required this.icon,
    required this.accent,
    required this.chipBg,
    required this.chipFg,
    required this.chipBorder,
    required this.cardBg,
    required this.cardBorder,
    required this.iconBg,
    required this.iconFg,
  });

  final String state;
  final String label;
  final IconData icon;
  final Color accent;
  final Color chipBg;
  final Color chipFg;
  final Color chipBorder;
  final Color cardBg;
  final Color cardBorder;
  final Color iconBg;
  final Color iconFg;
}

class TierVisuals {
  static String normalizeState(String state) {
    switch (state) {
      case "locked":
      case "unlocked":
      case "progress":
      case "bronze":
      case "silver":
      case "gold":
      case "mastered":
      case "master":
        return state == "master" ? "mastered" : state;
      default:
        return "unlocked";
    }
  }

  static bool isLocked(String state) => normalizeState(state) == "locked";

  static bool isMastered(String state) => normalizeState(state) == "mastered";

  static bool isUnlockedGroup(String state) {
    final s = normalizeState(state);
    return s != "locked" && s != "mastered";
  }

  // Rank from lowest to highest progression.
  static int progressionRank(String state) {
    switch (normalizeState(state)) {
      case "locked":
        return 0;
      case "unlocked":
        return 1;
      case "progress":
        return 2;
      case "bronze":
        return 3;
      case "silver":
        return 4;
      case "gold":
        return 5;
      case "mastered":
        return 6;
      default:
        return 1;
    }
  }

  static String labelForState(String state) {
    switch (normalizeState(state)) {
      case "locked":
        return "Locked";
      case "unlocked":
        return "Unlocked";
      case "progress":
        return "Progress";
      case "bronze":
        return "Bronze";
      case "silver":
        return "Silver";
      case "gold":
        return "Gold";
      case "mastered":
        return "Master";
      default:
        return "Unlocked";
    }
  }

  static String? nextLabelForState(String state) {
    switch (normalizeState(state)) {
      case "locked":
      case "unlocked":
        return "Progress";
      case "progress":
        return "Bronze";
      case "bronze":
        return "Silver";
      case "silver":
        return "Gold";
      case "gold":
        return "Master";
      case "mastered":
        return null;
      default:
        return "Progress";
    }
  }

  static TierVisual forState(String state, ColorScheme scheme) {
    final s = normalizeState(state);
    final accent = _accentForState(s, scheme);
    final icon = _iconForState(s);

    final chipBg = s == "locked"
        ? scheme.surfaceContainerHighest
        : Color.alphaBlend(
            accent.withOpacity(0.26),
            scheme.surfaceContainerHighest,
          );
    final chipFg = _onColor(chipBg);
    final chipBorder = s == "locked"
        ? scheme.outlineVariant
        : Color.alphaBlend(accent.withOpacity(0.62), scheme.outlineVariant);

    final cardBg = s == "locked"
        ? scheme.surface
        : Color.alphaBlend(accent.withOpacity(0.11), scheme.surface);
    final cardBorder = s == "locked"
        ? scheme.outlineVariant
        : Color.alphaBlend(accent.withOpacity(0.70), scheme.outlineVariant);

    final iconBg = s == "locked"
        ? scheme.surfaceContainerHighest
        : Color.alphaBlend(
            accent.withOpacity(0.24),
            scheme.surfaceContainerHighest,
          );
    final iconFg = s == "locked" ? scheme.onSurfaceVariant : _onColor(iconBg);

    return TierVisual(
      state: s,
      label: labelForState(s),
      icon: icon,
      accent: accent,
      chipBg: chipBg,
      chipFg: chipFg,
      chipBorder: chipBorder,
      cardBg: cardBg,
      cardBorder: cardBorder,
      iconBg: iconBg,
      iconFg: iconFg,
    );
  }

  static Color _accentForState(String state, ColorScheme scheme) {
    switch (state) {
      case "locked":
        return scheme.onSurfaceVariant;
      case "unlocked":
        return const Color(0xFF4D9EFF);
      case "progress":
        return const Color(0xFF2EA46E);
      case "bronze":
        return const Color(0xFFB87333);
      case "silver":
        return const Color(0xFFB8C0CC);
      case "gold":
        return const Color(0xFFE0B84F);
      case "mastered":
        return const Color(0xFF8E44AD);
      default:
        return scheme.primary;
    }
  }

  static IconData _iconForState(String state) {
    switch (state) {
      case "locked":
        return Icons.lock_outline;
      case "unlocked":
        return Icons.lock_open;
      case "progress":
        return Icons.trending_up;
      case "bronze":
        return Icons.workspace_premium;
      case "silver":
        return Icons.workspace_premium;
      case "gold":
        return Icons.workspace_premium;
      case "mastered":
        return Icons.auto_awesome;
      default:
        return Icons.lock_open;
    }
  }

  static Color _onColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}
