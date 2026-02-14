import '../../models/cycle_models.dart';

class CycleCalculationService {
  static Map<String, dynamic> calculateStats(
    List<DailyData> allData, {
    int defaultCycleLength = 28,
    int defaultPeriodLength = 5,
  }) {
    final periodDates = _extractPeriodDates(allData);
    final periods = _groupIntoPeriods(periodDates);

    if (periods.isEmpty) {
      return _emptyStats();
    }

    if (periods.length == 1) {
      return _singlePeriodStats(
          periods, defaultCycleLength, defaultPeriodLength);
    }

    return _multiPeriodStats(periods, defaultPeriodLength);
  }

  static List<DateTime> _extractPeriodDates(List<DailyData> data) {
    return data.where((d) => d.isPeriod).map((d) => d.date).toList()..sort();
  }

  static List<List<DateTime>> _groupIntoPeriods(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final periods = <List<DateTime>>[];
    List<DateTime> currentPeriod = [dates.first];

    for (int i = 1; i < dates.length; i++) {
      final currentDate = dates[i];
      final lastDate = currentPeriod.last;

      if (currentDate.difference(lastDate).inDays > 2) {
        periods.add(List.from(currentPeriod));
        currentPeriod = [currentDate];
      } else {
        currentPeriod.add(currentDate);
      }
    }

    periods.add(currentPeriod);
    return periods;
  }

  static Map<String, dynamic> _emptyStats() {
    return {
      'average': null,
      'prediction': null,
      'periods': <List<DateTime>>[],
      'cycleLengths': <int>[],
      'periodLengths': <int>[],
      'ovulationDate': null,
      'fertileWindowStart': null,
      'fertileWindowEnd': null,
    };
  }

  static Map<String, dynamic> _singlePeriodStats(
    List<List<DateTime>> periods,
    int defaultCycleLength,
    int defaultPeriodLength,
  ) {
    final lastPeriodStart = periods.last.first;
    final lastPeriodLength = periods.last.length;
    final periodLength =
        lastPeriodLength > 0 ? lastPeriodLength : defaultPeriodLength;

    final prediction = lastPeriodStart.add(Duration(days: defaultCycleLength));
    final ovulationDate = prediction.subtract(const Duration(days: 14));
    final fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = ovulationDate;

    return {
      'average': defaultCycleLength,
      'prediction': prediction,
      'periods': periods,
      'cycleLengths': <int>[],
      'periodLengths': [periodLength],
      'ovulationDate': ovulationDate,
      'fertileWindowStart': fertileWindowStart,
      'fertileWindowEnd': fertileWindowEnd,
      'currentPeriodLength': periodLength,
    };
  }

  static Map<String, dynamic> _multiPeriodStats(
    List<List<DateTime>> periods,
    int defaultPeriodLength,
  ) {
    final cycleLengths = <int>[];
    final periodLengths = <int>[];

    for (int i = 1; i < periods.length; i++) {
      final cycleLength =
          periods[i].first.difference(periods[i - 1].first).inDays;
      cycleLengths.add(cycleLength);
    }

    for (final period in periods) {
      periodLengths.add(period.length);
    }

    final averageCycle =
        cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;
    final averagePeriodLength =
        periodLengths.reduce((a, b) => a + b) ~/ periodLengths.length;

    final lastPeriodStart = periods.last.first;
    final prediction = lastPeriodStart.add(Duration(days: averageCycle));

    final ovulationDate = prediction.subtract(const Duration(days: 14));

    final fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = ovulationDate.add(const Duration(days: 1));

    return {
      'average': averageCycle,
      'prediction': prediction,
      'periods': periods,
      'cycleLengths': cycleLengths,
      'periodLengths': periodLengths,
      'averagePeriodLength': averagePeriodLength,
      'ovulationDate': ovulationDate,
      'fertileWindowStart': fertileWindowStart,
      'fertileWindowEnd': fertileWindowEnd,
      'currentPeriodLength': periods.last.length,
    };
  }

  static double calculateProgress(
    List<List<DateTime>> periods,
    int averageCycleLength,
  ) {
    if (periods.isEmpty) return 0.0;

    final lastPeriodStart = periods.last.first;
    final now = DateTime.now();
    final daysPassed = now.difference(lastPeriodStart).inDays;

    if (daysPassed > averageCycleLength) {
      final daysIntoPredictedCycle = daysPassed % averageCycleLength;
      return (daysIntoPredictedCycle / averageCycleLength).clamp(0.0, 1.0);
    }

    return (daysPassed / averageCycleLength).clamp(0.0, 1.0);
  }

  static PredictedRange? getCurrentCycle(List<List<DateTime>> periods) {
    if (periods.isEmpty) return null;

    final lastPeriod = periods.last;
    return PredictedRange(
      index: -1,
      startDate: lastPeriod.first,
      endDate: lastPeriod.last,
    );
  }

  static List<PeriodRange> groupPeriods(List<DailyData> periodDays) {
    if (periodDays.isEmpty) return [];

    final sorted = List<DailyData>.from(periodDays)
      ..sort((a, b) => a.date.compareTo(b.date));

    final ranges = <PeriodRange>[];
    DateTime? currentStart;
    DateTime? currentEnd;

    for (final data in sorted) {
      if (currentStart == null) {
        currentStart = data.date;
        currentEnd = data.date;
      } else if (data.date.difference(currentEnd!).inDays <= 2) {
        currentEnd = data.date;
      } else {
        ranges.add(PeriodRange(currentStart, currentEnd));
        currentStart = data.date;
        currentEnd = data.date;
      }
    }

    if (currentStart != null && currentEnd != null) {
      ranges.add(PeriodRange(currentStart, currentEnd));
    }

    return ranges;
  }

  static int calculateConsistency(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return 0;
    if (cycleLengths.length == 1) return 100;

    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final differences = cycleLengths.map((l) => (l - average).abs()).toList();
    final averageDifference =
        differences.reduce((a, b) => a + b) / differences.length;

    final consistency =
        (100 - (averageDifference / average * 100)).clamp(0, 100);
    return consistency.round();
  }

  static int? daysUntilNextPeriod(DateTime? prediction) {
    if (prediction == null) return null;
    return prediction.difference(DateTime.now()).inDays;
  }

  static int? getCurrentCycleDay(
    List<List<DateTime>> periods, {
    int averageCycleLength = 28,
  }) {
    if (periods.isEmpty) return null;

    final lastPeriodStart = periods.last.first;
    final now = DateTime.now();
    final daysPassed = now.difference(lastPeriodStart).inDays + 1;

    if (daysPassed > averageCycleLength) {
      return ((daysPassed - 1) % averageCycleLength) + 1;
    }

    return daysPassed;
  }
}
