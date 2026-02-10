// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/cycle_models.dart';
import '../../services/storage/storage_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';
import '../../widgets/common/cards.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();

  Future<void> _deleteAllData() async {
    await _storage.clearAllData();

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
              const Expanded(
                child: Text(
                  'All data has been deleted',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
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
                  'Factory Reset',
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppDimensions.smallSpacing),
                Text(
                  'Are you sure you want to delete all data? This action cannot be undone.',
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
                            'Cancel',
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
                            'Delete',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: AppDimensions.iconXL,
                  ),
                  const SizedBox(height: 8),
                  const Text('Settings'),
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
                _buildSectionHeader(context, 'General', Icons.tune),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      ValueListenableBuilder<Box<Options>>(
                        valueListenable: Hive.box<Options>('options').listenable(),
                        builder: (context, box, _) {
                          final options = box.get('theme') ?? Options(darkMode: false);
                          return _buildSettingTile(
                            context,
                            icon: Icons.color_lens,
                            iconColor: AppColors.peach,
                            title: 'Theme',
                            subtitle: options.darkMode ? 'Dark' : 'Light',
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
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildSettingTile(context,
                          icon: Icons.language,
                          iconColor: AppColors.mint,
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                          onChanged: (e) {}),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Support section
                _buildSectionHeader(context, 'Support', Icons.support),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  child: Column(
                    children: [
                      _buildSettingTile(context,
                          icon: Icons.help_outline,
                          iconColor: AppColors.secondary,
                          title: 'Help & FAQ',
                          onTap: () {},
                          onChanged: (e) {}),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildSettingTile(context,
                          icon: Icons.feedback_outlined,
                          iconColor: AppColors.ovulation,
                          title: 'Send Feedback',
                          onTap: () {},
                          onChanged: (e) {}),
                      Divider(
                        height: 1,
                        indent: 0,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      _buildSettingTile(context,
                          icon: Icons.info_outline,
                          iconColor: AppColors.secondary,
                          title: 'About',
                          onTap: () {},
                          onChanged: (e) {}),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),
                // Danger zone
                _buildSectionHeader(context, 'Danger Zone', Icons.warning_amber,
                    color: AppColors.error),
                const SizedBox(height: AppDimensions.elementSpacing),
                ClayCard(
                  color: AppColors.error.withOpacity(0.05),
                  child: _buildSettingTile(context,
                      icon: Icons.delete_forever,
                      iconColor: AppColors.error,
                      title: 'Factory Reset',
                      subtitle: 'Delete all data and settings',
                      textColor: AppColors.error,
                      onTap: _confirmDataDeletion,
                      onChanged: (e) {}),
                ),
                const SizedBox(height: AppDimensions.sectionSpacing * 2),
                // Version
                Center(
                  child: Text(
                    'Version 1.0.0',
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: AppDimensions.iconMedium,
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
              color: textColor?.withOpacity(0.5) ?? theme.colorScheme.onSurface.withOpacity(0.4),
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
