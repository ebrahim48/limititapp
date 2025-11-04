import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class SaveMotivationPhrasesScreen extends StatefulWidget {
  const SaveMotivationPhrasesScreen({super.key});

  @override
  State<SaveMotivationPhrasesScreen> createState() => _SaveMotivationPhrasesScreenState();
}

class _SaveMotivationPhrasesScreenState extends State<SaveMotivationPhrasesScreen> {


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
              text: context.l10n.motivationalPhrases,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textColor3D3D3D,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25.h),

                TextField(
                  controller: enterMotivationController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: context.l10n.enterMotivationQuotes,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: enterAuthorNameController,
                  decoration: InputDecoration(
                    hintText: context.l10n.enterAuthorName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),



                SizedBox(height: 35.h),

                CustomButton(
                  title: context.l10n.saveMotivation,
                  onpress: () {

                  },
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController  enterMotivationController = TextEditingController();
  TextEditingController  enterAuthorNameController = TextEditingController();
}
