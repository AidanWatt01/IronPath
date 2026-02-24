// lib/ui/screens/movement_detail_screen.dart
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:url_launcher/url_launcher.dart";

import "../../data/db/app_db.dart";
import "../../domain/cosmetic_catalog.dart";
import "../../domain/movement_guide_catalog.dart";
import "../../domain/prereq_rules.dart";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";
import "../widgets/mastery_requirements_card.dart";
import "../widgets/quick_log_sheet.dart";

class MovementDetailScreen extends ConsumerWidget {
  const MovementDetailScreen({super.key, required this.movementId});

  final String movementId;

  Future<void> _openQuickLog(
    BuildContext context,
    MovementWithProgress d,
  ) async {
    if (d.progress.state == "locked") return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickLogSheet(
        movementId: d.movement.id,
        movementName: d.movement.name,
        xpPerRep: d.movement.xpPerRep,
        xpPerSecond: d.movement.xpPerSecond,
        category: d.movement.category,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(movementDetailProvider(movementId));
    final prereqs = ref.watch(movementDetailPrereqsProvider(movementId));
    final sessions = ref.watch(movementDetailSessionsProvider(movementId));
    final all = ref.watch(movementsWithProgressProvider);
    final stats = ref.watch(userStatProvider);
    final cosmeticStatus = ref.watch(cosmeticStatusProvider);

    return detail.when(
      data: (d) {
        final guide = seedMovementGuidesById[d.movement.id];
        final scheme = Theme.of(context).colorScheme;
        final isCompact = MediaQuery.sizeOf(context).width < 720;
        final equippedCosmeticId = cosmeticStatus.maybeWhen(
          data: (v) => v.equippedCosmeticId,
          orElse: () => null,
        );
        final cosmeticVisual = cosmeticVisualForId(
          equippedCosmeticId,
          fallbackColor: scheme.primary,
        );
        final cosmeticAccent = cosmeticVisual.color;
        final styleName = equippedCosmeticId == null
            ? "Default style active"
            : "${CosmeticCatalog.byId(equippedCosmeticId)?.name ?? equippedCosmeticId} active";

        return Scaffold(
          appBar: AppBar(
            title: Text(d.movement.name),
            actions: [
              IconButton(
                tooltip: d.progress.state == "locked" ? "Locked" : "Quick log",
                onPressed: d.progress.state == "locked"
                    ? null
                    : () => _openQuickLog(context, d),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: all.when(
              data: (allItems) {
                final nameById = <String, String>{};
                final stateById = <String, String>{};

                for (final x in allItems) {
                  nameById[x.movement.id] = x.movement.name;
                  stateById[x.movement.id] = x.progress.state;
                }

                // Build lock reasons UI once (no nested .when() soup).
                Widget? lockReasonsWidget;
                if (d.progress.state == "locked") {
                  lockReasonsWidget = _buildLockReasonsSection(
                    context: context,
                    stats: stats,
                    prereqs: prereqs,
                    movementXpToUnlock: d.movement.xpToUnlock,
                    movementNameById: nameById,
                    stateById: stateById,
                  );
                }

                return ListView(
                  children: [
                    _MovementHeroCard(
                      movementName: d.movement.name,
                      category: d.movement.category,
                      state: d.progress.state,
                      styleLabel: styleName,
                      accentColor: cosmeticAccent,
                      accentIcon: cosmeticVisual.icon,
                      compact: isCompact,
                    ),
                    SizedBox(height: isCompact ? 10 : 12),

                    // --------------------
                    // Status
                    // --------------------
                    _StatusCard(
                      state: d.progress.state,
                      totalXp: d.progress.totalXp,
                      bestReps: d.progress.bestReps,
                      bestHoldSeconds: d.progress.bestHoldSeconds,
                      bestFormScore: d.progress.bestFormScore,
                      userTotalXp: stats.valueOrNull?.totalXp ?? 0,
                      unlockXp: d.movement.xpToUnlock,
                      unlockedAt: d.progress.unlockedAt,
                      masteredAt: d.progress.masteredAt,
                      category: d.movement.category,
                      difficulty: d.movement.difficulty,
                      accentColor: cosmeticAccent,
                      compact: isCompact,
                    ),

                    if (lockReasonsWidget != null) ...[
                      SizedBox(height: isCompact ? 10 : 12),
                      lockReasonsWidget,
                    ],

                    SizedBox(height: isCompact ? 10 : 12),

                    MasteryRequirementsCard(
                      movement: d.movement,
                      state: d.progress.state,
                      bestReps: d.progress.bestReps,
                      bestHoldSeconds: d.progress.bestHoldSeconds,
                      movementXp: d.progress.totalXp,
                      compact: isCompact,
                      showTierTargets: true,
                    ),

                    SizedBox(height: isCompact ? 10 : 12),

                    // --------------------
                    // Description + coaching content
                    // --------------------
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(d.movement.description),
                            const SizedBox(height: 12),

                            if (guide != null) ...[
                              const _SectionTitle("Primary muscles"),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: guide.primaryMuscles
                                    .map(
                                      (m) => _GuideTag(
                                        label: m,
                                        compact: isCompact,
                                      ),
                                    )
                                    .toList(),
                              ),

                              if (guide.secondaryMuscles.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const _SectionTitle("Secondary muscles"),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: guide.secondaryMuscles
                                      .map(
                                        (m) => _GuideTag(
                                          label: m,
                                          compact: isCompact,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],

                              SizedBox(height: isCompact ? 10 : 14),
                              if (isCompact) ...[
                                _GuideExpansion(
                                  title: "Setup",
                                  child: Text(guide.setup),
                                ),
                                _GuideExpansion(
                                  title: "Execution",
                                  child: Text(guide.execution),
                                ),
                                _GuideExpansion(
                                  title: "Form cues",
                                  child: _Bullets(guide.cues),
                                ),
                              ] else ...[
                                const _SectionTitle("Setup"),
                                const SizedBox(height: 8),
                                Text(guide.setup),
                                const SizedBox(height: 14),
                                const _SectionTitle("Execution"),
                                const SizedBox(height: 8),
                                Text(guide.execution),
                                const SizedBox(height: 14),
                                const _SectionTitle("Form cues"),
                                const SizedBox(height: 8),
                                _Bullets(guide.cues),
                              ],

                              if (guide.commonMistakes.isNotEmpty) ...[
                                SizedBox(height: isCompact ? 6 : 10),
                                ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  childrenPadding: EdgeInsets.zero,
                                  title: const Text(
                                    "Common mistakes",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _Bullets(guide.commonMistakes),
                                    ),
                                  ],
                                ),
                              ],

                              if (guide.regressions.isNotEmpty) ...[
                                SizedBox(height: isCompact ? 6 : 10),
                                if (isCompact)
                                  _GuideExpansion(
                                    title: "Regressions",
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: guide.regressions
                                          .map(
                                            (x) => _GuideTag(
                                              label: x,
                                              compact: true,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )
                                else ...[
                                  const _SectionTitle("Regressions"),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: guide.regressions
                                        .map(
                                          (x) => _GuideTag(
                                            label: x,
                                            compact: false,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],

                              if (guide.progressions.isNotEmpty) ...[
                                SizedBox(height: isCompact ? 6 : 10),
                                if (isCompact)
                                  _GuideExpansion(
                                    title: "Progressions",
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: guide.progressions
                                          .map(
                                            (x) => _GuideTag(
                                              label: x,
                                              compact: true,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )
                                else ...[
                                  const _SectionTitle("Progressions"),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: guide.progressions
                                        .map(
                                          (x) => _GuideTag(
                                            label: x,
                                            compact: false,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ],

                              SizedBox(height: isCompact ? 10 : 12),
                            ],

                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  final query =
                                      (guide?.youtubeQuery.isNotEmpty ?? false)
                                      ? guide!.youtubeQuery
                                      : "${d.movement.name} calisthenics tutorial";
                                  await _openYoutubeQuery(context, query);
                                },
                                icon: const Icon(Icons.play_circle_outline),
                                label: const Text("Watch on YouTube"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isCompact ? 10 : 12),

                    // --------------------
                    // Prereqs (full list with checks)
                    // --------------------
                    prereqs.when(
                      data: (reqs) {
                        if (reqs.isEmpty) return const SizedBox.shrink();

                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(isCompact ? 12 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Prerequisites",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (isCompact)
                                  Column(
                                    children: reqs.map((r) {
                                      final name =
                                          nameById[r.prereqMovementId] ??
                                          r.prereqMovementId;
                                      final st =
                                          stateById[r.prereqMovementId] ??
                                          "locked";
                                      final ok = isPrereqSatisfied(
                                        prereqType: r.prereqType,
                                        currentState: st,
                                      );
                                      final required = normalizePrereqType(
                                        r.prereqType,
                                      );
                                      final tierText = required == "unlocked"
                                          ? "Unlock"
                                          : prereqLabel(required);

                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          ok
                                              ? Icons.check_circle
                                              : Icons.lock_outline,
                                          size: 20,
                                        ),
                                        title: Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text("Need $tierText"),
                                      );
                                    }).toList(),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: reqs.map((r) {
                                      final name =
                                          nameById[r.prereqMovementId] ??
                                          r.prereqMovementId;
                                      final st =
                                          stateById[r.prereqMovementId] ??
                                          "locked";
                                      final ok = isPrereqSatisfied(
                                        prereqType: r.prereqType,
                                        currentState: st,
                                      );
                                      final required = normalizePrereqType(
                                        r.prereqType,
                                      );
                                      final tierText = required == "unlocked"
                                          ? "unlock"
                                          : prereqLabel(required).toLowerCase();

                                      return Chip(
                                        avatar: Icon(
                                          ok
                                              ? Icons.check_circle
                                              : Icons.lock_outline,
                                        ),
                                        label: Text("$name ($tierText)"),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, _) => Text("Prereqs error: $e"),
                    ),

                    const SizedBox(height: 12),

                    // --------------------
                    // Sessions
                    // --------------------
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isCompact ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sessions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            sessions.when(
                              data: (items) {
                                if (items.isEmpty) {
                                  return const Text("No sessions yet.");
                                }

                                final show = items
                                    .take(isCompact ? 6 : 12)
                                    .toList();

                                return Column(
                                  children: show.map((s) {
                                    final titleBits = <String>[];
                                    if (s.reps > 0) {
                                      titleBits.add("${s.reps} reps");
                                    }
                                    if (s.holdSeconds > 0) {
                                      titleBits.add("${s.holdSeconds}s hold");
                                    }
                                    titleBits.add("Form ${s.formScore}/10");

                                    final title = titleBits.join(" - ");

                                    return ListTile(
                                      dense: isCompact,
                                      contentPadding: EdgeInsets.zero,
                                      leading: isCompact
                                          ? null
                                          : const Icon(Icons.fitness_center),
                                      title: Text(title),
                                      subtitle: Text(
                                        _formatDateTime(context, s.startedAt),
                                      ),
                                      trailing: Text(
                                        "+${s.xpEarned} XP",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const LinearProgressIndicator(),
                              error: (e, _) => Text("Sessions error: $e"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Load error: $e")),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cosmeticAccent,
                foregroundColor:
                    ThemeData.estimateBrightnessForColor(cosmeticAccent) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              onPressed: d.progress.state == "locked"
                  ? null
                  : () => _openQuickLog(context, d),
              child: Text(
                d.progress.state == "locked" ? "Locked" : "Log Session",
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Detail error: $e"))),
    );
  }
}

// -----------------------------------------------------------------------------
// Lock reasons (typed, cleaner async handling)
// -----------------------------------------------------------------------------

Widget _buildLockReasonsSection({
  required BuildContext context,
  required AsyncValue<UserStat> stats,
  required AsyncValue<List<MovementPrereq>> prereqs,
  required int movementXpToUnlock,
  required Map<String, String> movementNameById,
  required Map<String, String> stateById,
}) {
  if (stats.isLoading || prereqs.isLoading) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
    );
  }

  if (stats.hasError || prereqs.hasError) {
    final msg = (stats.error ?? prereqs.error).toString();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text("Could not load lock reasons: $msg"),
      ),
    );
  }

  final s = stats.value;
  final reqs = prereqs.value ?? const <MovementPrereq>[];

  final reasons = _computeLockReasons(
    userTotalXp: s?.totalXp ?? 0,
    movementXpToUnlock: movementXpToUnlock,
    prereqs: reqs,
    nameById: movementNameById,
    stateById: stateById,
  );

  return _LockReasonsCard(reasons: reasons);
}

List<String> _computeLockReasons({
  required int userTotalXp,
  required int movementXpToUnlock,
  required List<MovementPrereq> prereqs,
  required Map<String, String> nameById,
  required Map<String, String> stateById,
}) {
  final reasons = <String>[];

  if (userTotalXp < movementXpToUnlock) {
    final remaining = movementXpToUnlock - userTotalXp;
    reasons.add(
      "XP gate: $userTotalXp / $movementXpToUnlock (need $remaining more)",
    );
  }

  for (final r in prereqs) {
    final name = nameById[r.prereqMovementId] ?? r.prereqMovementId;
    final st = stateById[r.prereqMovementId] ?? "locked";
    final required = normalizePrereqType(r.prereqType);

    if (isPrereqSatisfied(prereqType: required, currentState: st)) {
      continue;
    }

    if (required == "unlocked") {
      reasons.add("Prereq: unlock $name");
    } else {
      reasons.add("Prereq: reach ${prereqLabel(required)} in $name");
    }
  }

  if (reasons.isEmpty) {
    reasons.add("Unknown lock reason (check rules)");
  }

  return reasons;
}

class _LockReasonsCard extends StatelessWidget {
  const _LockReasonsCard({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Why it's locked",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Bullets(reasons),
          ],
        ),
      ),
    );
  }
}

class _GuideExpansion extends StatelessWidget {
  const _GuideExpansion({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      children: [Align(alignment: Alignment.centerLeft, child: child)],
    );
  }
}

class _GuideTag extends StatelessWidget {
  const _GuideTag({required this.label, required this.compact});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets(this.items);
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "-  ",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Expanded(child: Text(c)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MovementHeroCard extends StatelessWidget {
  const _MovementHeroCard({
    required this.movementName,
    required this.category,
    required this.state,
    required this.styleLabel,
    required this.accentColor,
    required this.accentIcon,
    required this.compact,
  });

  final String movementName;
  final String category;
  final String state;
  final String styleLabel;
  final Color accentColor;
  final IconData accentIcon;
  final bool compact;

  String _prettyState(String raw) {
    if (raw.isEmpty) return raw;
    return raw[0].toUpperCase() + raw.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final prettyCategory = category.isEmpty
        ? category
        : category[0].toUpperCase() + category.substring(1);
    final onAccent =
        ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.24),
            accentColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.62)),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 44,
            height: compact ? 40 : 44,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(accentIcon, color: onAccent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movementName,
                  style: TextStyle(
                    fontSize: compact ? 15 : 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$prettyCategory - ${_prettyState(state)}",
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    styleLabel,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.state,
    required this.totalXp,
    required this.bestReps,
    required this.bestHoldSeconds,
    required this.bestFormScore,
    required this.userTotalXp,
    required this.unlockXp,
    required this.unlockedAt,
    required this.masteredAt,
    required this.category,
    required this.difficulty,
    required this.accentColor,
    required this.compact,
  });

  final String state;
  final int totalXp;
  final int bestReps;
  final int bestHoldSeconds;
  final int bestFormScore;
  final int userTotalXp;
  final int unlockXp;

  final DateTime? unlockedAt;
  final DateTime? masteredAt;

  final String category;
  final int difficulty;
  final Color accentColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final icon = state == "mastered"
        ? Icons.emoji_events
        : state == "unlocked"
        ? Icons.lock_open
        : Icons.lock_outline;

    final statusLabel = state[0].toUpperCase() + state.substring(1);
    final unlockPct = unlockXp <= 0
        ? 0.0
        : (userTotalXp / unlockXp).clamp(0.0, 1.0);

    final subtitleBits = <String>[category.toUpperCase(), "Diff $difficulty"];

    if (state == "unlocked" && unlockedAt != null) {
      subtitleBits.add("Unlocked ${_formatDateTime(context, unlockedAt!)}");
    }
    if (state == "mastered" && masteredAt != null) {
      subtitleBits.add("Mastered ${_formatDateTime(context, masteredAt!)}");
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accentColor.withValues(alpha: 0.48)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: compact ? 24 : 28, color: accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Status: $statusLabel",
                        style: TextStyle(
                          fontSize: compact ? 15 : 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitleBits.join(" - "),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Movement XP: $totalXp",
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (state == "locked") ...[
              const SizedBox(height: 12),
              Text(
                "Unlock progress: ${min(userTotalXp, unlockXp)} / $unlockXp XP",
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: unlockPct,
                  minHeight: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MiniStat(label: "Best reps", value: "$bestReps"),
                _MiniStat(label: "Best hold", value: "${bestHoldSeconds}s"),
                if (!compact)
                  _MiniStat(label: "Best form", value: "$bestFormScore/10"),
              ],
            ),
            if (compact) ...[
              const SizedBox(height: 8),
              Text(
                "Best form: $bestFormScore/10",
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

String _formatDateTime(BuildContext context, DateTime dt) {
  final local = dt.toLocal();
  final date = MaterialLocalizations.of(context).formatShortDate(local);
  final time = MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true);
  return "$date - $time";
}

// --------------------
// YouTube helpers
// --------------------

String _youtubeSearchUrlFromQuery(String query) {
  final q = Uri.encodeComponent(query);
  return "https://www.youtube.com/results?search_query=$q";
}

Future<void> _openYoutubeQuery(BuildContext context, String query) async {
  final uri = Uri.parse(_youtubeSearchUrlFromQuery(query));

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (!ok) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Could not open YouTube")));
  }
}
