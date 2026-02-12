// lib/screens/insights/widgets/phase_breakdown.dart

import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../../../models/cycle_models.dart';
import '../../../services/cycle/cycle_calculation_service.dart';
import '../../../services/cycle/phase_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../widgets/common/phase_widgets.dart';

class PhaseBreakdown extends StatelessWidget {
  final Map<String, dynamic> stats;

  const PhaseBreakdown({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final currentCycle = CycleCalculationService.getCurrentCycle(
      stats['periods'] ?? [],
    );

    if (currentCycle == null) {
      return const SizedBox.shrink();
    }

    // Check if we should use predicted cycle instead of last tracked period
    final averageCycle = stats['average'] as int? ?? 28;
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(currentCycle.startDate).inDays;
    
    PredictedRange cycleToUse = currentCycle;
    
    // If we're past the expected cycle length, calculate which predicted cycle we're in
    if (daysSinceLastPeriod >= averageCycle) {
      final cyclesPassed = daysSinceLastPeriod ~/ averageCycle;
      final predictedCycleStart = currentCycle.startDate.add(
        Duration(days: cyclesPassed * averageCycle),
      );
      final predictedCycleEnd = predictedCycleStart.add(
        Duration(days: (stats['currentPeriodLength'] as int? ?? 5) - 1),
      );
      
      cycleToUse = PredictedRange(
        index: cyclesPassed - 1,
        startDate: predictedCycleStart,
        endDate: predictedCycleEnd,
      );
    }

    final phases = PhaseService.calculatePhaseDetails(cycleToUse, stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('phaseBreakdown'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.elementSpacing),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: phases.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppDimensions.elementSpacing),
            itemBuilder: (context, index) => PhaseCard(
              phase: phases[index],
              isCurrent:
                  PhaseService.isDateInPhase(DateTime.now(), phases[index]),
            ),
          ),
        ),
      ],
    );
  }
}
