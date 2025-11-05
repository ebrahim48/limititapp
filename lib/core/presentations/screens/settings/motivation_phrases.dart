import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';

class MotivationPhrasesScreen extends StatefulWidget {
  const MotivationPhrasesScreen({super.key});

  @override
  State<MotivationPhrasesScreen> createState() => _MotivationPhrasesScreenState();
}

class _MotivationPhrasesScreenState extends State<MotivationPhrasesScreen> {


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

                Obx(() {
                  final displayQuotes = isExpanded.value
                      ? quotes
                      : quotes.take(3).toList();

                  return Column(
                    children: displayQuotes.map((quote) => _buildQuoteCard(quote)).toList(),
                  );
                }),

                SizedBox(height: 16.h),

                // More/Less button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      isExpanded.value = !isExpanded.value;
                    },
                    child: Obx(() => Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 24.r,
                      color: Colors.black,
                    )),
                  ),
                ),

                SizedBox(height: 35.h),

                // Add Motivation button
                CustomButton(
                  title: context.l10n.addMotivation,
                  onpress: () {
                    context.pushNamed(AppRoutes.saveMotivationPhrasesScreen);
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


}
final RxBool isExpanded = false.obs;

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
  MotivationalQuote(
    text: 'Success is not final, failure is not fatal: it is the courage to continue that counts',
    author: 'Winston Churchill',
    isHighlighted: false,
  ),
  MotivationalQuote(
    text: 'The only way to do great work is to love what you do',
    author: 'Steve Jobs',
    isHighlighted: false,
  ),
];
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