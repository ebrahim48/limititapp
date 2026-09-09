import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/notifications_controller.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/notification_widget.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.addListener(() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            controller.loadMoreNotifications();
          }
        });
      }
    });

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ===================== AppBar =====================
          SliverAppBar(
            forceMaterialTransparency: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            floating: true,
            snap: true,
            titleSpacing: 0,
            title: Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon:
                  Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
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
            actions: [
              Obx(() {
                if (controller.notifications.isEmpty) return const SizedBox();
                return Row(
                  children: [
                    // Mark all as read
                    IconButton(
                      icon: Icon(
                        Icons.done_all,
                        color: AppColors.primaryColor,
                        size: 22.r,
                      ),
                      tooltip: context.l10n.markAllAsRead,
                      onPressed: () => _showMarkAllReadDialog(context, controller),
                    ),
                    // Clear all
                    IconButton(
                      icon: Icon(
                        Icons.delete_sweep_outlined,
                        color: AppColors.textColorA70D0D,
                        size: 22.r,
                      ),
                      tooltip: context.l10n.clearAll,
                      onPressed: () =>
                          _showClearAllDialog(context, controller),
                    ),
                    SizedBox(width: 4.w),
                  ],
                );
              }),
            ],
          ),

          // ===================== Body =====================
          Obx(() {
            // Initial loading
            if (controller.isLoading.value &&
                controller.notifications.isEmpty) {
              return SliverFillRemaining(
                child: _buildLoadingState(context),
              );
            }

            // Empty state
            if (controller.notifications.isEmpty) {
              return SliverFillRemaining(
                child: _buildEmptyState(context),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // Loading more indicator at bottom
                  if (index == controller.notifications.length) {
                    if (controller.isLoadingMore.value) {
                      return _buildLoadingMoreIndicator();
                    }
                    if (!controller.hasMore.value) {
                      return _buildNoMoreItemsIndicator(context);
                    }
                    return _buildLoadingMoreIndicator();
                  }

                  final notification = controller.notifications[index];

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.w, vertical: 6.h),
                    child: Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: _buildDismissBackground(),
                      confirmDismiss: (_) async {
                        return await _showDeleteConfirmDialog(context);
                      },
                      onDismissed: (_) {
                        controller.deleteSingleNotification(notification.id);
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!notification.read) {
                            controller.markAsRead(notification.id);
                          }
                        },
                        child: NotificationItemWidget(
                          title: notification.title,
                          message: notification.message,
                          time: notification.timeAgo,
                          avatarText: notification.avatarText,
                          avatarColor: _hexToColor(notification.avatarColor),
                          isRead: notification.read,
                        ),
                      ),
                    ),
                  );
                },
                childCount: controller.notifications.length +
                    (controller.hasMore.value ? 1 : 0),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===================== Dismiss Background =====================
  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.w),
      decoration: BoxDecoration(
        color: AppColors.textColorA70D0D,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 26.r,
      ),
    );
  }

  // ===================== Loading State =====================
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.h,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor:
              AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          SizedBox(height: 16.h),
          CustomText(
            text: context.l10n.loading,
            fontsize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textColor5D5D5D,
          ),
        ],
      ),
    );
  }

  // ===================== Empty State =====================
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

  // ===================== Loading More =====================
  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 30.w,
          height: 30.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor:
            AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      ),
    );
  }

  // ===================== No More Items =====================
  Widget _buildNoMoreItemsIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CustomText(
          text: context.l10n.noMoreNotifications,
          fontsize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textColor888888,
        ),
      ),
    );
  }

  // ===================== Dialogs =====================
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColors.textColorFFFFFF,
        title: CustomText(
          text: context.l10n.deleteNotification,
          fontsize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor3D3D3D,
        ),
        content: CustomText(
          text: context.l10n.deleteNotificationConfirm,
          fontsize: 14.sp,
          color: AppColors.textColor5D5D5D,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(
              text: context.l10n.cancel,
              fontsize: 14.sp,
              color: AppColors.textColor5D5D5D,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              text: context.l10n.delete,
              fontsize: 14.sp,
              color: AppColors.textColorA70D0D,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkAllReadDialog(
      BuildContext context, NotificationsController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColors.textColorFFFFFF,
        title: CustomText(
          text: context.l10n.markAllAsRead,
          fontsize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor3D3D3D,
        ),
        content: CustomText(
          text: context.l10n.markAllAsReadConfirm,
          fontsize: 14.sp,
          color: AppColors.textColor5D5D5D,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(
              text: context.l10n.cancel,
              fontsize: 14.sp,
              color: AppColors.textColor5D5D5D,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.markAllAsRead();
            },
            child: CustomText(
              text: context.l10n.confirm,
              fontsize: 14.sp,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
      BuildContext context, NotificationsController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        backgroundColor: AppColors.textColorFFFFFF,
        title: CustomText(
          text: context.l10n.clearAllNotifications,
          fontsize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textColor3D3D3D,
        ),
        content: CustomText(
          text: context.l10n.clearAllNotificationsConfirm,
          fontsize: 14.sp,
          color: AppColors.textColor5D5D5D,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(
              text: context.l10n.cancel,
              fontsize: 14.sp,
              color: AppColors.textColor5D5D5D,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearAllNotifications();
            },
            child: CustomText(
              text: context.l10n.clearAll,
              fontsize: 14.sp,
              color: AppColors.textColorA70D0D,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== Helper =====================
  Color? _hexToColor(String? hexColor) {
    if (hexColor == null) return null;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return null;
    }
  }
}