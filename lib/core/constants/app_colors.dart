import 'package:flutter/material.dart';

/// ============================================================
///  LimitIt Design System — Color Palette
///  (Figma: "LimitIt UI Kit" → Color Palette section)
///
///  NOTE: jodi kono hex UI kit er sathe na mile, sudhu ei file er
///  value ta change korun — puro app e automatically apply hobe.
/// ============================================================
class AppColors {
  AppColors._();

  /// ---------------- GREENS ----------------
  /// Headers, primary actions, active nav
  static const Color forestGreen = Color(0xFF2C5E1A);

  /// CTA buttons, highlights, progress
  static const Color leafGreen = Color(0xFF5FA330);

  /// Backgrounds, chips, subtle fills
  static const Color mint = Color(0xFFEAF4E1);

  /// Body text on green backgrounds
  static const Color fern = Color(0xFF3E7B25);

  /// ---------------- NEUTRALS ----------------
  /// Primary text, headings
  static const Color ink = Color(0xFF1A1A1A);

  /// Secondary text, labels
  static const Color slateGreen = Color(0xFF5A6B55);

  /// Placeholders, dividers, captions
  static const Color mist = Color(0xFF9AA79A);

  /// Card backgrounds, button text
  static const Color white = Color(0xFFFFFFFF);

  /// Page background
  static const Color fog = Color(0xFFF7F8F6);

  /// Card borders, dividers
  static const Color haze = Color(0xFFE6E9E4);

  /// ---------------- ACCENTS ----------------
  /// Premium badge, crown accent
  static const Color gold = Color(0xFFF2C230);

  /// Destructive actions, error states
  static const Color alertRed = Color(0xFFE8443A);

  /// Soft red surface (delete / cancel info cards)
  static const Color alertRedSoft = Color(0xFFFDECEB);

  /// Info blue (Blocked opens tile, Restore button)
  static const Color infoBlue = Color(0xFF2F4FA8);
  static const Color infoBlueSoft = Color(0xFFEDF2FD);

  /// Warm surface (Streak tile)
  static const Color warmSoft = Color(0xFFFFF6E0);
  static const Color warmText = Color(0xFF8A5A00);

  /// ---------------- GRADIENT ----------------
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreen, leafGreen],
  );

  /// ---------------- SEMANTIC ALIASES ----------------
  static const Color scaffoldBg = white;
  static const Color primary = forestGreen;
  static const Color accent = leafGreen;
  static const Color textPrimary = ink;
  static const Color textSecondary = slateGreen;
  static const Color textMuted = mist;
  static const Color border = haze;
  static const Color surface = white;
  static const Color surfaceSoft = mint;

  /// ============================================================
  ///  LEGACY TOKENS — purano screen gulo compile rakhar jonno.
  ///  Notun UI er sathe map kora hoyeche. Notun code e use korben na.
  /// ============================================================
  @Deprecated('Use AppColors.scaffoldBg')
  static const Color backGroundColor = white;
  @Deprecated('Use AppColors.forestGreen')
  static const Color primaryColor = forestGreen;
  @Deprecated('Use AppColors.leafGreen')
  static const Color primaryColor4C956C = leafGreen;
  @Deprecated('Use AppColors.forestGreen')
  static const Color primaryColor214432 = forestGreen;
  @Deprecated('Use AppColors.fern')
  static const Color primaryColor526E4B = fern;
  @Deprecated('Use AppColors.leafGreen')
  static const Color primaryGreen = leafGreen;
  @Deprecated('Use AppColors.slateGreen')
  static const Color textColor5D5D5D = slateGreen;
  @Deprecated('Use AppColors.ink')
  static const Color textColor3D3D3D = ink;
  @Deprecated('Use AppColors.haze')
  static const Color borderColorD1D1D1 = haze;
  @Deprecated('Use AppColors.warmText')
  static const Color textColor803D20 = warmText;
  @Deprecated('Use AppColors.slateGreen')
  static const Color textColor6D6D6D = slateGreen;
  @Deprecated('Use AppColors.haze')
  static const Color borderColor = haze;
  @Deprecated('Use AppColors.white')
  static const Color textColorF6F6F6 = white;
  @Deprecated('Use AppColors.ink')
  static const Color textColor1A1A1A = ink;
  @Deprecated('Use AppColors.ink')
  static const Color textColor2C2C2C = ink;
  @Deprecated('Use AppColors.slateGreen')
  static const Color textColor454545 = slateGreen;
  @Deprecated('Use AppColors.white')
  static const Color textColorFFFFFF = white;
  @Deprecated('Use AppColors.alertRed')
  static const Color textColorA70D0D = alertRed;
  @Deprecated('Use AppColors.haze')
  static const Color textColorE7E7E7 = haze;
  @Deprecated('Use AppColors.gold')
  static const Color textColorDDA742 = gold;
  @Deprecated('Use AppColors.mist')
  static const Color textColor888888 = mist;
}
