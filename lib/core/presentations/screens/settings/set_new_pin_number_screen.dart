import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/pin_lock_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';

class SetNewPinNumberScreen extends StatefulWidget {
  final String pinId;
  final String providerName;
  final String mode; // 'create' or 'update'
  
  const SetNewPinNumberScreen({
    super.key,
    required this.pinId,
    required this.providerName,
    this.mode = 'update',
  });

  @override
  State<SetNewPinNumberScreen> createState() => _SetNewPinNumberScreenState();
}

class _SetNewPinNumberScreenState extends State<SetNewPinNumberScreen> {
  late final PinLockController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PinLockController>();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdateMode = widget.mode == 'update';
    
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
              text: isUpdateMode 
                  ? context.l10n.updatePinNumber 
                  : context.l10n.setPinNumber,
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

            CustomText(
              text: '${context.l10n.provider}: ${widget.providerName}',
              fontsize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16.h),

            CustomTextField(
              hintextColor: AppColors.textColor5D5D5D,
              controller: pinNumberController,
              hintText: context.l10n.enterNewPinNumber,
              isPassword: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) => null,
            ),
            SizedBox(height: 24.h),

            Obx(() {
              final isUpdating = controller.isUpdating.value;
              return CustomButton(
                title: isUpdating
                    ? context.l10n.updating
                    : (isUpdateMode
                        ? context.l10n.updatePinNumber
                        : context.l10n.savePinNumber),
                onpress: () {
                  if (!isUpdating) {
                    _handleSave();
                  }
                },
                loading: isUpdating,
              );
            }),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  TextEditingController pinNumberController = TextEditingController();

  void _handleSave() {
    final pinCode = pinNumberController.text.trim();

    // Validate PIN code (should be 4 digits)
    if (pinCode.isEmpty) {
      Get.snackbar(
        'Error',
        appL10n.pleaseEnterPinCode,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (pinCode.length != 4 || !RegExp(r'^[0-9]+$').hasMatch(pinCode)) {
      Get.snackbar(
        'Error',
        appL10n.pinCodeMustBe4Digits,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (widget.mode == 'update') {
      // Call controller to update PIN lock
      controller.updatePinLock(
        pinId: widget.pinId,
        providerName: widget.providerName,
        pinCode: pinCode,
        context: context,
      );
    } else {
      // Create new PIN (shouldn't happen from PinSettingsScreen, but for completeness)
      controller.createPinLock(
        providerName: widget.providerName,
        pinCode: pinCode,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    pinNumberController.dispose();
    super.dispose();
  }
}
