import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../state/providers.dart";

class RunningTreeScreen extends ConsumerWidget {
  const RunningTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref
        .watch(runningGoalProvider)
        .maybeWhen(data: (x) => x, orElse: () => null);
    final plan = ref.watch(runningPlanProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Text(
            "Progression Tree",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (goal == null || plan == null)
            const _StageCard(
              title: "No tree yet",
              description: "Set a running goal to build your progression path.",
            )
          else ...[
            _StageCard(
              title: "Base",
              description:
                  "${goal.baselineDistanceKm.toStringAsFixed(1)} km at ${goal.baselineDurationMinutes} min.",
            ),
            _StageCard(
              title: "Consistency",
              description:
                  "Complete ${plan.weeks.length >= 3 ? 3 : plan.weeks.length} weeks of planned runs.",
            ),
            _StageCard(
              title: "Peak Week",
              description:
                  "Reach ${plan.peakWeekDistanceKm.toStringAsFixed(1)} km weekly volume.",
            ),
            _StageCard(
              title: "Goal Day",
              description:
                  "${goal.targetDistanceKm.toStringAsFixed(1)} km by ${_formatDate(goal.targetDate)}.",
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = <String>[
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.trending_up,
              size: 16,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
