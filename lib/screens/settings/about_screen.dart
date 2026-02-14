import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/strings.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/cards.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: AppDimensions.tinySpacing,
                children: [
                  const SizedBox(height: 8),
                  Text(context.tr('about')),
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
                const SizedBox(height: AppDimensions.sectionSpacing),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(90),
                          child: Image.asset(
                            'lib/icons/icon-192.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.elementSpacing),
                      Text(
                        AppStrings.appName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        AppStrings.appTagline,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing * 2),
                ClayCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.new_releases,
                        iconColor: AppColors.primary,
                        label: context.tr('version'),
                        value: '1.0.0',
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today,
                        iconColor: AppColors.secondary,
                        label: 'Released',
                        value: 'February 2026',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Text(
                  context.tr('keyFeatures'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        icon: Icons.track_changes,
                        title: context.tr('featureTracking'),
                        description: context.tr('featureTrackingDesc'),
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.auto_awesome,
                        title: context.tr('featurePrediction'),
                        description: context.tr('featurePredictionDesc'),
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.insights,
                        title: context.tr('featureInsights'),
                        description: context.tr('featureInsightsDesc'),
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildFeatureItem(
                        context,
                        icon: Icons.privacy_tip,
                        title: context.tr('featurePrivacy'),
                        description: context.tr('featurePrivacyDesc'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Text(
                  'Credits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      _buildCreditItem(
                        context,
                        title: 'Design & Development',
                        value: '${AppStrings.appName} Creator',
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildCreditItem(
                        context,
                        title: 'Built With',
                        value: 'Flutter & Dart',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Center(
                  child: Text(
                    '© 2026 ${AppStrings.appName}. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.smallSpacing),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: AppDimensions.iconSmall,
        ),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.smallSpacing),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: AppDimensions.iconSmall,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCreditItem(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
