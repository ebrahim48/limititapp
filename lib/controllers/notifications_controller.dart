import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/notification_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

class NotificationsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxInt unreadCountValue = 0.obs;
  int currentPage = 1;
  int totalPages = 1;
  int totalData = 0;
  final int limit = 10;
  RxBool hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  // ===================== Fetch Notifications =====================
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        notifications.clear();
        isRefreshing(true);
      } else if (currentPage > 1) {
        isLoadingMore(true);
      } else {
        isLoading(true);
      }

      if (!hasMore.value && !isRefresh && currentPage > 1) return;

      final endpoint =
          '${ApiConstants.notificationEndPoint.split('?')[0]}?page=$currentPage&limit=$limit';

      final response = await ApiClient.getData(endpoint);

      dynamic responseBody = response.body;
      if (responseBody is String) {
        try {
          responseBody = jsonDecode(responseBody);
        } catch (e) {
          debugPrint('❌ Error parsing JSON: $e');
        }
      }

      if (response.statusCode == 200) {
        final resBody = responseBody;
        if (resBody['status'] == 'success') {
          final data = resBody['data'] as List;
          final pagination = resBody['pagination'];

          if (pagination != null) {
            totalPages = pagination['totalPage'] ?? 1;
            currentPage = pagination['currentPage'] ?? currentPage;
            totalData = pagination['totalData'] ?? 0;
            hasMore.value = currentPage < totalPages && data.length == limit;
          } else {
            hasMore.value = data.length == limit;
          }

          final newNotifications =
          data.map((item) => NotificationModel.fromJson(item)).toList();

          if (isRefresh) {
            notifications.assignAll(newNotifications);
          } else {
            notifications.addAll(newNotifications);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching notifications: $e');
      if (currentPage > 1) currentPage--;
    } finally {
      isLoading(false);
      isRefreshing(false);
      isLoadingMore(false);
    }
  }

  // ===================== Fetch Unread Count =====================
  Future<void> fetchUnreadCount() async {
    try {
      final response =
      await ApiClient.getData(ApiConstants.notificationUnreadEndPoint);

      if (response.statusCode == 200) {
        final body = response.body;
        if (body['status'] == 'success') {
          unreadCountValue.value = body['data']['unreadCount'] ?? 0;
          debugPrint('======>>> Unread Count: ${unreadCountValue.value}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching unread count: $e');
    }
  }

  // ===================== Mark Single as Read =====================
  Future<void> markAsRead(String notificationId) async {
    try {
      final endpoint = ApiConstants.notificationMarkReadEndPoint
          .replaceAll('{{notificationId}}', notificationId);

      final response = await ApiClient.postData(endpoint, {});

      if (response.statusCode == 200) {
        // Update locally
        final index =
        notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(read: true);
          notifications.refresh();
        }
        await fetchUnreadCount();
        debugPrint('======>>> Marked $notificationId as read');
      }
    } catch (e) {
      debugPrint('❌ Error marking as read: $e');
    }
  }

  // ===================== Mark All as Read =====================
  Future<void> markAllAsRead() async {
    try {
      final response = await ApiClient.patchData(ApiConstants.notificationMarkAllReadEndPoint);

      if (response.statusCode == 200) {
        // Update all locally
        notifications.assignAll(
          notifications.map((n) => n.copyWith(read: true)).toList(),
        );
        unreadCountValue.value = 0;
        debugPrint('======>>> All notifications marked as read');
      }
    } catch (e) {
      debugPrint('❌ Error marking all as read: $e');
    }
  }

  // ===================== Delete Single Notification =====================
  Future<void> deleteSingleNotification(String notificationId) async {
    try {
      final endpoint = ApiConstants.notificationSingleDeleteEndPoint
          .replaceAll('{{notificationId}}', notificationId);

      final response = await ApiClient.deleteData(endpoint);

      if (response.statusCode == 200) {
        notifications.removeWhere((n) => n.id == notificationId);
        await fetchUnreadCount();
        debugPrint('======>>> Deleted notification $notificationId');
      }
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  // ===================== Clear All Notifications =====================
  Future<void> clearAllNotifications() async {
    try {
      final response =
      await ApiClient.deleteData(ApiConstants.notificationAllClearEndPoint);

      if (response.statusCode == 200) {
        notifications.clear();
        unreadCountValue.value = 0;
        currentPage = 1;
        totalPages = 1;
        hasMore.value = false;
        debugPrint('======>>> All notifications cleared');
      }
    } catch (e) {
      debugPrint('❌ Error clearing notifications: $e');
    }
  }

  // ===================== Refresh & Load More =====================
  Future<void> refreshNotifications() async {
    hasMore.value = true;
    await fetchNotifications(isRefresh: true);
    await fetchUnreadCount();
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMore.value ||
        isLoading.value ||
        isRefreshing.value ||
        isLoadingMore.value) return;

    currentPage++;
    await fetchNotifications();
  }

  int get totalCount => notifications.length;
}