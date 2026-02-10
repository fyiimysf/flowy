// lib/screens/insights/widgets/phase_breakdown.dart

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

    final phases = PhaseService.calculatePhaseDetails(currentCycle, stats);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phase Breakdown',
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
