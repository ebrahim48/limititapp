import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/notification_widget.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Your booking is confirmed!',
      message: 'Thank you for choosing us. We look forward to serving you.',
      time: '2m ago',
      avatarText: 'Tm',
      avatarColor: Color(0xFFE5E5E5),
    ),
    NotificationModel(
      title: 'New Feature Available',
      message: 'Check out our new advanced scheduling feature for better time management.',
      time: '1h ago',
      avatarText: 'LI',
      avatarColor: Color(0xFFDCFCE7),
    ),
    NotificationModel(
      title: 'Weekly Report Ready',
      message: 'Your weekly screen time report is now available. You\'ve reduced usage by 25%!',
      time: '3h ago',
      avatarText: 'WR',
      avatarColor: Color(0xFFEDD69A),
    ),
    NotificationModel(
      title: 'Goal Achievement',
      message: 'Congratulations! You\'ve met your daily screen time goal for 7 days in a row.',
      time: '1d ago',
      avatarText: 'GA',
      avatarColor: Color(0xFFDCFCE7),
    ),
    NotificationModel(
      title: 'Premium Offer',
      message: 'Upgrade to Premium and get 50% off for the first month. Limited time offer!',
      time: '2d ago',
      avatarText: 'PO',
      avatarColor: Color(0xFFEDD69A),
    ),
  ];

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
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: context.l10n.notifications,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItemWidget(
            title: notification.title,
            message: notification.message,
            time: notification.time,
            avatarText: notification.avatarText,
            avatarColor: notification.avatarColor,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.r,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: context.l10n.noNotificationsYet,
            fontsize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: context.l10n.notifyWhenNewArrives,
            fontsize: 14.sp,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class NotificationModel {
  final String title;
  final String message;
  final String time;
  final String? avatarText;
  final Color? avatarColor;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    this.avatarText,
    this.avatarColor,
  });
}