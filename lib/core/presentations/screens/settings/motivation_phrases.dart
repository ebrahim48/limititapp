import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/motivation_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/motivation_model.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_loader.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class MotivationPhrasesScreen extends StatefulWidget {
  const MotivationPhrasesScreen({super.key});

  @override
  State<MotivationPhrasesScreen> createState() => _MotivationPhrasesScreenState();
}

class _MotivationPhrasesScreenState extends State<MotivationPhrasesScreen> {
  final MotivationController controller = Get.put(MotivationController());
  final RxBool isExpanded = false.obs;

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
                SizedBox(height: 23.h),

                // Loading indicator or quotes list
                Obx(() {
                  if (controller.isLoading.value && controller.motivations.isEmpty) {
                    return const Center(child: CustomLoader());
                  }

                  if (controller.motivations.isEmpty) {
                    return Center(
                      child: CustomText(
                        text: context.l10n.noMotivationalPhrasesFound,
                        fontsize: 16.sp,
                        color: AppColors.textColor5D5D5D,
                      ),
                    );
                  }

                  final displayQuotes = isExpanded.value
                      ? controller.motivations
                      : controller.motivations.take(3).toList();

                  return Column(
                    children: displayQuotes.map((quote) => _buildQuoteCard(quote)).toList(),
                  );
                }),

                SizedBox(height: 16.h),

                // More/Less button
                Obx(() {
                  if (controller.motivations.length > 3) {
                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          isExpanded.value = !isExpanded.value;
                        },
                        child: Icon(
                          isExpanded.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 24.r,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 35.h),

                // Add Motivation button
                CustomButton(
                  title: context.l10n.addMotivation,
                  onpress: () {
                    // context.pushNamed(AppRoutes.saveMotivationPhrasesScreen);
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

  Widget _buildQuoteCard(MotivationModel quote) {
    return Container(
      width: 345.w,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(0xFFD1D1D1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            textAlign: TextAlign.start,
            text: quote.content,
            fontsize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor3D3D3D,
            maxline: 5,
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: '- ${quote.author}',
            fontsize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor214432,
          ),
        ],
      ),
    );
  }
}