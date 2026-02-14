import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:intl/intl.dart';
import '../../../services/cycle/cycle_calculation_service.dart';
import '../../../services/cycle/phase_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../utils/extensions/localization_extension.dart';
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
    final total = stats['average'] ?? 28;

    if (periods.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysUntil = prediction != null
        ? DateTime(prediction.year, prediction.month, prediction.day)
            .difference(todayDate)
            .inDays
        : null;
    final isNearPrediction =
        daysUntil != null && daysUntil >= 0 && daysUntil <= 7;

    if (isNearPrediction && prediction != null) {
      return _buildPredictionState(context, isDark, prediction, daysUntil);
    }

    final currentPhase =
        PhaseService.getPhaseDisplay(DateTime.now(), stats, context);
    final phaseName = PhaseService.getPhaseName(DateTime.now(), stats);
    final phaseColor = PhaseService.getPhaseColor(phaseName);
    final progress = CycleCalculationService.calculateProgress(
      periods,
      stats['average'] ?? 28,
    );
    final currentCycleDay = CycleCalculationService.getCurrentCycleDay(
      periods,
      averageCycleLength: stats['average'] ?? 28,
    );

    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                ProgressIndicator(
                  value: progress,
                  size: 80,
                  strokeWidth: 12,
                  color: phaseColor,
                  showPercentage: true,
                ),
                const SizedBox(width: AppDimensions.elementSpacing * 2),
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
                              context.tr('currentPhase'),
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
                            ? "${context.tr('Day')} $currentCycleDay ${context.tr('of')} $total"
                            : context.tr('trackPeriodHint'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.smallSpacing * 3),
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
                      PhaseService.getPhaseDescription(phaseName, context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.smallSpacing),
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
                            context.tr('nextPeriod'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
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
                          ? '$daysUntil ${context.tr('days')}'
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
            context.tr('welcomeTitle'),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
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
                    context.tr('welcomeHint'),
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

  Widget _buildPredictionState(
      BuildContext context, bool isDark, DateTime prediction, int daysUntil) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: ClayCard(
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
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
                              context.tr('expectedSoon'),
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
                        context.tr('periodExpected'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.predicted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.tinySpacing),
                      Text(
                        daysUntil == 0
                            ? context.tr('periodExpectedToday')
                            : daysUntil == 1
                                ? context.tr('periodExpectedTomorrow')
                                : '${context.tr('In')} $daysUntil ${context.tr('days')}',
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
                          context.tr('expectedDate'),
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
