import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../global/custom_assets/assets.gen.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import 'app_icons.dart';

/// The four tab destinations of the redesigned app.
enum AppTab { home, statistics, premium, settings }

class AppTabItem {
  const AppTabItem({
    required this.tab,
    required this.label,
    required this.icon,
    this.activeColor,
  });

  final AppTab tab;
  final String label;
  final SvgGenImage icon;

  /// Premium tab keeps its gold accent when selected.
  final Color? activeColor;
}

List<AppTabItem> get kAppTabs => [
      AppTabItem(
        tab: AppTab.home,
        label: 'Home',
        icon: Assets.icons.ui.home,
      ),
      AppTabItem(
        tab: AppTab.statistics,
        label: 'Statistics',
        icon: Assets.icons.ui.barChart,
      ),
      AppTabItem(
        tab: AppTab.premium,
        label: 'Premium',
        icon: Assets.icons.ui.crown,
        activeColor: AppColors.gold,
      ),
      AppTabItem(
        tab: AppTab.settings,
        label: 'Settings',
        icon: Assets.icons.ui.sun,
      ),
    ];

/// White bottom bar with a hairline top border, four tabs, and a 2px
/// indicator under the active item.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppTabItem>? items;

  @override
  Widget build(BuildContext context) {
    final tabs = items ?? kAppTabs;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.haze)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62.h,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final item = tabs[i];
              final active = i == currentIndex;
              final color = active
                  ? (item.activeColor ?? AppColors.forestGreen)
                  : AppColors.mist;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(item.icon, size: 22.w, color: color),
                      SizedBox(height: 5.h),
                      Text(
                        item.label,
                        style: AppTextStyles.micro(color: color).copyWith(
                          fontWeight:
                              active ? AppFont.semiBold : AppFont.regular,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: 16.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: active ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
