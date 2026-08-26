import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';
import '../../../constants/app_text_styles.dart';

enum AppButtonVariant {
  /// Dark forest green fill — main screen CTA
  primary,

  /// Leaf green fill — brand / secondary emphasis
  brand,

  /// White fill + haze border — "Cancel"
  outline,

  /// Alert red fill — "Delete", "Yes, log out"
  destructive,

  /// White fill + red border + red label — "Yes, cancel subscription"
  destructiveOutline,

  /// Deep blue fill — "Restore" backup action
  info,
}

/// Design-system button. Height 54, radius 14, Inter Bold 15.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.enabled = true,
    this.height,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool loading;
  final bool enabled;
  final double? height;
  final bool expand;

  bool get _interactive => enabled && !loading && onPressed != null;

  Color get _bg {
    if (!enabled) return AppColors.haze;
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.forestGreen;
      case AppButtonVariant.brand:
        return AppColors.leafGreen;
      case AppButtonVariant.outline:
      case AppButtonVariant.destructiveOutline:
        return AppColors.white;
      case AppButtonVariant.destructive:
        return AppColors.alertRed;
      case AppButtonVariant.info:
        return AppColors.infoBlue;
    }
  }

  Color get _fg {
    if (!enabled) return AppColors.mist;
    switch (variant) {
      case AppButtonVariant.outline:
        return AppColors.ink;
      case AppButtonVariant.destructiveOutline:
        return AppColors.alertRed;
      default:
        return AppColors.white;
    }
  }

  Color? get _borderColor {
    switch (variant) {
      case AppButtonVariant.outline:
        return AppColors.haze;
      case AppButtonVariant.destructiveOutline:
        return AppColors.alertRed.withValues(alpha: 0.45);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = _borderColor;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height ?? 54.h,
      child: Material(
        color: _bg,
        borderRadius: AppRadius.buttonRadius,
        clipBehavior: Clip.antiAlias,
        shape: border != null
            ? RoundedRectangleBorder(
                borderRadius: AppRadius.buttonRadius,
                side: BorderSide(color: border),
              )
            : null,
        child: InkWell(
          onTap: _interactive ? onPressed : null,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(_fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        SizedBox(width: 10.w),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.button(color: _fg),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// White pill button with a leading brand logo — "Continue with Apple/Google".
class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.dark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget icon;

  /// `true` renders the black Apple style, `false` the white Google style.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: Material(
        color: dark ? AppColors.ink : AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonRadius,
          side: BorderSide(
            color: dark ? AppColors.ink : AppColors.haze,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 10.w),
              Text(
                label,
                style: AppTextStyles.button(
                  color: dark ? AppColors.white : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borderless text link — "Forgot password?", "Restore purchases".
class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.style,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style ??
              AppTextStyles.small(color: color ?? AppColors.slateGreen),
        ),
      ),
    );
  }
}
