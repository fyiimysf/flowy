// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cycle_models.dart';
import '../../services/storage/storage_service.dart';
import '../../services/localization/app_localizations.dart';
import '../../services/localization/language_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../utils/constants/strings.dart';
import '../../utils/extensions/localization_extension.dart';
import '../../widgets/common/cards.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  final LanguageService _languageService = LanguageService();

  Future<void> _deleteAllData() async {
    await _storage.clearAllData();

    // Also clear onboarding status to show it again on next launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', false);
    await prefs.remove('onboarding_dark_mode');

    if (mounted) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          backgroundColor: AppColors.error.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppDimensions.screenPadding),
          content: Row(
            children: [
              const Icon(Icons.delete_outline, color: Colors.white),
              const SizedBox(width: AppDimensions.elementSpacing),
              Expanded(
                child: Text(
                  context.tr('allDataDeleted'),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to root route which will show onboarding
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      });
    }
  }

  Future<void> _confirmDataDeletion() async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClayCard(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.elementSpacing),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: AppDimensions.iconXL,
                  ),
                ),
                const SizedBox(height: AppDimensions.elementSpacing),
                Text(
                  context.tr('factoryReset'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                Text(
                  context.tr('deleteAllData'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: Center(
                          child: Text(
                            context.tr('cancel'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.elementSpacing),
                    Expanded(
                      child: ClayButton(
                        onTap: () {
                          _deleteAllData();
                          Navigator.of(context).pop();
                        },
                        color: AppColors.error.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            context.tr('delete'),
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.cardPadding),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.elementSpacing),
              Text(
                context.tr('language'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.smallSpacing),
              Text(
                context.tr('chooseLanguage'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: AppDimensions.sectionSpacing),
              ..._languageService.languages.entries.map((entry) {
                final code = entry.key;
                final names = entry.value;
                final isSelected =
                    _languageService.currentLocale.languageCode == code;

                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppDimensions.smallSpacing),
                  child: ClayButton(
                    onTap: () async {
                      await _languageService.setLanguage(code);
                      if (mounted) {
                        Navigator.pop(context);
                        setState(() {});
                      }
                    },
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : isDark
                            ? Colors.white.withOpacity(0.05)
                            : theme.colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.2)
                                : theme.colorScheme.onSurface.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              code.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.primary
                                    : theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.elementSpacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                names['nativeName']!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              Text(
                                names['name']!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: AppDimensions.iconMedium,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: AppDimensions.elementSpacing),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimensions.tinySpacing,
                children: [
                  Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: AppDimensions.iconLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(context.tr('settings')),
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
                const SizedBox(height: AppDimensions.sectionSpacing * 2),
                // General section
                _buildSectionHeader(context, context.tr('general'), Icons.tune),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      ValueListenableBuilder<Box<Options>>(
                        valueListenable:
                            Hive.box<Options>('options').listenable(),
                        builder: (context, box, _) {
                          final options =
                              box.get('theme') ?? Options(darkMode: true);
                          return _buildSettingTile(
                            context,
                            icon: Icons.color_lens,
                            iconColor: AppColors.peach,
                            title: context.tr('theme'),
                            subtitle: options.darkMode
                                ? context.tr('dark')
                                : context.tr('light'),
                            onTap: () {},
                            onChanged: (val) async {
                              options.darkMode = val;
                              await box.put('theme', options);
                            },
                            isToggle: true,
                            value: options.darkMode,
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      _buildSettingTile(context,
                          icon: Icons.language,
                          iconColor: AppColors.mint,
                          title: context.tr('language'),
                          subtitle: _languageService.getLanguageName(
                              _languageService.currentLocale.languageCode),
                          onTap: _showLanguageDialog,
                          onChanged: (e) {}),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      _buildSettingTile(context,
                          icon: Icons.waving_hand,
                          iconColor: AppColors.secondaryLight,
                          title: context.tr('viewOnboarding'),
                          subtitle: context.tr('viewOnboardingSubtitle'),
                          onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('has_completed_onboarding', false);
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      }, onChanged: (e) {}),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Support section
                _buildSectionHeader(
                    context, context.tr('support'), Icons.support),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      _buildSettingTile(context,
                          icon: Icons.help_outline,
                          iconColor: AppColors.secondary,
                          title: context.tr('helpAndFaq'),
                          onTap: () =>
                              Navigator.pushNamed(context, '/help-faq'),
                          onChanged: (e) {}),
                      const SizedBox(height: AppDimensions.elementSpacing),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      const SizedBox(height: AppDimensions.elementSpacing),
                      _buildSettingTile(context,
                          icon: Icons.feedback_outlined,
                          iconColor: AppColors.ovulation,
                          title: context.tr('sendFeedback'),
                          onTap: () =>
                              Navigator.pushNamed(context, '/feedback'),
                          onChanged: (e) {}),
                      const SizedBox(height: AppDimensions.elementSpacing),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      const SizedBox(height: AppDimensions.elementSpacing),
                      _buildSettingTile(context,
                          icon: Icons.info_outline,
                          iconColor: AppColors.secondary,
                          title: context.tr('about'),
                          onTap: () => Navigator.pushNamed(context, '/about'),
                          onChanged: (e) {}),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Danger zone
                _buildSectionHeader(
                    context, context.tr('dangerZone'), Icons.warning_amber,
                    color: AppColors.error),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  color: AppColors.error.withOpacity(0.05),
                  child: _buildSettingTile(context,
                      icon: Icons.delete_forever,
                      iconColor: AppColors.error,
                      title: context.tr('factoryReset'),
                      subtitle: context.tr('deleteAllData'),
                      textColor: AppColors.error,
                      onTap: _confirmDataDeletion,
                      onChanged: (e) {}),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing * 2),
                // Version
                Center(
                  child: Text(
                    '${context.tr('version')} 1.0.0',
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

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon,
      {Color? color}) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconSmall,
          color: color ?? AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.smallSpacing),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: color ?? theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? textColor,
    bool isToggle = false,
    bool value = false,
    required VoidCallback onTap,
    required Function(dynamic) onChanged,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: iconColor,
            size: AppDimensions.iconLarge,
          ),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: !isToggle
          ? Icon(
              Icons.chevron_right,
              color: textColor?.withOpacity(0.5) ??
                  theme.colorScheme.onSurface.withOpacity(0.4),
            )
          : Switch(
              value: value,
              onChanged: (val) => {
                    onChanged(val),
                    setState(() {
                      value = val;
                    })
                  }),
      onTap: onTap,
    );
  }
}
