// lib/services/cycle/phase_service.dart

import 'package:flutter/material.dart';
import '../../models/cycle_models.dart';
import '../../models/enums.dart';
import '../../utils/constants/colors.dart';

/// Medical facts about cycle phases:
/// - Menstrual: Days 1-X (actual bleeding, typically 3-7 days)
/// - Follicular: From end of period until ovulation
/// - Ovulation: ~14 days BEFORE next period, typically 1-2 days
/// - Luteal: Always ~14 days after ovulation until next period
class PhaseService {
  /// Determines which cycle phase a date falls into
  /// Uses actual cycle data for accurate detection
  static CyclePhase getPhase(DateTime date, Map<String, dynamic> stats) {
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    if (periods.isEmpty) return CyclePhase.menstrual;

    final lastPeriod = periods.last;
    final lastPeriodStart = lastPeriod.first;
    final lastPeriodEnd = lastPeriod.last;

    // Check if in menstrual phase (actual period)
    if (!date.isBefore(lastPeriodStart) && !date.isAfter(lastPeriodEnd)) {
      return CyclePhase.menstrual;
    }

    // Get ovulation date from stats
    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) {
      // Fallback: use approximate calculation
      return _getApproximatePhase(date, lastPeriodStart, stats);
    }

    // Check if in ovulation phase (1 day before, ovulation day, 1 day after)
    final ovulationStart = ovulationDate.subtract(const Duration(days: 1));
    final ovulationEnd = ovulationDate.add(const Duration(days: 1));
    if (!date.isBefore(ovulationStart) && !date.isAfter(ovulationEnd)) {
      return CyclePhase.ovulation;
    }

    // Check if in luteal phase (after ovulation until next period)
    if (date.isAfter(ovulationEnd)) {
      return CyclePhase.luteal;
    }

    // Otherwise in follicular phase (between period and ovulation)
    return CyclePhase.follicular;
  }

  /// Fallback method using approximate day counts
  static CyclePhase _getApproximatePhase(
    DateTime date,
    DateTime periodStart,
    Map<String, dynamic> stats,
  ) {
    final daysSincePeriod = date.difference(periodStart).inDays;
    final averageCycle = stats['average'] as int? ?? 28;
    final ovulationDay =
        averageCycle - 14; // Ovulation is 14 days before next period

    if (daysSincePeriod < 5) return CyclePhase.menstrual;
    if (daysSincePeriod < ovulationDay - 1) return CyclePhase.follicular;
    if (daysSincePeriod <= ovulationDay + 1) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Gets phase name without icon
  static String getPhaseName(DateTime date, Map<String, dynamic> stats) {
    return getPhase(date, stats).name;
  }

  /// Gets phase with icon for display
  static String getPhaseDisplay(DateTime date, Map<String, dynamic> stats) {
    return getPhase(date, stats).displayName;
  }

  /// Gets color for a phase
  static Color getPhaseColor(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return AppColors.menstrual;
      case 'Follicular':
        return AppColors.follicular;
      case 'Ovulation':
        return AppColors.ovulationPhase;
      case 'Luteal':
        return AppColors.luteal;
      default:
        return Colors.grey;
    }
  }

  /// Gets description for a phase
  static String getPhaseDescription(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return 'Rest and self-care. Energy may be lower.';
      case 'Follicular':
        return 'Rising energy and creativity. Great time for new projects.';
      case 'Ovulation':
        return 'Peak fertility and energy. You may feel more social.';
      case 'Luteal':
        return 'Slow down and focus inward. Premenstrual symptoms may appear.';
      default:
        return 'Track your cycle for personalized insights';
    }
  }

  /// Gets icon for a phase
  static IconData getPhaseIcon(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return Icons.water_drop;
      case 'Follicular':
        return Icons.spa;
      case 'Ovulation':
        return Icons.wb_sunny;
      case 'Luteal':
        return Icons.nights_stay;
      default:
        return Icons.calendar_today;
    }
  }

  /// Calculates phase details (start, end, duration) for the current cycle
  /// Based on medical facts:
  /// - Luteal phase is always ~14 days
  /// - Menstrual phase uses actual period length
  /// - Follicular phase is everything in between
  static List<PhaseDetail> calculatePhaseDetails(
      PredictedRange currentCycle, Map<String, dynamic> stats) {
    final periodLength = stats['currentPeriodLength'] as int? ?? 5;
    final averageCycle = stats['average'] as int? ?? 28;
    final ovulationDate = stats['ovulationDate'] as DateTime?;

    DateTime menstrualEnd;
    DateTime ovulationStart;
    DateTime ovulationEnd;
    DateTime lutealEnd;

    if (ovulationDate != null) {
      // Use calculated ovulation date
      menstrualEnd =
          currentCycle.startDate.add(Duration(days: periodLength - 1));
      ovulationStart = ovulationDate.subtract(const Duration(days: 1));
      ovulationEnd = ovulationDate.add(const Duration(days: 1));
      lutealEnd = ovulationDate.add(const Duration(days: 14));
    } else {
      // Fallback: use approximate calculations
      menstrualEnd =
          currentCycle.startDate.add(Duration(days: periodLength - 1));
      final ovulationDayOffset = averageCycle - 14;
      ovulationStart =
          currentCycle.startDate.add(Duration(days: ovulationDayOffset - 1));
      ovulationEnd =
          currentCycle.startDate.add(Duration(days: ovulationDayOffset + 1));
      lutealEnd = currentCycle.startDate.add(Duration(days: averageCycle - 1));
    }

    return [
      PhaseDetail(
        name: 'Menstrual',
        startDate: currentCycle.startDate,
        endDate: menstrualEnd,
      ),
      PhaseDetail(
        name: 'Follicular',
        startDate: menstrualEnd.add(const Duration(days: 1)),
        endDate: ovulationStart.subtract(const Duration(days: 1)),
      ),
      PhaseDetail(
        name: 'Ovulation',
        startDate: ovulationStart,
        endDate: ovulationEnd,
      ),
      PhaseDetail(
        name: 'Luteal',
        startDate: ovulationEnd.add(const Duration(days: 1)),
        endDate: lutealEnd,
      ),
    ];
  }

  /// Calculates progress within a phase (0.0 to 1.0)
  static double calculatePhaseProgress(PhaseDetail phase) {
    final now = DateTime.now();
    if (now.isBefore(phase.startDate)) return 0.0;
    if (now.isAfter(phase.endDate)) return 1.0;

    final totalDays = phase.endDate.difference(phase.startDate).inDays + 1;
    final daysPassed = now.difference(phase.startDate).inDays + 1;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  /// Checks if a date is within a specific phase
  static bool isDateInPhase(DateTime date, PhaseDetail phase) {
    return !date.isBefore(phase.startDate) && !date.isAfter(phase.endDate);
  }

  /// Gets the current active phase from the list
  static PhaseDetail? getCurrentPhase(List<PhaseDetail> phases) {
    final now = DateTime.now();
    for (final phase in phases) {
      if (isDateInPhase(now, phase)) {
        return phase;
      }
    }
    return null;
  }

  /// Calculates days remaining in current phase
  static int? daysRemainingInPhase(PhaseDetail phase) {
    final now = DateTime.now();
    if (now.isAfter(phase.endDate)) return 0;
    if (now.isBefore(phase.startDate))
      return phase.endDate.difference(phase.startDate).inDays + 1;
    return phase.endDate.difference(now).inDays + 1;
  }
}
