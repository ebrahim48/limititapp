import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/stats_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import '../../widgets/ui/ui.dart';

/// Today's per-app screen time — "In use" (only protected apps) or
/// "Most used" (everything on the device).
class AppUsageScreen extends StatefulWidget {
  const AppUsageScreen({super.key});

  @override
  State<AppUsageScreen> createState() => _AppUsageScreenState();
}

class _AppUsageScreenState extends State<AppUsageScreen> {
  final StatsController _stats = Get.put(StatsController());

  int _tabIndex = 0;
  Set<String> _protectedPackages = {};

  @override
  void initState() {
    super.initState();
    _loadProtected();
  }

  Future<void> _loadProtected() async {
    final limits = await AppLimitStorageService.instance.getAppLimits();
    if (mounted) {
      setState(() =>
          _protectedPackages = limits.map((l) => l.packageName).toSet());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.appUsage),
      body: Obx(() {
        final all = _stats.todayUsage;
        final rows = _tabIndex == 0
            ? all.where((u) => _protectedPackages.contains(u.packageName)).toList()
            : all;
        final max = rows.isEmpty ? 0 : rows.first.usageTimeMs;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            AppSegmentedTabs(
              segments: [l10n.inUse, l10n.mostUsed],
              selectedIndex: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
            SizedBox(height: 20.h),

            AppSoftCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalScreenTime,
                    style: AppTextStyles.label(color: AppColors.fern),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    StatsController.formatMinutes(_stats.screenTimeMinutes.value),
                    style: AppTextStyles.display(color: AppColors.forestGreen),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            if (rows.isEmpty)
              AppCard(
                padding: EdgeInsets.symmetric(vertical: 28.h),
                child: Center(
                  child: Text(
                    l10n.noUsageYet,
                    style: AppTextStyles.body(color: AppColors.mist),
                  ),
                ),
              )
            else
              AppCard(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Column(
                  children: [
                    for (final row in rows)
                      AppUsageRow(
                        icon: AppLogoTile(
                          packageName: row.packageName,
                          appName: row.name,
                          preloadedIcon: row.icon,
                          size: 32.w,
                        ),
                        name: row.name,
                        value: row.usageString,
                        fraction: max == 0 ? 0 : row.usageTimeMs / max,
                      ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }
}
