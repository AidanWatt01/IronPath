import "dart:math";

import "running_adaptation_service.dart";
import "running_goal.dart";

enum RunningPhase { base, build, taper }

enum RunningWorkoutType { easy, quality, longRun, recovery, goal }

enum RunningGoalFeasibility { onTrack, stretch, aggressive }

String runningPhaseLabel(RunningPhase phase) {
  return switch (phase) {
    RunningPhase.base => "Base",
    RunningPhase.build => "Build",
    RunningPhase.taper => "Taper",
  };
}

String runningFeasibilityLabel(RunningGoalFeasibility feasibility) {
  return switch (feasibility) {
    RunningGoalFeasibility.onTrack => "On track",
    RunningGoalFeasibility.stretch => "Stretch",
    RunningGoalFeasibility.aggressive => "Aggressive",
  };
}

class RunningPaceZone {
  const RunningPaceZone({
    required this.id,
    required this.label,
    required this.slowerMinutesPerKm,
    required this.fasterMinutesPerKm,
  });

  final String id;
  final String label;
  final double slowerMinutesPerKm;
  final double fasterMinutesPerKm;

  String get rangeLabel {
    final slower = RunningPlanService.formatPace(slowerMinutesPerKm);
    final faster = RunningPlanService.formatPace(fasterMinutesPerKm);
    return "$slower - $faster";
  }
}

class RunningWorkout {
  const RunningWorkout({
    required this.dayLabel,
    required this.title,
    required this.distanceKm,
    required this.description,
    required this.prescription,
    required this.type,
    required this.paceZoneId,
  });

  final String dayLabel;
  final String title;
  final double distanceKm;
  final String description;
  final String prescription;
  final RunningWorkoutType type;
  final String paceZoneId;
}

class RunningPlanWeek {
  const RunningPlanWeek({
    required this.weekNumber,
    required this.weekStart,
    required this.totalDistanceKm,
    required this.workouts,
    required this.phase,
    required this.isRecoveryWeek,
    required this.focus,
  });

  final int weekNumber;
  final DateTime weekStart;
  final double totalDistanceKm;
  final List<RunningWorkout> workouts;
  final RunningPhase phase;
  final bool isRecoveryWeek;
  final String focus;
}

class RunningPlan {
  const RunningPlan({
    required this.headline,
    required this.summary,
    required this.weeks,
    required this.nextWorkout,
    required this.paceZones,
    required this.baseWeeks,
    required this.buildWeeks,
    required this.taperWeeks,
    required this.recoveryWeeks,
    required this.peakWeekDistanceKm,
    required this.estimatedFinishMinutes,
    required this.feasibility,
    required this.feasibilityReason,
    required this.adaptation,
  });

  final String headline;
  final String summary;
  final List<RunningPlanWeek> weeks;
  final RunningWorkout? nextWorkout;
  final List<RunningPaceZone> paceZones;
  final int baseWeeks;
  final int buildWeeks;
  final int taperWeeks;
  final int recoveryWeeks;
  final double peakWeekDistanceKm;
  final int estimatedFinishMinutes;
  final RunningGoalFeasibility feasibility;
  final String feasibilityReason;
  final RunningPlanAdaptation adaptation;
}

class _FeasibilityResult {
  const _FeasibilityResult({required this.feasibility, required this.reason});

  final RunningGoalFeasibility feasibility;
  final String reason;
}

class RunningPlanService {
  const RunningPlanService._();

  static RunningPlan buildPlan({
    required RunningGoalConfig goal,
    RunningPlanAdaptation? adaptation,
    DateTime? now,
  }) {
    final today = _dayStart(now ?? DateTime.now());
    final targetDate = _dayStart(goal.targetDate);
    final daysUntilTarget = max(1, targetDate.difference(today).inDays);
    final totalWeeks = (daysUntilTarget / 7).ceil().clamp(4, 32);

    final taperWeeks = totalWeeks >= 10 ? 2 : 1;
    final developmentalWeeks = max(2, totalWeeks - taperWeeks);
    final baseWeeks = _clampInt(
      (developmentalWeeks * 0.45).round(),
      2,
      developmentalWeeks - 1,
    );
    final buildWeeks = developmentalWeeks - baseWeeks;

    final baselinePace = goal.baselineDurationMinutes / goal.baselineDistanceKm;
    final targetPace = _targetPace(goal, baselinePace);
    final estimatedPace = _estimatedGoalPace(
      goal: goal,
      totalWeeks: totalWeeks,
      baselinePace: baselinePace,
    );
    final estimatedFinishMinutes = (estimatedPace * goal.targetDistanceKm)
        .round()
        .clamp(1, 99999);
    final feasibility = _feasibilityForGoal(
      goal: goal,
      totalWeeks: totalWeeks,
      baselinePace: baselinePace,
      estimatedPace: estimatedPace,
      taperWeeks: taperWeeks,
    );
    final paceZones = _buildPaceZones(
      baselinePaceMinutesPerKm: baselinePace,
      targetPaceMinutesPerKm: targetPace,
    );

    final effectiveAdaptation = adaptation ?? _fallbackAdaptation();

    final startWeeklyDistance =
        _startingWeeklyDistance(goal) * effectiveAdaptation.volumeMultiplier;
    final peakWeeklyDistance =
        _peakWeeklyDistance(
          goal: goal,
          startWeeklyDistance: startWeeklyDistance,
        ) *
        effectiveAdaptation.volumeMultiplier;

    final planWeeks = <RunningPlanWeek>[];
    var previousWeekVolume = startWeeklyDistance;
    var recoveryWeeks = 0;

    for (var i = 0; i < totalWeeks; i += 1) {
      final weekStart = today.add(Duration(days: i * 7));
      final phase = _phaseForWeek(
        weekIndex: i,
        baseWeeks: baseWeeks,
        developmentalWeeks: developmentalWeeks,
      );
      final weekIndexInPhase = _weekIndexInPhase(
        weekIndex: i,
        phase: phase,
        baseWeeks: baseWeeks,
        developmentalWeeks: developmentalWeeks,
      );
      final phaseLength = phase == RunningPhase.base
          ? baseWeeks
          : phase == RunningPhase.build
          ? buildWeeks
          : taperWeeks;

      final isRecoveryWeek =
          phase != RunningPhase.taper &&
          _isRecoveryWeek(
            indexInPhase: weekIndexInPhase,
            phaseLength: phaseLength,
          );
      if (isRecoveryWeek) {
        recoveryWeeks += 1;
      }

      final weekDistance = _weekDistance(
        goal: goal,
        weekIndex: i,
        totalWeeks: totalWeeks,
        developmentalWeeks: developmentalWeeks,
        taperWeeks: taperWeeks,
        phase: phase,
        isRecoveryWeek: isRecoveryWeek,
        previousWeekVolume: previousWeekVolume,
        startWeeklyDistance: startWeeklyDistance,
        peakWeeklyDistance: peakWeeklyDistance,
      );

      previousWeekVolume = weekDistance;

      final workouts = _buildWorkoutsForWeek(
        goal: goal,
        phase: phase,
        isRecoveryWeek: isRecoveryWeek,
        absoluteWeekIndex: i,
        weekIndexInPhase: weekIndexInPhase,
        phaseLength: phaseLength,
        totalDistanceKm: weekDistance,
        paceZones: paceZones,
        adaptation: effectiveAdaptation,
      );
      final weekTotal = workouts.fold<double>(
        0,
        (sum, w) => sum + w.distanceKm,
      );

      planWeeks.add(
        RunningPlanWeek(
          weekNumber: i + 1,
          weekStart: weekStart,
          totalDistanceKm: weekTotal,
          workouts: workouts,
          phase: phase,
          isRecoveryWeek: isRecoveryWeek,
          focus: _focusForWeek(
            goal: goal,
            phase: phase,
            isRecoveryWeek: isRecoveryWeek,
          ),
        ),
      );
    }

    final peakWeekDistance = planWeeks.fold<double>(
      0.0,
      (maxValue, w) => max(maxValue, w.totalDistanceKm),
    );

    final summary =
        "${totalWeeks}w periodized plan - ${baseWeeks}w base / ${buildWeeks}w build / ${taperWeeks}w taper - "
        "$recoveryWeeks recovery week${recoveryWeeks == 1 ? "" : "s"} - "
        "target ${goal.targetDistanceKm.toStringAsFixed(1)} km by ${_formatDate(targetDate)}";

    final nextWorkout = planWeeks.isEmpty || planWeeks.first.workouts.isEmpty
        ? null
        : planWeeks.first.workouts.first;

    return RunningPlan(
      headline: goal.type == RunningGoalType.getFaster
          ? "Periodized Speed Plan"
          : "Periodized Distance Plan",
      summary: summary,
      weeks: planWeeks,
      nextWorkout: nextWorkout,
      paceZones: paceZones,
      baseWeeks: baseWeeks,
      buildWeeks: buildWeeks,
      taperWeeks: taperWeeks,
      recoveryWeeks: recoveryWeeks,
      peakWeekDistanceKm: peakWeekDistance,
      estimatedFinishMinutes: estimatedFinishMinutes,
      feasibility: feasibility.feasibility,
      feasibilityReason: feasibility.reason,
      adaptation: effectiveAdaptation,
    );
  }

  static RunningPlanAdaptation _fallbackAdaptation() {
    return const RunningPlanAdaptation(
      recentRunCount: 0,
      recentDistanceKm: 0,
      expectedDistanceKm: 0,
      adherenceScore: 1.0,
      volumeMultiplier: 1.0,
      intensityMultiplier: 1.0,
      message:
          "No recent run data yet. Sync watch data to personalize this plan.",
      paceTrendPercent: 0.0,
      loadSpikeDetected: false,
    );
  }

  static String formatPace(double minutesPerKm) {
    final totalSeconds = (minutesPerKm * 60).round().clamp(1, 3600);
    final mm = totalSeconds ~/ 60;
    final ss = totalSeconds % 60;
    return "$mm:${ss.toString().padLeft(2, "0")}/km";
  }

  static List<RunningPaceZone> _buildPaceZones({
    required double baselinePaceMinutesPerKm,
    required double targetPaceMinutesPerKm,
  }) {
    final thresholdCenter =
        (baselinePaceMinutesPerKm + targetPaceMinutesPerKm) / 2;
    final z1Slow = baselinePaceMinutesPerKm * 1.24;
    final z1Fast = baselinePaceMinutesPerKm * 1.12;
    final z2Slow = baselinePaceMinutesPerKm * 1.12;
    final z2Fast = baselinePaceMinutesPerKm * 1.03;
    final z3Slow = baselinePaceMinutesPerKm * 1.01;
    final z3Fast = min(baselinePaceMinutesPerKm * 0.94, thresholdCenter * 1.02);
    final z4Slow = thresholdCenter * 1.03;
    final z4Fast = thresholdCenter * 0.95;
    final z5Slow = targetPaceMinutesPerKm * 0.98;
    final z5Fast = targetPaceMinutesPerKm * 0.88;

    return <RunningPaceZone>[
      _zone(id: "z1", label: "Z1 Recovery", slower: z1Slow, faster: z1Fast),
      _zone(id: "z2", label: "Z2 Easy", slower: z2Slow, faster: z2Fast),
      _zone(id: "z3", label: "Z3 Tempo", slower: z3Slow, faster: z3Fast),
      _zone(id: "z4", label: "Z4 Threshold", slower: z4Slow, faster: z4Fast),
      _zone(id: "z5", label: "Z5 Interval", slower: z5Slow, faster: z5Fast),
    ];
  }

  static RunningPaceZone _zone({
    required String id,
    required String label,
    required double slower,
    required double faster,
  }) {
    final fixedSlow = max(slower, faster + 0.05);
    final fixedFast = min(faster, fixedSlow - 0.05);
    return RunningPaceZone(
      id: id,
      label: label,
      slowerMinutesPerKm: fixedSlow,
      fasterMinutesPerKm: fixedFast,
    );
  }

  static RunningPhase _phaseForWeek({
    required int weekIndex,
    required int baseWeeks,
    required int developmentalWeeks,
  }) {
    if (weekIndex < baseWeeks) {
      return RunningPhase.base;
    }
    if (weekIndex < developmentalWeeks) {
      return RunningPhase.build;
    }
    return RunningPhase.taper;
  }

  static int _weekIndexInPhase({
    required int weekIndex,
    required RunningPhase phase,
    required int baseWeeks,
    required int developmentalWeeks,
  }) {
    return switch (phase) {
      RunningPhase.base => weekIndex,
      RunningPhase.build => weekIndex - baseWeeks,
      RunningPhase.taper => weekIndex - developmentalWeeks,
    };
  }

  static bool _isRecoveryWeek({
    required int indexInPhase,
    required int phaseLength,
  }) {
    if (phaseLength < 3) {
      return false;
    }
    if ((indexInPhase + 1) % 4 == 0) {
      return true;
    }
    if (phaseLength >= 3 && indexInPhase == phaseLength - 1) {
      return true;
    }
    return false;
  }

  static double _startingWeeklyDistance(RunningGoalConfig goal) {
    if (goal.type == RunningGoalType.getFaster) {
      return max(14.0, goal.baselineDistanceKm * 1.2);
    }
    return max(16.0, goal.baselineDistanceKm * 1.35);
  }

  static double _peakWeeklyDistance({
    required RunningGoalConfig goal,
    required double startWeeklyDistance,
  }) {
    final goalMultiplier = goal.type == RunningGoalType.getFaster ? 1.9 : 2.25;
    final byGoal = goal.targetDistanceKm * goalMultiplier;
    final byProgression = startWeeklyDistance * 1.35;
    return max(byGoal, byProgression);
  }

  static double _weekDistance({
    required RunningGoalConfig goal,
    required int weekIndex,
    required int totalWeeks,
    required int developmentalWeeks,
    required int taperWeeks,
    required RunningPhase phase,
    required bool isRecoveryWeek,
    required double previousWeekVolume,
    required double startWeeklyDistance,
    required double peakWeeklyDistance,
  }) {
    if (phase == RunningPhase.taper) {
      final taperIndex = weekIndex - developmentalWeeks;
      if (taperWeeks <= 1) {
        final singleWeek = max(
          peakWeeklyDistance * 0.55,
          goal.targetDistanceKm * 1.15,
        );
        return singleWeek;
      }
      if (taperIndex == taperWeeks - 1) {
        return max(peakWeeklyDistance * 0.50, goal.targetDistanceKm * 1.12);
      }
      return max(peakWeeklyDistance * 0.72, goal.targetDistanceKm * 1.25);
    }

    if (isRecoveryWeek) {
      final floor = startWeeklyDistance * 0.85;
      return max(floor, previousWeekVolume * 0.78);
    }

    final growth = phase == RunningPhase.base
        ? (goal.type == RunningGoalType.getFaster ? 1.06 : 1.08)
        : (goal.type == RunningGoalType.getFaster ? 1.08 : 1.10);
    final proposed = previousWeekVolume * growth;

    final progress = developmentalWeeks <= 1
        ? 1.0
        : (weekIndex / (developmentalWeeks - 1));
    final progressionFloor = _lerp(
      startWeeklyDistance,
      peakWeeklyDistance,
      progress,
    );
    final bounded = min(peakWeeklyDistance, max(proposed, progressionFloor));
    final minStep = max(startWeeklyDistance * 0.90, previousWeekVolume * 0.98);
    return max(minStep, bounded);
  }

  static List<RunningWorkout> _buildWorkoutsForWeek({
    required RunningGoalConfig goal,
    required RunningPhase phase,
    required bool isRecoveryWeek,
    required int absoluteWeekIndex,
    required int weekIndexInPhase,
    required int phaseLength,
    required double totalDistanceKm,
    required List<RunningPaceZone> paceZones,
    required RunningPlanAdaptation adaptation,
  }) {
    final isFinalTaperWeek =
        phase == RunningPhase.taper && weekIndexInPhase == phaseLength - 1;

    late double easyAKm;
    late double qualityKm;
    late double easyBKm;
    late double longKm;

    if (phase == RunningPhase.base) {
      easyAKm = totalDistanceKm * (isRecoveryWeek ? 0.38 : 0.34);
      qualityKm = totalDistanceKm * (isRecoveryWeek ? 0.15 : 0.20);
      easyBKm = totalDistanceKm * (isRecoveryWeek ? 0.20 : 0.16);
      longKm = totalDistanceKm * (isRecoveryWeek ? 0.27 : 0.30);
    } else if (phase == RunningPhase.build) {
      easyAKm = totalDistanceKm * (isRecoveryWeek ? 0.36 : 0.28);
      qualityKm = totalDistanceKm * (isRecoveryWeek ? 0.14 : 0.24);
      easyBKm = totalDistanceKm * (isRecoveryWeek ? 0.20 : 0.14);
      longKm = totalDistanceKm * (isRecoveryWeek ? 0.30 : 0.34);
    } else {
      easyAKm = totalDistanceKm * 0.30;
      qualityKm = totalDistanceKm * 0.18;
      easyBKm = totalDistanceKm * 0.12;
      longKm = totalDistanceKm * 0.40;
    }

    easyAKm = max(3.0, easyAKm);
    qualityKm = max(3.0, qualityKm);
    easyBKm = max(2.5, easyBKm);
    longKm = max(5.0, longKm);

    qualityKm = max(2.0, qualityKm * adaptation.intensityMultiplier);
    if (adaptation.intensityMultiplier < 0.95) {
      longKm *= 0.96;
    } else if (adaptation.intensityMultiplier > 1.03) {
      longKm *= 1.02;
    }

    if (isFinalTaperWeek) {
      longKm = max(goal.targetDistanceKm, longKm);
      easyAKm = max(3.0, totalDistanceKm * 0.22);
      qualityKm = max(2.5, totalDistanceKm * 0.12);
      easyBKm = max(2.0, totalDistanceKm * 0.08);
    }

    final z1 = _zoneById(paceZones, "z1");
    final z2 = _zoneById(paceZones, "z2");

    final qualityTitle = _qualityTitle(
      goal: goal,
      phase: phase,
      isRecoveryWeek: isRecoveryWeek,
      isFinalTaperWeek: isFinalTaperWeek,
    );
    final qualityZone = _qualityZoneId(
      goal: goal,
      phase: phase,
      isRecoveryWeek: isRecoveryWeek,
      isFinalTaperWeek: isFinalTaperWeek,
    );
    final adaptedQualityZone = _adjustZoneForIntensity(
      zoneId: qualityZone,
      intensityMultiplier: adaptation.intensityMultiplier,
    );
    final qualityZoneInfo = _zoneById(paceZones, adaptedQualityZone);
    final qualityPrescription = _qualityPrescription(
      goal: goal,
      phase: phase,
      isRecoveryWeek: isRecoveryWeek,
      isFinalTaperWeek: isFinalTaperWeek,
      weekIndexInPhase: weekIndexInPhase,
      absoluteWeekIndex: absoluteWeekIndex,
      qualityZone: qualityZoneInfo,
    );

    final longTitle = isFinalTaperWeek ? "Goal Run / Time Trial" : "Long Run";
    final longType = isFinalTaperWeek
        ? RunningWorkoutType.goal
        : RunningWorkoutType.longRun;
    final longZone = isFinalTaperWeek ? "z3" : "z2";
    final longZoneInfo = _zoneById(paceZones, longZone);
    final easyPrescription = phase == RunningPhase.taper
        ? "Easy aerobic run + 4 x 20s strides."
        : "Steady conversational effort.";
    final recoveryPrescription = isRecoveryWeek
        ? "Keep HR low; no surges."
        : "Relaxed easy day, full recovery intent.";
    final longPrescription = isFinalTaperWeek
        ? "Goal simulation day. Start controlled and finish strong."
        : (phase == RunningPhase.base
              ? "Progress the final 20 minutes to upper easy effort."
              : "Last 25-35 minutes at steady marathon effort.");

    final workouts = <RunningWorkout>[
      RunningWorkout(
        dayLabel: "Tue",
        title: phase == RunningPhase.taper ? "Easy + Strides" : "Easy Run",
        distanceKm: easyAKm,
        description: "Stay relaxed in ${z2.label} (${z2.rangeLabel}).",
        prescription: easyPrescription,
        type: RunningWorkoutType.easy,
        paceZoneId: "z2",
      ),
      RunningWorkout(
        dayLabel: "Thu",
        title: qualityTitle,
        distanceKm: qualityKm,
        description:
            "${qualityZoneInfo.label} session (${qualityZoneInfo.rangeLabel}). Keep form smooth.",
        prescription: qualityPrescription,
        type: isRecoveryWeek
            ? RunningWorkoutType.recovery
            : RunningWorkoutType.quality,
        paceZoneId: adaptedQualityZone,
      ),
      RunningWorkout(
        dayLabel: "Sat",
        title: isRecoveryWeek ? "Recovery Jog" : "Easy Run",
        distanceKm: easyBKm,
        description: "Very easy turnover in ${z1.label} (${z1.rangeLabel}).",
        prescription: recoveryPrescription,
        type: isRecoveryWeek
            ? RunningWorkoutType.recovery
            : RunningWorkoutType.easy,
        paceZoneId: "z1",
      ),
      RunningWorkout(
        dayLabel: "Sun",
        title: longTitle,
        distanceKm: longKm,
        description: isFinalTaperWeek
            ? "Execute goal effort near ${longZoneInfo.label} (${longZoneInfo.rangeLabel})."
            : "Build durability in ${longZoneInfo.label} (${longZoneInfo.rangeLabel}).",
        prescription: longPrescription,
        type: longType,
        paceZoneId: longZone,
      ),
    ];

    final total = workouts.fold<double>(0.0, (sum, w) => sum + w.distanceKm);
    if (total <= 0) {
      return workouts;
    }

    final scale = totalDistanceKm / total;
    return workouts
        .map(
          (w) => RunningWorkout(
            dayLabel: w.dayLabel,
            title: w.title,
            distanceKm: max(1.5, w.distanceKm * scale),
            description: w.description,
            prescription: w.prescription,
            type: w.type,
            paceZoneId: w.paceZoneId,
          ),
        )
        .toList();
  }

  static String _qualityTitle({
    required RunningGoalConfig goal,
    required RunningPhase phase,
    required bool isRecoveryWeek,
    required bool isFinalTaperWeek,
  }) {
    if (isFinalTaperWeek) {
      return "Race Pace Rehearsal";
    }
    if (isRecoveryWeek) {
      return "Controlled Fartlek";
    }
    if (phase == RunningPhase.base) {
      return "Tempo Intervals";
    }
    if (goal.type == RunningGoalType.getFaster) {
      return "Speed Intervals";
    }
    return "Threshold Tempo";
  }

  static String _qualityZoneId({
    required RunningGoalConfig goal,
    required RunningPhase phase,
    required bool isRecoveryWeek,
    required bool isFinalTaperWeek,
  }) {
    if (isRecoveryWeek) {
      return "z3";
    }
    if (isFinalTaperWeek) {
      return "z3";
    }
    if (phase == RunningPhase.base) {
      return "z3";
    }
    if (goal.type == RunningGoalType.getFaster) {
      return "z5";
    }
    return "z4";
  }

  static String _adjustZoneForIntensity({
    required String zoneId,
    required double intensityMultiplier,
  }) {
    if (intensityMultiplier < 0.95) {
      return switch (zoneId) {
        "z5" => "z4",
        "z4" => "z3",
        _ => zoneId,
      };
    }

    if (intensityMultiplier > 1.04) {
      return switch (zoneId) {
        "z3" => "z4",
        "z4" => "z5",
        _ => zoneId,
      };
    }
    return zoneId;
  }

  static String _qualityPrescription({
    required RunningGoalConfig goal,
    required RunningPhase phase,
    required bool isRecoveryWeek,
    required bool isFinalTaperWeek,
    required int weekIndexInPhase,
    required int absoluteWeekIndex,
    required RunningPaceZone qualityZone,
  }) {
    if (isFinalTaperWeek) {
      return "2 x 8 min at race rhythm in ${qualityZone.label}. Full recovery.";
    }
    if (isRecoveryWeek) {
      return "6 x 1 min smooth surges in ${qualityZone.label}, easy float recoveries.";
    }
    if (phase == RunningPhase.base) {
      final reps = 3 + (weekIndexInPhase % 2);
      return "$reps x 6 min controlled tempo in ${qualityZone.label} with 2 min easy jog.";
    }
    if (goal.type == RunningGoalType.getFaster) {
      if (absoluteWeekIndex.isEven) {
        return "8 x 400m at ${qualityZone.label}, 200m jog recoveries.";
      }
      return "10 x 60s hill repeats at ${qualityZone.label}, walk/jog back down.";
    }
    final reps = 2 + (weekIndexInPhase % 2);
    return "$reps x 12 min threshold in ${qualityZone.label} with 3 min easy jog.";
  }

  static double _estimatedGoalPace({
    required RunningGoalConfig goal,
    required int totalWeeks,
    required double baselinePace,
  }) {
    final baseImprovement = goal.type == RunningGoalType.getFaster
        ? 0.018
        : 0.012;
    final growth = 1.0 - exp(-totalWeeks / 10.0);
    final cappedImprovement = goal.type == RunningGoalType.getFaster
        ? 0.18
        : 0.12;
    final expectedImprovement = min(
      cappedImprovement,
      baseImprovement * totalWeeks * growth,
    );

    var estimated = baselinePace * (1.0 - expectedImprovement);
    if (goal.type == RunningGoalType.getFaster &&
        goal.targetDurationMinutes != null &&
        goal.targetDurationMinutes! > 0) {
      final required = goal.targetDurationMinutes! / goal.targetDistanceKm;
      estimated = max(required, estimated);
    }
    return estimated;
  }

  static _FeasibilityResult _feasibilityForGoal({
    required RunningGoalConfig goal,
    required int totalWeeks,
    required double baselinePace,
    required double estimatedPace,
    required int taperWeeks,
  }) {
    if (goal.type == RunningGoalType.getFaster &&
        goal.targetDurationMinutes != null &&
        goal.targetDurationMinutes! > 0) {
      final requiredPace = goal.targetDurationMinutes! / goal.targetDistanceKm;
      final requiredGain = ((baselinePace - requiredPace) / baselinePace).clamp(
        0.0,
        0.95,
      );
      final expectedGain = ((baselinePace - estimatedPace) / baselinePace)
          .clamp(0.0, 0.95);

      if (requiredGain <= expectedGain * 1.05) {
        return _FeasibilityResult(
          feasibility: RunningGoalFeasibility.onTrack,
          reason:
              "Target pace is within expected adaptation for $totalWeeks weeks.",
        );
      }
      if (requiredGain <= expectedGain * 1.35) {
        return _FeasibilityResult(
          feasibility: RunningGoalFeasibility.stretch,
          reason:
              "Target is ambitious. Consistency and recovery execution will matter.",
        );
      }
      return _FeasibilityResult(
        feasibility: RunningGoalFeasibility.aggressive,
        reason:
            "Requested pace gain is high for this timeline. Consider extending target date.",
      );
    }

    final progressionWeeks = max(1, totalWeeks - taperWeeks);
    final startLong = max(5.0, goal.baselineDistanceKm * 0.75);
    final requiredGrowthPerWeek =
        (goal.targetDistanceKm - startLong) / progressionWeeks;

    if (requiredGrowthPerWeek <= 1.1) {
      return _FeasibilityResult(
        feasibility: RunningGoalFeasibility.onTrack,
        reason: "Distance ramp is realistic for the timeline.",
      );
    }
    if (requiredGrowthPerWeek <= 1.7) {
      return _FeasibilityResult(
        feasibility: RunningGoalFeasibility.stretch,
        reason:
            "Distance ramp is demanding. Protect recovery and avoid skipping deload weeks.",
      );
    }
    return _FeasibilityResult(
      feasibility: RunningGoalFeasibility.aggressive,
      reason:
          "Distance ramp is steep for the available weeks. Extend timeline or lower first target.",
    );
  }

  static RunningPaceZone _zoneById(List<RunningPaceZone> zones, String id) {
    return zones.firstWhere((z) => z.id == id, orElse: () => zones.first);
  }

  static String _focusForWeek({
    required RunningGoalConfig goal,
    required RunningPhase phase,
    required bool isRecoveryWeek,
  }) {
    if (isRecoveryWeek) {
      return "Absorb training load and restore freshness.";
    }
    return switch (phase) {
      RunningPhase.base => "Aerobic durability and smooth mechanics.",
      RunningPhase.build =>
        goal.type == RunningGoalType.getFaster
            ? "Raise top-end speed and lactate tolerance."
            : "Extend sustained effort at threshold pace.",
      RunningPhase.taper => "Reduce fatigue while keeping race sharpness.",
    };
  }

  static double _targetPace(RunningGoalConfig goal, double baselinePace) {
    if (goal.type == RunningGoalType.getFaster &&
        goal.targetDurationMinutes != null &&
        goal.targetDurationMinutes! > 0) {
      return goal.targetDurationMinutes! / goal.targetDistanceKm;
    }
    return baselinePace * 0.98;
  }

  static int _clampInt(int value, int minValue, int maxValue) {
    if (minValue > maxValue) {
      return minValue;
    }
    return value.clamp(minValue, maxValue);
  }

  static DateTime _dayStart(DateTime x) {
    return DateTime(x.year, x.month, x.day);
  }

  static double _lerp(double a, double b, double t) {
    return a + ((b - a) * t);
  }

  static String _formatDate(DateTime date) {
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
    final month = months[date.month - 1];
    return "$month ${date.day}, ${date.year}";
  }
}
