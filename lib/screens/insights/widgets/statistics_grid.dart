// lib/screens/insights/widgets/statistics_grid.dart

import 'dart:math';

import 'package:flutter/material.dart';
import '../../../services/cycle/cycle_calculation_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/dimensions.dart';
import '../../../widgets/common/cards.dart';

class StatisticsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatisticsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final periods = stats['periods'] as List<List<DateTime>>? ?? [];
    final cycleLengths = _getCycleLengths(periods);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.elementSpacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: AppDimensions.elementSpacing,
          crossAxisSpacing: AppDimensions.elementSpacing,
          children: [
            MetricCard(
              title: 'Average Cycle',
              value: '${stats['average'] ?? '--'} days',
              icon: Icons.calendar_today,
            ),
            MetricCard(
              title: 'Consistency',
              value: cycleLengths.length > 1
                  ? '${CycleCalculationService.calculateConsistency(cycleLengths)}%'
                  : '--',
              icon: Icons.trending_up,
            ),
            MetricCard(
              title: 'Longest Cycle',
              value: cycleLengths.isNotEmpty
                  ? '${cycleLengths.reduce(max)} days'
                  : '--',
              icon: Icons.arrow_upward,
            ),
            MetricCard(
              title: 'Shortest Cycle',
              value: cycleLengths.isNotEmpty
                  ? '${cycleLengths.reduce(min)} days'
                  : '--',
              icon: Icons.arrow_downward,
            ),
          ],
        ),
      ],
    );
  }

  List<int> _getCycleLengths(List<List<DateTime>> periods) {
    final lengths = <int>[];
    for (int i = 1; i < periods.length; i++) {
      final length = periods[i].first.difference(periods[i - 1].first).inDays;
      lengths.add(length);
    }
    return lengths;
  }
}
