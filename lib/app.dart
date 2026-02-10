// lib/app.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cycle_models.dart';
import 'screens/home/home_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/storage/storage_service.dart';
import 'theme/app_theme.dart';

class FlowyApp extends StatelessWidget {
  const FlowyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Options>>(
      valueListenable: Hive.box<Options>('options').listenable(),
      builder: (context, box, _) {
        final isDarkMode = box.get('theme')?.darkMode ?? false;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        
        return AnimatedTheme(
          data: theme,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: MaterialApp(
            title: 'Flowy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/insights': (context) {
                final stats = ModalRoute.of(context)!.settings.arguments 
                    as Map<String, dynamic>? ?? {};
                return InsightsScreen(stats: stats);
              },
              '/settings': (context) => const SettingsScreen(),
            },
          ),
        );
      },
    );
  }
}
