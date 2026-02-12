// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cycle_models.dart';
import 'screens/home/home_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/help_faq_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/feedback_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/app_wrapper.dart';
import 'services/storage/storage_service.dart';
import 'services/localization/app_localizations.dart';
import 'services/localization/language_service.dart';
import 'theme/app_theme.dart';

class FloiiApp extends StatefulWidget {
  const FloiiApp({super.key});

  @override
  State<FloiiApp> createState() => _FloiiAppState();
}

class _FloiiAppState extends State<FloiiApp> {
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _languageService.init();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Options>>(
      valueListenable: Hive.box<Options>('options').listenable(),
      builder: (context, box, _) {
        final isDarkMode = box.get('theme')?.darkMode ?? true;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        return AnimatedTheme(
          data: theme,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: MaterialApp(
            key: ValueKey(_languageService.currentLocale.languageCode),
            title: 'Floii',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: _languageService.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('ur'),
              Locale('id'),
              Locale('de'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: _languageService.isRtl()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const AppWrapper(),
              '/home': (context) => const HomeScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/insights': (context) {
                final stats = ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return InsightsScreen(stats: stats);
              },
              '/settings': (context) => const SettingsScreen(),
              '/help-faq': (context) => const HelpFaqScreen(),
              '/about': (context) => const AboutScreen(),
              '/feedback': (context) => const FeedbackScreen(),
            },
          ),
        );
      },
    );
  }
}
