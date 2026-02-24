import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data/db/app_db.dart";
import "../../state/providers.dart";

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutHistoryProvider);
    final legacyAsync = ref.watch(legacySessionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: workoutsAsync.when(
        data: (workouts) {
          return legacyAsync.when(
            data: (legacy) {
              if (workouts.isEmpty && legacy.isEmpty) {
                return const _EmptyHistory();
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (workouts.isNotEmpty) ...[
                    const _SectionTitle(title: "Workouts"),
                    const SizedBox(height: 8),
                    ...workouts.map((w) => _WorkoutSummaryTile(workout: w)),
                    const SizedBox(height: 14),
                  ],
                  if (legacy.isNotEmpty) ...[
                    const _SectionTitle(title: "Older Logs"),
                    const SizedBox(height: 8),
                    ...legacy.map((x) => _LegacyLogTile(item: x)),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("History error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("History error: $e")),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

class _WorkoutSummaryTile extends ConsumerWidget {
  const _WorkoutSummaryTile({required this.workout});

  final WorkoutSummary workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(workoutEntriesProvider(workout.workoutId));

    return entriesAsync.when(
      data: (entries) {
        final movementTitle = entries.isEmpty
            ? "Workout"
            : entries.first.movement.name;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(
              movementTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              "${_fmtDate(workout.startedAt)} ${_fmtTime(workout.startedAt)} - ${workout.totalSets} sets - ${_fmtDuration(workout.durationSeconds)}",
            ),
            trailing: Text(
              "+${workout.totalXp} XP",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            onTap: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => _WorkoutDetailsSheet(workout: workout),
              );
            },
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const Icon(Icons.fitness_center),
          title: Text(
            "${_fmtDate(workout.startedAt)} ${_fmtTime(workout.startedAt)}",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text("Loading movement..."),
          trailing: Text(
            "+${workout.totalXp} XP",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      error: (_, _) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const Icon(Icons.fitness_center),
          title: const Text(
            "Workout",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            "${_fmtDate(workout.startedAt)} ${_fmtTime(workout.startedAt)} - ${workout.totalSets} sets",
          ),
          trailing: Text(
            "+${workout.totalXp} XP",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _WorkoutDetailsSheet extends ConsumerWidget {
  const _WorkoutDetailsSheet({required this.workout});

  final WorkoutSummary workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(workoutEntriesProvider(workout.workoutId));
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Workout ${_fmtDate(workout.startedAt)} ${_fmtTime(workout.startedAt)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: "Close",
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              "${workout.totalSets} sets - ${_fmtDuration(workout.durationSeconds)} - +${workout.totalXp} XP",
            ),
            const SizedBox(height: 10),
            entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text("No set details saved."),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 380),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    separatorBuilder: (_, i) => const Divider(height: 10),
                    itemBuilder: (context, i) {
                      final x = entries[i];
                      final bits = <String>[];
                      if (x.session.reps > 0) {
                        bits.add("${x.session.reps} reps");
                      }
                      if (x.session.holdSeconds > 0) {
                        bits.add("${x.session.holdSeconds}s hold");
                      }
                      if (x.session.durationSeconds > 0) {
                        bits.add("${x.session.durationSeconds}s");
                      }
                      if (x.session.sets > 1) {
                        bits.add("${x.session.sets} sets");
                      }
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          x.movement.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(bits.join(" - ")),
                        trailing: Text("+${x.session.xpEarned}"),
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text("Workout details error: $e"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegacyLogTile extends StatelessWidget {
  const _LegacyLogTile({required this.item});

  final SessionWithMovement item;

  @override
  Widget build(BuildContext context) {
    final s = item.session;
    final bits = <String>[];
    if (s.reps > 0) {
      bits.add("${s.reps} reps");
    }
    if (s.holdSeconds > 0) {
      bits.add("${s.holdSeconds}s hold");
    }
    if (s.durationSeconds > 0) {
      bits.add("${s.durationSeconds}s");
    }
    if (s.sets > 1) {
      bits.add("${s.sets} sets");
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(item.movement.name),
        subtitle: Text(
          "${_fmtDate(s.startedAt)} ${_fmtTime(s.startedAt)} - ${bits.join(" - ")}",
        ),
        trailing: Text(
          "+${s.xpEarned}",
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 36),
            const SizedBox(height: 10),
            const Text(
              "No workout history yet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              "Log a workout from any movement and it will appear here.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime dt) {
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
  return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
}

String _fmtTime(DateTime dt) {
  final isPm = dt.hour >= 12;
  final h12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final mm = dt.minute.toString().padLeft(2, "0");
  return "$h12:$mm ${isPm ? "PM" : "AM"}";
}

String _fmtDuration(int seconds) {
  if (seconds <= 0) return "0m";
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;

  if (h > 0) return "${h}h ${m}m";
  if (m > 0) return "${m}m ${s}s";
  return "${s}s";
}
