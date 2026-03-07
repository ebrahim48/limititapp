import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import 'package:limit_it_app/core/services/pin_lock_storage_service.dart';
import '../core/app_constants/app_constants.dart';

class PinLockController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isUpdating = false.obs;

  /// Get all user's PINs from API
  Future<List<Map<String, dynamic>>> getUserPins() async {
    try {
      debugPrint('====> Fetching user PINs...');
      
      final bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken);
      final isLoggedIn = bearerToken != null && bearerToken.isNotEmpty;
      
      if (!isLoggedIn) {
        debugPrint('⚠️ User not logged in, returning empty list');
        return [];
      }

      final response = await ApiClient.getData('/pins');
      
      debugPrint('========> Get PINs Response Status: ${response.statusCode}');
      debugPrint('========> Get PINs Response Body: ${response.body}');

      if (response.statusCode == 200 && response.body != null) {
        final resBody = response.body;
        if (resBody['status'] == 'success') {
          final data = resBody['data'];
          
          // Handle different response structures
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          } else if (data is Map) {
            // If data is a Map, check if it contains a list
            if (data['pins'] is List) {
              return (data['pins'] as List).map((item) => item as Map<String, dynamic>).toList();
            }
            // If data is a single item Map, wrap it in a list
            return [data as Map<String, dynamic>];
          }
          
          debugPrint('⚠️ Unexpected data format: $data');
          return [];
        }
      }

      return [];
    } catch (e) {
      debugPrint("=====> Get PINs error: $e");
      return [];
    }
  }

  /// Create PIN lock via API or locally if not logged in
  Future<void> createPinLock({
    required String providerName,
    required String pinCode,
    required BuildContext context,
  }) async {
    try {
      isLoading(true);

      debugPrint('====> Creating PIN lock...');
      debugPrint('====> Provider: $providerName');
      debugPrint('====> PIN: $pinCode');
      debugPrint('====> Endpoint: ${ApiConstants.pinLockCreateEndPoint}');
      debugPrint('====> Base URL: ${ApiConstants.baseUrl}');

      // Check if user is logged in
      final bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken);
      final isLoggedIn = bearerToken != null && bearerToken.isNotEmpty;
      
      debugPrint('====> User Logged In: $isLoggedIn');
      debugPrint('====> Bearer Token: ${isLoggedIn ? "${bearerToken.substring(0, 20)}..." : "NOT SET"}');

      final body = {
        "providerName": providerName,
        "pincode": pinCode,
      };

      debugPrint('====> Request Body: ${jsonEncode(body)}');

      // Save PIN locally first (works offline)
      final pinLockService = Get.find<PinLockStorageService>();
      await pinLockService.savePinCode(pinCode);
      debugPrint('======>>> PIN saved locally');

      // If user is logged in, try to save to API
      if (isLoggedIn) {
        debugPrint('====> Attempting to save to API...');
        debugPrint('====> Full URL: ${ApiConstants.baseUrl}${ApiConstants.pinLockCreateEndPoint}');

        // Send with authentication headers (don't override Content-Type)
        final response = await ApiClient.postData(
          ApiConstants.pinLockCreateEndPoint,
          jsonEncode(body),
        );

        debugPrint('========> PIN Lock Response Status: ${response.statusCode}');
        debugPrint('========> PIN Lock Response Headers: ${response.headers}');
        debugPrint('========> PIN Lock Response Body: ${response.body}');

        isLoading(false);

        // Handle timeout or connection errors
        if (response.statusCode == 1) {
          ToastMessageHelper.showToastMessage(
            response.statusText ?? "Connection error. Please check your internet and try again.",
          );
          _navigateBack(context);
          return;
        }

        // Handle server errors (500, 502, 503, etc.)
        if (response.statusCode != null && response.statusCode! >= 500 && response.statusCode! < 600) {
          final errorMessage = response.body?['message'] ?? "Server error. Please try again later.";
          final statusCode = response.statusCode;
          
          debugPrint('❌ Server Error ($statusCode): $errorMessage');
          debugPrint('⚠️ PIN saved locally but could not sync to server.');
          debugPrint('📝 Response body: ${response.body}');
          
          // Show user-friendly message based on status code
          String userMessage;
          switch (statusCode) {
            case 500:
              userMessage = 'Server error. PIN saved locally and will sync when server is available.';
              break;
            case 502:
              userMessage = 'Bad gateway. PIN saved locally and will sync later.';
              break;
            case 503:
              userMessage = 'Service unavailable. PIN saved locally and will sync later.';
              break;
            default:
              userMessage = 'Server error ($statusCode). PIN saved locally.';
          }
          
          ToastMessageHelper.showToastMessage(
            userMessage,
            title: 'Warning',
          );
          _navigateBack(context);
          return;
        }

        // Handle client errors (400, 401, 403, 404, etc.)
        if (response.statusCode != null && response.statusCode! >= 400 && response.statusCode! < 500) {
          final errorMessage = response.body?['message'] ?? "Failed to create PIN lock.";
          debugPrint('❌ Client Error: $errorMessage');
          ToastMessageHelper.showToastMessage(
            errorMessage,
            title: 'Error',
          );
          return;
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resBody = response.body;

          if (resBody['status'] == 'success') {
            debugPrint('======>>> PIN created successfully on server');

            // ToastMessageHelper.showToastMessage(
            //   resBody['message'] ?? 'PIN lock created successfully',
            //   title: 'Success',
            // );

            _navigateBack(context);
          } else {
            final errorMessage = resBody['message'] ?? 'Failed to create PIN lock';
            ToastMessageHelper.showToastMessage(errorMessage);
          }
        } else {
          final errorMessage = response.body?["message"] ?? "Failed to create PIN lock. Please try again.";
          ToastMessageHelper.showToastMessage(errorMessage);
        }
      } else {
        // User not logged in - save locally only
        isLoading(false);
        debugPrint('⚠️ User not logged in. PIN saved locally only.');
        
        // ToastMessageHelper.showToastMessage(
        //   'PIN saved locally. Log in to sync across devices.',
        //   title: 'Success',
        // );

        _navigateBack(context);
      }
    } catch (e) {
      debugPrint("=====> Create PIN lock error: $e");
      isLoading(false);
      ToastMessageHelper.showToastMessage(
        "Network error. PIN saved locally.",
        title: 'Warning',
      );
      _navigateBack(context);
    }
  }

  /// Helper to navigate back
  void _navigateBack(BuildContext context) {
    if (context.mounted) {
      // Pop set PIN screen
      Navigator.pop(context);
      
      // Pop pin lock limits screen  
      Navigator.pop(context);
    }
  }

  /// Verify PIN lock
  Future<bool> verifyPinLock({
    required String pinCode,
  }) async {
    try {
      final pinLockService = Get.find<PinLockStorageService>();
      final storedPin = await pinLockService.getPinCode();

      return storedPin == pinCode;
    } catch (e) {
      debugPrint("=====> Verify PIN lock error: $e");
      return false;
    }
  }

  /// Update PIN lock via API
  Future<void> updatePinLock({
    required String pinId,
    required String providerName,
    required String pinCode,
    required BuildContext context,
  }) async {
    try {
      isUpdating(true);

      debugPrint('====> Updating PIN lock...');
      debugPrint('====> PIN ID: $pinId');
      debugPrint('====> Provider: $providerName');
      debugPrint('====> New PIN: $pinCode');

      final body = {
        "providerName": providerName,
        "pincode": pinCode,
      };

      debugPrint('====> Request Body: ${jsonEncode(body)}');

      // Try primary endpoint first
      var response = await ApiClient.postData(
        ApiConstants.pinUpdateEndPoint(pinId),
        jsonEncode(body),
      );

      debugPrint('========> Update PIN Response Status: ${response.statusCode}');
      debugPrint('========> Update PIN Response Body: ${response.body}');

      // If 404, try alternative endpoint
      if (response.statusCode == 404) {
        debugPrint('⚠️ Primary endpoint not found, trying alternative endpoint...');
        response = await ApiClient.postData(
          ApiConstants.pinUpdateAlternativeEndPoint(pinId),
          jsonEncode(body),
        );
        
        debugPrint('========> Update PIN (Alternative) Response Status: ${response.statusCode}');
        debugPrint('========> Update PIN (Alternative) Response Body: ${response.body}');
      }

      isUpdating(false);

      if (response.statusCode == 1) {
        ToastMessageHelper.showToastMessage(
          response.statusText ?? "Connection error. Please try again.",
        );
        return;
      }

      // Handle 404 - Route not found (backend feature not implemented)
      if (response.statusCode == 404) {
        debugPrint('❌ 404 Error: Update PIN endpoint not implemented on server');
        debugPrint('💡 Feature update: PIN update feature requires backend implementation');
        
        // Update locally anyway
        final pinLockService = Get.find<PinLockStorageService>();
        await pinLockService.savePinCode(pinCode);
        
        ToastMessageHelper.showToastMessage(
          'PIN updated locally. Server sync will be available soon.',
          title: 'Updated Locally',
        );
        
        // Navigate back
        if (context.mounted) {
          Navigator.pop(context); // Pop SetNewPinNumberScreen
          Navigator.pop(context); // Pop PinSettingsScreen
        }
        return;
      }

      if (response.statusCode != null && response.statusCode! >= 500) {
        ToastMessageHelper.showToastMessage(
          'Server error. Please try again later.',
          title: 'Error',
        );
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        if (resBody['status'] == 'success') {
          debugPrint('======>>> PIN updated successfully');

          // Update local storage
          final pinLockService = Get.find<PinLockStorageService>();
          await pinLockService.savePinCode(pinCode);

          // ToastMessageHelper.showToastMessage(
          //   resBody['message'] ?? 'PIN updated successfully',
          //   title: 'Success',
          // );

          // Navigate back twice to return to PinSettingsScreen
          if (context.mounted) {
            Navigator.pop(context); // Pop SetNewPinNumberScreen
            Navigator.pop(context); // Pop PinSettingsScreen
          }
        } else {
          ToastMessageHelper.showToastMessage(
            resBody['message'] ?? 'Failed to update PIN',
          );
        }
      } else {
        ToastMessageHelper.showToastMessage(
          response.body?['message'] ?? 'Failed to update PIN',
        );
      }
    } catch (e) {
      debugPrint("=====> Update PIN lock error: $e");
      isUpdating(false);
      ToastMessageHelper.showToastMessage(
        "Network error. Please try again.",
        title: 'Error',
      );
    }
  }

  /// Delete PIN lock via API
  Future<void> deletePinLock({
    required String pinId,
    required BuildContext context,
  }) async {
    try {
      isDeleting(true);

      debugPrint('====> Deleting PIN lock...');
      debugPrint('====> PIN ID: $pinId');

      // Try primary endpoint first
      var response = await ApiClient.postData(
        ApiConstants.pinDeleteEndPoint(pinId),
        {},
      );

      debugPrint('========> Delete PIN Response Status: ${response.statusCode}');
      debugPrint('========> Delete PIN Response Body: ${response.body}');

      // If 404, try alternative endpoint
      if (response.statusCode == 404) {
        debugPrint('⚠️ Primary endpoint not found, trying alternative endpoint...');
        response = await ApiClient.postData(
          ApiConstants.pinDeleteAlternativeEndPoint(pinId),
          {},
        );
        
        debugPrint('========> Delete PIN (Alternative) Response Status: ${response.statusCode}');
        debugPrint('========> Delete PIN (Alternative) Response Body: ${response.body}');
      }

      isDeleting(false);

      if (response.statusCode == 1) {
        ToastMessageHelper.showToastMessage(
          response.statusText ?? "Connection error. Please try again.",
        );
        return;
      }

      // Handle 404 - Route not found (backend feature not implemented)
      if (response.statusCode == 404) {
        debugPrint('❌ 404 Error: Delete PIN endpoint not implemented on server');
        debugPrint('💡 Feature update: PIN delete feature requires backend implementation');
        
        // Clear local PIN anyway
        final pinLockService = Get.find<PinLockStorageService>();
        await pinLockService.clearPinLockSettings();
        
        // ToastMessageHelper.showToastMessage(
        //   'PIN deleted locally. Server sync will be available soon.',
        //   title: 'Deleted Locally',
        // );
        
        // Refresh the PIN list - go back to PinSettingsScreen
        if (context.mounted) {
          Navigator.pop(context);
        }
        return;
      }

      if (response.statusCode != null && response.statusCode! >= 500) {
        ToastMessageHelper.showToastMessage(
          'Server error. Please try again later.',
          title: 'Error',
        );
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        if (resBody['status'] == 'success') {
          debugPrint('======>>> PIN deleted successfully');

          // Clear local PIN
          final pinLockService = Get.find<PinLockStorageService>();
          await pinLockService.clearPinLockSettings();

          // ToastMessageHelper.showToastMessage(
          //   resBody['message'] ?? 'PIN deleted successfully',
          //   title: 'Success',
          // );

          // Refresh the PIN list - go back to PinSettingsScreen
          if (context.mounted) {
            Navigator.pop(context);
          }
        } else {
          ToastMessageHelper.showToastMessage(
            resBody['message'] ?? 'Failed to delete PIN',
          );
        }
      } else {
        ToastMessageHelper.showToastMessage(
          response.body?['message'] ?? 'Failed to delete PIN',
        );
      }
    } catch (e) {
      debugPrint("=====> Delete PIN lock error: $e");
      isDeleting(false);
      ToastMessageHelper.showToastMessage(
        "Network error. Please try again.",
        title: 'Error',
      );
    }
  }
}
