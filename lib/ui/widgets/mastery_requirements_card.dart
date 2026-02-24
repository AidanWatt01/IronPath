// lib/ui/widgets/mastery_requirements_card.dart
import "dart:math";
import "package:flutter/material.dart";

import "../../data/db/app_db.dart";
import "../../domain/mastery_rules.dart";

class MasteryRequirementsCard extends StatelessWidget {
  const MasteryRequirementsCard({
    super.key,
    required this.movement,
    required this.state, // locked/unlocked/mastered
    required this.bestReps,
    required this.bestHoldSeconds,
    required this.movementXp,
    this.showTierTargets = false,
    this.compact = false,
  });

  final Movement movement;
  final String state;
  final int bestReps;
  final int bestHoldSeconds;
  final int movementXp;
  final bool showTierTargets;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final tiers = MasteryRules.tiersForMovementEntity(movement);
    final masteredTarget = tiers.mastered;
    final nextTarget = MasteryRules.nextTargetForState(
      movement: movement,
      state: state,
    );

    // Strict AND for the final mastered tier.
    final meetsAll = masteredTarget.isMet(
      bestReps: bestReps,
      bestHoldSeconds: bestHoldSeconds,
      movementTotalXp: movementXp,
    );

    final hasAnyReq =
        masteredTarget.reps > 0 ||
        masteredTarget.holdSeconds > 0 ||
        masteredTarget.totalXp > 0;

    final missing = _missingParts(
      target: nextTarget,
      bestReps: bestReps,
      bestHoldSeconds: bestHoldSeconds,
      movementXp: movementXp,
    );

    final isMastered = state == "mastered";
    final isLocked = state == "locked";

    final subtitle = !hasAnyReq
        ? "No benchmark configured yet for this movement."
        : isMastered
        ? "All benchmarks met."
        : "Next target: ${_nextStateLabel(state)}";

    final pill = _pillConfig(
      scheme: scheme,
      state: state,
      meetsAll: meetsAll,
      hasAnyReq: hasAnyReq,
    );

    final reqWidgets = _buildRequirements(
      target: nextTarget,
      bestReps: bestReps,
      bestHoldSeconds: bestHoldSeconds,
      movementXp: movementXp,
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Mastery benchmarks",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                _Pill(
                  text: pill.text,
                  icon: pill.icon,
                  color: pill.bg,
                  textColor: pill.fg,
                  borderColor: pill.border,
                ),
              ],
            ),

            SizedBox(height: compact ? 6 : 8),
            Text(
              subtitle,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Missing line (only if relevant)
            if (hasAnyReq && !isMastered && missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "Missing: ${missing.join(" | ")}",
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],

            // Locked hint
            if (isLocked) ...[
              const SizedBox(height: 8),
              Text(
                "Unlock this movement first to start accumulating mastery.",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],

            if (hasAnyReq) ...[
              SizedBox(height: compact ? 10 : 14),
              ...reqWidgets,
              if (showTierTargets) ...[
                const SizedBox(height: 14),
                const Text(
                  "Tier targets",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                ..._buildTierRows(
                  tiers: tiers,
                  state: state,
                  bestReps: bestReps,
                  bestHoldSeconds: bestHoldSeconds,
                  movementXp: movementXp,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRequirements({
    required MasteryTarget target,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementXp,
  }) {
    final widgets = <Widget>[];

    void addSpacer() {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 12));
    }

    // Strength benchmark (reps)
    if (target.reps > 0) {
      addSpacer();
      widgets.add(
        _ReqRow(
          label: "Strength benchmark",
          now: "$bestReps reps",
          goal: "${target.reps} reps",
          progress: _ratio(bestReps, target.reps),
          isMet: bestReps >= target.reps,
          icon: Icons.repeat,
        ),
      );
    }

    // Hold benchmark (seconds)
    if (target.holdSeconds > 0) {
      addSpacer();
      widgets.add(
        _ReqRow(
          label: "Hold benchmark",
          now: "${bestHoldSeconds}s",
          goal: "${target.holdSeconds}s",
          progress: _ratio(bestHoldSeconds, target.holdSeconds),
          isMet: bestHoldSeconds >= target.holdSeconds,
          icon: Icons.timer_outlined,
        ),
      );
    }

    // Practice volume (movement XP)
    if (target.totalXp > 0) {
      addSpacer();
      widgets.add(
        _ReqRow(
          label: "Practice volume",
          now: "$movementXp XP",
          goal: "${target.totalXp} XP",
          progress: _ratio(movementXp, target.totalXp),
          isMet: movementXp >= target.totalXp,
          icon: Icons.auto_awesome,
        ),
      );
    }

    // Remove leading spacer if present
    if (widgets.isNotEmpty && widgets.first is SizedBox) {
      widgets.removeAt(0);
    }

    return widgets;
  }

  List<Widget> _buildTierRows({
    required MasteryTiers tiers,
    required String state,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementXp,
  }) {
    final goals = <_TierGoal>[
      _TierGoal(label: "Progress", state: "progress", target: tiers.progress),
      _TierGoal(label: "Bronze", state: "bronze", target: tiers.bronze),
      _TierGoal(label: "Silver", state: "silver", target: tiers.silver),
      _TierGoal(label: "Gold", state: "gold", target: tiers.gold),
      _TierGoal(label: "Mastered", state: "mastered", target: tiers.mastered),
    ];

    final rows = <Widget>[];

    for (final g in goals) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 10));

      rows.add(
        _TierRow(
          label: g.label,
          goalText: _goalText(g.target),
          progressText: _progressText(
            target: g.target,
            bestReps: bestReps,
            bestHoldSeconds: bestHoldSeconds,
            movementXp: movementXp,
          ),
          progress: _targetProgress(
            target: g.target,
            bestReps: bestReps,
            bestHoldSeconds: bestHoldSeconds,
            movementXp: movementXp,
          ),
          isMet: g.target.isMet(
            bestReps: bestReps,
            bestHoldSeconds: bestHoldSeconds,
            movementTotalXp: movementXp,
          ),
          isCurrent: _tierRank(g.state) == _tierRank(state),
          isNext: g.state == _nextTierState(state),
        ),
      );
    }

    return rows;
  }

  int _tierRank(String tierState) {
    switch (tierState) {
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
        return 0;
    }
  }

  String _prettyState(String tierState) {
    switch (tierState) {
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
        return "Mastered";
      default:
        if (tierState.isEmpty) return tierState;
        return tierState[0].toUpperCase() + tierState.substring(1);
    }
  }

  String _nextStateLabel(String tierState) =>
      _prettyState(_nextTierState(tierState));

  String _nextTierState(String tierState) {
    switch (tierState) {
      case "locked":
      case "unlocked":
        return "progress";
      case "progress":
        return "bronze";
      case "bronze":
        return "silver";
      case "silver":
        return "gold";
      case "gold":
      case "mastered":
        return "mastered";
      default:
        return "progress";
    }
  }

  String _goalText(MasteryTarget target) {
    final parts = <String>[];
    if (target.reps > 0) {
      parts.add("${target.reps} reps");
    }
    if (target.holdSeconds > 0) {
      parts.add("${target.holdSeconds}s hold");
    }
    if (target.totalXp > 0) {
      parts.add("${target.totalXp} XP");
    }
    if (parts.isEmpty) return "No benchmark configured";
    return parts.join(" | ");
  }

  String _progressText({
    required MasteryTarget target,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementXp,
  }) {
    final parts = <String>[];
    if (target.reps > 0) {
      parts.add("$bestReps/${target.reps} reps");
    }
    if (target.holdSeconds > 0) {
      parts.add("$bestHoldSeconds/${target.holdSeconds}s");
    }
    if (target.totalXp > 0) {
      parts.add("$movementXp/${target.totalXp} XP");
    }
    if (parts.isEmpty) return "No benchmark configured";
    return parts.join(" | ");
  }

  double _targetProgress({
    required MasteryTarget target,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementXp,
  }) {
    final parts = <double>[];
    if (target.reps > 0) {
      parts.add(_ratio(bestReps, target.reps));
    }
    if (target.holdSeconds > 0) {
      parts.add(_ratio(bestHoldSeconds, target.holdSeconds));
    }
    if (target.totalXp > 0) {
      parts.add(_ratio(movementXp, target.totalXp));
    }
    if (parts.isEmpty) return 0;
    return (parts.reduce((a, b) => a + b) / parts.length).clamp(0.0, 1.0);
  }

  double _ratio(int current, int required) {
    if (required <= 0) return 1.0;
    return (current / required).clamp(0.0, 1.0);
  }

  List<String> _missingParts({
    required MasteryTarget target,
    required int bestReps,
    required int bestHoldSeconds,
    required int movementXp,
  }) {
    final parts = <String>[];

    if (target.reps > 0 && bestReps < target.reps) {
      parts.add("${target.reps - bestReps} reps");
    }

    if (target.holdSeconds > 0 && bestHoldSeconds < target.holdSeconds) {
      parts.add("${target.holdSeconds - bestHoldSeconds}s hold");
    }

    if (target.totalXp > 0 && movementXp < target.totalXp) {
      parts.add("${target.totalXp - movementXp} XP");
    }

    return parts;
  }

  _PillSpec _pillConfig({
    required ColorScheme scheme,
    required String state,
    required bool meetsAll,
    required bool hasAnyReq,
  }) {
    // If already mastered, always show mastered (even if targets change later)
    if (state == "mastered") {
      return _PillSpec(
        text: "Mastered",
        icon: Icons.emoji_events,
        bg: scheme.tertiary,
        fg: scheme.onTertiary,
        border: scheme.tertiary,
      );
    }

    if (!hasAnyReq) {
      return _PillSpec(
        text: "No rules",
        icon: Icons.tune,
        bg: scheme.surfaceContainerHighest,
        fg: scheme.onSurfaceVariant,
        border: scheme.outlineVariant,
      );
    }

    if (state == "locked") {
      return _PillSpec(
        text: "Locked",
        icon: Icons.lock_outline,
        bg: scheme.surfaceContainerHighest,
        fg: scheme.onSurfaceVariant,
        border: scheme.outlineVariant,
      );
    }

    // Unlocked but not mastered
    if (meetsAll) {
      return _PillSpec(
        text: "Ready",
        icon: Icons.check_circle,
        bg: scheme.tertiary,
        fg: scheme.onTertiary,
        border: scheme.tertiary,
      );
    }

    return _PillSpec(
      text: "In progress",
      icon: Icons.info_outline,
      bg: scheme.surfaceContainerHighest,
      fg: scheme.onSurfaceVariant,
      border: scheme.outlineVariant,
    );
  }
}

class _TierGoal {
  const _TierGoal({
    required this.label,
    required this.state,
    required this.target,
  });

  final String label;
  final String state;
  final MasteryTarget target;
}

class _ReqRow extends StatelessWidget {
  const _ReqRow({
    required this.label,
    required this.now,
    required this.goal,
    required this.progress,
    required this.isMet,
    required this.icon,
  });

  final String label;
  final String now;
  final String goal;
  final double progress;
  final bool isMet;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Icon(
              isMet ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: isMet ? scheme.tertiary : scheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "$now | Goal: $goal",
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: max(0.0, progress),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.label,
    required this.goalText,
    required this.progressText,
    required this.progress,
    required this.isMet,
    required this.isCurrent,
    required this.isNext,
  });

  final String label;
  final String goalText;
  final String progressText;
  final double progress;
  final bool isMet;
  final bool isCurrent;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final bg = isMet
        ? scheme.primaryContainer
        : (isNext ? scheme.secondaryContainer : scheme.surfaceContainerHighest);
    final fg = isMet
        ? scheme.onPrimaryContainer
        : (isNext ? scheme.onSecondaryContainer : scheme.onSurface);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w900),
                ),
              ),
              if (isCurrent) _TierTag(text: "Current", color: fg),
              if (isNext) ...[
                const SizedBox(width: 6),
                _TierTag(text: "Next", color: fg),
              ],
              const SizedBox(width: 6),
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: fg,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Goal: $goalText",
            style: TextStyle(color: fg, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text("Now: $progressText", style: TextStyle(color: fg)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: max(0.0, progress),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierTag extends StatelessWidget {
  const _TierTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PillSpec {
  _PillSpec({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.border,
  });

  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color border;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.borderColor,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
