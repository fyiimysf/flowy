import 'package:floi/utils/extensions/localization_extension.dart';
import 'package:flutter/material.dart';
import '../../../services/cycle/prediction_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../utils/extensions/date_extensions.dart';
import '../../../widgets/common/cards.dart';
import '../../../widgets/common/indicators.dart';

class FertilityForecast extends StatelessWidget {
  final DateTime prediction;

  const FertilityForecast({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final fertileDates = PredictionService.predictFertileWindow(prediction);
    final ovulationDate = PredictionService.predictOvulation(prediction);

    return ClayCard(
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.smallSpacing),
                decoration: BoxDecoration(
                  color: AppColors.fertile.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.child_friendly,
                  color: AppColors.fertile,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.elementSpacing),
              Text(
                context.tr('fertForcast'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.elementSpacing),
          Row(
            children: [
              FertilityIndicator(
                label: '${context.tr('fertile')} ${context.tr('days')}',
                color: AppColors.fertile,
              ),
              const SizedBox(width: AppDimensions.elementSpacing * 2),
              FertilityIndicator(
                label: '${context.tr('ovulationPhase')} ${context.tr('Day')}',
                color: AppColors.ovulation,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.elementSpacing),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: fertileDates.length,
            itemBuilder: (context, index) {
              final date = fertileDates[index];
              final isOvulation = date.isSameDate(ovulationDate);

              return Container(
                margin: const EdgeInsets.all(AppDimensions.calendarDaySpacing),
                decoration: BoxDecoration(
                  color: isOvulation
                      ? AppColors.ovulation.withOpacity(0.15)
                      : AppColors.fertile.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(
                    color:
                        isOvulation ? AppColors.ovulation : AppColors.fertile,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isOvulation
                            ? AppColors.ovulation
                            : AppColors.fertile,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isOvulation)
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.ovulation,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
