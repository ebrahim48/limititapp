import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/constants/appselection_helper.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_model_pin.dart';
import 'package:limit_it_app/core/presentations/widgets/app_pin_lock_card.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/pin_lock_toggle.dart';


class PinLockLimitsScreen extends StatefulWidget {
  const PinLockLimitsScreen({super.key});

  @override
  State<PinLockLimitsScreen> createState() => _PinLockLimitsScreenState();
}

class _PinLockLimitsScreenState extends State<PinLockLimitsScreen> {


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
            PinLockToggle(isPinLockEnabled: isPinLockEnabled),
            Obx(() => isPinLockEnabled.value
                ? Column(
              children: [
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      selectedApps.value =
                          AppSelectionHelper.toggleSelectAll(selectedApps, apps);
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
                            AppSelectionHelper.toggleApp(selectedApps, appKey);
                      }),
                    );
                  }).toList(),
                ),
              ],
            )
                : const SizedBox.shrink()),
            SizedBox(height: 32.h),
            CustomButton(
              title: context.l10n.next,
              onpress: () {
                context.pushNamed(AppRoutes.setPinNumberScreen);

                print('Pin Lock Enabled: ${isPinLockEnabled.value}');
                print('Selected apps: ${selectedApps.length}');
                selectedApps.forEach(print);
              },
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
  final RxBool isPinLockEnabled = true.obs;
  final RxSet<String> selectedApps = <String>{'Facebook_1', 'Netflix_6'}.obs;

  final List<AppModel> apps = [
    AppModel(name: 'Instagram', icon: 'assets/icons/instagram.svg'),
    AppModel(name: 'Facebook', icon: 'assets/icons/facebook.svg'),
    AppModel(name: 'Twitter', icon: 'assets/icons/twitter.svg'),
    AppModel(name: 'Youtube', icon: 'assets/icons/youtube.svg'),
    AppModel(name: 'Snapchat', icon: 'assets/icons/snapshot.svg'),
    AppModel(name: 'Netflix', icon: 'assets/icons/netflix.svg'),
  ];

  bool get isAllSelected => selectedApps.length == apps.length;
}
