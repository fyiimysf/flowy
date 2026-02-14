import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/cycle_models.dart';
import '../../services/cycle/cycle_calculation_service.dart';
import '../../services/cycle/prediction_service.dart';
import '../../services/cycle/phase_service.dart';
import '../../services/storage/storage_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/drawers/predictions_drawer.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/cycle_status_card.dart';
import 'widgets/phase_timeline.dart';
import 'dialogs/period_editor_dialog.dart';
import 'dialogs/menstrual_settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  DateTime _currentMonth = DateTime.now();
  List<DateTime> _predictedPeriods = [];

  int get _menstrualDays => _storage.getMenstrualDays();

  @override
  void initState() {
    super.initState();
    _calculatePredictions();
  }

  void _calculatePredictions() {
    final stats = _getCycleStats();
    final periods = stats['periods'] as List<List<DateTime>>;

    if (periods.isEmpty) {
      _predictedPeriods = [];
      setState(() {});
      return;
    }

    final average = stats['average'] ?? 28;
    _predictedPeriods = [];

    DateTime lastPeriod = periods.last.first;
    for (int i = 0; i < 3; i++) {
      lastPeriod = lastPeriod.add(Duration(days: average));
      _predictedPeriods.addAll(List.generate(
        _menstrualDays,
        (index) => lastPeriod.add(Duration(days: index)),
      ));
    }

    setState(() {});
  }

  Map<String, dynamic> _getCycleStats() {
    return CycleCalculationService.calculateStats(
      _storage.getAllDailyData(),
      defaultCycleLength: 28,
      defaultPeriodLength: _menstrualDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getCycleStats();
    final periods = stats['periods'] as List<List<DateTime>>;
    final theme = Theme.of(context);

    if (periods.isEmpty && _predictedPeriods.isNotEmpty) {
      _predictedPeriods = [];
    } else if (periods.isNotEmpty && _predictedPeriods.isEmpty) {
      _calculatePredictions();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: PredictionsDrawer(
        stats: stats,
        menstrualDays: _menstrualDays,
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 0, 6),
            child: ClayButton(
              color: Colors.transparent,
              onTap: () => Scaffold.of(context).openDrawer(),
              padding: const EdgeInsets.all(10),
              radius: AppDimensions.radiusMedium,
              child: const Icon(
                Icons.menu,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ),
        leadingWidth: 70,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('appName'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ClayButton(
              color: Colors.transparent,
              onTap: () => Navigator.pushNamed(context, '/settings'),
              radius: AppDimensions.radiusMedium,
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: kToolbarHeight),
              CycleStatusCard(
                stats: stats,
                onTap: () => _showInsights(context, stats),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              CalendarHeader(
                currentMonth: _currentMonth,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              CalendarWidget(
                currentMonth: _currentMonth,
                predictedPeriods: _predictedPeriods,
                stats: stats,
                onDateTap: _handleDateTap,
                onDateLongPress: _showPeriodEditor,
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              Divider(
                height: 1,
                indent: AppDimensions.buttonHeightSmall,
                endIndent: AppDimensions.buttonHeightSmall,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              if (stats['periods'] != null &&
                  (stats['periods'] as List).isNotEmpty)
                Builder(builder: (context) {
                  final cycle = _getCurrentOrPredictedCycle(stats);
                  if (cycle == null) return _buildEmptyState();
                  return PhaseTimeline(
                    stats: stats,
                    currentCycle: cycle,
                  );
                })
              else
                _buildEmptyState(),
              const SizedBox(height: AppDimensions.sectionSpacing * 2),
            ],
          ),
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  void _handleDateTap(DateTime date, bool isPredicted) {
    if (isPredicted) {
      _confirmPrediction(date);
    } else {
      final data = _storage.getDailyData(date);
      if (data?.isPeriod ?? false) {
        _showPeriodEditor(date);
      } else {
        _askToStartPeriod(date);
      }
    }
  }

  void _askToStartPeriod(DateTime date) {
    final isFirstPeriod = _storage.getPeriodDays().isEmpty;

    if (isFirstPeriod) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (context) => MenstrualSettingsDialog(
          initialDays: _menstrualDays,
          onSave: (days) {
            _storage.setMenstrualDays(days);
            _markPeriodRange(date, days);
          },
        ),
      );
    } else {
      _showClayDialog(
        title: context.tr('startPeriod'),
        content: context
            .trArgs('startPeriodMessage', {'date': date.format('MMM dd')}),
        icon: Icons.water_drop,
        iconColor: AppColors.period,
        confirmText: context.tr('confirm'),
        onConfirm: () {
          _markPeriodRange(date, _menstrualDays);
        },
      );
    }
  }

  void _confirmPrediction(DateTime date) {
    final predictionStart = _predictedPeriods.firstWhere(
      (d) => d.isSameDate(date),
      orElse: () => DateTime.now(),
    );

    _showClayDialog(
      title: context.tr('confirmPrediction'),
      content: context.trArgs(
          'acceptPredictedPeriod', {'date': predictionStart.format('MMM dd')}),
      icon: Icons.auto_awesome,
      iconColor: AppColors.predicted,
      confirmText: context.tr('accept'),
      onConfirm: () {
        _markPeriodRange(predictionStart, 7);
      },
    );
  }

  void _showClayDialog({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required String confirmText,
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              Container(
                padding: const EdgeInsets.all(AppDimensions.elementSpacing),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: AppDimensions.iconXL,
                ),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimensions.smallSpacing),
              Text(
                content,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              Row(
                children: [
                  Expanded(
                    child: ClayButton(
                      onTap: () => Navigator.pop(context),
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        context.tr('cancel'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.elementSpacing),
                  Expanded(
                    child: ClayButton(
                      onTap: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      color: iconColor.withOpacity(0.1),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          color: iconColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
            ],
          ),
        ),
      ),
    );
  }

  void _showPeriodEditor(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PeriodEditorDialog(
        initialDate: date,
        defaultMenstrualDays: _menstrualDays,
        onSave: (startDate, duration) {
          _markPeriodRange(startDate, duration);
        },
        onClear: (startDate) {
          _removePeriod(startDate);
        },
      ),
    );
  }

  void _markPeriodRange(DateTime startDate, int duration) {
    for (int i = 0; i < duration; i++) {
      final date = startDate.addDays(i);
      final data = _storage.getDailyData(date) ?? DailyData(date: date);
      data.isPeriod = true;
      _storage.saveDailyData(date, data);
    }
    _calculatePredictions();
  }

  void _removePeriod(DateTime startDate) {
    for (int i = 0; i < 7; i++) {
      final date = startDate.addDays(i);
      final data = _storage.getDailyData(date);
      if (data != null) {
        data.isPeriod = false;
        _storage.saveDailyData(date, data);
      }
    }
    _calculatePredictions();
  }

  void _showInsights(BuildContext context, Map<String, dynamic> stats) {
    Navigator.pushNamed(context, '/insights', arguments: stats);
  }

  PredictedRange? _getCurrentOrPredictedCycle(Map<String, dynamic> stats) {
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    if (periods.isEmpty) return null;

    final lastPeriod = periods.last;
    final averageCycle = stats['average'] as int? ?? 28;
    final periodLength = stats['currentPeriodLength'] as int? ?? 5;
    final lastPeriodStart = lastPeriod.first;
    final lastPeriodEnd = lastPeriod.last;
    final now = DateTime.now();

    final daysSinceLastPeriod = now.difference(lastPeriodStart).inDays;

    if (daysSinceLastPeriod <= averageCycle) {
      return PredictedRange(
        index: -1,
        startDate: lastPeriodStart,
        endDate: lastPeriodEnd,
      );
    }

    final cyclesPassed = daysSinceLastPeriod ~/ averageCycle;
    final predictedCycleStart = lastPeriodStart.add(
      Duration(days: cyclesPassed * averageCycle),
    );
    final predictedCycleEnd = predictedCycleStart.add(
      Duration(days: periodLength - 1),
    );

    return PredictedRange(
      index: cyclesPassed - 1,
      startDate: predictedCycleStart,
      endDate: predictedCycleEnd,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.screenPadding * 2),
      child: ClayCard(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : theme.colorScheme.surfaceContainerHighest,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.elementSpacing),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: AppDimensions.iconXL,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
            Text(
              context.tr('welcomeTitle'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
            Text(
              context.tr('welcomeSubtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _askToStartPeriod(DateTime.now()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.elementSpacing),
                ),
                child: Text(
                  context.tr('trackMyPeriod'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.fontLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
