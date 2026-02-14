import 'package:floi/utils/extensions/date_extensions.dart';

import '../../models/cycle_models.dart';

class PredictionService {
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

  static List<DateTime> predictFertileWindow(DateTime nextPeriodStart) {
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

    return List.generate(
      6,
      (i) => ovulationDate.subtract(Duration(days: 5 - i)),
    );
  }

  static DateTime predictOvulation(DateTime nextPeriodStart) {
    return nextPeriodStart.subtract(const Duration(days: 14));
  }

  static DateTime? getOvulationDate(Map<String, dynamic> stats) {
    return stats['ovulationDate'] as DateTime?;
  }

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

  static bool isInFertileWindow(DateTime date, Map<String, dynamic> stats) {
    final start = stats['fertileWindowStart'] as DateTime?;
    final end = stats['fertileWindowEnd'] as DateTime?;

    if (start == null || end == null) return false;

    return !date.isBefore(start) && !date.isAfter(end);
  }

  static bool isOvulationDay(DateTime date, Map<String, dynamic> stats) {
    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) return false;
    return date.isSameDate(ovulationDate);
  }

  static bool isPredictedDate(DateTime date, List<DateTime> predictedDates) {
    return predictedDates.any((d) => d.isSameDate(date));
  }

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

  static int? daysUntilOvulation(Map<String, dynamic> stats) {
    final ovulationDate = stats['ovulationDate'] as DateTime?;
    if (ovulationDate == null) return null;

    return ovulationDate.difference(DateTime.now()).inDays;
  }

  static int? daysUntilNextPeriod(Map<String, dynamic> stats) {
    final prediction = stats['prediction'] as DateTime?;
    if (prediction == null) return null;

    return prediction.difference(DateTime.now()).inDays;
  }
}
