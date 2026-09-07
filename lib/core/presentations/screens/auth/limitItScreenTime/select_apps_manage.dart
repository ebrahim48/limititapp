import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/app_icon_widget.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/core/services/device_apps_service.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';

class SelectAppsManageScreen extends StatefulWidget {
  const SelectAppsManageScreen({super.key});

  @override
  State<SelectAppsManageScreen> createState() => _SelectAppsManageScreenState();
}

class _SelectAppsManageScreenState extends State<SelectAppsManageScreen>
    with WidgetsBindingObserver {
  // Real app usage data
  bool _isLoading = true;
  bool _hasPermission = false;
  List<AppUsageData> _appUsageList = [];

  /// iOS list — the catalogue apps this device actually has (see
  /// [DeviceAppsService]); Apple exposes no usage numbers for them.
  List<KnownApp> _detectedApps = [];
  final DeviceAppsService _deviceApps = DeviceAppsService();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppUsageData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-load apps when user returns from settings
      _loadAppUsageData();
    }
  }

  /// Load app usage data
  Future<void> _loadAppUsageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // iOS exposes neither usage stats nor an app list, so we fall back to
      // probing the known catalogue and show whatever is really installed.
      if (!Platform.isAndroid) {
        final detected = await _deviceApps.detectInstalled();
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasPermission = false;
          _detectedApps =
              detected.isNotEmpty ? detected : DeviceAppsService.catalog;
          _errorMessage =
              detected.isNotEmpty ? null : context.l10n.appDetectionLimited;
        });
        return;
      }

      // Check permission
      final appUsageService = Get.find<AppUsageService>();
      bool hasPermission = await appUsageService.hasPermission();

      if (!hasPermission) {
        // Request permission
        hasPermission = await appUsageService.requestPermission();
      }

      setState(() {
        _hasPermission = hasPermission;
      });

      if (hasPermission) {
        // Get ALL installed apps (not just ones with usage)
        List<AppUsageData> allApps = await appUsageService.getAllInstalledApps();

        setState(() {
          _appUsageList = allApps;
          _isLoading = false;
          if (allApps.isEmpty) {
            _errorMessage = 'No apps found on this device';
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Permission denied. Please grant usage access permission in settings';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading app usage data: ${e.toString()}';
      });
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
              text: context.l10n.selectAppsToManage,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              SizedBox(
                height: 48.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemCount: days.length + 1,
                  itemBuilder: (context, index) {
                    if (index == days.length) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEEDE2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: allSelected,
                              activeColor: const Color(0xFF214432),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              onChanged: (val) => toggleAllDays(val ?? false),
                            ),
                            CustomText(
                              text: context.l10n.all,
                              fontsize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor3D3D3D,
                            ),
                          ],
                        ),
                      );
                    }

                    final day = days[index];
                    final isSelected = selectedDays.contains(day);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedDays.remove(day);
                          } else {
                            selectedDays.add(day);
                          }
                          allSelected = selectedDays.length == days.length;
                        });
                      },
                      child: Container(
                        width: 48.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF214432)
                                  : const Color(0xFFDEEDE2),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: CustomText(
                          text: day,
                          color:
                              isSelected
                                  ? AppColors.textColorF6F6F6
                                  : AppColors.textColor3D3D3D,
                          fontWeight: FontWeight.w400,
                          fontsize: 10.sp,
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),

              // Show info message if needed
              if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFFF9800),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textColor3D3D3D,
                          ),
                        ),
                      ),
                      if (!_hasPermission && Platform.isAndroid)
                        TextButton(
                          onPressed: _loadAppUsageData,
                          child: Text(
                            context.l10n.retry,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingList()
                        : _appUsageList.isNotEmpty
                        ? _buildRealAppsList()
                        : _buildFallbackAppsList(),
              ),

              /// ===================================> Continue Button ===============================>
              GestureDetector(
                onTap: () {
                  if (selectedApps.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.pleaseSelectAtLeastOneApp),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Prepare selected apps data
                  List<SelectedAppInfo> selectedAppsData = [];

                  if (_appUsageList.isNotEmpty) {
                    // Use real app data
                    for (var packageName in selectedApps) {
                      final appData = _appUsageList.firstWhere(
                        (app) => app.packageName == packageName,
                        orElse: () => AppUsageData(
                          name: packageName,
                          packageName: packageName,
                          usageTimeMs: 0,
                          percentage: 0,
                          openCount: 0,
                        ),
                      );

                      selectedAppsData.add(SelectedAppInfo(
                        packageName: appData.packageName,
                        appName: appData.name,
                        appIcon: appData.icon,
                      ));
                    }
                  } else {
                    // Detected (iOS) apps — package name is the stable id.
                    for (var packageName in selectedApps) {
                      final app = _detectedApps.firstWhere(
                        (a) => a.packageName == packageName,
                        orElse: () => KnownApp(
                          name: packageName,
                          packageName: packageName,
                          iosSchemes: const [],
                        ),
                      );

                      selectedAppsData.add(SelectedAppInfo(
                        packageName: app.packageName,
                        appName: app.name,
                      ));
                    }
                  }

                  /// ====================================>  Navigate with selected apps and days =======================================>

                  context.pushNamed(AppRoutes.setUsageLimitScreen, extra: {
                      'selectedApps': selectedAppsData,
                      'selectedDays': selectedDays.toList(),
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF214432),
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  child: CustomText(
                    text: context.l10n.continueWithAppsCount(selectedApps.length),
                    fontsize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColorF6F6F6,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  final List<String> days = ['SAT', 'SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI'];
  bool allSelected = false;
  Set<String> selectedDays = {'WED', 'TUE'};

  Set<String> selectedApps = {}; // Start with empty selection

  void toggleAllDays(bool value) {
    setState(() {
      allSelected = value;
      if (allSelected) {
        selectedDays = days.toSet();
      } else {
        selectedDays.clear();
      }
    });
  }

  /// Build loading shimmer list
  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 160.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build list with real app usage data
  Widget _buildRealAppsList() {
    // Remove duplicates by package name and hide this app itself
    const String ownPackageName = 'com.limitit.digitalbalance';
    final seen = <String>{};
    final uniqueApps =
        _appUsageList.where((appData) {
          if (appData.packageName.trim() == ownPackageName) return false;
          if (seen.contains(appData.packageName.trim())) {
            return false;
          }
          seen.add(appData.packageName.trim());
          return true;
        }).toList();

    return ListView.builder(
      itemCount: uniqueApps.length,
      itemBuilder: (context, index) {
        final appData = uniqueApps[index];
        final isSelected = selectedApps.contains(appData.packageName);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedApps.remove(appData.packageName);
              } else {
                selectedApps.add(appData.packageName);
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFFEDD69A)
                      : AppColors.backGroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D1D1)),
            ),
            child: Row(
              children: [
                // Display real app icon or placeholder
                AppIconWidget(
                  packageName: appData.packageName,
                  appName: appData.name,
                  preloadedIcon: appData.icon,
                  size: 32,
                  borderRadius: 8,
                  padding: 2,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appData.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "${appData.usageString} today • ${appData.openCount} Opens",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1.4),
                    color:
                        isSelected
                            ? const Color(0xFF214432)
                            : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the list for platforms without usage stats (iOS): real installed
  /// apps where detection worked, the catalogue otherwise — and no usage line,
  /// because there are no numbers to show.
  Widget _buildFallbackAppsList() {
    return ListView.builder(
      itemCount: _detectedApps.length,
      itemBuilder: (context, index) {
        final app = _detectedApps[index];
        final isSelected = selectedApps.contains(app.packageName);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedApps.remove(app.packageName);
              } else {
                selectedApps.add(app.packageName);
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFEDD69A)
                  : AppColors.backGroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFD1D1D1)),
            ),
            child: Row(
              children: [
                AppIconWidget(
                  packageName: app.packageName,
                  appName: app.name,
                  size: 32,
                  borderRadius: 8,
                  padding: 2,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    app.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1.4),
                    color: isSelected
                        ? const Color(0xFF214432)
                        : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build placeholder icon with first letter
  Widget _buildPlaceholderIcon(String appName) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: const Color(0xFF5D5D5D),
        borderRadius: BorderRadius.circular(8.r),
      ),
      alignment: Alignment.center,
      child: Text(
        appName.isNotEmpty ? appName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
