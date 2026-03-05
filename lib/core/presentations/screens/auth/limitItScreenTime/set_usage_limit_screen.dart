import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_slider.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:go_router/go_router.dart';

class SetUsageLimitScreen extends StatefulWidget {
  final List<SelectedAppInfo>? selectedApps;
  final List<String>? selectedDays;

  const SetUsageLimitScreen({
    super.key,
    this.selectedApps,
    this.selectedDays,
  });

  @override
  State<SetUsageLimitScreen> createState() => _SetUsageLimitScreenState();
}

class _SetUsageLimitScreenState extends State<SetUsageLimitScreen> {
  double totalScreenTime = 120;
  Map<String, String> appOpens = {}; // packageName -> opens value
  Map<String, String> appDurations = {}; // packageName -> duration value
  bool _isSaving = false;

  final List<String> opensList = ['1 Time', '3 Times', '5 Times', '10 Times', '15 Times', '20 Times'];
  final List<String> durationList = ['15 Mins', '30 Mins', '45 Mins', '60 Mins', '90 Mins', '120 Mins'];

  @override
  void initState() {
    super.initState();
    // Initialize limits for each selected app
    if (widget.selectedApps != null) {
      for (var app in widget.selectedApps!) {
        appOpens[app.packageName] = '5 Times';
        appDurations[app.packageName] = '30 Mins';
      }
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
            CustomText(text: context.l10n.setUsageLimit,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                CustomText(
                   text: context.l10n.totalDailyScreenTime,
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),
                /// ==================================> Slider ==============================>
                SizedBox(height: 20.h),
                CustomSoundSlider(),
                SizedBox(height: 20.h),

                /// =================== Dynamic App Sections ===================
                if (widget.selectedApps != null && widget.selectedApps!.isNotEmpty)
                  ...widget.selectedApps!.map((app) {
                    return Column(
                      children: [
                        _buildAppLimitSection(
                          icon: app.appIcon != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.memory(
                                    app.appIcon!,
                                    width: 32.w,
                                    height: 32.h,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(Icons.apps, size: 20.r),
                                ),
                          appName: app.appName,
                          packageName: app.packageName,
                          opensValue: appOpens[app.packageName] ?? '5 Times',
                          durationValue: appDurations[app.packageName] ?? '30 Mins',
                          onOpensChanged: (value) {
                            setState(() => appOpens[app.packageName] = value!);
                          },
                          onDurationChanged: (value) {
                            setState(() => appDurations[app.packageName] = value!);
                          },
                        ),
                        SizedBox(height: 30.h),
                      ],
                    );
                  })
                else
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: CustomText(
                        text: context.l10n.noAppsSelected,
                        fontsize: 14.sp,
                        color: Colors.grey,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                SizedBox(height: 18.h),
                CustomButton(
                  title: _isSaving ? context.l10n.saving : context.l10n.saveContinue,
                  onpress: _isSaving ? () {} : _saveAndContinue,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Save app limits to SharedPreferences and navigate
  Future<void> _saveAndContinue() async {
    if (widget.selectedApps == null || widget.selectedApps!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No apps to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save daily screen time
      final appLimitStorageService = Get.find<AppLimitStorageService>();
      await appLimitStorageService.saveDailyScreenTime(totalScreenTime.toInt());

      // Load existing app limits
      List<AppLimitModel> existingLimits = await appLimitStorageService.getAppLimits();

      // Create app limit models for new apps
      List<AppLimitModel> newAppLimits = [];

      for (var app in widget.selectedApps!) {
        final opensStr = appOpens[app.packageName] ?? '5 Times';
        final durationStr = appDurations[app.packageName] ?? '30 Mins';

        // Parse opens (e.g., "5 Times" -> 5)
        final int maxOpens = int.tryParse(opensStr.split(' ').first) ?? 5;

        // Parse duration (e.g., "30 Mins" -> 30)
        final int maxDuration = int.tryParse(durationStr.split(' ').first) ?? 30;

        newAppLimits.add(AppLimitModel(
          packageName: app.packageName,
          appName: app.appName,
          appIcon: app.appIcon,
          maxDailyOpens: maxOpens,
          maxSessionDurationMinutes: maxDuration,
          activeDays: widget.selectedDays ?? [],
        ));
      }

      // Remove duplicates from existing limits (if user is re-adding an app)
      existingLimits.removeWhere((existing) =>
          newAppLimits.any((newLimit) => newLimit.packageName == existing.packageName));

      // Combine existing and new limits
      final allLimits = [...existingLimits, ...newAppLimits];

      // Save combined app limits
      final saved = await appLimitStorageService.saveAppLimits(allLimits);

      if (saved) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved limits for ${newAppLimits.length} apps'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to timer settings screen with origin information
        context.pushNamed(AppRoutes.timerSettingsScreen, extra: {'origin': 'setUsage'});
      } else {
        throw Exception('Failed to save app limits');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving limits: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildAppLimitSection({
    required Widget icon,
    required String appName,
    required String packageName,
    required String opensValue,
    required String durationValue,
    required ValueChanged<String?> onOpensChanged,
    required ValueChanged<String?> onDurationChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon,
            SizedBox(width: 12.w),
            CustomText(
              text: appName,
              fontsize: 20.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        CustomText(
          text: context.l10n.dailyOpensLimit,
          fontsize: 16.sp,
          color: AppColors.textColor3D3D3D,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildDropdown(opensValue, opensList, onOpensChanged),
        SizedBox(height: 16.h),
        CustomText(
          text: context.l10n.sessionDuration,
          fontsize: 16.sp,
          color: AppColors.textColor3D3D3D,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 8.h),
        _buildDropdown(durationValue, durationList, onDurationChanged),
      ],
    );
  }

  Widget _buildDropdown(
      String selectedValue,
      List<String> items,
      ValueChanged<String?> onChanged,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderColorD1D1D1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
          items: items
              .map((value) => DropdownMenuItem(
            value: value,
            child: CustomText(text: value),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

}
