import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../../models/cycle_models.dart';
import '../../models/enums.dart';
import '../../utils/constants/colors.dart';

class PhaseService {
  static CyclePhase getPhase(DateTime date, Map<String, dynamic> stats) {
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    if (periods.isEmpty) return CyclePhase.menstrual;

    final lastPeriod = periods.last;
    final lastPeriodStart = lastPeriod.first;
    final lastPeriodEnd = lastPeriod.last;

    if (!date.isBefore(lastPeriodStart) && !date.isAfter(lastPeriodEnd)) {
      return CyclePhase.menstrual;
    }

    final prediction = stats['prediction'] as DateTime?;
    final averageCycle = stats['average'] as int? ?? 28;

    if (prediction != null && date.isAfter(lastPeriodEnd)) {
      final daysSinceLastPeriod = date.difference(lastPeriodStart).inDays;

      if (daysSinceLastPeriod >= averageCycle) {
        final daysIntoPredictedCycle = daysSinceLastPeriod % averageCycle;
        final ovulationDay = averageCycle - 14;

        if (daysIntoPredictedCycle < 5) return CyclePhase.menstrual;
        if (daysIntoPredictedCycle < ovulationDay - 1)
          return CyclePhase.follicular;
        if (daysIntoPredictedCycle <= ovulationDay + 1)
          return CyclePhase.ovulation;
        return CyclePhase.luteal;
      }
    }

    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) {
      return _getApproximatePhase(date, lastPeriodStart, stats);
    }

    final ovulationStart = ovulationDate.subtract(const Duration(days: 1));
    final ovulationEnd = ovulationDate.add(const Duration(days: 1));
    if (!date.isBefore(ovulationStart) && !date.isAfter(ovulationEnd)) {
      return CyclePhase.ovulation;
    }

    if (date.isAfter(ovulationEnd)) {
      return CyclePhase.luteal;
    }

    return CyclePhase.follicular;
  }

  static CyclePhase _getApproximatePhase(
    DateTime date,
    DateTime periodStart,
    Map<String, dynamic> stats,
  ) {
    final daysSincePeriod = date.difference(periodStart).inDays;
    final averageCycle = stats['average'] as int? ?? 28;
    final ovulationDay = averageCycle - 14;

    if (daysSincePeriod < 5) return CyclePhase.menstrual;
    if (daysSincePeriod < ovulationDay - 1) return CyclePhase.follicular;
    if (daysSincePeriod <= ovulationDay + 1) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  static String getPhaseName(DateTime date, Map<String, dynamic> stats) {
    return getPhase(date, stats).name;
  }

  static String getPhaseDisplay(
      DateTime date, Map<String, dynamic> stats, BuildContext context) {
    return getPhase(date, stats).displayName;
  }

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

  static String getPhaseDescription(String phaseName, BuildContext context) {
    switch (phaseName) {
      case 'Menstrual':
        return context.tr('menstrualDescription');
      case 'Follicular':
        return context.tr('follicularDescription');
      case 'Ovulation':
        return context.tr('ovulationDescription');
      case 'Luteal':
        return context.tr('lutealDescription');
      default:
        return context.tr('nullDescription');
    }
  }

  static IconData getPhaseIcon(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return Icons.water_drop;
      case 'Follicular':
        return Icons.local_florist;
      case 'Ovulation':
        return Icons.wb_sunny;
      case 'Luteal':
        return Icons.energy_savings_leaf;
      default:
        return Icons.calendar_today;
    }
  }

  static List<PhaseDetail> calculatePhaseDetails(
      PredictedRange currentCycle, Map<String, dynamic> stats) {
    final periodLength = stats['currentPeriodLength'] as int? ?? 5;
    final averageCycle = stats['average'] as int? ?? 28;
    final ovulationDate = stats['ovulationDate'] as DateTime?;

    DateTime menstrualEnd;
    DateTime ovulationStart;
    DateTime ovulationEnd;
    DateTime lutealEnd;

    final now = DateTime.now();
    final isPredictedCycle = currentCycle.startDate.isAfter(now) ||
        currentCycle.startDate.difference(now).inDays < -averageCycle;

    if (ovulationDate != null && !isPredictedCycle) {
      menstrualEnd =
          currentCycle.startDate.add(Duration(days: periodLength - 1));
      ovulationStart = ovulationDate.subtract(const Duration(days: 1));
      ovulationEnd = ovulationDate.add(const Duration(days: 1));
      lutealEnd = ovulationDate.add(const Duration(days: 14));
    } else {
      menstrualEnd =
          currentCycle.startDate.add(Duration(days: periodLength - 1));
      final ovulationDayOffset = averageCycle - 14;
      ovulationStart =
          currentCycle.startDate.add(Duration(days: ovulationDayOffset - 1));
      ovulationEnd =
          currentCycle.startDate.add(Duration(days: ovulationDayOffset + 1));
      lutealEnd = currentCycle.startDate.add(Duration(days: averageCycle - 1));
    }

    final follicularStart = currentCycle.startDate;
    final follicularEnd = ovulationStart.subtract(const Duration(days: 1));

    final postMenstrualFollicularStart =
        menstrualEnd.add(const Duration(days: 1));
    final postMenstrualFollicularDays =
        follicularEnd.difference(postMenstrualFollicularStart).inDays + 1;

    return [
      PhaseDetail(
        name: 'Menstrual',
        startDate: currentCycle.startDate,
        endDate: menstrualEnd,
      ),
      PhaseDetail(
        name: 'Follicular',
        startDate: follicularStart,
        endDate: follicularEnd,
        duration:
            postMenstrualFollicularDays > 0 ? postMenstrualFollicularDays : 0,
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

  static double calculatePhaseProgress(PhaseDetail phase) {
    final now = DateTime.now();
    if (now.isBefore(phase.startDate)) return 0.0;
    if (now.isAfter(phase.endDate)) return 1.0;

    final totalDays = phase.endDate.difference(phase.startDate).inDays + 1;
    final daysPassed = now.difference(phase.startDate).inDays + 1;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  static bool isDateInPhase(DateTime date, PhaseDetail phase) {
    return !date.isBefore(phase.startDate) && !date.isAfter(phase.endDate);
  }

  static PhaseDetail? getCurrentPhase(List<PhaseDetail> phases) {
    final now = DateTime.now();
    for (final phase in phases) {
      if (isDateInPhase(now, phase)) {
        return phase;
      }
    }
    return null;
  }

  static int? daysRemainingInPhase(PhaseDetail phase) {
    final now = DateTime.now();
    if (now.isAfter(phase.endDate)) return 0;
    if (now.isBefore(phase.startDate))
      return phase.endDate.difference(phase.startDate).inDays + 1;
    return phase.endDate.difference(now).inDays + 1;
  }
}
