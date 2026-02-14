import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cycle_models.dart';
import '../../services/cycle/cycle_calculation_service.dart';
import '../../services/cycle/prediction_service.dart';
import '../../services/cycle/phase_service.dart';
import '../../services/storage/storage_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../common/cards.dart';
import '../common/phase_widgets.dart';
import '../common/indicators.dart';

class PredictionsDrawer extends StatelessWidget {
  final Map<String, dynamic> stats;
  final int menstrualDays;

  const PredictionsDrawer({
    super.key,
    required this.stats,
    required this.menstrualDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentCycle = CycleCalculationService.getCurrentCycle(
      stats['periods'] ?? [],
    );
    final predictedCycles = PredictionService.generatePredictions(
      stats,
      menstrualDays,
    );
    final storage = StorageService();
    final periodRanges = CycleCalculationService.groupPeriods(
      storage.getPeriodDays(),
    );

    return Drawer(
      width: 345,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.elementSpacing),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: AppDimensions.elementSpacing),
                  if (currentCycle != null)
                    _CycleCard(
                      cycle: currentCycle,
                      isCurrent: true,
                      stats: stats,
                      progress: CycleCalculationService.calculateProgress(
                        stats['periods'] ?? [],
                        stats['average'] ?? 28,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.elementSpacing),
                  if (predictedCycles.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.elementSpacing,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: AppDimensions.iconSmall,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: AppDimensions.smallSpacing),
                          Text(
                            ' ${context.tr('cycle')} ${context.tr('Upcoming')}',
                            style: TextStyle(
                              fontSize: AppDimensions.fontSmall,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.elementSpacing),
                    ...predictedCycles.map((cycle) => _CycleCard(
                          cycle: cycle,
                          stats: stats,
                        )),
                  ],
                  const SizedBox(height: AppDimensions.sectionSpacing),
                  _buildHistorySection(context, periodRanges, isDark),
                  const SizedBox(height: AppDimensions.sectionSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusLarge),
          bottomRight: Radius.circular(AppDimensions.radiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.insights,
                  size: 44,
                  color: Colors.white,
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                Text(
                  '${context.tr('cycle')} ${context.tr('insights')}',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('appTagline'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
      BuildContext context, List<PeriodRange> ranges, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.elementSpacing),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: AppDimensions.iconSmall,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: AppDimensions.smallSpacing),
              Text(
                context.tr('history'),
                style: TextStyle(
                  fontSize: AppDimensions.fontSmall,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.elementSpacing),
        if (ranges.isEmpty)
          ClayCard(
            color: isDark ? Colors.white.withOpacity(0.05) : null,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: AppDimensions.iconSmall,
                ),
                const SizedBox(width: AppDimensions.elementSpacing),
                Expanded(
                  child: Text(
                    context.tr('welcomeSubtitle'),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: AppDimensions.fontMedium,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ClayCard(
            child: Column(
              children: ranges.asMap().entries.map((entry) {
                final index = entry.key;
                final range = entry.value;
                final isLast = index == ranges.length - 1;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding:
                            const EdgeInsets.all(AppDimensions.smallSpacing),
                        decoration: BoxDecoration(
                          color: AppColors.period.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.water_drop,
                          color: AppColors.period,
                          size: AppDimensions.iconSmall,
                        ),
                      ),
                      title: Text(
                        '${DateFormat('MMM dd').format(range.startDate)} - '
                        '${DateFormat('MMM dd').format(range.endDate)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${range.duration} days',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: AppDimensions.fontSmall,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.elementSpacing,
                          vertical: AppDimensions.smallSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.period.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCircular),
                        ),
                        child: Text(
                          '${range.duration}d',
                          style: TextStyle(
                            color: AppColors.period,
                            fontWeight: FontWeight.w700,
                            fontSize: AppDimensions.fontSmall,
                          ),
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CycleCard extends StatelessWidget {
  final PredictedRange cycle;
  final bool isCurrent;
  final double? progress;
  final stats;

  const _CycleCard({
    required this.cycle,
    this.isCurrent = false,
    this.progress,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final phaseDetails = PhaseService.calculatePhaseDetails(cycle, stats);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ClayCard(
        color: isCurrent
            ? null
            : isDark
                ? Colors.white.withOpacity(0.03)
                : theme.colorScheme.surfaceContainerHighest,
        shadows: isDark || !isCurrent
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(AppDimensions.smallSpacing),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.predicted.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrent ? Icons.timeline : Icons.auto_awesome,
                color: isCurrent ? AppColors.primary : AppColors.predicted,
                size: AppDimensions.iconMedium,
              ),
            ),
            title: Text(
              isCurrent
                  ? '${context.tr('current')} ${context.tr('cycle')}'
                  : '${context.tr('predicted')} ${context.tr('cycle')} ${cycle.index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              '${DateFormat('MMM dd').format(cycle.startDate)} - '
              '${DateFormat('MMM dd').format(cycle.endDate)}',
              style: TextStyle(
                fontSize: AppDimensions.fontMedium,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            trailing: isCurrent && progress != null
                ? SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.onSurface.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  )
                : null,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: AppDimensions.elementSpacing),
                child: Column(
                  children: [
                    ...phaseDetails.map((phase) => PhaseRow(phase: phase)),
                    if (isCurrent) ...[
                      const SizedBox(height: AppDimensions.elementSpacing),
                      _buildCycleStats(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleStats(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClayCard(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${context.tr('averageCycle')}',
              '${stats['average'] ?? 28} days', theme),
          Container(
            width: 1,
            height: 30,
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          _buildStatItem('${context.tr('period')}',
              '${stats['currentPeriodLength'] ?? 5} days', theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppDimensions.fontSmall,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: AppDimensions.tinySpacing),
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimensions.fontLarge,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
