import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/app_selection_helper.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/models/app_model_pin.dart';
import 'package:limit_it_app/core/presentations/widgets/app_pin_lock_card.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/pin_lock_toggle.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/pin_lock_storage_service.dart';

class PinLockLimitsScreen extends StatefulWidget {
  const PinLockLimitsScreen({super.key});

  @override
  State<PinLockLimitsScreen> createState() => _PinLockLimitsScreenState();
}

class _PinLockLimitsScreenState extends State<PinLockLimitsScreen> {
  final RxBool isPinLockEnabled = false.obs;
  final RxSet<String> selectedApps = <String>{}.obs;
  final RxList<AppModel> apps = <AppModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadPinLockSettings();
    _loadApps();
  }

  /// Load saved PIN lock settings
  Future<void> _loadPinLockSettings() async {
    try {
      final pinLockService = Get.find<PinLockStorageService>();
      final settings = await pinLockService.getPinLockSettings();

      isPinLockEnabled.value = settings.isEnabled;
      selectedApps.addAll(settings.selectedAppKeys);
    } catch (e) {
      debugPrint('Error loading PIN lock settings: $e');
    }
  }

  /// Load real apps from device
  Future<void> _loadApps() async {
    try {
      isLoading(true);
      errorMessage('');

      if (!Platform.isAndroid) {
        errorMessage.value = 'PIN Lock is only available on Android devices';
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
        errorMessage.value = 'Please grant usage access permission';
        isLoading(false);
        return;
      }

      // Get all installed apps
      final allApps = await appUsageService.getAllInstalledApps();

      if (allApps.isEmpty) {
        errorMessage.value = 'No apps found on this device';
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
      errorMessage.value = 'Error loading apps: ${e.toString()}';
      isLoading(false);
    }
  }

  /// Save PIN lock settings
  Future<void> _savePinLockSettings() async {
    try {
      final pinLockService = Get.find<PinLockStorageService>();

      final settings = PinLockSettings(
        isEnabled: isPinLockEnabled.value,
        selectedAppKeys: selectedApps,
        pinCode: await pinLockService.getPinCode(),
      );

      final success = await pinLockService.savePinLockSettings(settings);

      if (success && isPinLockEnabled.value && selectedApps.isNotEmpty) {
        ToastMessageHelper.showToastMessage(
          'PIN lock settings saved successfully',
          title: 'Success',
        );
      }
    } catch (e) {
      debugPrint('Error saving PIN lock settings: $e');
    }
  }

  /// Handle PIN lock toggle change
  Future<void> _onPinLockToggle(bool enabled) async {
    isPinLockEnabled.value = enabled;
    await _savePinLockSettings();
  }

  /// Handle app selection
  void _toggleAppSelection(String appKey) {
    if (selectedApps.contains(appKey)) {
      selectedApps.remove(appKey);
    } else {
      selectedApps.add(appKey);
    }
  }

  /// Handle select all
  void _toggleSelectAll() {
    final allKeys = <String>{};
    for (int i = 0; i < apps.length; i++) {
      allKeys.add('${apps[i].name}_$i');
    }

    if (selectedApps.length == apps.length) {
      selectedApps.clear();
    } else {
      selectedApps.addAll(allKeys);
    }
  }

  /// Navigate to set PIN screen
  Future<void> _handleNext() async {
    if (!isPinLockEnabled.value) {
      ToastMessageHelper.showToastMessage(
        'Please enable PIN lock to continue',
        title: 'Warning',
      );
      return;
    }

    if (selectedApps.isEmpty) {
      ToastMessageHelper.showToastMessage(
        'Please select at least one app to protect',
        title: 'Warning',
      );
      return;
    }

    // Save settings before navigating
    await _savePinLockSettings();

    // Get the first selected app's name to use as providerName
    if (selectedApps.isNotEmpty && apps.isNotEmpty) {
      // Extract app name from the first selected app key
      // Format is "appName_index", so we need to extract the app name
      final firstSelectedKey = selectedApps.first;
      final providerName = firstSelectedKey.split('_').first;

      debugPrint('====> Selected provider: $providerName');
      debugPrint('====> Selected app key: $firstSelectedKey');

      if (mounted) {
        context.pushNamed(
          AppRoutes.setPinNumberScreen,
          extra: {"providerName": providerName},
        );
      }
    } else {
      ToastMessageHelper.showToastMessage(
        'No app selected',
        title: 'Warning',
      );
    }
  }

  bool get isAllSelected => selectedApps.length == apps.length;

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
              text: context.l10n.pinLock,
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
            PinLockToggle(
              isPinLockEnabled: isPinLockEnabled,
              onToggle: _onPinLockToggle,
            ),
            Obx(() {
              if (!isPinLockEnabled.value) {
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
                          title: 'Retry',
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
                          text: 'No apps available',
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
                      onTap: _toggleSelectAll,
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
                          textAlign: TextAlign.start,
                          text: '$selectedCount ${selectedCount == 1 ? 'app' : 'apps'} selected',
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
                        onTap: () => _toggleAppSelection(appKey),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            SizedBox(height: 32.h),
            CustomButton(
              title: context.l10n.next,
              onpress: _handleNext,
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
