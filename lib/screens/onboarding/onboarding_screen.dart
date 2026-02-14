import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/cycle_models.dart';
import '../../services/localization/app_localizations.dart';
import '../../services/localization/language_service.dart';
import '../../utils/constants/colors.dart';
import '../../utils/constants/dimensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final LanguageService _languageService = LanguageService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentPage = 0;
  String _selectedLanguage = 'en';
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
    _selectedLanguage = _languageService.currentLocale.languageCode;
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box<Options>('options');
    final options = box.get('theme');
    if (mounted) {
      setState(() {
        _isDarkMode = options?.darkMode ?? true;
      });
    }
  }

  Future<void> _toggleTheme() async {
    final box = Hive.box<Options>('options');
    final currentOptions = box.get('theme') ?? Options(darkMode: true);
    final newOptions = Options(darkMode: !currentOptions.darkMode);
    await box.put('theme', newOptions);

    if (mounted) {
      setState(() {
        _isDarkMode = newOptions.darkMode;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _showLanguageModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LanguageSelectionModal(
        selectedLanguage: _selectedLanguage,
        isDarkMode: _isDarkMode,
        onLanguageSelected: (code) {
          setState(() {
            _selectedLanguage = code;
          });
          _languageService.setLanguage(code);
          Navigator.pop(context);
        },
      ),
    );
  }

  Color get _backgroundColor =>
      _isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get _textColor => _isDarkMode ? Colors.white : AppColors.textPrimary;
  Color get _textSecondaryColor =>
      _isDarkMode ? Colors.white70 : AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: _isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
                onPressed: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              )
            : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _showLanguageModal,
              icon: Icon(
                Icons.language,
                color: _isDarkMode ? Colors.white70 : AppColors.primary,
                size: 20,
              ),
              label: Text(
                _selectedLanguage.toUpperCase(),
                style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildWelcomePage(context, size),
                  _buildFeaturesPage(context, size),
                  _buildReadyPage(context, size),
                ],
              ),
            ),
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: WormEffect(
                      dotWidth: 100,
                      dotHeight: 05,
                      spacing: 10,
                      dotColor: _isDarkMode
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.2),
                      activeDotColor: AppColors.primary,
                    ),
                  ),
                  if (_currentPage < 2)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        key: const ValueKey('skip_button'),
                        onPressed: _completeOnboarding,
                        child: Text(
                          AppLocalizations.of(context)?.translate('skip') ??
                              'Skip',
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.white70
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 48,
                    ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == 2
                          ? (AppLocalizations.of(context)
                                  ?.translate('getStarted') ??
                              'Get Started')
                          : (AppLocalizations.of(context)?.translate('next') ??
                              'Next'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.elementSpacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(BuildContext context, Size screenSize) {
    final localizations = AppLocalizations.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constr) => ListView(
            children: [
              Container(
                constraints: BoxConstraints(minHeight: constr.maxHeight),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.period
                                      .withOpacity(_isDarkMode ? 0.4 : 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'lib/icons/icon-512.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          localizations?.translate('appName') ?? 'Floii',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.smallSpacing),
                      Text(
                        localizations?.translate('appTagline') ??
                            'Track your cycle with ease',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.sectionSpacing),
                      Container(
                        padding:
                            const EdgeInsets.all(AppDimensions.cardPadding),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : AppColors.primary.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLarge),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.1),
                            width: 0,
                          ),
                        ),
                        child: Text(
                          localizations?.translate('onboardingWelcomeDesc') ??
                              'Your personal companion for understanding and tracking your menstrual cycle with precision and care.',
                          style: TextStyle(
                            height: 1.6,
                            color: _textColor,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesPage(BuildContext context, Size screenSize) {
    final localizations = AppLocalizations.of(context);

    final features = [
      {
        'icon': Icons.calendar_today,
        'color': AppColors.period,
        'title':
            localizations?.translate('featureTracking') ?? 'Smart Tracking',
        'desc': localizations?.translate('featureTrackingDesc') ??
            'Easily log your period dates and symptoms with just a tap',
      },
      {
        'icon': Icons.auto_awesome,
        'color': AppColors.ovulation,
        'title':
            localizations?.translate('featurePrediction') ?? 'AI Predictions',
        'desc': localizations?.translate('featurePredictionDesc') ??
            'Get accurate predictions for your next period and fertile window',
      },
      {
        'icon': Icons.insights,
        'color': AppColors.clayShadow,
        'title': localizations?.translate('featureInsights') ?? 'Deep Insights',
        'desc': localizations?.translate('featureInsightsDesc') ??
            'Understand your cycle phases and patterns with detailed analytics',
      },
      {
        'icon': Icons.privacy_tip,
        'color': AppColors.today,
        'title': localizations?.translate('featurePrivacy') ?? '100% Private',
        'desc': localizations?.translate('featurePrivacyDesc') ??
            'Your data stays on your device. No cloud, no tracking, complete privacy',
      },
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      localizations?.translate('keyFeatures') ?? 'Key Features',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    ...features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.elementSpacing),
                        child: Container(
                          padding: const EdgeInsets.all(
                              AppDimensions.elementSpacing),
                          decoration: BoxDecoration(
                            color: _isDarkMode
                                ? Colors.white.withOpacity(0.05)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: (feature['color'] as Color)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusMedium),
                                ),
                                child: Icon(
                                  feature['icon'] as IconData,
                                  color: feature['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(
                                  width: AppDimensions.elementSpacing),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feature['title'] as String,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: feature['color'] as Color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      feature['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyPage(BuildContext context, Size screenSize) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
      child: LayoutBuilder(
        builder: (conx, conr) => ListView(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: conr.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple
                                .withOpacity(_isDarkMode ? 0.4 : 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'lib/icons/icon-512.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing * 1.5),
                    Text(
                      localizations?.translate('allSet') ?? "You're All Set!",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _textColor,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.elementSpacing),
                    Text(
                      localizations?.translate('readyToStart') ??
                          'Start tracking your cycle and discover insights about your body.',
                      style: TextStyle(
                        color: _textSecondaryColor,
                        height: 1.6,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.cardPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.lilac.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLarge),
                      ),
                      child: Column(
                        children: [
                          _buildTipItem(
                              Icons.touch_app,
                              localizations?.translate('tip1') ??
                                  'Tap any date to mark your period'),
                          const SizedBox(height: AppDimensions.elementSpacing),
                          _buildTipItem(
                              Icons.notifications_active,
                              localizations?.translate('tip2') ??
                                  'Get predictions for your next cycle'),
                          const SizedBox(height: AppDimensions.elementSpacing),
                          _buildTipItem(
                              Icons.security,
                              localizations?.translate('tip3') ??
                                  'Your data is safe and private'),
                          const SizedBox(height: AppDimensions.elementSpacing),
                          _buildTipItem(
                              Icons.history,
                              localizations?.translate('tip4') ??
                                  'Add 2+ previous cycles for accurate predictions'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: AppDimensions.elementSpacing),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageSelectionModal extends StatelessWidget {
  final String selectedLanguage;
  final bool isDarkMode;
  final Function(String) onLanguageSelected;

  const _LanguageSelectionModal({
    required this.selectedLanguage,
    required this.isDarkMode,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    final bgColor =
        isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.elementSpacing),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPadding),
              child: Text(
                AppLocalizations.of(context)?.translate('chooseLanguage') ??
                    'Choose Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.screenPadding),
                itemCount: languageService.languages.length,
                itemBuilder: (context, index) {
                  final entry =
                      languageService.languages.entries.toList()[index];
                  final code = entry.key;
                  final name = entry.value['name']!;
                  final nativeName = entry.value['nativeName']!;
                  final isSelected = selectedLanguage == code;

                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.smallSpacing),
                    child: InkWell(
                      onTap: () => onLanguageSelected(code),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Container(
                        padding:
                            const EdgeInsets.all(AppDimensions.elementSpacing),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : (isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.shade50),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 2)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMedium),
                              ),
                              child: Center(
                                child: Text(
                                  code.toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        isSelected ? Colors.white : textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
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
                                    nativeName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primary
                                          : textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 28,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.elementSpacing),
          ],
        ),
      ),
    );
  }
}
