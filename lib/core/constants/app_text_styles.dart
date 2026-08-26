import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// ============================================================
///  LimitIt Design System — Typography
///  Typeface: Inter (Regular 400 / Medium 500 / SemiBold 600 /
///            Bold 700 / ExtraBold 800)
/// ============================================================
class AppFont {
  AppFont._();
  static const String family = 'Inter';

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: AppFont.family,
      fontSize: size.sp,
      fontWeight: weight,
      height: lineHeight / size,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.ink,
    );
  }

  /// 32 / 40 · ExtraBold — big stat numbers ("21h 45m")
  static TextStyle display({Color? color}) =>
      _base(size: 32, weight: AppFont.extraBold, lineHeight: 40, color: color);

  /// 28 / 34 · Bold — screen headings ("Statistics")
  static TextStyle h1({Color? color}) =>
      _base(size: 28, weight: AppFont.bold, lineHeight: 34, color: color);

  /// 22 / 28 · Bold — section headings ("App Usage")
  static TextStyle h2({Color? color}) =>
      _base(size: 22, weight: AppFont.bold, lineHeight: 28, color: color);

  /// 18 / 24 · SemiBold — card titles, nav titles ("Time Saved")
  static TextStyle h3({Color? color}) =>
      _base(size: 18, weight: AppFont.semiBold, lineHeight: 24, color: color);

  /// 16 / 22 · SemiBold — list headers, row titles
  static TextStyle h4({Color? color}) =>
      _base(size: 16, weight: AppFont.semiBold, lineHeight: 22, color: color);

  /// 15 / 22 · Regular — primary body copy
  static TextStyle body({Color? color}) =>
      _base(size: 15, weight: AppFont.regular, lineHeight: 22, color: color);

  /// 15 / 22 · Medium — interactive list items
  static TextStyle bodyMedium({Color? color}) =>
      _base(size: 15, weight: AppFont.medium, lineHeight: 22, color: color);

  /// 13 / 18 · Regular — secondary descriptions
  static TextStyle small({Color? color}) => _base(
        size: 13,
        weight: AppFont.regular,
        lineHeight: 18,
        color: color ?? AppColors.slateGreen,
      );

  /// 13 / 18 · Medium — tab labels, stat labels
  static TextStyle label({Color? color}) => _base(
        size: 13,
        weight: AppFont.medium,
        lineHeight: 18,
        color: color ?? AppColors.slateGreen,
      );

  /// 12 / 16 · Regular — timestamps, footnotes
  static TextStyle caption({Color? color}) => _base(
        size: 12,
        weight: AppFont.regular,
        lineHeight: 16,
        color: color ?? AppColors.mist,
      );

  /// 11 / 14 · SemiBold · +0.8 tracking — UPPERCASE section dividers
  static TextStyle overline({Color? color}) => _base(
        size: 11,
        weight: AppFont.semiBold,
        lineHeight: 14,
        letterSpacing: 0.8,
        color: color ?? AppColors.mist,
      );

  /// 10 / 13 · Regular — chart labels, axis ticks
  static TextStyle micro({Color? color}) => _base(
        size: 10,
        weight: AppFont.regular,
        lineHeight: 13,
        color: color ?? AppColors.mist,
      );

  /// 15 / 20 · Bold — button label
  static TextStyle button({Color? color}) => _base(
        size: 15,
        weight: AppFont.bold,
        lineHeight: 20,
        color: color ?? AppColors.white,
      );
}
