import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';


class SetPinNumberScreen extends StatefulWidget {
  const SetPinNumberScreen({super.key});

  @override
  State<SetPinNumberScreen> createState() => _SetPinNumberScreenState();
}

class _SetPinNumberScreenState extends State<SetPinNumberScreen> {


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

            CustomTextField(
              hintextColor: AppColors.textColor5D5D5D,
              controller: pinNumberController,
              hintText: context.l10n.enterPinNumber,
              isPassword: true,
            ),
            SizedBox(height: 24.h),

            CustomButton(
              title: context.l10n.savePinNumber,
              onpress: () {

              },
            ),
            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  TextEditingController pinNumberController = TextEditingController();

}
