import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../domain/running_plan_service.dart";
import "../../state/providers.dart";

class RunningPlanScreen extends ConsumerWidget {
  const RunningPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(runningPlanProvider);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: plan == null
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _PlanCard(
                  title: "No running plan",
                  subtitle: "Create a running goal first.",
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                Text(
                  "Plan",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  plan.summary,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                _FeasibilityCard(plan: plan),
                const SizedBox(height: 10),
                _PlanCard(
                  title: "Adaptive Inputs",
                  subtitle:
                      "Recent runs: ${plan.adaptation.recentRunCount} | "
                      "Load: ${plan.adaptation.recentDistanceKm.toStringAsFixed(1)}/${plan.adaptation.expectedDistanceKm.toStringAsFixed(1)} km (21d)\n"
                      "Volume x${plan.adaptation.volumeMultiplier.toStringAsFixed(2)} | "
                      "Intensity x${plan.adaptation.intensityMultiplier.toStringAsFixed(2)}\n"
                      "${plan.adaptation.message}",
                ),
                const SizedBox(height: 10),
                _PlanCard(
                  title: "Block Structure",
                  subtitle:
                      "Base ${plan.baseWeeks}w - Build ${plan.buildWeeks}w - Taper ${plan.taperWeeks}w - Recovery ${plan.recoveryWeeks}w",
                ),
                const SizedBox(height: 10),
                _PaceZonesCard(zones: plan.paceZones),
                const SizedBox(height: 12),
                ...plan.weeks.map((week) {
                  final phaseLabel = runningPhaseLabel(week.phase);
                  final recoveryText = week.isRecoveryWeek
                      ? "Recovery week"
                      : "$phaseLabel block";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Week ${week.weekNumber} - ${week.totalDistanceKm.toStringAsFixed(1)} km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: week.isRecoveryWeek
                                    ? scheme.secondaryContainer
                                    : scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                recoveryText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: week.isRecoveryWeek
                                      ? scheme.onSecondaryContainer
                                      : scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          week.focus,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        ...week.workouts.map((w) {
                          final zone = plan.paceZones.firstWhere(
                            (z) => z.id == w.paceZoneId,
                            orElse: () => plan.paceZones.first,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${w.dayLabel}: ${w.title} - ${w.distanceKm.toStringAsFixed(1)} km",
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${zone.label} (${zone.rangeLabel})",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  w.prescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _FeasibilityCard extends StatelessWidget {
  const _FeasibilityCard({required this.plan});

  final RunningPlan plan;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final feasibility = plan.feasibility;
    final (bg, fg) = switch (feasibility) {
      RunningGoalFeasibility.onTrack => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      RunningGoalFeasibility.stretch => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      RunningGoalFeasibility.aggressive => (
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Target Feasibility",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  runningFeasibilityLabel(feasibility),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Estimated finish: ${_formatMinutes(plan.estimatedFinishMinutes)}",
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            plan.feasibilityReason,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return "${h}h ${m.toString().padLeft(2, "0")}m";
  }
}

class _PaceZonesCard extends StatelessWidget {
  const _PaceZonesCard({required this.zones});

  final List<RunningPaceZone> zones;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pace Zones",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...zones.map((z) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text("${z.label}: ${z.rangeLabel}"),
            );
          }),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
