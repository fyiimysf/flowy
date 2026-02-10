// lib/services/cycle/cycle_calculation_service.dart

import '../../models/cycle_models.dart';
import '../../utils/extensions/date_extensions.dart';

/// Medical facts about menstrual cycles:
/// - Ovulation occurs ~14 days BEFORE next period (luteal phase is consistently 14 days)
/// - Average cycle length: 28 days (range: 21-35 days)
/// - Menstrual phase: 3-7 days (actual bleeding)
/// - Fertile window: 5 days before ovulation + ovulation day
/// - Egg viable: 12-24 hours
/// - Sperm viable: 3-5 days
class CycleCalculationService {
  /// Calculates comprehensive cycle statistics
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
      return _singlePeriodStats(periods, defaultCycleLength, defaultPeriodLength);
    }
    
    return _multiPeriodStats(periods, defaultPeriodLength);
  }
  
  static List<DateTime> _extractPeriodDates(List<DailyData> data) {
    return data
        .where((d) => d.isPeriod)
        .map((d) => d.date)
        .toList()
      ..sort();
  }
  
  static List<List<DateTime>> _groupIntoPeriods(List<DateTime> dates) {
    if (dates.isEmpty) return [];
    
    final periods = <List<DateTime>>[];
    List<DateTime> currentPeriod = [dates.first];
    
    for (int i = 1; i < dates.length; i++) {
      final currentDate = dates[i];
      final lastDate = currentPeriod.last;
      
      // If gap is more than 2 days, it's a new period
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
    final periodLength = lastPeriodLength > 0 ? lastPeriodLength : defaultPeriodLength;
    
    // Calculate key dates
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
    // Calculate cycle lengths (days between period starts)
    final cycleLengths = <int>[];
    final periodLengths = <int>[];
    
    for (int i = 1; i < periods.length; i++) {
      final cycleLength = periods[i].first.difference(periods[i - 1].first).inDays;
      cycleLengths.add(cycleLength);
    }
    
    // Calculate period lengths
    for (final period in periods) {
      periodLengths.add(period.length);
    }
    
    final averageCycle = cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;
    final averagePeriodLength = periodLengths.reduce((a, b) => a + b) ~/ periodLengths.length;
    
    // Calculate predictions based on averages
    final lastPeriodStart = periods.last.first;
    final prediction = lastPeriodStart.add(Duration(days: averageCycle));
    
    // Ovulation is ALWAYS 14 days before next period (medical fact)
    final ovulationDate = prediction.subtract(const Duration(days: 14));
    
    // Fertile window: 5 days before ovulation + ovulation day
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
  
  /// Calculates cycle progress (0.0 to 1.0)
  static double calculateProgress(
    List<List<DateTime>> periods,
    int averageCycleLength,
  ) {
    if (periods.isEmpty) return 0.0;
    
    final lastPeriodStart = periods.last.first;
    final daysPassed = DateTime.now().difference(lastPeriodStart).inDays;
    return (daysPassed / averageCycleLength).clamp(0.0, 1.0);
  }
  
  /// Gets the current cycle if tracking
  static PredictedRange? getCurrentCycle(List<List<DateTime>> periods) {
    if (periods.isEmpty) return null;
    
    final lastPeriod = periods.last;
    return PredictedRange(
      index: -1,
      startDate: lastPeriod.first,
      endDate: lastPeriod.last,
    );
  }
  
  /// Groups period days into ranges
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
  
  /// Calculates consistency percentage (0-100)
  static int calculateConsistency(List<int> cycleLengths) {
    if (cycleLengths.isEmpty) return 0;
    if (cycleLengths.length == 1) return 100;
    
    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final differences = cycleLengths.map((l) => (l - average).abs()).toList();
    final averageDifference = differences.reduce((a, b) => a + b) / differences.length;
    
    // Consistency decreases as variation increases
    final consistency = (100 - (averageDifference / average * 100)).clamp(0, 100);
    return consistency.round();
  }
  
  /// Calculates days until next period
  static int? daysUntilNextPeriod(DateTime? prediction) {
    if (prediction == null) return null;
    return prediction.difference(DateTime.now()).inDays;
  }
  
  /// Calculates which day of cycle user is on
  static int? getCurrentCycleDay(List<List<DateTime>> periods) {
    if (periods.isEmpty) return null;
    
    final lastPeriodStart = periods.last.first;
    return DateTime.now().difference(lastPeriodStart).inDays + 1;
  }
}
