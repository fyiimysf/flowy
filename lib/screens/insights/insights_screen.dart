// lib/screens/insights/insights_screen.dart

import 'package:flutter/material.dart' hide ProgressIndicator;
import '../../services/cycle/cycle_calculation_service.dart';
import '../../services/cycle/phase_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/common/cards.dart';
import '../../widgets/common/indicators.dart';
import 'widgets/fertility_forecast.dart';
import 'widgets/phase_breakdown.dart';
import 'widgets/statistics_grid.dart';

class InsightsScreen extends StatelessWidget {
  final Map<String, dynamic> stats;

  const InsightsScreen({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final prediction = stats['prediction'] as DateTime?;
    final phaseName = PhaseService.getPhaseName(DateTime.now(), stats);
    final phaseColor = PhaseService.getPhaseColor(phaseName);
    final currentPhase = PhaseService.getPhaseDisplay(DateTime.now(), stats);
    final cycleProgress = CycleCalculationService.calculateProgress(
      stats['periods'] ?? [],
      stats['average'] ?? 28,
    );
    final currentCycleDay =
        CycleCalculationService.getCurrentCycleDay(stats['periods'] ?? []);
    final daysUntil = prediction?.difference(DateTime.now()).inDays;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom app bar
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.insights,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium,
                  ),
                  const SizedBox(width: 8),
                  const Text('Cycle Insights'),
                ],
              ),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Progress card
                _buildProgressCard(cycleProgress, currentPhase, phaseColor,
                    stats, context, currentCycleDay, daysUntil),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Statistics
                StatisticsGrid(stats: stats),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Phase breakdown
                PhaseBreakdown(stats: stats),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Fertility forecast
                if (prediction != null)
                  FertilityForecast(prediction: prediction),
                const SizedBox(height: AppDimensions.sectionSpacing),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      double progress,
      String currentPhase,
      Color phaseColor,
      Map<String, dynamic> stats,
      BuildContext context,
      int? currentCycleDay,
      int? daysUntil) {
    return ClayCard(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 350;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isNarrow) ...[
                // Vertical layout for narrow screens
                ProgressIndicator(
                  value: progress,
                  size: 80,
                  strokeWidth: 10,
                  color: phaseColor,
                  label: 'Cycle',
                ),
                const SizedBox(height: AppDimensions.elementSpacing),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isNarrow) ...[
                    // Horizontal layout for wider screens
                    ProgressIndicator(
                      value: progress,
                      size: 80,
                      strokeWidth: 10,
                      color: phaseColor,
                      label: 'Cycle',
                    ),
                    const SizedBox(width: AppDimensions.elementSpacing),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.elementSpacing,
                            vertical: AppDimensions.smallSpacing,
                          ),
                          decoration: BoxDecoration(
                            color: phaseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCircular),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhaseService.getPhaseIcon(
                                  PhaseService.getPhaseName(
                                      DateTime.now(), stats),
                                ),
                                color: phaseColor,
                                size: AppDimensions.iconSmall,
                              ),
                              const SizedBox(width: AppDimensions.smallSpacing),
                              Flexible(
                                child: Text(
                                  'Current Phase',
                                  style: TextStyle(
                                    color: phaseColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: AppDimensions.fontSmall,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.smallSpacing),
                        Text(
                          currentPhase,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: phaseColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.tinySpacing),
                        Text(
                          currentCycleDay != null
                              ? 'Day $currentCycleDay of ${stats['average'] ?? 28} day cycle'
                              : 'Track your period to see cycle day',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (daysUntil != null && daysUntil >= 0) ...[
                          const SizedBox(height: AppDimensions.tinySpacing),
                          Text(
                            '$daysUntil days until next period',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
