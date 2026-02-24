import "dart:math";

import "running_activity.dart";
import "running_goal.dart";

class RunningPlanAdaptation {
  const RunningPlanAdaptation({
    required this.recentRunCount,
    required this.recentDistanceKm,
    required this.expectedDistanceKm,
    required this.adherenceScore,
    required this.volumeMultiplier,
    required this.intensityMultiplier,
    required this.message,
    required this.paceTrendPercent,
    required this.loadSpikeDetected,
  });

  final int recentRunCount;
  final double recentDistanceKm;
  final double expectedDistanceKm;
  final double adherenceScore;
  final double volumeMultiplier;
  final double intensityMultiplier;
  final String message;
  final double paceTrendPercent;
  final bool loadSpikeDetected;
}

class RunningAdaptationService {
  const RunningAdaptationService._();

  static RunningPlanAdaptation fromRecentActivities({
    required RunningGoalConfig goal,
    required List<RunningActivity> allActivities,
    DateTime? now,
  }) {
    final today = _dayStart(now ?? DateTime.now());
    final windowStart = today.subtract(const Duration(days: 21));
    final activities =
        allActivities.where((x) => x.startedAt.isAfter(windowStart)).toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final recentDistance = activities.fold<double>(
      0.0,
      (sum, x) => sum + x.distanceKm,
    );
    final expectedWeekly = goal.type == RunningGoalType.getFaster
        ? max(14.0, goal.baselineDistanceKm * 1.2)
        : max(16.0, goal.baselineDistanceKm * 1.35);
    final expectedDistance = expectedWeekly * 3.0;
    final adherence = expectedDistance <= 0
        ? 1.0
        : (recentDistance / expectedDistance);

    var volume = 1.0;
    if (activities.length < 3) {
      volume = 0.94;
    } else if (adherence < 0.55) {
      volume = 0.84;
    } else if (adherence < 0.75) {
      volume = 0.90;
    } else if (adherence > 1.25 && activities.length >= 10) {
      volume = 1.06;
    } else if (adherence > 1.10 && activities.length >= 8) {
      volume = 1.03;
    }

    final intensityTrend = _paceTrendPercent(activities);
    var intensity = 1.0;
    if (intensityTrend <= -0.04) {
      intensity = 0.93;
    } else if (intensityTrend <= -0.02) {
      intensity = 0.97;
    } else if (intensityTrend >= 0.03) {
      intensity = 1.04;
    }

    final week0 = _distanceInRange(
      activities,
      start: today.subtract(const Duration(days: 7)),
      end: today,
    );
    final week1 = _distanceInRange(
      activities,
      start: today.subtract(const Duration(days: 14)),
      end: today.subtract(const Duration(days: 7)),
    );
    final loadSpike =
        week1 > 0 && (week0 / week1) > 1.3 && week0 > expectedWeekly * 1.2;
    if (loadSpike) {
      volume *= 0.92;
      intensity *= 0.90;
    }

    volume = volume.clamp(0.80, 1.10);
    intensity = intensity.clamp(0.86, 1.08);

    final message = _adaptationMessage(
      adherence: adherence,
      paceTrendPercent: intensityTrend,
      loadSpikeDetected: loadSpike,
      volumeMultiplier: volume,
      intensityMultiplier: intensity,
      runCount: activities.length,
    );

    return RunningPlanAdaptation(
      recentRunCount: activities.length,
      recentDistanceKm: recentDistance,
      expectedDistanceKm: expectedDistance,
      adherenceScore: adherence,
      volumeMultiplier: volume,
      intensityMultiplier: intensity,
      message: message,
      paceTrendPercent: intensityTrend,
      loadSpikeDetected: loadSpike,
    );
  }

  static String _adaptationMessage({
    required double adherence,
    required double paceTrendPercent,
    required bool loadSpikeDetected,
    required double volumeMultiplier,
    required double intensityMultiplier,
    required int runCount,
  }) {
    if (runCount < 3) {
      return "Low data confidence. Sync at least 3 runs for stronger adaptation.";
    }
    if (loadSpikeDetected) {
      return "Recent load spike detected. Plan is protecting recovery for this cycle.";
    }
    if (adherence < 0.75) {
      return "Execution is below target. Plan reduces load to rebuild consistency.";
    }
    if (adherence > 1.15 && paceTrendPercent >= 0.02) {
      return "Strong execution and pace trend. Plan slightly increases challenge.";
    }
    if (intensityMultiplier < 0.97) {
      return "Pace trend suggests fatigue. Plan trims intensity while keeping frequency.";
    }
    if (volumeMultiplier > 1.02 || intensityMultiplier > 1.01) {
      return "Good momentum. Plan adds a controlled progression step.";
    }
    return "Execution is stable. Plan keeps current progression.";
  }

  static double _paceTrendPercent(List<RunningActivity> activities) {
    final candidates = activities.where((x) => x.distanceKm >= 3.0).toList();
    if (candidates.length < 6) {
      return 0.0;
    }

    final recent = candidates.take(3).toList();
    final older = candidates.skip(3).take(3).toList();
    if (recent.isEmpty || older.isEmpty) {
      return 0.0;
    }

    final recentPace =
        recent.fold<double>(0, (sum, x) => sum + x.paceMinutesPerKm) /
        recent.length;
    final olderPace =
        older.fold<double>(0, (sum, x) => sum + x.paceMinutesPerKm) /
        older.length;
    if (olderPace <= 0) {
      return 0.0;
    }

    // Positive value means pace improved (faster).
    return ((olderPace - recentPace) / olderPace).clamp(-0.40, 0.40);
  }

  static double _distanceInRange(
    List<RunningActivity> activities, {
    required DateTime start,
    required DateTime end,
  }) {
    var sum = 0.0;
    for (final a in activities) {
      if (a.startedAt.isBefore(start) || !a.startedAt.isBefore(end)) {
        continue;
      }
      sum += a.distanceKm;
    }
    return sum;
  }

  static DateTime _dayStart(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
