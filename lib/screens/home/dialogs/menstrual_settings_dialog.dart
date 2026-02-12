// lib/screens/home/dialogs/menstrual_settings_dialog.dart

import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../utils/constants/strings.dart';
import '../../../utils/extensions/localization_extension.dart';
import '../../../widgets/common/cards.dart';

class MenstrualSettingsDialog extends StatefulWidget {
  final int initialDays;
  final Function(int days) onSave;

  const MenstrualSettingsDialog({
    super.key,
    required this.initialDays,
    required this.onSave,
  });

  @override
  State<MenstrualSettingsDialog> createState() =>
      _MenstrualSettingsDialogState();
}

class _MenstrualSettingsDialogState extends State<MenstrualSettingsDialog> {
  late int selectedDays;

  @override
  void initState() {
    super.initState();
    selectedDays = widget.initialDays;
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
      ),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: SafeArea(
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
            // Icon header
            Container(
              padding: const EdgeInsets.all(AppDimensions.elementSpacing),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.settings_suggest,
                color: AppColors.primary,
                size: AppDimensions.iconXL,
              ),
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
            // Title
            Text(
              context.tr('welcomeTitle'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
            // Subtitle
            Text(
              context.tr('menstrualDaysQuestion'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            // Duration selector
            ClayCard(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(AppDimensions.elementSpacing),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppDimensions.iconSmall,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.smallSpacing),
                      Text(
                        '${context.tr('period')} ${context.tr('duration')}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.elementSpacing),
                  // Day selector buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (index) {
                        final days = 3 + index;
                        final isSelected = selectedDays == days;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDays = days;
                              });
                            },
                            child: Container(
                              // Removed AnimatedContainer to prevent theme switch flash
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall),
                                boxShadow: isDark
                                    ? []
                                    : isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: AppColors.clayShadow
                                                  .withOpacity(0.15),
                                              blurRadius: 3,
                                              offset: const Offset(3, 3),
                                            ),
                                          ],
                              ),
                              child: Center(
                                child: Text(
                                  '$days',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.elementSpacing),
                  Text(
                    '$selectedDays ${context.tr('days')}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            // Action buttons
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
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.elementSpacing),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check, size: 35),
                    label: Text(
                      context.tr('save'),
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.elementSpacing),
                    ),
                    onPressed: () {
                      widget.onSave(selectedDays);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
          ],
        ),
      ),
    );
  }
}
