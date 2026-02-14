import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/dimensions.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primarySwatch: _createMaterialColor(AppColors.primary),
      fontFamily: 'Nunito',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
            color: AppColors.primary, size: AppDimensions.iconMedium),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppDimensions.fontXXL,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: BorderSide(
            color: AppColors.clayShadow.withOpacity(0.5),
            width: AppDimensions.borderThin,
          ),
        ),
        color: AppColors.cardLight,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppDimensions.cardElevationClay,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.cardPadding,
            vertical: AppDimensions.elementSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.fontLarge,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primaryLight, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.cardPadding,
            vertical: AppDimensions.elementSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.elementSpacing,
            vertical: AppDimensions.smallSpacing,
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppDimensions.cardElevationClay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.elementSpacing,
          vertical: AppDimensions.elementSpacing,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.clayShadow.withOpacity(0.3),
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: AppColors.textMuted.withOpacity(0.6),
          fontSize: AppDimensions.fontMedium,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
        labelStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppDimensions.fontMedium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.elementSpacing,
          vertical: AppDimensions.smallSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.clayShadow,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.clayShadow;
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppDimensions.radiusLarge),
            bottomRight: Radius.circular(AppDimensions.radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.cardLight,
        elevation: AppDimensions.cardElevation,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.fontDisplay,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontSize: AppDimensions.fontTitle,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: AppDimensions.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.fontLarge,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.fontMedium,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.fontSmall,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.fontLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primarySwatch: _createMaterialColor(AppColors.primary),
      fontFamily: 'Nunito',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.cardDark,
        surfaceContainerHighest: AppColors.cardDark,
        background: AppColors.backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onSurfaceVariant: Colors.white70,
        onBackground: Colors.white,
        outline: Colors.white24,
        outlineVariant: Colors.white12,
        shadow: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.primaryLight),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: AppDimensions.fontXXL,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: AppDimensions.borderThin,
          ),
        ),
        color: AppColors.cardDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: AppDimensions.cardElevationClay,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.cardPadding,
            vertical: AppDimensions.elementSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.elementSpacing,
          vertical: AppDimensions.elementSpacing,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: AppDimensions.fontMedium,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.fontDisplay,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -1,
        ),
        titleLarge: TextStyle(
          fontSize: AppDimensions.fontTitle,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: AppDimensions.fontXXL,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.fontLarge,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.fontMedium,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.fontSmall,
          color: Colors.white60,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.fontLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
