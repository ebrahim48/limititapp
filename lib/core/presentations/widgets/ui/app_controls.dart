import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';
import '../../../constants/app_text_styles.dart';
import 'app_surfaces.dart';

/// Small pill label — "Premium", "Active", "Save 33%", "Time block".
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final Widget? icon;
  final bool dense;

  /// Gold "Premium" badge with a crown.
  factory AppBadge.premium({String label = 'Premium', Widget? icon}) =>
      AppBadge(
        label: label,
        background: AppColors.gold,
        foreground: AppColors.warmText,
        icon: icon,
      );

  /// Mint "Active" / "Time block" chip.
  factory AppBadge.mint(String label) => AppBadge(
        label: label,
        background: AppColors.mint,
        foreground: AppColors.fern,
      );

  /// Solid leaf-green chip — "Save 33%" on a selected tab.
  factory AppBadge.leaf(String label) => AppBadge(
        label: label,
        background: AppColors.leafGreen,
        foreground: AppColors.white,
        dense: true,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8.w : 10.w,
        vertical: dense ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: background ?? AppColors.mint,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: AppTextStyles.caption(
              color: foreground ?? AppColors.fern,
            ).copyWith(fontWeight: AppFont.semiBold),
          ),
        ],
      ),
    );
  }
}

/// Two/three-way segmented switcher — "Week | Month", "Monthly | Yearly",
/// "In use | Most used". Active segment = forest green pill.
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.trailingBadges,
    this.height,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// Optional per-segment badge (e.g. "Save 33%" on the Yearly tab).
  final List<String?>? trailingBadges;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 48.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.fog,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: List.generate(segments.length, (i) {
          final active = i == selectedIndex;
          final badge = trailingBadges != null && i < trailingBadges!.length
              ? trailingBadges![i]
              : null;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: active ? AppColors.forestGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        segments[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label(
                          color: active ? AppColors.white : AppColors.slateGreen,
                        ).copyWith(fontWeight: AppFont.semiBold),
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: 6.w),
                      AppBadge(
                        label: badge,
                        dense: true,
                        background:
                            active ? AppColors.leafGreen : AppColors.gold,
                        foreground:
                            active ? AppColors.white : AppColors.warmText,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Bordered option row that shows a green check when selected —
/// "Every day / Weekdays / Weekends / Custom", plan cards, suggestions.
class AppSelectableTile extends StatelessWidget {
  const AppSelectableTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding,
    this.trailing,
    this.showCheck = true,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: selected ? AppColors.mint : AppColors.white,
      borderColor: selected ? AppColors.leafGreen : AppColors.haze,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(child: child),
          if (trailing != null)
            trailing!
          else if (showCheck && selected)
            Icon(
              Icons.check_circle_rounded,
              size: 22.sp,
              color: AppColors.leafGreen,
            ),
        ],
      ),
    );
  }
}

/// Square weekday chip — S M T W T F S.
class AppDayChip extends StatelessWidget {
  const AppDayChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.size,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = size ?? 42.w;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: s,
        height: s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.leafGreen : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? AppColors.leafGreen : AppColors.haze,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(
            color: selected ? AppColors.white : AppColors.slateGreen,
          ).copyWith(fontWeight: AppFont.semiBold),
        ),
      ),
    );
  }
}

/// Icon + title + subtitle + switch, inside a card — the Reminders rows.
class AppToggleRow extends StatelessWidget {
  const AppToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                Text(title, style: AppTextStyles.h4()),
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
          SizedBox(width: 8.w),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.leafGreen,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: AppColors.haze,
          ),
        ],
      ),
    );
  }
}
