import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../domain/running_goal.dart";
import "../../state/providers.dart";

class RunningGoalsScreen extends ConsumerStatefulWidget {
  const RunningGoalsScreen({super.key});

  @override
  ConsumerState<RunningGoalsScreen> createState() => _RunningGoalsScreenState();
}

class _RunningGoalsScreenState extends ConsumerState<RunningGoalsScreen> {
  final _targetDistanceController = TextEditingController();
  final _baselineDistanceController = TextEditingController();
  final _baselineDurationController = TextEditingController();
  final _targetDurationController = TextEditingController();
  final _notesController = TextEditingController();

  RunningGoalType _goalType = RunningGoalType.distanceByDate;
  DateTime? _targetDate;
  String? _errorText;
  bool _hydratedFromProvider = false;
  bool _saving = false;

  late final ProviderSubscription<AsyncValue<RunningGoalConfig?>> _goalSub;

  @override
  void initState() {
    super.initState();

    _goalSub = ref.listenManual(runningGoalProvider, (prev, next) {
      next.whenData((goal) {
        if (!mounted) return;
        if (_hydratedFromProvider) return;
        _applyGoal(goal);
        _hydratedFromProvider = true;
      });
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _goalSub.close();
    _targetDistanceController.dispose();
    _baselineDistanceController.dispose();
    _baselineDurationController.dispose();
    _targetDurationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyGoal(RunningGoalConfig? goal) {
    if (goal == null) {
      final now = DateTime.now();
      _targetDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 56));
      return;
    }

    setState(() {
      _goalType = goal.type;
      _targetDate = DateTime(
        goal.targetDate.year,
        goal.targetDate.month,
        goal.targetDate.day,
      );
      _targetDistanceController.text = goal.targetDistanceKm.toStringAsFixed(1);
      _baselineDistanceController.text = goal.baselineDistanceKm
          .toStringAsFixed(1);
      _baselineDurationController.text = "${goal.baselineDurationMinutes}";
      _targetDurationController.text = goal.targetDurationMinutes == null
          ? ""
          : "${goal.targetDurationMinutes}";
      _notesController.text = goal.notes ?? "";
      _errorText = null;
    });
  }

  double? _parseDouble(String raw) {
    final text = raw.trim().replaceAll(",", ".");
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? _parseInt(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _targetDate ?? today.add(const Duration(days: 56));

    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
      initialDate: initial.isBefore(today) ? today : initial,
    );

    if (!mounted || picked == null) return;
    setState(() {
      _targetDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _saveGoal() async {
    final targetDistance = _parseDouble(_targetDistanceController.text);
    final baselineDistance = _parseDouble(_baselineDistanceController.text);
    final baselineDuration = _parseInt(_baselineDurationController.text);
    final targetDuration = _parseInt(_targetDurationController.text);
    final targetDate = _targetDate;

    String? validationError;

    if (targetDistance == null || targetDistance <= 0) {
      validationError = "Enter a valid target distance.";
    } else if (baselineDistance == null || baselineDistance <= 0) {
      validationError = "Enter your current/baseline distance.";
    } else if (baselineDuration == null || baselineDuration <= 0) {
      validationError = "Enter your baseline time in minutes.";
    } else if (targetDate == null) {
      validationError = "Pick a target date.";
    } else if (_goalType == RunningGoalType.getFaster &&
        (targetDuration == null || targetDuration <= 0)) {
      validationError = "Enter a target finish time for speed goal.";
    }

    if (validationError != null) {
      setState(() {
        _errorText = validationError;
      });
      return;
    }

    final config = RunningGoalConfig(
      type: _goalType,
      targetDistanceKm: targetDistance!,
      targetDate: targetDate!,
      baselineDistanceKm: baselineDistance!,
      baselineDurationMinutes: baselineDuration!,
      targetDurationMinutes: _goalType == RunningGoalType.getFaster
          ? targetDuration
          : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await ref.read(runningGoalProvider.notifier).saveGoal(config);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Running goal saved.")));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _clearGoal() async {
    await ref.read(runningGoalProvider.notifier).clearGoal();
    if (!mounted) return;
    setState(() {
      _hydratedFromProvider = false;
      _goalType = RunningGoalType.distanceByDate;
      _targetDistanceController.clear();
      _baselineDistanceController.clear();
      _baselineDurationController.clear();
      _targetDurationController.clear();
      _notesController.clear();
      _errorText = null;
    });
    _applyGoal(null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            "Running Goal",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          SegmentedButton<RunningGoalType>(
            segments: const [
              ButtonSegment(
                value: RunningGoalType.distanceByDate,
                label: Text("Distance by Date"),
                icon: Icon(Icons.event),
              ),
              ButtonSegment(
                value: RunningGoalType.getFaster,
                label: Text("Get Faster"),
                icon: Icon(Icons.speed),
              ),
            ],
            selected: <RunningGoalType>{_goalType},
            onSelectionChanged: (next) {
              if (next.isEmpty) return;
              setState(() {
                _goalType = next.first;
              });
            },
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: "Target distance (km)",
            controller: _targetDistanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _LabeledField(
            label: "Current best distance (km)",
            controller: _baselineDistanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          _LabeledField(
            label: "Current time (minutes)",
            controller: _baselineDurationController,
            keyboardType: TextInputType.number,
          ),
          if (_goalType == RunningGoalType.getFaster)
            _LabeledField(
              label: "Target time (minutes)",
              controller: _targetDurationController,
              keyboardType: TextInputType.number,
            ),
          const SizedBox(height: 6),
          Text(
            "Target date",
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _targetDate == null ? "Pick date" : _formatDate(_targetDate!),
            ),
          ),
          _LabeledField(
            label: "Notes (optional)",
            controller: _notesController,
            maxLines: 2,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorText!,
              style: TextStyle(
                color: scheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _saveGoal,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text("Save goal"),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _saving ? null : _clearGoal,
            child: const Text("Clear goal"),
          ),
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

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
