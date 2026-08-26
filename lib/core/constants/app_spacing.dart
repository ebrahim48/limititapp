import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ============================================================
///  LimitIt Design System — Spacing & Radius (4px base grid)
/// ============================================================
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;   // icon gap, tight spacing
  static double get sm => 8.w;   // element padding, chip gap
  static double get md => 12.w;  // card inner padding
  static double get lg => 16.w;  // card padding
  static double get xl => 20.w;  // screen horizontal padding
  static double get xxl => 24.w; // standard section gap
  static double get xxxl => 32.w;
  static double get huge => 40.w;

  /// Screen horizontal padding
  static double get screenH => 20.w;

  /// Screen top padding under the app bar
  static double get screenTop => 16.h;

  /// Gap between two sections
  static double get section => 24.h;

  /// Bottom padding so content clears the CTA / nav bar
  static double get bottomSafe => 24.h;

  static EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: screenH);

  static EdgeInsets get cardPadding => EdgeInsets.all(16.w);
}

class AppRadius {
  AppRadius._();

  static double get sm => 8.r;
  static double get md => 12.r;
  static double get card => 14.r;   // cards, surfaces
  static double get button => 14.r; // buttons
  static double get lg => 16.r;
  static double get xl => 20.r;
  static double get pill => 999.r;  // badges, chips, toggles

  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}
