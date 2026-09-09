import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/pin_lock_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class PinSettingsScreen extends StatefulWidget {
  const PinSettingsScreen({super.key});

  @override
  State<PinSettingsScreen> createState() => _PinSettingsScreenState();
}

class _PinSettingsScreenState extends State<PinSettingsScreen> {
  final PinLockController controller = Get.find<PinLockController>();
  final RxList<Map<String, dynamic>> pinsList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  /// Load user's PINs from API
  Future<void> _loadPins() async {
    try {
      isLoading(true);
      final pins = await controller.getUserPins();
      pinsList.assignAll(pins);
      isLoading(false);
    } catch (e) {
      debugPrint('Error loading PINs: $e');
      isLoading(false);
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
              text: context.l10n.pinSettings,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        if (pinsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80.r,
                  color: AppColors.textColor5D5D5D,
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: context.l10n.noPinsCreated,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor5D5D5D,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: context.l10n.createYourFirstPin,
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor5D5D5D,
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  title: context.l10n.createPin,
                  onpress: () {
                    context.pushNamed(AppRoutes.pinLockLimitsScreen);
                  },
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              
              // PIN list
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: pinsList.length,
                itemBuilder: (context, index) {
                  final pin = pinsList[index];
                  final providerName = pin['providerName'] ?? 'Unknown';
                  final pinId = pin['_id'] ?? '';
                  
                  return _buildPinCard(
                    context: context,
                    providerName: providerName,
                    pinId: pinId,
                    index: index,
                  );
                },
              ),
              
              SizedBox(height: 32.h),
              
              // Update PIN button
              CustomButton(
                title: context.l10n.updatePin,
                onpress: () {
                  if (pinsList.isNotEmpty) {
                    final firstPin = pinsList.first;
                    context.pushNamed(
                      AppRoutes.setNewPinNumberScreen,
                      extra: {
                        "pinId": firstPin['_id'] ?? '',
                        "providerName": firstPin['providerName'] ?? '',
                        "mode": "update",
                      },
                    );
                  }
                },
              ),
              SizedBox(height: 60.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPinCard({
    required BuildContext context,
    required String providerName,
    required String pinId,
    required int index,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // App icon placeholder
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.apps,
              color: AppColors.primaryColor,
              size: 28.r,
            ),
          ),
          SizedBox(width: 16.w),
          
          // Provider name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: providerName,
                  fontsize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor3D3D3D,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: 'PIN ••••',
                  fontsize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor5D5D5D,
                ),
              ],
            ),
          ),
          
          // View and Delete buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.visibility, color: AppColors.primaryColor, size: 22.r),
                onPressed: () {
                  _showPinDetails(context, providerName);
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
              SizedBox(width: 8.w),
              Obx(() => IconButton(
                icon: controller.isDeleting.value
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : Icon(Icons.delete_outline, color: Colors.red, size: 22.r),
                onPressed: controller.isDeleting.value
                    ? null
                    : () => _confirmDelete(context, pinId),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              )),
            ],
          ),
        ],
      ),
    );
  }

  void _showPinDetails(BuildContext context, String providerName) {
    // Get the PIN code from the list (if available from API)
    final currentPin = pinsList.firstWhere(
      (pin) => pin['providerName'] == providerName,
      orElse: () => {'pincode': null},
    );
    final pinCode = currentPin['pincode'] ?? '••••';
    final isPinHidden = true.obs;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: CustomText(
            text: providerName,
            fontsize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor3D3D3D,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: context.l10n.pinCode,
                fontsize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor5D5D5D,
              ),
              SizedBox(height: 8.h),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: isPinHidden.value ? '••••' : pinCode,
                    fontsize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(
                      isPinHidden.value ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.primaryColor,
                      size: 24.r,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        isPinHidden.value = !isPinHidden.value;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              )),
              SizedBox(height: 16.h),
              if (pinCode == '••••')
                CustomText(
                  text: context.l10n.pinCodeNotAvailable,
                  fontsize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textColor5D5D5D,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                text: context.l10n.close,
                fontsize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String pinId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: CustomText(
          text: context.l10n.deletePin,
          fontsize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor3D3D3D,
        ),
        content: CustomText(
          text: context.l10n.deletePinConfirmation,
          fontsize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textColor5D5D5D,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(
              text: context.l10n.cancel,
              fontsize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor5D5D5D,
            ),
          ),
          Obx(() => TextButton(
            onPressed: controller.isDeleting.value
                ? null
                : () {
                    Navigator.pop(context);
                    controller.deletePinLock(
                      pinId: pinId,
                      context: context,
                    );
                  },
            child: controller.isDeleting.value
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : CustomText(
                    text: context.l10n.delete,
                    fontsize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
          )),
        ],
      ),
    );
  }
}
