import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';
import '../../../constants/app_text_styles.dart';

/// White card with a 1px haze border and 14px radius — the app's default surface.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius ?? AppRadius.card);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: br,
        border: Border.all(color: borderColor ?? AppColors.haze),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tinted, borderless surface — mint info panels, quote blocks, callouts.
class AppSoftCard extends StatelessWidget {
  const AppSoftCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.onTap,
    this.radius,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color ?? AppColors.mint,
      borderColor: Colors.transparent,
      padding: padding,
      margin: margin,
      onTap: onTap,
      radius: radius,
      child: child,
    );
  }
}

/// Uppercase divider label — "MORE OPTIONS", "SAVED BY APP", "OPTIONS".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color, this.padding});

  final String text;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: 8.h),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.overline(color: color),
      ),
    );
  }
}

/// A group of rows rendered as one bordered card with hairline dividers,
/// like the Settings and "More options" lists.
class AppCardList extends StatelessWidget {
  const AppCardList({
    super.key,
    required this.children,
    this.margin,
    this.dividerIndent,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final double? dividerIndent;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(
          height: 1,
          thickness: 1,
          color: AppColors.haze,
          indent: dividerIndent ?? 0,
        ));
      }
    }

    return AppCard(
      margin: margin,
      padding: EdgeInsets.zero,
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// Row with an optional leading icon, a title, an optional subtitle and a
/// trailing chevron — Settings rows, "Customize message", "Change plan".
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showChevron = true,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showChevron;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium(
                        color: titleColor ?? AppColors.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: AppTextStyles.small(color: AppColors.mist),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (trailing == null && showChevron) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.mist,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded square that holds a small icon inside a list row.
class AppIconBox extends StatelessWidget {
  const AppIconBox({
    super.key,
    required this.child,
    this.background,
    this.size,
    this.radius,
  });

  final Widget child;
  final Color? background;
  final double? size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 36.w;
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.mint,
        borderRadius: BorderRadius.circular(radius ?? 10.r),
      ),
      child: child,
    );
  }
}
