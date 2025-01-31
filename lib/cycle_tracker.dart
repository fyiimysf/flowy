import 'dart:math';

import 'package:floi/main.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'settings_page.dart';

class CycleTracker extends StatefulWidget {
  const CycleTracker({super.key});

  @override
  State<CycleTracker> createState() => _CycleTrackerState();
}

class _CycleTrackerState extends State<CycleTracker> {
  late Box<DailyData> dailyDataBox;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final List<DateTime> _periodDates = [];
  DateTime _currentSheetDate = DateTime.now();
  int get _menstrualDays =>
      Hive.box<int>('settings').get('menstrualDays', defaultValue: 7)!;

  void _saveMenstrualDays(int days) {
    Hive.box<int>('settings').put('menstrualDays', days);
  }

  final List<String> moods = ['😊', '😐', '😢', '😡', '😴', '💪'];
  List<DateTime> _predictedPeriods = [];

  List<DateTime> _getFertileDates(DateTime periodStart) {
    final ovulationDate = periodStart.subtract(Duration(days: 14));
    return List.generate(
        6, (i) => ovulationDate.subtract(Duration(days: 3 - i)));
  }

  List<DateTime> _getOvulationDates(DateTime periodStart) {
    return [periodStart.subtract(Duration(days: 14))];
  }

  @override
  void initState() {
    super.initState();
    dailyDataBox = Hive.box<DailyData>('dailyData');
    _calculatePredictions();
  }

  void _calculatePredictions() {
    final stats = _calculateCycleStats();
    final periods = stats['periods'] as List<List<DateTime>>;
    if (periods.isEmpty) return;

    final average = stats['average'] ?? 28;
    _predictedPeriods = [];

    DateTime lastPeriod = periods.last.first;
    for (int i = 0; i < 3; i++) {
      lastPeriod = lastPeriod.add(Duration(days: average));
      _predictedPeriods.addAll(List.generate(
          _menstrualDays, (index) => lastPeriod.add(Duration(days: index))));
    }
  }

  bool _isPredictedDate(DateTime date) {
    return _predictedPeriods.any((d) => _isSameDate(d, date));
  }

// Update the cycle stats calculation
  Map<String, dynamic> _calculateCycleStats() {
    final periodDates = dailyDataBox.values
        .where((data) => data.isPeriod)
        .map((data) => data.date)
        .toList()
      ..sort();

    final periods = <List<DateTime>>[];
    List<DateTime> currentPeriod = [];

    for (final date in periodDates) {
      if (currentPeriod.isEmpty) {
        currentPeriod.add(date);
      } else {
        final difference = date.difference(currentPeriod.last).inDays;
        if (difference == 1) {
          currentPeriod.add(date);
        } else {
          periods.add(currentPeriod);
          currentPeriod = [date];
        }
      }
    }
    if (currentPeriod.isNotEmpty) periods.add(currentPeriod);

    if (periods.isEmpty) {
      return {'average': null, 'prediction': null, 'periods': periods};
    }

    if (periods.length == 1) {
      final lastPeriod = periods.last.first;
      return {
        'average': 28, // Default to 28-day cycle
        'prediction': lastPeriod.add(const Duration(days: 28)),
        'periods': periods
      };
    }

    final cycleLengths = <int>[];
    for (int i = 1; i < periods.length; i++) {
      final length = periods[i].first.difference(periods[i - 1].first).inDays;
      cycleLengths.add(length);
    }

    final average = cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length;
    final prediction = periods.last.first.add(Duration(days: average));

    return {'average': average, 'prediction': prediction, 'periods': periods};
  }

  DailyData _getDailyData(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return dailyDataBox.get(key, defaultValue: DailyData(date: date))!;
  }

  void _updateData(DateTime date, DailyData newData) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    dailyDataBox.put(key, newData);
    setState(() {});
  }

  void _showDailyLog(DateTime initialDate) {
    setState(() => _currentSheetDate = initialDate);
    _getDailyData(initialDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final data = _getDailyData(_currentSheetDate);
          final canNavigateLeft = dailyDataBox.values
              .any((d) => d.date.isBefore(_currentSheetDate));
          final canNavigateRight =
              dailyDataBox.values.any((d) => d.date.isAfter(_currentSheetDate));

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                // Swipe left - next day
                if (canNavigateRight) {
                  setSheetState(() => _currentSheetDate =
                      _currentSheetDate.add(const Duration(days: 1)));
                }
              } else if (details.primaryVelocity! > 0) {
                // Swipe right - previous day
                if (canNavigateLeft) {
                  setSheetState(() => _currentSheetDate =
                      _currentSheetDate.subtract(const Duration(days: 1)));
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add period toggle
                  SwitchListTile(
                    title: Text('Period Day'),
                    value: data.isPeriod,
                    onChanged: (value) => _toggleSingleDay(initialDate, data),
                  ),
                  // Date Navigation Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left,
                            color: canNavigateLeft ? Colors.pink : Colors.grey),
                        onPressed: canNavigateLeft
                            ? () {
                                setSheetState(() => _currentSheetDate =
                                    _currentSheetDate
                                        .subtract(const Duration(days: 1)));
                              }
                            : null,
                      ),
                      Text(
                        DateFormat('MMMM dd').format(_currentSheetDate),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right,
                            color:
                                canNavigateRight ? Colors.pink : Colors.grey),
                        onPressed: canNavigateRight
                            ? () {
                                setSheetState(() => _currentSheetDate =
                                    _currentSheetDate
                                        .add(const Duration(days: 1)));
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      children: moods
                          .map((mood) => _buildMoodButton(mood, data))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildMoodInsights(initialDate),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodButton(String emoji, DailyData data) {
    final isSelected = data.mood == emoji;
    return GestureDetector(
      onTap: () {
        _updateData(data.date, data..mood = isSelected ? null : emoji);
        Navigator.pop(context);
        _showDailyLog(data.date); // Reopen to show updated insights
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.pink : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            Text(
              _moodLabel(emoji),
              style: TextStyle(
                color: isSelected ? Colors.pink : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodAndPhase() {
    final selectedData = _getDailyData(_selectedDate);
    final cycleData = _calculateCycleStats();
    final currentPhase = _getCyclePhase(_selectedDate, cycleData);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Insights',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Current Mood',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          selectedData.mood != null
                              ? '${selectedData.mood} ${_moodLabel(selectedData.mood!)}'
                              : 'Tap to add mood',
                          style: TextStyle(
                            fontSize: 18,
                            color: selectedData.mood != null
                                ? Colors.pink
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Cycle Phase',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(
                          currentPhase,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mood pattern prediction based on cycle phase
  Widget _buildMoodInsights(DateTime date) {
    final cycleData = _calculateCycleStats();
    final currentPhase = _getCyclePhase(date, cycleData);
    final moodPatterns = _analyzeMoodPatterns(currentPhase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        const Text('Mood Patterns in this Phase:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: moodPatterns.entries
              .map((entry) => Column(
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 24)),
                      Text('${(entry.value * 100).toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.pink)),
                    ],
                  ))
              .toList(),
        ),
        if (moodPatterns.isEmpty)
          const Text('Log more moods to see patterns',
              style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Map<String, double> _analyzeMoodPatterns(String phase) {
    final phaseData = dailyDataBox.values
        .where((data) =>
            _getCyclePhase(data.date, _calculateCycleStats()) == phase &&
            data.mood != null)
        .toList();

    final moodCounts = <String, int>{};
    for (final data in phaseData) {
      moodCounts[data.mood!] = (moodCounts[data.mood] ?? 0) + 1;
    }

    final total = phaseData.length;
    return phaseData.isEmpty
        ? {' Neutral': 1.0} // Default to happy emoji
        : Map.fromEntries(moodCounts.entries
            .map((e) => MapEntry(_moodLabel(e.key), e.value / total)));
  }

  String _getCyclePhase(DateTime date, Map<String, dynamic> cycleData) {
    final periods = (cycleData['periods'] as List<List<DateTime>>?) ?? [];
    if (periods.isEmpty) return 'Not Tracking';

    final lastPeriod = periods.last.first;
    final daysSince = date.difference(lastPeriod).inDays;

    if (daysSince < 5) return '🌑 Menstrual';
    if (daysSince < 11) return '🌱 Follicular';
    if (daysSince < 18) return '🌕 Ovulation';
    return '🍂 Luteal';
  }

  String _getCyclePhaseNoIcon(DateTime date, Map<String, dynamic> cycleData) {
    final periods = (cycleData['periods'] as List<List<DateTime>>?) ?? [];
    if (periods.isEmpty) return 'Not Tracking';

    final lastPeriod = periods.last.first;
    final daysSince = date.difference(lastPeriod).inDays;

    if (daysSince < 5) return 'Menstrual';
    if (daysSince < 11) return 'Follicular';
    if (daysSince < 18) return 'Ovulation';
    return 'Luteal';
  }

  String _moodLabel(String emoji) {
    switch (emoji) {
      case '😊':
        return 'Happy';
      case '😐':
        return 'Neutral';
      case '😢':
        return 'Sad';
      case '😡':
        return 'Angry';
      case '😴':
        return 'Tired';
      case '💪':
        return 'Energetic';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _calculateCycleStats();

    return Scaffold(
      drawer: _buildPredictionsDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.pink,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text('🌸 Flowy'),
        centerTitle: true,
        actions: [
          
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.pink,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            ),
            tooltip: 'Delete All Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCycleCardMain(),

            _buildMonthHeader(),
            _buildCalendar(),
            SizedBox(height: 24,),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_getCurrentCycle() != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.1),
                            blurRadius: 60,
                            spreadRadius: 7,
                            blurStyle: BlurStyle.normal,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPhaseDetailsList(
                              _getPhaseDetails(_getCurrentCycle()!)),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(50),
                      child: Column(
                        children: [
                          const Text(
                            textAlign: TextAlign.center,
                            'No cycle data available',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                                letterSpacing: 0.5,
                                fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 17),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 30),
                              ),
                              onPressed: () =>
                                  _showMenstrualDaysDialog(DateTime.now()),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.add,
                                        size: 44, color: Colors.white),
                                    const Text('Track Today',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            )
            // _buildHistory()
          ],
        ),
      ),
    );
  }

  void _showCycleInsightsModal() {
    final stats = _calculateCycleStats();
    final prediction = stats['prediction'] as DateTime?;
    final currentPhase = _getCyclePhase(DateTime.now(), stats);
    final phaseDetails =
        _getCurrentCycle() != null ? _getPhaseDetails(_getCurrentCycle()!) : [];
    final cycleProgress = _calculateCycleProgressMain();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Card(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cycle Insights',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Overview
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: cycleProgress,
                                    strokeWidth: 6,
                                    color: Colors.pink,
                                    backgroundColor:
                                        const Color.fromARGB(37, 238, 238, 238),
                                  ),
                                ),
                                Text(
                                  '${(cycleProgress * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPhase,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Day ${(cycleProgress * (stats['average'] ?? 28)).round()} of cycle',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Key Metrics Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.6,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildMetricCard('Average Cycle',
                              '${stats['average'] ?? '--'} days'),
                          _buildMetricCard(
                              'Cycle Consistency',
                              stats['periods'].length > 1
                                  ? '${_calculateConsistency(_getCycleLengths(stats['periods']))}%'
                                  : '--'),
                          _buildMetricCard(
                              'Next Period',
                              prediction != null
                                  ? DateFormat('MMM dd').format(prediction)
                                  : '--'),
                          _buildMetricCard(
                              'Current Phase',
                              phaseDetails.isNotEmpty
                                  ? '${_getCurrentPhaseDuration(phaseDetails.cast<PhaseDetail>())} days'
                                  : '--'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Phase Timeline
                      Text(
                        'Phase Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: phaseDetails.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) =>
                              _buildPhaseCard(phaseDetails[index]),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Fertility Forecast
                      if (prediction != null) _buildFertilityCard(prediction),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFertilityCard(DateTime prediction) {
    final fertileDates = _getFertileDates(prediction);
    final ovulationDates = _getOvulationDates(prediction);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fertility Forecast',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            children: [
              _buildFertilityIndicator('Fertile', _kFertileColor),
              const SizedBox(width: 16),
              _buildFertilityIndicator('Ovulation', _kOvulationColor),
            ],
          ),
          const SizedBox(height: 16),

          // Date Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
              mainAxisSpacing: 4,
              crossAxisSpacing: 6,
            ),
            itemCount: fertileDates.length,
            itemBuilder: (context, index) {
              final date = fertileDates[index];
              final isOvulation =
                  ovulationDates.any((d) => _isSameDate(d, date));

              return Container(
                decoration: BoxDecoration(
                  color: isOvulation
                      ? _kOvulationColor.withOpacity(0.1)
                      : _kFertileColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isOvulation ? _kOvulationColor : _kFertileColor,
                      width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isOvulation ? _kOvulationColor : _kFertileColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOvulation)
                      const Icon(Icons.circle,
                          size: 8, color: _kOvulationColor),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFertilityIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getCurrentPhaseDuration(List<PhaseDetail> phases) {
    final current = phases.firstWhere(
      (phase) =>
          DateTime.now().isAfter(phase.startDate) &&
          DateTime.now().isBefore(phase.endDate),
      orElse: () => phases.first,
    );
    return current.duration.toString();
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w600, color: Colors.pink),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(PhaseDetail phase) {
    final isCurrent = DateTime.now().isAfter(phase.startDate) &&
        DateTime.now().isBefore(phase.endDate);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isCurrent
            ? _getPhaseColor(phase.name).withOpacity(0.1)
            : const Color.fromARGB(0, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? _getPhaseColor(phase.name) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            phase.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _getPhaseColor(phase.name),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${phase.duration} days',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(String phaseName) {
    switch (phaseName) {
      case 'Menstrual':
        return Icons.water_drop;
      case 'Follicular':
        return Icons.spa;
      case 'Ovulation':
        return Icons.wb_sunny;
      case 'Luteal':
        return Icons.eco;
      default:
        return Icons.calendar_today;
    }
  }

  String _getCurrentPhaseDetails(List<PhaseDetail> phases) {
    final currentPhase = phases.firstWhere(
      (phase) =>
          DateTime.now().isAfter(phase.startDate) &&
          DateTime.now().isBefore(phase.endDate),
      orElse: () => phases.last,
    );
    return currentPhase.duration.toString();
  }

  Widget _buildCycleProgressHeader(double progress, String currentPhase) {
    return Row(
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 8,
          backgroundColor: Colors.grey[200],
          color: Colors.pink,
          semanticsLabel: 'Cycle progress',
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentPhase,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              Text(
                'Day ${(progress * (_calculateCycleStats()['average'] ?? 28)).round()} of cycle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseTimeline(List<PhaseDetail> phases) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: phases.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final phase = phases[index];
          final isCurrent = DateTime.now().isAfter(phase.startDate) &&
              DateTime.now().isBefore(phase.endDate);

          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _getPhaseColor(phase.name).withOpacity(isCurrent ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPhaseColor(phase.name).withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phase.name,
                  style: TextStyle(
                    color: _getPhaseColor(phase.name),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${phase.duration}d',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseDetailsList(List<PhaseDetail> phases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Cycle Phases',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 5),
        ...phases.map((phase) => _buildPhaseExpansionTile(phase)),
      ],
    );
  }

  Widget _buildPhaseExpansionTile(PhaseDetail phase) {
    final isCurrent = DateTime.now().isAfter(phase.startDate) &&
        DateTime.now().isBefore(phase.endDate);
    final daysRemaining = phase.endDate.difference(DateTime.now()).inDays;

    return ExpansionTile(
      initiallyExpanded: isCurrent,
      leading: CircleAvatar(
        backgroundColor: _getPhaseColor(phase.name),
        child: Icon(
          _getPhaseIcon(phase.name),
          color: Colors.white,
        ),
      ),
      title: Text(phase.name),
      subtitle: Text(
        '${DateFormat('MMM dd').format(phase.startDate)} - '
        '${DateFormat('MMM dd').format(phase.endDate)}',
      ),
      trailing: Chip(
        label: Text('${phase.duration} days'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _getPhaseColor(phase.name).withOpacity(0.5),
        side: daysRemaining > 0
            ? BorderSide(
                color: const Color.fromARGB(255, 255, 255, 255), width: 1.5)
            : BorderSide.none,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _calculatePhaseProgress(phase),
                      backgroundColor: const Color.fromARGB(19, 0, 0, 0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPhaseColor(phase.name),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isCurrent ? '$daysRemaining days left' : '--',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _getPhaseDescription(phase.name),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  double _calculatePhaseProgress(PhaseDetail phase) {
    final now = DateTime.now();
    if (now.isBefore(phase.startDate)) return 0;
    if (now.isAfter(phase.endDate)) return 1;

    final totalDays = phase.endDate.difference(phase.startDate).inDays;
    final daysPassed = now.difference(phase.startDate).inDays;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  Widget _buildCycleStatistics(Map<String, dynamic> stats) {
    final periods = stats['periods'] as List<List<DateTime>>;
    final cycleLengths = _getCycleLengths(periods);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          children: [
            _buildStatCard('Average Cycle', '${stats['average'] ?? '--'} days'),
            _buildStatCard(
                'Longest Cycle',
                cycleLengths.isNotEmpty
                    ? '${cycleLengths.reduce(max)} days'
                    : '--'),
            _buildStatCard(
                'Shortest Cycle',
                cycleLengths.isNotEmpty
                    ? '${cycleLengths.reduce(min)} days'
                    : '--'),
            _buildStatCard(
                'Consistency',
                cycleLengths.length > 1
                    ? '${_calculateConsistency(cycleLengths)}%'
                    : '--'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  List<int> _getCycleLengths(List<List<DateTime>> periods) {
    final lengths = <int>[];
    for (int i = 1; i < periods.length; i++) {
      final length = periods[i].first.difference(periods[i - 1].first).inDays;
      lengths.add(length);
    }
    return lengths;
  }

  int _calculateConsistency(List<int> cycleLengths) {
    final average = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final differences = cycleLengths.map((l) => (l - average).abs()).toList();
    final averageDifference =
        differences.reduce((a, b) => a + b) / differences.length;
    return (100 - (averageDifference / average * 100)).clamp(0, 100).round();
  }

  Widget _buildFertilitySection(DateTime nextPeriod) {
    final fertileDates = _getFertileDates(nextPeriod);
    final ovulationDate = _getOvulationDates(nextPeriod).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fertility Forecast',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 16),
        _buildFertilityCalendar(fertileDates, ovulationDate),
      ],
    );
  }

  Widget _buildFertilityCalendar(
      List<DateTime> fertileDates, DateTime ovulationDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFertilityIndicator('Fertile Window', _kFertileColor),
              _buildFertilityIndicator('Ovulation Day', _kOvulationColor),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: fertileDates.length,
            itemBuilder: (context, index) {
              final date = fertileDates[index];
              final isOvulation = _isSameDate(date, ovulationDate);

              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isOvulation
                      ? _kOvulationColor.withOpacity(0.2)
                      : _kFertileColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color:
                              isOvulation ? _kOvulationColor : _kFertileColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isOvulation)
                        const Icon(Icons.circle,
                            size: 8, color: _kOvulationColor),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Food cravings and fatigue possible';
      case 'Follicular':
        return 'Prodcutivity and creativity possible';
      case 'Ovulation':
        return 'Peak fertility and energy possible';
      case 'Luteal':
        return 'Mood swings & Sensitivity possible';
      default:
        return 'Track your cycle for insights ';
    }
  }

  List<PredictedRange> _generatePredictedRanges() {
    final stats = _calculateCycleStats();
    final periods = stats['periods'] as List<List<DateTime>>;
    if (periods.isEmpty) return [];

    final averageCycle = stats['average'] ?? 28;
    final List<PredictedRange> predictions = [];

    DateTime lastPeriod = periods.last.first;
    for (int i = 0; i < 3; i++) {
      final startDate = lastPeriod.add(Duration(days: averageCycle));
      final endDate = startDate.add(Duration(days: _menstrualDays - 1));
      predictions.add(PredictedRange(
        index: i,
        startDate: startDate,
        endDate: endDate,
      ));
      lastPeriod = startDate;
    }

    return predictions;
  }

  Widget _buildPredictionsDrawer() {
    final currentCycle = _getCurrentCycle();
    final predictedCycles = _generatePredictedRanges();

    return Drawer(
      child: Card(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    if (currentCycle != null)
                      _buildCycleCardDrawer(currentCycle, isCurrent: true),
                    const SizedBox(height: 10),
                    if (predictedCycles.isNotEmpty)
                      Text('UPCOMING CYCLES',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                          )),
                    SizedBox(
                      height: 10,
                    ),
                    ...predictedCycles
                        .map((cycle) => _buildCycleCardDrawer(cycle)),

                    const SizedBox(height: 20),
                    Expanded(child: _buildHistory()),
                    // History
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          topRight: Radius.circular(15),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Icon(Icons.auto_awesome,
                size: 150, color: Colors.white.withOpacity(0.1)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  'Cycle Insights',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCardDrawer(PredictedRange cycle, {bool isCurrent = false}) {
    final phaseDetails = _getPhaseDetails(cycle);
    final progress = _calculateCycleProgressMain();

    return Card(
      // margin: const EdgeInsets.only(bottom: 20),
      // decoration: BoxDecoration(
      //   color: const Color.fromARGB(255, 50, 16, 59),
      //   borderRadius: BorderRadius.circular(16),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.pink.withOpacity(0.05),
      //       blurRadius: 12,
      //       spreadRadius: 4,
      //     )
      //   ],
      // ),
      elevation: 8,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isCurrent ? Colors.pink : Colors.purple,
          child: Icon(
            isCurrent ? Icons.timeline : Icons.auto_awesome,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          isCurrent ? 'Current Cycle' : 'Predicted Cycle ${cycle.index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[00],
          ),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd').format(cycle.startDate)} - '
          '${DateFormat('MMM dd').format(cycle.endDate)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: isCurrent
            ? SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                  borderRadius: BorderRadius.circular(10),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: Column(
              children: [
                ...phaseDetails.map((phase) => _buildPhaseRow(phase)),
                if (isCurrent) ...[
                  const SizedBox(height: 12),
                  _buildCycleStats(cycle),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseRow(PhaseDetail phase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getPhaseColor(phase.name).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getPhaseColor(phase.name),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _getPhaseColor(phase.name),
                  ),
                ),
                Text(
                  '${DateFormat('MMM dd').format(phase.startDate)} - '
                  '${DateFormat('MMM dd').format(phase.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${phase.duration}d',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _getPhaseColor(phase.name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleStats(PredictedRange cycle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Total Days',
            '${cycle.endDate.difference(cycle.startDate).inDays + 1}'),
        _buildStatItem('Phase', _getCurrentPhase(cycle)),
        _buildStatItem('Progress',
            '${(_calculateCycleProgressMain() * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _phaseTile(String title, DateTime start, DateTime end) {
    return ListTile(
      dense: true,
      leading: const SizedBox(width: 40),
      title: Text(
        '$title: ${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd').format(end)}',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _confirmDataDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
            'This will permanently remove all period tracking and mood data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteAllData();
              Navigator.pop(context);
            },
            child: const Text(
              'Delete Everything',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAllData() {
    // Clear Hive data
    dailyDataBox.clear();

    // Reset local state
    _predictedPeriods = [];

    // Force UI refresh
    setState(() {});

    // Optional: Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(40),
        content: Text('All data has been deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tracking History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder(
          valueListenable: dailyDataBox.listenable(),
          builder: (context, Box<DailyData> box, _) {
            final periods = _groupPeriods(
                box.values.where((data) => data.isPeriod).toList());
            final moodEntries =
                box.values.where((data) => data.mood != null).toList();

            final combined = [...periods, ...moodEntries]..sort((a, b) {
                final dateA =
                    a is PeriodRange ? a.startDate : (a as DailyData).date;
                final dateB =
                    b is PeriodRange ? b.startDate : (b as DailyData).date;
                return dateB.compareTo(dateA);
              });

            return Card(
              elevation: 10,
              surfaceTintColor: Colors.white,
              child: SizedBox(
                height: 300, // Fixed height for scrollable content
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final item = combined[index];
                    if (item is PeriodRange) {
                      return ListTile(
                        leading: const Icon(Icons.water_drop_rounded,
                            color: Colors.pink),
                        title: Text(
                            '${DateFormat('MMM dd').format(item.startDate)} '
                            '- ${DateFormat('MMM dd').format(item.endDate)}'),
                        subtitle: Text('${item.duration} days'),
                      );
                    } else if (item is DailyData) {
                      return ListTile(
                        leading: Text(item.mood!),
                        title: Text(DateFormat.yMMMd().format(item.date)),
                        subtitle: const Text('Mood Entry'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<PeriodRange> _groupPeriods(List<DailyData> periodDays) {
    final sorted = periodDays..sort((a, b) => a.date.compareTo(b.date));
    final ranges = <PeriodRange>[];
    DateTime? currentStart;
    DateTime? currentEnd;

    for (final data in sorted) {
      if (currentStart == null) {
        currentStart = data.date;
        currentEnd = data.date;
      } else if (data.date.difference(currentEnd!).inDays == 1) {
        currentEnd = data.date;
      } else {
        ranges.add(PeriodRange(currentStart, currentEnd));
        currentStart = data.date;
        currentEnd = data.date;
      }
    }
    if (currentStart != null) {
      ranges.add(PeriodRange(currentStart, currentEnd!));
    }
    return ranges;
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstrual':
        return Colors.pink.withOpacity(0.8);
      case 'Follicular':
        return Colors.green.withOpacity(0.8);
      case 'Ovulation':
        return Colors.orange.withOpacity(0.8);
      case 'Luteal':
        return const Color.fromARGB(255, 160, 114, 97).withOpacity(0.8);
      default:
        return const Color.fromARGB(255, 132, 132, 132).withOpacity(0.8);
    }
  }

  List<PhaseDetail> _getPhaseDetails(PredictedRange cycle) {
    final totalDays = _calculateCycleStats()['average'] ?? 28;

    // Calculate phase durations based on typical percentages of cycle
    final menstrualDays = (totalDays * 0.25).round(); // ~15% of cycle
    final follicularDays = (totalDays * 0.30).round(); // ~30% of cycle
    final ovulationDays = (totalDays * 0.10).round(); // ~15% of cycle
    final lutealDays =
        totalDays - (menstrualDays + follicularDays + ovulationDays);

    return [
      PhaseDetail(
        name: 'Menstrual',
        startDate: cycle.startDate,
        endDate:
            cycle.endDate.difference(cycle.startDate).inDays > menstrualDays
                ? cycle.startDate.add(Duration(days: menstrualDays - 1))
                : cycle.endDate,
      ),
      PhaseDetail(
        name: 'Follicular',
        startDate: cycle.startDate.add(Duration(days: menstrualDays)),
        endDate: cycle.startDate
            .add(Duration(days: menstrualDays + follicularDays - 1)),
      ),
      PhaseDetail(
        name: 'Ovulation',
        startDate:
            cycle.startDate.add(Duration(days: menstrualDays + follicularDays)),
        endDate: cycle.startDate.add(
            Duration(days: menstrualDays + follicularDays + ovulationDays - 1)),
      ),
      PhaseDetail(
        name: 'Luteal',
        startDate: cycle.startDate.add(
            Duration(days: menstrualDays + follicularDays + ovulationDays)),
        endDate: cycle.startDate.add(Duration(
            days: menstrualDays +
                follicularDays +
                ovulationDays +
                lutealDays -
                1)),
      ),
    ];
  }

// Helper Methods
  PredictedRange? _getCurrentCycle() {
    final periods = (_calculateCycleStats()['periods'] as List<List<DateTime>>);
    if (periods.isEmpty) return null;

    final lastPeriod = periods.last;
    return PredictedRange(
      index: -1,
      startDate: lastPeriod.first,
      endDate: lastPeriod.last,
    );
  }

  String _getCurrentPhase(PredictedRange cycle) {
    final now = DateTime.now();
    if (now.isBefore(cycle.startDate)) return 'Pre-cycle';
    if (now.isAfter(cycle.endDate)) return 'Post-cycle';

    for (final phase in _getPhaseDetails(cycle)) {
      if (!now.isBefore(phase.startDate) && !now.isAfter(phase.endDate)) {
        return phase.name;
      }
    }
    return 'Transition';
  }

  Widget _buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM y').format(_currentMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
            ),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final weekdayOffset = firstDay.weekday - 1;
    final totalWeeks = ((daysInMonth + weekdayOffset) / 7).ceil();
    final totalCells = totalWeeks * 7;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.pink.withOpacity(0.4)),
      ),
      elevation: 8,
      shadowColor: Colors.pink.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(20),
      //   boxShadow: [/*...*/],
      // ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final date = _calculateDateForIndex(
                index, firstDay, daysInMonth, weekdayOffset);
            return _buildDayCell(date, date.day);
          },
        ),
      ),
    );
  }

  DateTime _calculateDateForIndex(
      int index, DateTime firstDay, int daysInMonth, int weekdayOffset) {
    if (index < weekdayOffset) {
      return firstDay.subtract(Duration(days: weekdayOffset - index));
    }

    final day = index - weekdayOffset + 1;
    if (day > daysInMonth) {
      return DateTime(firstDay.year, firstDay.month + 1, day - daysInMonth);
    }

    return DateTime(firstDay.year, firstDay.month, day);
  }

  Widget _buildDayCell(DateTime date, int day) {
    final data = _getDailyData(date);
    final isToday = _isSameDate(date, DateTime.now());
    final isPredicted = _isPredictedDate(date) && !data.isPeriod;
    final isCurrentMonth = date.month == _currentMonth.month;

    // New fertility calculations
    final stats = _calculateCycleStats();
    final nextPeriod = stats['prediction'] as DateTime?;
    final fertileDates = nextPeriod != null ? _getFertileDates(nextPeriod) : [];
    final ovulationDates =
        nextPeriod != null ? _getOvulationDates(nextPeriod) : [];

    final isFertile = fertileDates.any((d) => _isSameDate(d, date));
    final isOvulation = ovulationDates.any((d) => _isSameDate(d, date));

    return GestureDetector(
      onTap: () => _handleDateTap(date, isPredicted),
      onLongPress: () => _showRangeEditor(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getDayBackgroundColor(
              data, isPredicted, isFertile, isOvulation, isToday),
          borderRadius: BorderRadius.circular(8),
          border:
              _getDayBorder(data, isPredicted, isFertile, isOvulation, isToday),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: _getDayTextColor(
                      data, isCurrentMonth, isFertile, isOvulation, isToday),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
            if (isOvulation)
              Positioned(
                right: 2,
                top: 2,
                child:
                    Icon(Icons.bubble_chart, size: 14, color: _kOvulationColor),
              ),
            if (isToday)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (isPredicted)
              Positioned(
                right: 2,
                bottom: 2,
                child: Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDayBackgroundColor(DailyData data, bool isPredicted, bool isFertile,
      bool isOvulation, bool isToday) {
    if (data.isPeriod) return Colors.pink.withOpacity(0.2);
    if (isOvulation) return _kOvulationColor.withOpacity(0.15);
    if (isFertile) return _kFertileColor.withOpacity(0.1);
    if (isPredicted) return Colors.purple.withOpacity(0.1);
    if (isToday) return Colors.blue.withOpacity(0.1);
    return Colors.transparent;
  }

  Border _getDayBorder(DailyData data, bool isPredicted, bool isFertile,
      bool isOvulation, bool isToday) {
    if (isOvulation) {
      return Border.all(
          color: _kOvulationColor.withValues(alpha: 0.5), width: 1.5);
    }
    if (isFertile) {
      return Border.all(color: _kFertileColor.withValues(alpha: 0), width: 1);
    }
    if (data.isPeriod) return Border.all(color: Colors.pink, width: 1.5);
    if (isPredicted) return Border.all(color: Colors.purple, width: 1);
    if (isToday) return Border.all(color: Colors.blue, width: 2);
    return Border.all(color: Colors.transparent, width: 0);
  }

  Color _getDayTextColor(DailyData data, bool isCurrentMonth, bool isFertile,
      bool isOvulation, bool isToday) {
    if (!isCurrentMonth) return Colors.grey[400]!;
    if (isOvulation) return _kOvulationColor;
    if (isFertile) return _kFertileColor;
    if (isToday) return Colors.blue;
    if (data.isPeriod) return Colors.pink;
    return const Color.fromARGB(255, 116, 116, 116)!;
  }

  void _handleDateTap(DateTime date, bool isPredicted) {
    if (isPredicted) {
      _confirmPrediction(date);
    } else if (_getDailyData(date).isPeriod) {
      _showRangeEditor(date);
    } else {
      _askToStartPeriod(date);
    }
  }

  void _askToStartPeriod(DateTime date) {
    final isFirstPeriod = dailyDataBox.values.where((d) => d.isPeriod).isEmpty;

    if (isFirstPeriod) {
      _showMenstrualDaysDialog(date);
    } else {
      _confirmPeriodStart(date);
    }
  }

  void _confirmPeriodStart(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Period?'),
        content: Text(
            'Did your period start on ${DateFormat('MMM dd').format(date)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _markPeriodRange(date, _menstrualDays);
              _calculatePredictions();
              setState(() {});
            },
            child: const Text('Yes, Start Here'),
          ),
        ],
      ),
    );
  }

  void _showMenstrualDaysDialog(DateTime startDate) {
    final controller = TextEditingController(text: _menstrualDays.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Period Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many days does your typical period last?'),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Menstrual Days',
                suffixText: 'days',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final days = int.tryParse(controller.text) ?? 7;
              _saveMenstrualDays(days.clamp(3, 14)); // Keep between 3-14 days
              _markPeriodRange(startDate, _menstrualDays);
              _calculatePredictions();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmPrediction(DateTime date) {
    final predictionStart = _predictedPeriods.firstWhere(
      (d) => _isSameDate(d, date),
      orElse: () => DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Prediction'),
        content: Text(
            'Accept predicted period starting from ${DateFormat('MMM dd').format(predictionStart)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _markPeriodRange(predictionStart, 7);
              _calculatePredictions();
              Navigator.pop(context);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRangeEditor(DateTime initialDate) {
    DateTime startDate = _findPeriodStart(initialDate) ?? initialDate;
    int menstrualDays = _menstrualDays;
    List<DateTime> periodDates =
        List.generate(menstrualDays, (i) => startDate.add(Duration(days: i)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  spreadRadius: 4,
                )
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left,
                          color: Colors.pink.withOpacity(0.8)),
                      onPressed: () {
                        setSheetState(() {
                          startDate =
                              startDate.subtract(const Duration(days: 1));
                          periodDates = List.generate(menstrualDays,
                              (i) => startDate.add(Duration(days: i)));
                        });
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          'Edit Period',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${DateFormat('MMM dd').format(startDate)} - '
                          '${DateFormat('MMM dd').format(startDate.add(Duration(days: menstrualDays - 1)))}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right,
                          color: Colors.pink.withOpacity(0.8)),
                      onPressed: () {
                        setSheetState(() {
                          startDate = startDate.add(const Duration(days: 1));
                          periodDates = List.generate(menstrualDays,
                              (i) => startDate.add(Duration(days: i)));
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Dynamic Days Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / 7;
                    return Container(
                      height: cellSize * 2,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                        itemCount: menstrualDays,
                        itemBuilder: (context, index) {
                          final date = startDate.add(Duration(days: index));
                          final isPeriod = _getDailyData(date).isPeriod;
                          final isToday = _isSameDate(date, DateTime.now());

                          return GestureDetector(
                            onTap: () =>
                                _toggleSingleDay(date, _getDailyData(date)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isPeriod
                                    ? Colors.pink.withOpacity(0.2)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPeriod
                                      ? Colors.pink.withOpacity(0.8)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (isToday)
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    )
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isPeriod
                                            ? Colors.pink
                                            : Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isToday)
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.pink,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                // Duration Control
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Duration:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ToggleButtons(
                        isSelected: List.generate(
                            3, (index) => menstrualDays == (5 + index)),
                        onPressed: (index) {
                          setSheetState(() {
                            menstrualDays = 5 + index;
                            _saveMenstrualDays(menstrualDays);
                            periodDates = List.generate(menstrualDays,
                                (i) => startDate.add(Duration(days: i)));
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        selectedColor: Colors.white,
                        fillColor: Colors.pink,
                        color: Colors.pink,
                        constraints: const BoxConstraints(
                          minHeight: 36,
                          minWidth: 48,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('5'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('6'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('7'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.pink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _markPeriodRange(startDate, menstrualDays);
                          _calculatePredictions();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        _removePeriod(startDate);
                        _calculatePredictions();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _markPeriodRange(DateTime startDate, [int? duration]) {
    final days = duration ?? _menstrualDays;
    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final data = _getDailyData(date);
      _updateData(date, data..isPeriod = true);
    }
    _calculatePredictions();
  }

  void _removePeriod(DateTime startDate) {
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final data = _getDailyData(date);
      _updateData(date, data..isPeriod = false);
    }
  }

  DateTime? _findPeriodStart(DateTime date) {
    final periodDates = dailyDataBox.values
        .where((data) => data.isPeriod)
        .map((data) => data.date)
        .toList()
      ..sort();

    for (final d in periodDates) {
      if (date.difference(d).inDays >= 0 && date.difference(d).inDays < 7) {
        return d;
      }
    }
    return null;
  }

  // void _askToStartPeriod(DateTime date) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Start Period?'),
  //       content: Text(
  //           'Did your period start on ${DateFormat('MMM dd').format(date)}?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _markPeriodRange(date, 7);
  //             _showCombinedModal(date,_isPredictedDate(date));
  //           },
  //           child: const Text('Yes, Start Here'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _confirmPredictedPeriod(DateTime date) {
  //   final range = _predictedRanges.firstWhere((r) =>
  //       date.isAfter(r.first.subtract(Duration(days: 1))) &&
  //       date.isBefore(r.last.add(Duration(days: 1))));

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Adjust Prediction'),
  //       content: Text('This predicted period is from\n'
  //           '${DateFormat('MMM dd').format(range.first)} '
  //           'to ${DateFormat('MMM dd').format(range.last)}\n'
  //           'Would you like to keep or adjust these dates?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _showRangeEditSheet(range.first);
  //           },
  //           child: const Text('Adjust Dates'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             _markPeriodRange(range.first, 7);
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Keep Prediction'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showCombinedModal(DateTime date, bool isPredicted) {
    final data = _getDailyData(date);
    bool isPeriod = data.isPeriod;
    String? currentMood = data.mood;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM dd, y').format(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                // Period Toggle
                SwitchListTile(
                  title: Text(
                      isPredicted ? 'Confirm Prediction' : 'Mark as Period'),
                  value: isPeriod,
                  onChanged: (value) => setState(() => isPeriod = value),
                ),

                // Mood Selection
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  children: moods
                      .map((mood) => GestureDetector(
                            onTap: () => setState(() => currentMood = mood),
                            child: Container(
                              decoration: BoxDecoration(
                                color: currentMood == mood
                                    ? Colors.pink.withOpacity(0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(mood,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ))
                      .toList(),
                ),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    _updateData(
                        date,
                        data
                          ..isPeriod = isPeriod
                          ..mood = currentMood);
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRangeEditSheet(DateTime initialDate) {
    DateTime startDate = _findExistingRangeStart(initialDate) ?? initialDate;
    List<DateTime> rangeDates =
        List.generate(7, (i) => startDate.add(Duration(days: i)));
    List<bool> selectedDays =
        rangeDates.map((d) => _getDailyData(d).isPeriod).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setSheetState(() {
                          startDate =
                              startDate.subtract(const Duration(days: 1));
                          rangeDates = List.generate(
                              7, (i) => startDate.add(Duration(days: i)));
                          selectedDays = rangeDates
                              .map((d) => _getDailyData(d).isPeriod)
                              .toList();
                        });
                      },
                    ),
                    Text(DateFormat('MMM dd').format(startDate)),
                    const Text('to'),
                    Text(DateFormat('MMM dd')
                        .format(startDate.add(const Duration(days: 6)))),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setSheetState(() {
                          startDate = startDate.add(const Duration(days: 1));
                          rangeDates = List.generate(
                              7, (i) => startDate.add(Duration(days: i)));
                          selectedDays = rangeDates
                              .map((d) => _getDailyData(d).isPeriod)
                              .toList();
                        });
                      },
                    ),
                  ],
                ),

                // Day Toggles
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 7,
                  children: List.generate(7, (index) {
                    final date = startDate.add(Duration(days: index));
                    return GestureDetector(
                      onTap: () => _showCombinedEditor(date),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: selectedDays[index]
                              ? Colors.pink.withOpacity(0.2)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: selectedDays[index]
                                  ? Colors.pink
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < 7; i++) {
                      final date = startDate.add(Duration(days: i));
                      _updateData(date,
                          _getDailyData(date)..isPeriod = selectedDays[i]);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save Period'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCombinedEditor(DateTime date) {
    final data = _getDailyData(date);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('MMMM dd').format(date)),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: moods
                  .map((mood) => GestureDetector(
                        onTap: () {
                          _updateData(date, data..mood = mood);
                          Navigator.pop(context);
                        },
                        child: Text(mood, style: const TextStyle(fontSize: 24)),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // List<DateTime> get _predictedPeriods {
  //   final stats = _calculateCycleStats();
  //   final periods = stats['periods'] as List<List<DateTime>>;
  //   if (periods.isEmpty) return [];

  //   final average = stats['average'] ?? 28;
  //   final lastPeriod = periods.last.first;
  //   final predictions = <DateTime>[];

  //   DateTime currentPrediction = lastPeriod;
  //   for (int i = 0; i < 6; i++) {
  //     // Predict 6 months ahead
  //     currentPrediction = currentPrediction.add(Duration(days: average));
  //     predictions.add(currentPrediction);
  //   }

  //   return predictions;
  // }

  // bool _isPredictedDate(DateTime date) {
  //   return _predictedPeriods.any((d) => _isSameDate(d, date));
  // }

  DateTime? _findExistingRangeStart(DateTime date) {
    final periodDates = dailyDataBox.values
        .where((data) => data.isPeriod)
        .map((data) => data.date)
        .toList()
      ..sort();

    for (final d in periodDates) {
      if (date.isAfter(d.subtract(const Duration(days: 1))) &&
          date.isBefore(d.add(const Duration(days: 7)))) {
        return d;
      }
    }
    return null;
  }

  // void _markPeriodRange(DateTime startDate, int duration) {
  //   for (int i = 0; i < duration; i++) {
  //     final currentDate = startDate.add(Duration(days: i));
  //     final data = _getDailyData(currentDate);
  //     _updateData(currentDate, data..isPeriod = true);
  //   }
  // }

  void _toggleSingleDay(DateTime date, DailyData data) {
    final isFutureDate = date.isAfter(DateTime.now());

    if (isFutureDate) {
      // Direct toggle for future dates
      _updateData(date, data..isPeriod = !data.isPeriod);
    } else {
      // Show confirmation for past/present dates
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Past Date'),
          content: Text(
              'Are you sure you want to ${data.isPeriod ? 'remove' : 'add'} '
              'period for ${DateFormat('MMM dd').format(date)}?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateData(date, data..isPeriod = !data.isPeriod);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSymptoms() {
    const symptoms = ['😣 Cramps', '😔 Mood', '💤 Fatigue', '🤢 Nausea'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Symptoms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: symptoms
                .map((s) => Chip(
                      avatar: Text(s.substring(0, 2)),
                      label: Text(s.substring(2)),
                      backgroundColor: Colors.pink.withOpacity(0.1),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCardMain() {
    final stats = _calculateCycleStats();
    final periods = (stats['periods'] as List<List<DateTime>>?) ?? [];
    final prediction = stats['prediction'] as DateTime?;
    final currentPhase = _getCyclePhase(DateTime.now(), stats);

    return GestureDetector(
      onTap: _showCycleInsightsModal,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        margin: const EdgeInsets.all(16),
        // padding: const EdgeInsets.all(16),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(20),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.pink.withOpacity(0.05),
        //       blurRadius: 10,
        //       spreadRadius: 2,
        //     )
        //   ],
        // ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Current Phase & Prediction
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CURRENT PHASE',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(currentPhase,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('NEXT PERIOD',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(
                          prediction != null
                              ? DateFormat('MMM dd yyyy').format(prediction)
                              : '--/--',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                prediction != null ? Colors.pink : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getPhaseDescription(
                    _getCyclePhaseNoIcon(DateTime.now(), stats)),
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.pink,
                ),
              ),
              // Cycle Progress
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _calculateCycleProgressMain(),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 8),

              // Status Message
              Text(
                periods.isEmpty
                    ? 'Track your period by tapping a date on the calendar'
                    : prediction != null
                        ? '${stats['average']} day cycle predicted'
                        : 'Track more cycles for predictions',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightChip({required String emoji, required String label}) {
    return Chip(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.pink.withOpacity(0.1)),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Map<String, dynamic> _getCycleInsights(DateTime start, DateTime end) {
  //   final entries = dailyDataBox.values
  //       .where((data) => !data.date.isBefore(start) && !data.date.isAfter(end))
  //       .toList();

  //   // Calculate most common mood
  //   final moodCounts = <String, int>{};
  //   for (final entry in entries) {
  //     if (entry.mood != null) {
  //       moodCounts[entry.mood!] = (moodCounts[entry.mood] ?? 0) + 1;
  //     }
  //   }
  //   final commonMood = moodCounts.isNotEmpty
  //       ? moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
  //       : null;

  //   // Count diet entries
  //   final dietEntries =
  //       entries.where((e) => e.dietNotes?.isNotEmpty ?? false).length;

  //   return {
  //     'commonMood': commonMood,
  //     'dietEntries': dietEntries,
  //   };
  // }

  double _calculateCycleProgressMain() {
    final stats = _calculateCycleStats();
    final periods = stats['periods'] as List<List<DateTime>>;
    if (periods.isEmpty) return 0;

    final lastPeriodStart = periods.last.first;
    final cycleLength = stats['average'] ?? 28;
    final daysPassed = DateTime.now().difference(lastPeriodStart).inDays;
    return (daysPassed / cycleLength).clamp(0.0, 1.0);
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _addPeriodDay(DateTime date) {
    setState(() {
      if (_periodDates.contains(date)) {
        _periodDates.remove(date);
      } else {
        _periodDates.add(date);
      }
    });
  }

  void _togglePeriodDay(DateTime date, DailyData data) {
    _updateData(date, data..isPeriod = !data.isPeriod);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

const _kOvulationColor = Color(0xFFFFA726); // Orange
const _kFertileColor = Color(0xFF66BB6A); // Green
const _kPrimaryGradient = LinearGradient(
  colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const _kSoftPink = Color(0xFFF8D7E8);
const _kModernPurple = Color(0xFFB39DDB);
const _kGlassEffect = BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0x29FFFFFF), Color(0x0DFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  borderRadius: BorderRadius.all(Radius.circular(20)),
  border: Border.fromBorderSide(
    BorderSide(color: Colors.white24, width: 1.0),
  ),
);

ThemeData _girlifyTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9A9E),
      secondary: _kModernPurple,
      background: _kSoftPink,
    ),
    fontFamily: 'Poppins',
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.pressed)
              ? const Color(0xFFFF9A9E)
              : const Color(0xFFF48FB1),
        ),
      ),
    ),
  );
}
