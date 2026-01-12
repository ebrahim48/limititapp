import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class TimerSettingsScreen extends StatefulWidget {
  const TimerSettingsScreen({super.key});

  @override
  State<TimerSettingsScreen> createState() => _TimerSettingsScreenState();
}

class _TimerSettingsScreenState extends State<TimerSettingsScreen> {



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
              text: context.l10n.timerSettings,
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
                SizedBox(height: 20.h),

                CustomText(
                  textAlign: TextAlign.start,
                  text: context.l10n.preOpeningCountdown,
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                  maxline: 2,
                ),

                SizedBox(height: 16.h),


                // Duration chips - Initial + More (if expanded)
                Obx(() {
                  List<String> displayDurations = [...initialDurations];
                  if (showMoreDurations.value) {
                    displayDurations.addAll(moreDurations);
                  }

                  return Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: displayDurations.map((duration) {
                      final isSelected = selectedDuration.value == duration;
                      return GestureDetector(
                        onTap: () => selectedDuration.value = duration,
                        child: Container(
                          width: 64.w,
                          height: 32.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? Color(0xFF214432) : Color(0xFFE7E7E7),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: CustomText(
                            text: duration,
                            fontsize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),

                SizedBox(height: 12.h),

                // More/Less button
                Obx(() => GestureDetector(
                  onTap: () {
                    showMoreDurations.value = !showMoreDurations.value;
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF214432),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          text: showMoreDurations.value ? 'Less' : 'More',
                          fontsize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          showMoreDurations.value
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                )),

                SizedBox(height: 32.h),

                // Motivational Phrases
                CustomText(
                  text: context.l10n.motivationalPhrases,
                  fontsize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor3D3D3D,
                ),

                SizedBox(height: 16.h),

                // Quotes list
                ...quotes.map((quote) => _buildQuoteCard(quote)),

                SizedBox(height: 35.h),

                // Save button
                CustomButton(
                  title: context.l10n.save,
                  onpress: () {
                 context.pushNamed(AppRoutes.timerSuccessScreen);
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

  Widget _buildQuoteCard(MotivationalQuote quote) {
    return Container(
      width: 345.w,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: quote.isHighlighted ? Color(0xFFEDD69A) : AppColors.backGroundColor,
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
            text: quote.text,
            fontsize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textColor3D3D3D,
            maxline: 5,
          ),
          SizedBox(height: 12.h),
          CustomText(
            text: quote.author,
            fontsize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor214432,
          ),
        ],
      ),
    );
  }
  final RxString selectedDuration = '0 sec'.obs;
  final RxBool showMoreDurations = false.obs;
  final List<String> initialDurations = ['0 sec', '5 sec', '10 sec', '15 sec'];
  final List<String> moreDurations = ['20 sec', '25 sec', '30 sec', '35 sec', '40 sec', '45 sec'];


  final List<MotivationalQuote> quotes = [
    MotivationalQuote(
      text: 'Almost all good writing begins with terrible first efforts. You need to start somewhere',
      author: 'Anne Lamott',
      isHighlighted: false,
    ),
    MotivationalQuote(
      text: 'God gives every bird its food, but He does not throw it into its nest',
      author: 'J.G. Holland',
      isHighlighted: true,
    ),
    MotivationalQuote(
      text: 'An effort made for the happiness of others lifts above ourselves',
      author: 'Lydia M. Child',
      isHighlighted: false,
    ),
  ];
}

// Model class for motivational quotes
class MotivationalQuote {
  final String text;
  final String author;
  final bool isHighlighted;

  MotivationalQuote({
    required this.text,
    required this.author,
    required this.isHighlighted,
  });
}