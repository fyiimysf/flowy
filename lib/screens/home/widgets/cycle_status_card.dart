// lib/screens/home/widgets/cycle_status_card.dart

import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:intl/intl.dart';
import '../../../services/cycle/cycle_calculation_service.dart';
import '../../../services/cycle/phase_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../widgets/common/cards.dart';
import '../../../widgets/common/indicators.dart';

class CycleStatusCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  final VoidCallback? onTap;

  const CycleStatusCard({
    super.key,
    required this.stats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final periods = (stats['periods'] as List<List<DateTime>>?) ?? [];
    final prediction = stats['prediction'] as DateTime?;
    
    // Check if we have no data
    if (periods.isEmpty) {
      return _buildEmptyState(context, isDark);
    }
    
    // Check if we're near a prediction date (within 7 days)
    final daysUntil = prediction != null 
        ? prediction.difference(DateTime.now()).inDays 
        : null;
    final isNearPrediction = daysUntil != null && daysUntil >= 0 && daysUntil <= 7;
    
    if (isNearPrediction && prediction != null) {
      return _buildPredictionState(context, isDark, prediction, daysUntil);
    }
    
    // Normal cycle state
    final currentPhase = PhaseService.getPhaseDisplay(DateTime.now(), stats);
    final phaseName = PhaseService.getPhaseName(DateTime.now(), stats);
    final phaseColor = PhaseService.getPhaseColor(phaseName);
    final progress = CycleCalculationService.calculateProgress(
      periods,
      stats['average'] ?? 28,
    );
    final currentCycleDay = CycleCalculationService.getCurrentCycleDay(periods);

    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        // No custom shadows - ClayCard handles light/dark mode automatically
        child: Column(
          children: [
            // Progress circle with phase info
            Row(
              children: [
                // Circular progress
                ProgressIndicator(
                  value: progress,
                  size: 100,
                  strokeWidth: 12,
                  color: phaseColor,
                  showPercentage: false,
                ),
                const SizedBox(width: AppDimensions.elementSpacing * 2),
                // Phase info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.elementSpacing,
                          vertical: AppDimensions.smallSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: phaseColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircular),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              PhaseService.getPhaseIcon(phaseName),
                              color: phaseColor,
                              size: AppDimensions.iconSmall,
                            ),
                            const SizedBox(width: AppDimensions.smallSpacing),
                            Text(
                              'Current Phase',
                              style: theme.textTheme.bodySmall?.copyWith(
                                    color: phaseColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        currentPhase,
                        style: theme.textTheme.titleLarge?.copyWith(
                              color: phaseColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        currentCycleDay != null 
                            ? 'Day $currentCycleDay of ${stats['average'] ?? 28}'
                            : 'Track your period',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            // Phase description
            Container(
              padding: const EdgeInsets.all(AppDimensions.elementSpacing),
              decoration: BoxDecoration(
                color: phaseColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: phaseColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: phaseColor,
                    size: AppDimensions.iconMedium,
                  ),
                  const SizedBox(width: AppDimensions.elementSpacing),
                  Expanded(
                    child: Text(
                      PhaseService.getPhaseDescription(phaseName),
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            // Next period info
            if (prediction != null)
              Container(
                padding: const EdgeInsets.all(AppDimensions.elementSpacing),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.smallSpacing),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event,
                        color: AppColors.primary,
                        size: AppDimensions.iconSmall,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.elementSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Period',
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                          ),
                          const SizedBox(height: AppDimensions.tinySpacing),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(prediction),
                            style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      daysUntil != null && daysUntil >= 0
                          ? '$daysUntil days'
                          : 'Soon',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    
    return ClayCard(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
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
              color: AppColors.primary,
              size: AppDimensions.iconXL,
            ),
          ),
          const SizedBox(height: AppDimensions.elementSpacing),
          Text(
            'Welcome to Flowy!',
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Text(
            'Start tracking your period to see personalized insights and predictions.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          Container(
            padding: const EdgeInsets.all(AppDimensions.elementSpacing),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: AppDimensions.iconMedium,
                ),
                const SizedBox(width: AppDimensions.elementSpacing),
                Expanded(
                  child: Text(
                    'Tap on any date in the calendar to start tracking your period.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPredictionState(BuildContext context, bool isDark, DateTime prediction, int daysUntil) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                // Warning indicator
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.predicted.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notification_important,
                    color: AppColors.predicted,
                    size: AppDimensions.iconXL,
                  ),
                ),
                const SizedBox(width: AppDimensions.elementSpacing * 2),
                // Prediction info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.elementSpacing,
                          vertical: AppDimensions.smallSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.predicted.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircular),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.predicted,
                              size: AppDimensions.iconSmall,
                            ),
                            const SizedBox(width: AppDimensions.smallSpacing),
                            Text(
                              'Expected Soon',
                              style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.predicted,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        'Period Expected',
                        style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.predicted,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        daysUntil == 0 
                            ? 'Your period is expected today'
                            : daysUntil == 1
                                ? 'Your period is expected tomorrow'
                                : 'In $daysUntil days',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sectionSpacing),
            // Prediction details
            Container(
              padding: const EdgeInsets.all(AppDimensions.elementSpacing),
              decoration: BoxDecoration(
                color: AppColors.predicted.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(
                  color: AppColors.predicted.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.predicted,
                    size: AppDimensions.iconMedium,
                  ),
                  const SizedBox(width: AppDimensions.elementSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expected Date',
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(
                          DateFormat('MMMM dd, yyyy').format(prediction),
                          style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
