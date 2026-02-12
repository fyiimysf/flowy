// lib/screens/home/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/cycle_models.dart';
import '../../../services/cycle/prediction_service.dart';
import '../../../services/cycle/phase_service.dart';
import '../../../services/storage/storage_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../utils/extensions/date_extensions.dart';
import '../../../widgets/common/cards.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentMonth;
  final List<DateTime> predictedPeriods;
  final Function(DateTime date, bool isPredicted) onDateTap;
  final Function(DateTime date) onDateLongPress;
  final Map<String, dynamic> stats;

  const CalendarWidget({
    super.key,
    required this.currentMonth,
    required this.predictedPeriods,
    required this.onDateTap,
    required this.onDateLongPress,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    // Sunday-based offset: 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    final sundayBasedOffset = firstDay.weekday % 7;
    final totalWeeks = ((daysInMonth + sundayBasedOffset) / 7).ceil();
    final totalCells = totalWeeks * 7;
    final isDark = theme.brightness == Brightness.dark;
    return ClayCard(
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      // No custom shadows - ClayCard handles light/dark mode automatically
      child: Column(
        children: [
          // Weekday headers - aligned with calendar grid starting from Sunday
          Container(
            padding: const EdgeInsets.all(AppDimensions.elementSpacing),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              // Generate weekday abbreviations starting from Sunday (index 0 in grid)
              final now = DateTime.now();
              // Find the most recent Sunday
              final sunday = now.subtract(Duration(days: now.weekday % 7));
              final weekdays = List.generate(7, (index) {
                final day = sunday.add(Duration(days: index));
                return DateFormat.E()
                    .format(day)[0]; // First letter of weekday name
              });
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekdays.map((day) {
                  return SizedBox(
                    width: cellWidth - 8, // Account for margins
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final date = _calculateDateForIndex(
                index,
                firstDay,
                daysInMonth,
                sundayBasedOffset,
              );
              return _CalendarDayCell(
                date: date,
                currentMonth: currentMonth,
                predictedPeriods: predictedPeriods,
                stats: stats,
                onTap: () => onDateTap(date, _isPredictedDate(date)),
                onLongPress: () => onDateLongPress(date),
              );
            },
          ),
          const SizedBox(height: AppDimensions.elementSpacing),
          _buildLegend(context),

          // Legend
        ],
      ),
    );
  }

  DateTime _calculateDateForIndex(
    int index,
    DateTime firstDay,
    int daysInMonth,
    int weekdayOffset,
  ) {
    // weekdayOffset is 0-6 where 0 = Sunday, 6 = Saturday
    // DateTime.weekday is 1-7 where 1 = Monday, 7 = Sunday
    // Convert to Sunday-based: Sunday should be 0, Monday 1, etc.
    final sundayBasedOffset = (firstDay.weekday % 7);

    if (index < sundayBasedOffset) {
      return firstDay.subtract(Duration(days: sundayBasedOffset - index));
    }
    final day = index - sundayBasedOffset + 1;
    if (day > daysInMonth) {
      return DateTime(firstDay.year, firstDay.month + 1, day - daysInMonth);
    }
    return DateTime(firstDay.year, firstDay.month, day);
  }

  bool _isPredictedDate(DateTime date) {
    return predictedPeriods.any((d) => d.isSameDate(date));
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: AppColors.period, label: 'Period'),
          _LegendItem(color: AppColors.fertile, label: 'Fertile'),
          _LegendItem(color: AppColors.ovulation, label: 'Ovulation'),
          _LegendItem(color: AppColors.predicted, label: 'Predicted'),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatefulWidget {
  final DateTime date;
  final DateTime currentMonth;
  final List<DateTime> predictedPeriods;
  final Map<String, dynamic> stats;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CalendarDayCell({
    required this.date,
    required this.currentMonth,
    required this.predictedPeriods,
    required this.stats,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_CalendarDayCell> createState() => _CalendarDayCellState();
}

class _CalendarDayCellState extends State<_CalendarDayCell> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final storage = StorageService();
    final dailyData = storage.getDailyData(widget.date);
    final isToday = widget.date.isToday();
    final isCurrentMonth = widget.date.month == widget.currentMonth.month;
    final isPredicted =
        widget.predictedPeriods.any((d) => d.isSameDate(widget.date));

    final prediction = widget.stats['prediction'] as DateTime?;
    final fertileDates = prediction != null
        ? PredictionService.predictFertileWindow(prediction)
        : <DateTime>[];
    final ovulationDate = prediction != null
        ? PredictionService.predictOvulation(prediction)
        : null;

    final isFertile = fertileDates.any((d) => d.isSameDate(widget.date));
    final isOvulation =
        ovulationDate != null && ovulationDate.isSameDate(widget.date);
    final isPeriod = dailyData?.isPeriod ?? false;

    // Calculate follicular phase (after period ends, before fertile window)
    final isFollicular =
        _isInFollicularPhase(widget.date, widget.stats, fertileDates);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.calendarDaySpacing),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isPeriod, isOvulation, isFertile,
              isFollicular, isPredicted, isToday, isDark),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: _getBorder(isPeriod, isOvulation, isFertile, isFollicular,
              isPredicted, isToday),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : AppColors.clayShadow.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                      spreadRadius: -1),
                ]
              : _getShadow(isPeriod, isOvulation, isFertile, isFollicular,
                  isToday, isDark),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.date.day.toString(),
                style: TextStyle(
                  color: _getTextColor(isCurrentMonth, isOvulation, isFertile,
                      isFollicular, isToday, isPeriod, isDark),
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            if (isOvulation)
              Positioned(
                right: 3,
                top: 3,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.ovulation,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ovulation.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            if (isToday)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.today,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.today.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            if (isPredicted)
              Positioned(
                left: 3,
                bottom: 3,
                child: Icon(
                  Icons.auto_awesome,
                  size: 10,
                  color: AppColors.predicted.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isPeriod, bool isOvulation, bool isFertile,
      bool isFollicular, bool isPredicted, bool isToday, bool isDark) {
    if (isPeriod) return AppColors.period.withOpacity(0.15);
    if (isOvulation) return AppColors.ovulation.withOpacity(0.2);
    if (isFertile) return AppColors.fertile.withOpacity(0.1);
    if (isFollicular) return AppColors.follicular.withOpacity(0.1);
    if (isPredicted) return AppColors.predicted.withOpacity(0.08);
    if (isToday) return AppColors.today.withOpacity(0.1);
    return isDark ? Colors.transparent : theme.colorScheme.surface;
  }

  Border _getBorder(bool isPeriod, bool isOvulation, bool isFertile,
      bool isFollicular, bool isPredicted, bool isToday) {
    if (isOvulation) return Border.all(color: AppColors.ovulation, width: 2);
    if (isPeriod) {
      return Border.all(color: AppColors.period.withOpacity(0.5), width: 2);
    }
    if (isFertile) {
      return Border.all(color: AppColors.fertile.withOpacity(0.5), width: 0);
    }
    if (isFollicular) {
      return Border.all(color: AppColors.follicular.withOpacity(0.5), width: 1);
    }
    if (isPredicted) {
      return Border.all(color: AppColors.predicted.withOpacity(0.8), width: 2);
    }
    if (isToday) return Border.all(color: AppColors.today, width: 2);
    return Border.all(
      color: theme.colorScheme.outline.withOpacity(0),
      width: 1,
    );
  }

  List<BoxShadow> _getShadow(bool isPeriod, bool isOvulation, bool isFertile,
      bool isFollicular, bool isToday, bool isDark) {
    // No shadows in dark mode - clean flat design
    if (isDark) {
      return [];
    }
    // Light mode: minimal shadows for performance
    if (isPeriod || isToday) {
      return [
        BoxShadow(
          color:
              (isPeriod ? AppColors.period : AppColors.today).withOpacity(0.15),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];
    }
    // Light mode: single subtle shadow
    return [
      BoxShadow(
        color: AppColors.clayShadow.withOpacity(0.1),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  Color _getTextColor(bool isCurrentMonth, bool isOvulation, bool isFertile,
      bool isFollicular, bool isToday, bool isPeriod, bool isDark) {
    if (!isCurrentMonth) return theme.colorScheme.onSurface.withOpacity(0.3);
    if (isOvulation) return AppColors.ovulation;
    if (isFertile) return AppColors.fertile;
    if (isFollicular) return AppColors.follicular;
    if (isToday) return AppColors.today;
    if (isPeriod) return AppColors.period;
    return theme.colorScheme.onSurface;
  }

  /// Checks if a date falls within the follicular phase (after period, before fertile window)
  bool _isInFollicularPhase(
      DateTime date, Map<String, dynamic> stats, List<DateTime> fertileDates) {
    if (fertileDates.isEmpty) return false;

    // Get the last period info
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    if (periods.isEmpty) return false;

    final lastPeriod = periods.last;
    final lastPeriodEnd = lastPeriod.last;
    final averageCycle = stats['average'] as int? ?? 28;
    final now = DateTime.now();

    // Check if we're in a predicted cycle (past last tracked period)
    final daysSinceLastPeriod = now.difference(lastPeriod.first).inDays;
    DateTime periodEnd;
    DateTime fertileStart = fertileDates.first;

    if (daysSinceLastPeriod > averageCycle) {
      // We're in a predicted cycle - calculate the period end for this predicted cycle
      final cyclesPassed = daysSinceLastPeriod ~/ averageCycle;
      final predictedCycleStart = lastPeriod.first.add(
        Duration(days: cyclesPassed * averageCycle),
      );
      final periodLength = stats['currentPeriodLength'] as int? ?? 5;
      periodEnd = predictedCycleStart.add(Duration(days: periodLength - 1));

      // Recalculate fertile window for this predicted cycle
      final predictedNextPeriod =
          predictedCycleStart.add(Duration(days: averageCycle));
      fertileStart = predictedNextPeriod.subtract(const Duration(days: 14 + 5));
    } else {
      // Still in last tracked cycle
      periodEnd = lastPeriodEnd;
    }

    // Follicular phase is after period ends and before fertile window starts
    final dayAfterPeriod = periodEnd.add(const Duration(days: 1));
    final dayBeforeFertile = fertileStart.subtract(const Duration(days: 1));

    return !date.isBefore(dayAfterPeriod) && !date.isAfter(dayBeforeFertile);
  }

  ThemeData get theme => Theme.of(context);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClayButton(
            onTap: onPreviousMonth,
            padding: const EdgeInsets.all(10),
            radius: AppDimensions.radiusMedium,
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          ClayCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.cardPadding,
              vertical: AppDimensions.smallSpacing,
            ),
            // No custom shadows - ClayCard handles light/dark mode automatically
            child: Text(
              DateFormat('MMMM y').format(currentMonth),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ClayButton(
            onTap: onNextMonth,
            padding: const EdgeInsets.all(10),
            radius: AppDimensions.radiusMedium,
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
