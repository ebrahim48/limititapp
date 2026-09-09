import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/app_selection_detox_mode_helper.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/models/app_model_pin.dart';
import 'package:limit_it_app/core/presentations/widgets/app_pin_lock_card.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/detox_mode_toggle.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/blocked_apps_service.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';

class DetoxModeScreen extends StatefulWidget {
  const DetoxModeScreen({super.key});

  @override
  State<DetoxModeScreen> createState() => _DetoxModeScreenState();
}

class _DetoxModeScreenState extends State<DetoxModeScreen> {
  final RxBool isDetoxModeEnabled = false.obs;
  final RxSet<String> selectedApps = <String>{}.obs;
  final RxList<AppModel> apps = <AppModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  /// Load real apps from device
  Future<void> _loadApps() async {
    try {
      isLoading(true);
      errorMessage('');

      if (!Platform.isAndroid) {
        errorMessage.value = appL10n.detoxModeAndroidOnly;
        isLoading(false);
        return;
      }

      final appUsageService = Get.find<AppUsageService>();
      
      // Check permission
      bool hasPermission = await appUsageService.hasPermission();
      if (!hasPermission) {
        hasPermission = await appUsageService.requestPermission();
      }

      if (!hasPermission) {
        errorMessage.value = appL10n.pleaseGrantUsageAccess;
        isLoading(false);
        return;
      }

      // Get all installed apps
      final allApps = await appUsageService.getAllInstalledApps();
      
      if (allApps.isEmpty) {
        errorMessage.value = appL10n.noAppsFoundOnDevice;
        isLoading(false);
        return;
      }

      // Convert to AppModel format
      final appModels = allApps.map((appData) {
        return AppModel(
          name: appData.name,
          icon: '', // We'll use real icons from appData
          packageName: appData.packageName,
          appIcon: appData.icon,
        );
      }).toList();

      apps.assignAll(appModels);
      isLoading(false);
    } catch (e) {
      errorMessage.value = appL10n.errorLoadingApps(e.toString());
      isLoading(false);
    }
  }

  /// Save detox mode settings
  Future<void> _saveDetoxMode() async {
    if (selectedApps.isEmpty) {
      ToastMessageHelper.showToastMessage(
        appL10n.pleaseSelectAtLeastOneAppDetox,
        title: appL10n.warning,
      );
      return;
    }

    try {
      final blockedAppsService = Get.find<BlockedAppsService>();
      final appBlockerService = Get.find<AppBlockerService>();

      // Block all selected apps
      int successCount = 0;
      final List<String> blockedAppNames = [];
      
      for (final appKey in selectedApps) {
        final app = apps.firstWhere(
          (a) => '${a.name}_${apps.indexOf(a)}' == appKey,
          orElse: () => apps.first,
        );

        final success = await blockedAppsService.blockApp(
          app.packageName ?? '',
          app.name,
        );

        if (success) {
          successCount++;
          blockedAppNames.add(app.name);
        }
      }

      // Update native monitoring service
      final blockedPackages = await blockedAppsService.getBlockedPackageNames();
      await appBlockerService.updateBlockedApps(blockedPackages);

      // Show success message
      String message = '$successCount apps added to Detox Mode.';
      if (blockedAppNames.isNotEmpty) {
        final displayApps = blockedAppNames.take(3).join(', ');
        if (blockedAppNames.length > 3) {
          message += '\nBlocked: $displayApps and ${blockedAppNames.length - 3} more.';
        } else {
          message += '\nBlocked: $displayApps.';
        }
        message += '\n\nThese apps are now blocked to help you focus!';
      }

      ToastMessageHelper.showToastMessage(
        message,
        title: appL10n.success,
      );

      // Reset selection
      selectedApps.clear();
    } catch (e) {
      ToastMessageHelper.showToastMessage(
        appL10n.errorSavingDetoxMode(e.toString()),
        title: appL10n.error,
      );
    }
  }

  bool get isAllSelected => selectedApps.value.length == apps.length;

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
              text: context.l10n.detoxMode,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            DetoxModeToggle(isDetoxModeEnabled: isDetoxModeEnabled),
            Obx(() {
              if (!isDetoxModeEnabled.value) {
                return const SizedBox.shrink();
              }

              if (isLoading.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }

              if (errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.r,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: errorMessage.value,
                          fontsize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor5D5D5D,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        CustomButton(
                          title: context.l10n.retry,
                          onpress: _loadApps,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (apps.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.apps_outage,
                          size: 64.r,
                          color: AppColors.textColor5D5D5D,
                        ),
                        SizedBox(height: 16.h),
                        CustomText(
                          text: context.l10n.noAppsAvailable,
                          fontsize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textColor3D3D3D,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        selectedApps.value =
                            AppSelectionDetoxModeHelper.toggleSelectAllSet(
                              selectedApps,
                              apps.length,
                              (index) => '${apps[index].name}_$index',
                            );
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4.r),
                              color: isAllSelected
                                  ? const Color(0xFF214432)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isAllSelected
                                    ? const Color(0xFF214432)
                                    : const Color(0xFFD1D1D1),
                                width: 2,
                              ),
                            ),
                            child: isAllSelected
                                ? Icon(Icons.check, color: Colors.white, size: 14.r)
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          CustomText(
                            text: context.l10n.selectAll,
                            fontsize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF5D5D5D),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    final selectedCount = selectedApps.length;
                    if (selectedCount > 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: CustomText(
                          text: '$selectedCount ${selectedCount == 1 ? context.l10n.app : context.l10n.apps} ${context.l10n.selected}',
                          fontsize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Column(
                    children: apps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final app = entry.value;
                      final appKey = '${app.name}_$index';
                      final isSelected = selectedApps.contains(appKey);

                      return AppCardItem(
                        app: app,
                        index: index,
                        isSelected: isSelected,
                        onTap: () => setState(() {
                          selectedApps.value =
                              AppSelectionDetoxModeHelper.toggleApp(selectedApps, appKey);
                        }),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            SizedBox(height: 32.h),
            Obx(() {
              final hasSelection = selectedApps.isNotEmpty;
              return Opacity(
                opacity: hasSelection ? 1.0 : 0.5,
                child: CustomButton(
                  title: context.l10n.saveDetoxMode,
                  onpress: hasSelection ? _saveDetoxMode : () {},
                ),
              );
            }),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
