import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../../../models/cycle_models.dart';
import '../../../services/cycle/phase_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../widgets/common/cards.dart';
import '../../../widgets/common/phase_widgets.dart';

class PhaseTimeline extends StatelessWidget {
  final Map<String, dynamic> stats;
  final PredictedRange currentCycle;

  const PhaseTimeline({
    super.key,
    required this.stats,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final phases = PhaseService.calculatePhaseDetails(currentCycle, stats);

    return ClayCard(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.smallSpacing),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.primary,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.elementSpacing),
              Text(
                context.tr('cyclePhases'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.smallSpacing),
          Text(
            context.tr('trackYourJourney'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.sectionSpacing),
          ...phases.map((phase) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.elementSpacing),
              child: PhaseExpansionTile(phase: phase),
            );
          }).toList(),
        ],
      ),
    );
  }
}
