import "dart:math";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../../data/db/app_db.dart";
import "../../data/movements/movement_guides.dart"; // <-- adjust path if needed
import "../../domain/prereq_rules.dart";
import "../theme/tier_visuals.dart";

class MovementCard extends StatelessWidget {
  const MovementCard({
    super.key,
    required this.movement,
    required this.progress,
    required this.prereqs,
    required this.movementNamesById,
    required this.movementStateById,
    required this.userTotalXp,
    required this.onQuickLog,
    required this.onTap,
  });

  final Movement movement;
  final MovementProgress progress;
  final List<MovementPrereq> prereqs;

  final Map<String, String> movementNamesById;
  final Map<String, String> movementStateById;

  final int userTotalXp;

  final VoidCallback? onQuickLog;
  final VoidCallback? onTap;

  bool _isPrereqSatisfied(MovementPrereq p) {
    final st = movementStateById[p.prereqMovementId] ?? "locked";
    return isPrereqSatisfied(prereqType: p.prereqType, currentState: st);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 430;
    final tier = TierVisuals.forState(progress.state, cs);
    final stateLabel = tier.label;

    final locked = tier.state == "locked";
    final mastered = tier.state == "mastered";

    final xpMissing = max(0, movement.xpToUnlock - userTotalXp);
    final xpOk = xpMissing == 0;

    final progressValue = movement.xpToUnlock <= 0
        ? 1.0
        : (userTotalXp / movement.xpToUnlock).clamp(0.0, 1.0);

    final missingPrereqs = prereqs
        .where((p) => !_isPrereqSatisfied(p))
        .toList();
    final metCount = prereqs.length - missingPrereqs.length;

    String lockReason = "";
    if (locked) {
      if (!xpOk) {
        lockReason = "Need $xpMissing XP";
      } else if (prereqs.isNotEmpty && missingPrereqs.isNotEmpty) {
        lockReason =
            "Missing ${missingPrereqs.length} prerequisite${missingPrereqs.length == 1 ? "" : "s"}";
      } else if (prereqs.isNotEmpty) {
        lockReason = "Prerequisites met - log once to trigger unlock";
      } else {
        lockReason = "Locked";
      }
    }

    final badgeText = stateLabel.toUpperCase();

    final canQuickLog = !locked && onQuickLog != null;

    // ---- guide content (better description + targets + cues)
    final guide = movementGuides[movement.id];

    final descText = guide?.summary ?? movement.description;
    final targetsText = guide?.targets;
    final cues = guide?.cuesList ?? const <String>[];
    final cuePreview = cues.isEmpty
        ? null
        : (cues.length <= 2
              ? cues.join(" | ")
              : "${cues.take(2).join(" | ")}...");

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: tier.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: tier.cardBorder, width: mastered ? 1.4 : 1.0),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _IconBadge(state: tier.state),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    movement.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Compact YouTube watch button (mobile-safe)
                                _WatchButton(movementName: movement.name),

                                const SizedBox(width: 6),
                                _StateBadge(
                                  text: badgeText,
                                  bg: tier.chipBg,
                                  fg: tier.chipFg,
                                  border: tier.chipBorder,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${movement.category.toUpperCase()} | D${movement.difficulty} | $stateLabel",
                              style: TextStyle(
                                color: tier.state == "locked"
                                    ? cs.onSurfaceVariant
                                    : tier.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    descText,
                    maxLines: isCompact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.onSurface),
                  ),

                  if (!isCompact &&
                      targetsText != null &&
                      targetsText.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      "Targets: $targetsText",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  if (!isCompact &&
                      cuePreview != null &&
                      cuePreview.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Form: $cuePreview",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isCompact)
                              Expanded(
                                child: Text(
                                  "Unlock XP ${movement.xpToUnlock} | You $userTotalXp",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Text(
                                  "Unlock XP: ${movement.xpToUnlock}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            if (!isCompact)
                              Text(
                                "You: $userTotalXp",
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 10,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                locked
                                    ? (lockReason.isNotEmpty
                                          ? lockReason
                                          : "Locked")
                                    : mastered
                                    ? "Master tier reached - keep it sharp"
                                    : "$stateLabel tier - push toward ${TierVisuals.nextLabelForState(tier.state) ?? "Master"}",
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonal(
                              onPressed: canQuickLog ? onQuickLog : null,
                              child: const Text("Quick Log"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (prereqs.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Prerequisites",
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          "$metCount/${prereqs.length} met",
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: prereqs.map((p) {
                        final name =
                            movementNamesById[p.prereqMovementId] ??
                            p.prereqMovementId;
                        final required = normalizePrereqType(p.prereqType);
                        final label = required == "unlocked"
                            ? name
                            : "$name (${prereqLabel(required).toLowerCase()})";

                        final ok = _isPrereqSatisfied(p);

                        return _PrereqChip(text: label, satisfied: ok);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.state});

  final String state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tier = TierVisuals.forState(state, cs);

    final icon = tier.icon;
    final bg = tier.iconBg;
    final fg = tier.iconFg;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tier.chipBorder),
      ),
      child: Icon(icon, color: fg),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PrereqChip extends StatelessWidget {
  const _PrereqChip({required this.text, required this.satisfied});

  final String text;
  final bool satisfied;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bg = satisfied ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = satisfied ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    final icon = satisfied ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

// --------------------
// YouTube helpers + button
// --------------------

String _youtubeSearchUrl(String movementName) {
  final q = Uri.encodeComponent("$movementName calisthenics tutorial");
  return "https://www.youtube.com/results?search_query=$q";
}

Future<void> _openYoutube(BuildContext context, String movementName) async {
  final uri = Uri.parse(_youtubeSearchUrl(movementName));

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!ok) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Could not open YouTube")));
  }
}

class _WatchButton extends StatelessWidget {
  const _WatchButton({required this.movementName});

  final String movementName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: "Watch tutorial",
      child: IconButton(
        onPressed: () => _openYoutube(context, movementName),
        icon: const Icon(Icons.play_circle_outline),
        iconSize: 22,
        color: cs.onSurfaceVariant,

        // Mobile-safe (prevents right overflow)
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      ),
    );
  }
}
