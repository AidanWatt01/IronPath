// lib/ui/widgets/quick_log_sheet.dart
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:drift/drift.dart" show Value;

import "../../data/db/app_db.dart";
import "dart:math";
import "../../state/providers.dart";
import "../theme/cosmetic_visuals.dart";

class QuickLogSheet extends ConsumerStatefulWidget {
  const QuickLogSheet({
    super.key,
    required this.movementId,
    required this.movementName,

    // tells the sheet what fields to show
    required this.xpPerRep,
    required this.xpPerSecond,
    this.category,

    this.initialSets,
    this.initialReps,
    this.initialHoldSeconds,
    this.initialDurationSeconds,
    this.initialFormScore,
    this.showSnackOnSave = true,
  });

  final String movementId;
  final String movementName;

  final int xpPerRep;
  final int xpPerSecond;
  final String? category;

  final int? initialSets;
  final int? initialReps;
  final int? initialHoldSeconds;
  final int? initialDurationSeconds;
  final double? initialFormScore;

  final bool showSnackOnSave;

  @override
  ConsumerState<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends ConsumerState<QuickLogSheet> {
  // Sets
  int sets = 3;

  // Per-set inputs
  final List<int> repsBySet = <int>[];
  final List<int> holdBySet = <int>[];

  // Optional duration for reps-only movements (total workout time)
  bool trackDurationForReps = false;
  int totalDurationSeconds = 0;

  double formScore = 7;
  bool saving = false;

  bool get showReps => widget.xpPerRep > 0;
  bool get showHold => widget.xpPerSecond > 0;

  String get timeLabel =>
      (widget.category == "mobility") ? "Time (sec)" : "Hold (sec)";

  @override
  void initState() {
    super.initState();

    sets = (widget.initialSets ?? sets).clamp(1, 10);

    formScore = widget.initialFormScore ?? formScore;

    // If caller provided duration, default to tracking it (reps-only only).
    totalDurationSeconds =
        widget.initialDurationSeconds ?? totalDurationSeconds;
    trackDurationForReps =
        (widget.initialDurationSeconds != null &&
        widget.initialDurationSeconds! > 0);

    _ensureSetLists();

    final initReps = widget.initialReps;
    final initHold = widget.initialHoldSeconds;

    if (showReps && initReps != null) {
      for (int i = 0; i < repsBySet.length; i++) {
        repsBySet[i] = initReps.clamp(0, 999);
      }
    } else if (showReps) {
      // default reps pattern (easy baseline)
      for (int i = 0; i < repsBySet.length; i++) {
        repsBySet[i] = 5;
      }
    }

    if (showHold && initHold != null) {
      for (int i = 0; i < holdBySet.length; i++) {
        holdBySet[i] = initHold.clamp(0, 9999);
      }
    } else if (showHold) {
      // default holds pattern
      for (int i = 0; i < holdBySet.length; i++) {
        holdBySet[i] = 10;
      }
    }

    // If movement is timed, duration is implicitly tracked per-set, so ignore reps-only duration toggle.
    if (showHold) {
      trackDurationForReps = false;
      totalDurationSeconds = 0;
    }
  }

  void _ensureSetLists() {
    // Resize lists to match `sets`
    if (showReps) {
      while (repsBySet.length < sets) {
        repsBySet.add(repsBySet.isEmpty ? 5 : repsBySet.last);
      }
      while (repsBySet.length > sets) {
        repsBySet.removeLast();
      }
    } else {
      repsBySet.clear();
    }

    if (showHold) {
      while (holdBySet.length < sets) {
        holdBySet.add(holdBySet.isEmpty ? 10 : holdBySet.last);
      }
      while (holdBySet.length > sets) {
        holdBySet.removeLast();
      }
    } else {
      holdBySet.clear();
    }
  }

  int _totalReps() {
    if (!showReps) return 0;
    return repsBySet.fold<int>(0, (a, b) => a + b.clamp(0, 999));
  }

  int _totalHold() {
    if (!showHold) return 0;
    return holdBySet.fold<int>(0, (a, b) => a + b.clamp(0, 9999));
  }

  int _bestRepsSet() {
    if (!showReps || repsBySet.isEmpty) return 0;
    return repsBySet.reduce(max).clamp(0, 999);
  }

  int _bestHoldSet() {
    if (!showHold || holdBySet.isEmpty) return 0;
    return holdBySet.reduce(max).clamp(0, 9999);
  }

  List<int> _splitDurationAcrossSets(int total, int n) {
    if (n <= 0) return const <int>[];
    if (total <= 0) return List<int>.filled(n, 0);

    final base = total ~/ n;
    final remainder = total - (base * n);

    final out = List<int>.filled(n, base);
    // Put remainder on the last set so sum matches exactly
    out[n - 1] = out[n - 1] + remainder;
    return out;
  }

  Future<void> _showLevelUpDialog({
    required int levelsGained,
    required int newLevel,
    required int perkPointsEarned,
    required int coinsEarned,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Level Up"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                levelsGained == 1
                    ? "You reached Level $newLevel."
                    : "You gained $levelsGained levels and reached Level $newLevel.",
              ),
              const SizedBox(height: 10),
              Text(
                "+$perkPointsEarned Perk Point${perkPointsEarned == 1 ? "" : "s"}",
              ),
              Text("+$coinsEarned Coins"),
              const SizedBox(height: 8),
              const Text("Spend perk points from the Dashboard stats card."),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Nice"),
            ),
          ],
        );
      },
    );
  }

  Future<void> save() async {
    if (!showReps && !showHold) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This movement has no XP rules (no reps or hold)."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Build per-set durations:
    // - timed movements: duration = hold per set
    // - reps-only movements: optional total duration split across sets
    final perSetDuration = (!showHold && trackDurationForReps)
        ? _splitDurationAcrossSets(totalDurationSeconds.clamp(0, 99999), sets)
        : List<int>.filled(sets, 0);

    final entries = <_SetLogInput>[];
    for (int i = 0; i < sets; i++) {
      final reps = showReps ? repsBySet[i].clamp(0, 999) : 0;
      final hold = showHold ? holdBySet[i].clamp(0, 9999) : 0;

      // Skip empty sets (prevents accidental logging of zeros)
      if (showReps && reps == 0 && !showHold) continue;
      if (showHold && hold == 0 && !showReps) continue;
      if (showReps && showHold && reps == 0 && hold == 0) continue;

      final duration = showHold ? hold : perSetDuration[i];
      entries.add(
        _SetLogInput(reps: reps, holdSeconds: hold, durationSeconds: duration),
      );
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nothing to log - add reps/hold to at least one set."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => saving = true);

    final svc = ref.read(logSessionServiceProvider);
    final db = ref.read(appDbProvider);
    final startedAt = DateTime.now();

    final workoutDuration = trackDurationForReps
        ? totalDurationSeconds.clamp(0, 99999)
        : entries.fold<int>(0, (sum, e) => sum + e.durationSeconds);

    int totalXp = 0;
    int totalCoins = 0;
    int totalPerkPoints = 0;
    int totalLevelsGained = 0;
    int latestLevel = 0;
    int loggedSets = 0;
    int? workoutId;

    try {
      workoutId = await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              startedAt: startedAt,
              durationSeconds: Value(workoutDuration),
            ),
          );

      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        final result = await svc.log(
          movementId: widget.movementId,
          reps: e.reps,
          holdSeconds: e.holdSeconds,
          durationSeconds: e.durationSeconds,
          formScore: formScore.round(),
          workoutId: workoutId,
          setIndex: i,
          startedAt: startedAt,
        );

        totalXp += result.xpEarned;
        totalCoins += result.coinsEarned;
        totalPerkPoints += result.perkPointsEarned;
        totalLevelsGained += result.levelsGained;
        latestLevel = max(latestLevel, result.newLevel);
        loggedSets += 1;
      }

      if (!mounted) return;

      if (totalLevelsGained > 0) {
        await _showLevelUpDialog(
          levelsGained: totalLevelsGained,
          newLevel: latestLevel,
          perkPointsEarned: totalPerkPoints,
          coinsEarned: totalCoins,
        );
        if (!mounted) return;
      }

      Navigator.of(context).pop(totalXp);

      if (widget.showSnackOnSave) {
        final bits = <String>[];
        if (showReps) {
          bits.add("${_totalReps()} reps total (best ${_bestRepsSet()})");
        }
        if (showHold) {
          bits.add("${_totalHold()}s total (best ${_bestHoldSet()}s)");
        }
        bits.add("$loggedSets set${loggedSets == 1 ? "" : "s"}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Workout logged (+$totalXp XP, +$totalCoins coins) - ${bits.join(" - ")}",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$e"), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (loggedSets == 0 && workoutId != null) {
        await (db.delete(
          db.workouts,
        )..where((w) => w.id.equals(workoutId!))).go();
      }
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final scheme = Theme.of(context).colorScheme;
    final cosmeticStatus = ref.watch(cosmeticStatusProvider);
    final equippedCosmeticId = cosmeticStatus.maybeWhen(
      data: (v) => v.equippedCosmeticId,
      orElse: () => null,
    );
    final cosmeticVisual = cosmeticVisualForId(
      equippedCosmeticId,
      fallbackColor: scheme.primary,
    );
    final accent = cosmeticVisual.color;
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? Colors.white
        : Colors.black;

    // Keep lists sized correctly
    _ensureSetLists();

    final volumeLine = <String>[];
    if (showReps) {
      volumeLine.add("Total ${_totalReps()} reps - Best set ${_bestRepsSet()}");
    }
    if (showHold) {
      volumeLine.add("Total ${_totalHold()}s - Best set ${_bestHoldSet()}s");
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(color: accent.withValues(alpha: 0.58)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        cosmeticVisual.icon,
                        color: onAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Quick Log: ${widget.movementName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Log sets like a real workout. Benchmarks use your BEST set.",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              // Sets selector
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Sets",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: saving || sets <= 1
                        ? null
                        : () => setState(() {
                            sets = max(1, sets - 1);
                            _ensureSetLists();
                          }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: Text(
                        "$sets",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: saving
                        ? null
                        : () => setState(() {
                            sets = min(12, sets + 1);
                            _ensureSetLists();
                          }),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),

              if (volumeLine.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  volumeLine.join(" - "),
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ],

              const SizedBox(height: 12),

              // Quick apply buttons
              Row(
                children: [
                  if (showReps)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => setState(() {
                                final v = repsBySet.isEmpty
                                    ? 5
                                    : repsBySet.first;
                                for (int i = 0; i < repsBySet.length; i++) {
                                  repsBySet[i] = v;
                                }
                              }),
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy reps to all"),
                      ),
                    ),
                  if (showReps && showHold) const SizedBox(width: 10),
                  if (showHold)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () => setState(() {
                                final v = holdBySet.isEmpty
                                    ? 10
                                    : holdBySet.first;
                                for (int i = 0; i < holdBySet.length; i++) {
                                  holdBySet[i] = v;
                                }
                              }),
                        icon: const Icon(Icons.copy),
                        label: const Text("Copy time to all"),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // Per-set rows
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: accent.withValues(alpha: 0.40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      for (int i = 0; i < sets; i++) ...[
                        _SetHeaderRow(setIndex: i, accentColor: accent),
                        if (showReps)
                          _StepperRow(
                            label: "Reps",
                            value: repsBySet[i],
                            onChanged: (v) =>
                                setState(() => repsBySet[i] = v.clamp(0, 999)),
                            maxValue: 999,
                            quickSteps: const [5, 10],
                            accentColor: accent,
                            enabled: !saving,
                          ),
                        if (showHold)
                          _StepperRow(
                            label: timeLabel,
                            value: holdBySet[i],
                            onChanged: (v) =>
                                setState(() => holdBySet[i] = v.clamp(0, 9999)),
                            maxValue: 9999,
                            quickSteps: const [5, 10, 30, 60],
                            accentColor: accent,
                            enabled: !saving,
                          ),
                        if (i != sets - 1) const Divider(height: 18),
                      ],
                    ],
                  ),
                ),
              ),

              // Optional duration for reps-only movements (total time)
              if (showReps && !showHold) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Track workout time (optional)"),
                  subtitle: Text(
                    "Adds Duration (sec) for stats. We'll split it across sets.",
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  value: trackDurationForReps,
                  onChanged: saving
                      ? null
                      : (v) => setState(() => trackDurationForReps = v),
                ),
                if (trackDurationForReps) ...[
                  _StepperRow(
                    label: "Total Duration (sec)",
                    value: totalDurationSeconds,
                    onChanged: (v) => setState(
                      () => totalDurationSeconds = v.clamp(0, 99999),
                    ),
                    maxValue: 99999,
                    quickSteps: const [15, 30, 60, 120],
                    accentColor: accent,
                    enabled: !saving,
                  ),
                ],
              ],

              const SizedBox(height: 10),

              Text("Form Score: ${formScore.round()}/10"),
              Slider(
                value: formScore,
                min: 0,
                max: 10,
                divisions: 10,
                label: "${formScore.round()}",
                activeColor: accent,
                onChanged: saving ? null : (v) => setState(() => formScore = v),
              ),

              const SizedBox(height: 10),

              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                ),
                onPressed: saving ? null : save,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save workout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetLogInput {
  const _SetLogInput({
    required this.reps,
    required this.holdSeconds,
    required this.durationSeconds,
  });

  final int reps;
  final int holdSeconds;
  final int durationSeconds;
}

class _SetHeaderRow extends StatelessWidget {
  const _SetHeaderRow({required this.setIndex, required this.accentColor});

  final int setIndex;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accentColor.withValues(alpha: 0.55)),
            ),
            child: Text(
              "Set ${setIndex + 1}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.maxValue,
    this.quickSteps = const <int>[5, 10],
    required this.accentColor,
    this.enabled = true,
  });

  final String label;
  final int value;
  final int maxValue;
  final List<int> quickSteps;
  final Color accentColor;
  final bool enabled;
  final void Function(int) onChanged;

  Future<void> _editValue(BuildContext context) async {
    if (!enabled) return;

    final c = TextEditingController(text: "$value");
    final next = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set $label"),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter a number",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final parsed = int.tryParse(c.text.trim());
                Navigator.of(context).pop(parsed);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );

    if (next == null) return;
    onChanged(next.clamp(0, maxValue));
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            IconButton(
              onPressed: enabled ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 88,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: enabled ? () => _editValue(context) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: muted),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$value",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, size: 14, color: muted),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: enabled ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (quickSteps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 6,
                children: quickSteps.map((step) {
                  return ActionChip(
                    label: Text("+$step"),
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: accentColor.withValues(alpha: 0.45),
                    ),
                    onPressed: enabled ? () => onChanged(value + step) : null,
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
