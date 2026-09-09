import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/pin_lock_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';


class SetPinNumberScreen extends StatefulWidget {
  final String providerName;
  
  const SetPinNumberScreen({
    super.key,
    required this.providerName,
  });

  @override
  State<SetPinNumberScreen> createState() => _SetPinNumberScreenState();
}

class _SetPinNumberScreenState extends State<SetPinNumberScreen> {
  late final PinLockController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PinLockController>();
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
              text: context.l10n.setPinNumber,
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
              hintText: context.l10n.enterPinNumber,
              isPassword: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              validator: (value) => null,
            ),
            SizedBox(height: 24.h),

            Obx(() => CustomButton(
              title: controller.isLoading.value
                  ? context.l10n.saving
                  : context.l10n.savePinNumber,
              onpress: controller.isLoading.value
                  ? () {}
                  : () => _handleSave(),
              loading: controller.isLoading.value,
            )),

            // Obx(() => CustomButton(
            //   title: controller.isLoading.value
            //       ? context.l10n.saving
            //       : context.l10n.savePinNumber,
            //   onpress: controller.isLoading.value
            //       ? null
            //       : () => _handleSave(),
            //   isLoading: controller.isLoading.value,
            // )),
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

    // Call controller to create PIN lock
    controller.createPinLock(
      providerName: widget.providerName,
      pinCode: pinCode,
      context: context,
    );
  }

  @override
  void dispose() {
    pinNumberController.dispose();
    super.dispose();
  }
}
