import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_slider.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';

class EditUsageLimitScreen extends StatefulWidget {
  final String? packageName; // Pass the package name to edit

  const EditUsageLimitScreen({super.key, this.packageName});

  @override
  State<EditUsageLimitScreen> createState() => _EditUsageLimitScreenState();
}

class _EditUsageLimitScreenState extends State<EditUsageLimitScreen> {
  late AppLimitModel _appLimit;
  double totalScreenTime = 120;
  String opensValue = '5 Times';
  String durationValue = '30 Mins';
  bool _isLoading = true;

  final List<String> opensList = ['1 Time', '3 Times', '5 Times', '10 Times', '15 Times', '20 Times'];
  final List<String> durationList = ['15 Mins', '30 Mins', '45 Mins', '60 Mins', '90 Mins', '120 Mins'];

  @override
  void initState() {
    super.initState();
    _loadAppLimit();
  }

  Future<void> _loadAppLimit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appLimitStorageService = Get.find<AppLimitStorageService>();
      final appLimits = await appLimitStorageService.getAppLimits();

      // Find the specific app limit to edit
      final appLimit = appLimits.firstWhere(
        (limit) => limit.packageName == widget.packageName,
        orElse: () => AppLimitModel(
          packageName: widget.packageName ?? 'unknown',
          appName: widget.packageName ?? appL10n.unknownApp, // Fallback to package name
          maxDailyOpens: 5,
          maxSessionDurationMinutes: 30,
          activeDays: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
        ),
      );

      setState(() {
        _appLimit = appLimit;
        // Convert the values to the dropdown format
        opensValue = '${appLimit.maxDailyOpens} Times';
        durationValue = '${appLimit.maxSessionDurationMinutes} Mins';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorLoadingAppLimit('$e'))),
        );
      }
    }
  }

  Future<void> _saveAppLimit() async {
    try {
      // Parse the values from dropdowns
      final maxDailyOpens = int.tryParse(opensValue.split(' ')[0]) ?? 5;
      final maxSessionDurationMinutes = int.tryParse(durationValue.split(' ')[0]) ?? 30;

      // Create updated app limit
      final updatedAppLimit = _appLimit.copyWith(
        maxDailyOpens: maxDailyOpens,
        maxSessionDurationMinutes: maxSessionDurationMinutes,
      );

      // Save to storage
      final appLimitStorageService = Get.find<AppLimitStorageService>();
      final appLimits = await appLimitStorageService.getAppLimits();

      // Replace the existing limit with the updated one
      final updatedLimits = appLimits.map((limit) {
        if (limit.packageName == widget.packageName) {
          return updatedAppLimit;
        }
        return limit;
      }).toList();

      final success = await appLimitStorageService.saveAppLimits(updatedLimits);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.appLimitUpdated)),
        );

        // Go back to previous screen
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failedToUpdateAppLimit)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSavingAppLimit('$e'))),
        );
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
            CustomText(
              text: context.l10n.editUsageLimit,
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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

                      /// =================== App Section ===================
                      _buildAppLimitSection(
                        icon: _appLimit.appIcon != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.memory(
                                  _appLimit.appIcon!,
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
                                child: const Icon(Icons.apps, size: 20),
                              ),
                        appName: _appLimit.appName,
                        opensValue: opensValue,
                        durationValue: durationValue,
                        onOpensChanged: (value) {
                          setState(() => opensValue = value!);
                        },
                        onDurationChanged: (value) {
                          setState(() => durationValue = value!);
                        },
                      ),
                      SizedBox(height: 48.h),
                      CustomButton(
                        title: context.l10n.save,
                        onpress: _saveAppLimit,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAppLimitSection({
    required Widget icon,
    required String appName,
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
            Flexible(
              child: CustomText(
                text: appName,
                fontsize: 24.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor3D3D3D,
              ),
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
