// lib/screens/home/dialogs/period_editor_dialog.dart

import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/storage/storage_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../utils/extensions/date_extensions.dart';
import '../../../widgets/common/cards.dart';

class PeriodEditorDialog extends StatefulWidget {
  final DateTime initialDate;
  final int defaultMenstrualDays;
  final Function(DateTime startDate, int duration) onSave;
  final Function(DateTime startDate) onClear;

  const PeriodEditorDialog({
    super.key,
    required this.initialDate,
    required this.defaultMenstrualDays,
    required this.onSave,
    required this.onClear,
  });

  @override
  State<PeriodEditorDialog> createState() => _PeriodEditorDialogState();
}

class _PeriodEditorDialogState extends State<PeriodEditorDialog> {
  late DateTime startDate;
  late int menstrualDays;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialDate;
    menstrualDays = widget.defaultMenstrualDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.2),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
      ),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppDimensions.elementSpacing),
          _buildHeader(),
          const SizedBox(height: AppDimensions.elementSpacing),
          _buildDaysGrid(),
          const SizedBox(height: AppDimensions.elementSpacing),
          _buildDurationControl(),
          const SizedBox(height: AppDimensions.sectionSpacing),
          _buildActionButtons(),
          const SizedBox(height: AppDimensions.elementSpacing),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClayButton(
          onTap: () {
            setState(() {
              startDate = startDate.subtractDays(1);
            });
          },
          padding: const EdgeInsets.all(AppDimensions.smallSpacing),
          child: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.period.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: AppColors.period,
                    size: AppDimensions.iconMedium,
                  ),
                ),
                const SizedBox(width: AppDimensions.smallSpacing),
                Text(
                  context.tr('editPeriod'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
            ClayCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.elementSpacing,
                vertical: AppDimensions.smallSpacing,
              ),
              // No custom shadows - ClayCard handles light/dark mode automatically
              child: Text(
                '${DateFormat('MMM dd').format(startDate)} - '
                '${DateFormat('MMM dd').format(startDate.addDays(menstrualDays - 1))}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        ClayButton(
          onTap: () {
            setState(() {
              startDate = startDate.addDays(1);
            });
          },
          padding: const EdgeInsets.all(AppDimensions.smallSpacing),
          child: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 7;
        return Container(
          height: cellSize * 2,
          padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.elementSpacing),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: menstrualDays,
            itemBuilder: (context, index) {
              final date = startDate.addDays(index);
              final storage = StorageService();
              final isPeriod = storage.getDailyData(date)?.isPeriod ?? false;
              final isToday = date.isToday();

              return GestureDetector(
                onTap: () => _toggleDay(date),
                child: Container(
                  // Removed AnimatedContainer to prevent theme switch flash
                  margin: const EdgeInsets.all(
                      AppDimensions.calendarDaySpacing * 2),
                  decoration: BoxDecoration(
                    color: isPeriod
                        ? AppColors.period.withOpacity(0.15)
                        : isDark
                            ? Colors.white.withOpacity(0.05)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: isPeriod
                          ? AppColors.period
                          : theme.colorScheme.outline.withOpacity(0.2),
                      width: isPeriod ? 2 : 1,
                    ),
                    boxShadow: isDark
                        ? []
                        : isPeriod
                            ? [
                                BoxShadow(
                                  color: AppColors.period.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 3,
                                  offset: const Offset(-2, -2),
                                ),
                                BoxShadow(
                                  color: AppColors.clayShadow.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isPeriod
                                ? AppColors.period
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
                              color: AppColors.period,
                              shape: BoxShape.circle,
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color:
                                            AppColors.period.withOpacity(0.4),
                                        blurRadius: 4,
                                      ),
                                    ],
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
    );
  }

  Widget _buildDurationControl() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClayCard(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: AppDimensions.iconSmall,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: AppDimensions.smallSpacing),
          Text(
            context.tr('duration'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimensions.elementSpacing),
          ...List.generate(3, (index) {
            final days = 5 + index;
            final isSelected = menstrualDays == days;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    menstrualDays = days;
                  });
                },
                child: Container(
                  // Removed AnimatedContainer to prevent theme switch flash
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.elementSpacing,
                    vertical: AppDimensions.smallSpacing,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : theme.colorScheme.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    boxShadow: isDark
                        ? []
                        : isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 3,
                                  offset: const Offset(-2, -2),
                                ),
                                BoxShadow(
                                  color: AppColors.clayShadow.withOpacity(0.3),
                                  blurRadius: 3,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                  ),
                  child: Text(
                    '$days',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ClayButton(
            onTap: () {
              widget.onClear(startDate);
              Navigator.pop(context);
            },
            color: AppColors.error.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 22,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  context.tr('clear'),
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.elementSpacing),
        Expanded(
          flex: 1,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle_outline, size: 24),
            label: Text(
              context.tr('save'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.elementSpacing),
            ),
            onPressed: () {
              widget.onSave(startDate, menstrualDays);
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }

  void _toggleDay(DateTime date) {
    final storage = StorageService();
    final currentData = storage.getDailyData(date);
    if (currentData != null) {
      currentData.isPeriod = !currentData.isPeriod;
      storage.saveDailyData(date, currentData);
      setState(() {});
    }
  }
}
