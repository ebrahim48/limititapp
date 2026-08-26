import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

/// ============================================================
///  LimitIt Design System — App Theme
///  Background: #FFFFFF · Typeface: Inter
/// ============================================================
class Themes {
  ThemeData get lightTheme => _build();

  /// App e dark mode nei — light theme e alias kora hoyeche.
  ThemeData get darkTheme => _build();

  static ThemeData _build() {
    final base = ThemeData.light();

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      canvasColor: AppColors.scaffoldBg,
      primaryColor: AppColors.forestGreen,
      splashFactory: InkRipple.splashFactory,
      dividerColor: AppColors.haze,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.forestGreen,
        onPrimary: AppColors.white,
        secondary: AppColors.leafGreen,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.ink,
        error: AppColors.alertRed,
        onError: AppColors.white,
      ),

      textTheme: base.textTheme
          .apply(
            fontFamily: AppFont.family,
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          )
          .copyWith(
            titleLarge: AppTextStyles.h2(),
            titleMedium: AppTextStyles.h3(),
            titleSmall: AppTextStyles.h4(),
            bodyLarge: AppTextStyles.body(),
            bodyMedium: AppTextStyles.body(),
            bodySmall: AppTextStyles.small(),
            labelLarge: AppTextStyles.label(),
          ),

      /// ----------------- App bar -----------------
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldBg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
        titleTextStyle: AppTextStyles.h3(),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      /// ----------------- Buttons -----------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.haze,
          disabledForegroundColor: AppColors.mist,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.button(),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forestGreen,
          textStyle: AppTextStyles.bodyMedium(),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 54),
          side: const BorderSide(color: AppColors.haze),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: AppTextStyles.button(color: AppColors.ink),
        ),
      ),

      /// ----------------- Inputs -----------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.body(color: AppColors.mist),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(AppColors.haze),
        enabledBorder: _inputBorder(AppColors.haze),
        focusedBorder: _inputBorder(AppColors.leafGreen),
        errorBorder: _inputBorder(AppColors.alertRed),
        focusedErrorBorder: _inputBorder(AppColors.alertRed),
      ),

      /// ----------------- Surfaces -----------------
      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: const BorderSide(color: AppColors.haze),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.haze,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.h3(),
        contentTextStyle: AppTextStyles.body(color: AppColors.slateGreen),
      ),

      /// ----------------- Controls -----------------
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.leafGreen
              : AppColors.haze,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.leafGreen,
        linearTrackColor: AppColors.mint,
        circularTrackColor: AppColors.mint,
      ),

      iconTheme: const IconThemeData(color: AppColors.ink, size: 22),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.mist,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.micro(color: AppColors.forestGreen),
        unselectedLabelStyle: AppTextStyles.micro(color: AppColors.mist),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );
}
