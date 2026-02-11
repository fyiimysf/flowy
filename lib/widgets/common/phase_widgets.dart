// lib/widgets/common/phase_widgets.dart

import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../../models/cycle_models.dart';
import '../../services/cycle/phase_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import 'cards.dart';
import 'indicators.dart';

/// Phase card with claymorphism styling
class PhaseCard extends StatelessWidget {
  final PhaseDetail phase;
  final bool isCurrent;

  const PhaseCard({
    super.key,
    required this.phase,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = PhaseService.getPhaseColor(phase.name);

    return ClayCard(
      color: !isCurrent ? null : color.withOpacity(0.1),
      radius: AppDimensions.radiusMedium,
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.elementSpacing),
      shadows: isDark || !isCurrent
          ? [] // No shadows in dark mode
          : [
              // Only light mode + current gets shadows
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.smallSpacing),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PhaseService.getPhaseIcon(phase.name),
                color: color,
                size: AppDimensions.iconLarge,
              ),
            ),
            const SizedBox(height: AppDimensions.tinySpacing),
            Text(
              phase.name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            // const SizedBox(height: AppDimensions.tinySpacing),
            Text(
              '${phase.duration} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Phase expansion tile with feminine design
class PhaseExpansionTile extends StatelessWidget {
  final PhaseDetail phase;

  const PhaseExpansionTile({
    super.key,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = PhaseService.getPhaseColor(phase.name);
    final isCurrent = PhaseService.isDateInPhase(DateTime.now(), phase);
    final daysRemaining = phase.endDate.difference(DateTime.now()).inDays;
    final progress = PhaseService.calculatePhaseProgress(phase);

    return ClayCard(
      color: isCurrent ? color.withOpacity(0.05) : null,
      radius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.elementSpacing,
        vertical: AppDimensions.smallSpacing,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: isCurrent,
          tilePadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(AppDimensions.smallSpacing),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhaseService.getPhaseIcon(phase.name),
              color: color,
              size: AppDimensions.iconMedium,
            ),
          ),
          title: Text(
            phase.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${_formatDate(phase.startDate)} - ${_formatDate(phase.endDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: PhaseChip(
            label: '${phase.duration}d',
            color: color,
            isActive: isCurrent,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.cardPadding,
                right: AppDimensions.cardPadding,
                bottom: AppDimensions.elementSpacing,
                top: AppDimensions.smallSpacing,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.smallSpacing),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSmall),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  theme.colorScheme.onSurface.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.elementSpacing),
                        Text(
                          isCurrent
                              ? '$daysRemaining ${context.tr('days')} ${context.tr("left")}'
                              : '--',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isCurrent
                                ? color
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.elementSpacing),
                  // Description
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.elementSpacing),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: color.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppDimensions.iconSmall,
                          color: color,
                        ),
                        const SizedBox(width: AppDimensions.smallSpacing),
                        Expanded(
                          child: Text(
                            PhaseService.getPhaseDescription(
                                phase.name, context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Phase row with feminine styling
class PhaseRow extends StatelessWidget {
  final PhaseDetail phase;

  const PhaseRow({
    super.key,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = PhaseService.getPhaseColor(phase.name);

    return ClayCard(
      color: color.withOpacity(0.03),
      radius: AppDimensions.radiusMedium,
      padding: const EdgeInsets.all(AppDimensions.elementSpacing),
      shadows: isDark
          ? [] // No shadows in dark mode
          : [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
      child: Row(
        children: [
          // Phase indicator bar
          Container(
            width: 5,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.elementSpacing),
          // Phase icon
          Container(
            padding: const EdgeInsets.all(AppDimensions.smallSpacing),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhaseService.getPhaseIcon(phase.name),
              color: color,
              size: AppDimensions.iconSmall,
            ),
          ),
          const SizedBox(width: AppDimensions.elementSpacing),
          // Phase info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.tinySpacing),
                Text(
                  '${_formatDate(phase.startDate)} - ${_formatDate(phase.endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Duration chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.elementSpacing,
              vertical: AppDimensions.smallSpacing,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
            ),
            child: Text(
              '${phase.duration} days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
