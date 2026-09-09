import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/presentations/widgets/limit_screen_time_card.dart';

class LimitScreenTime extends StatefulWidget {
  const LimitScreenTime({super.key});

  @override
  State<LimitScreenTime> createState() => _LimitScreenTimeState();
}

class _LimitScreenTimeState extends State<LimitScreenTime> {
  List<AppLimitWithUsage> _appLimitsWithUsage = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppLimits();
  }

  Future<void> _loadAppLimits() async {
    setState(() => _isLoading = true);

    try {
      // Load saved app limits
      final appLimits = await AppLimitStorageService.instance.getAppLimits();

      // Get usage data for each app
      final allUsageData = await AppUsageService.instance.getAllInstalledApps();
      final usageMap = {for (var data in allUsageData) data.packageName: data};

      // Combine limit and usage data
      final combined = appLimits.map((limit) {
        final usage = usageMap[limit.packageName];
        return AppLimitWithUsage(
          limit: limit,
          usageData: usage,
        );
      }).toList();

      setState(() {
        _appLimitsWithUsage = combined;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading app limits: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAppLimit(String packageName, String appName) async {
    final success = await AppLimitStorageService.instance.deleteAppLimit(packageName);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.limitDeletedForApp(appName))),
      );
      // Reload the list
      _loadAppLimits();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failedToDeleteLimit)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: context.l10n.screenTime,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  if (_appLimitsWithUsage.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: CustomText(
                          text: context.l10n.noScreenTimeLimits,
                          fontsize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ..._appLimitsWithUsage.map((data) => LimitScreenTimeCard(
                          data: data,
                          onDelete: () => _deleteAppLimit(
                            data.limit.packageName,
                            data.limit.appName,
                          ),
                        )),
                  SizedBox(height: 32.h),
                  CustomButton(
                    title: context.l10n.addNewScreenTime,
                    onpress: () async {
                      await context.pushNamed(AppRoutes.selectAppsManageScreen);
                      // Reload data when returning from add screen
                      _loadAppLimits();
                    },
                  ),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
    );
  }
}

/// Model to hold app limit and its usage data together
class AppLimitWithUsage {
  final AppLimitModel limit;
  final AppUsageData? usageData;

  AppLimitWithUsage({
    required this.limit,
    this.usageData,
  });
}
