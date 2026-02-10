// lib/services/cycle/prediction_service.dart

import 'package:floi/utils/extensions/date_extensions.dart';

import '../../models/cycle_models.dart';

/// Medical facts:
/// - Ovulation occurs ~14 days BEFORE next period (luteal phase is always ~14 days)
/// - Fertile window: 5 days before ovulation + ovulation day (6 days total)
/// - Sperm can survive 3-5 days in female reproductive system
/// - Egg viable for 12-24 hours after ovulation
class PredictionService {
  /// Generates predicted period ranges for future cycles
  static List<PredictedRange> generatePredictions(
    Map<String, dynamic> stats,
    int menstrualDays, {
    int monthsAhead = 3,
  }) {
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    if (periods.isEmpty) return [];

    final averageCycle = stats['average'] as int? ?? 28;
    final List<PredictedRange> predictions = [];

    DateTime lastPeriodStart = periods.last.first;

    for (int i = 0; i < monthsAhead; i++) {
      final startDate = lastPeriodStart.add(Duration(days: averageCycle));
      final endDate = startDate.add(Duration(days: menstrualDays - 1));

      predictions.add(PredictedRange(
        index: i,
        startDate: startDate,
        endDate: endDate,
      ));

      lastPeriodStart = startDate;
    }

    return predictions;
  }

  /// Predicts fertile window dates
  /// Returns 6 days: 5 days before ovulation + ovulation day
  static List<DateTime> predictFertileWindow(DateTime nextPeriodStart) {
    // Ovulation occurs 14 days BEFORE next period
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

    // Fertile window: 5 days before ovulation through ovulation day
    return List.generate(
      6,
      (i) => ovulationDate.subtract(Duration(days: 5 - i)),
    );
  }

  /// Predicts ovulation date
  /// Medical fact: Ovulation is 14 days before next period
  static DateTime predictOvulation(DateTime nextPeriodStart) {
    return nextPeriodStart.subtract(const Duration(days: 14));
  }

  /// Gets ovulation date from stats
  static DateTime? getOvulationDate(Map<String, dynamic> stats) {
    return stats['ovulationDate'] as DateTime?;
  }

  /// Gets fertile window dates from stats
  static List<DateTime>? getFertileWindowDates(Map<String, dynamic> stats) {
    final start = stats['fertileWindowStart'] as DateTime?;
    final end = stats['fertileWindowEnd'] as DateTime?;

    if (start == null || end == null) return null;

    final dates = <DateTime>[];
    var current = start;
    while (!current.isAfter(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Checks if a date is within the fertile window
  static bool isInFertileWindow(DateTime date, Map<String, dynamic> stats) {
    final start = stats['fertileWindowStart'] as DateTime?;
    final end = stats['fertileWindowEnd'] as DateTime?;

    if (start == null || end == null) return false;

    return !date.isBefore(start) && !date.isAfter(end);
  }

  /// Checks if a date is the ovulation day
  static bool isOvulationDay(DateTime date, Map<String, dynamic> stats) {
    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) return false;
    return date.isSameDate(ovulationDate);
  }

  /// Checks if a date falls within predicted periods
  static bool isPredictedDate(DateTime date, List<DateTime> predictedDates) {
    return predictedDates.any((d) => d.isSameDate(date));
  }

  /// Generates all predicted dates (expanded from ranges)
  static List<DateTime> generatePredictedDates(
    List<PredictedRange> ranges,
    int menstrualDays,
  ) {
    final dates = <DateTime>[];

    for (final range in ranges) {
      for (int i = 0; i < menstrualDays; i++) {
        dates.add(range.startDate.add(Duration(days: i)));
      }
    }

    return dates;
  }

  /// Calculates days until ovulation
  static int? daysUntilOvulation(Map<String, dynamic> stats) {
    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) return null;

    return ovulationDate.difference(DateTime.now()).inDays;
  }

  /// Calculates days until next period
  static int? daysUntilNextPeriod(Map<String, dynamic> stats) {
    final prediction = stats['prediction'] as DateTime?;
    if (prediction == null) return null;

    return prediction.difference(DateTime.now()).inDays;
  }
}
