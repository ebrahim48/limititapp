import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/profile_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';


class ProfileController extends GetxController {
  final RxBool profileLoading = false.obs;
  final Rx<GetProfileModel?> userProfile = Rx<GetProfileModel?>(null);

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  /// Fetch user profile from API
  Future<void> getProfile() async {
    try {
      profileLoading(true);
      debugPrint('=====> Starting profile load...');

      final response = await ApiClient.getData(
        ApiConstants.getProfileEndPoint,
      );

      debugPrint('=========> Response Get Method : ${response.statusCode}');
      debugPrint('*********${jsonEncode(response.body)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        
        if (resBody != null && resBody['status'] == 'success' && resBody['data'] != null) {
          final data = resBody['data'];
          userProfile.value = GetProfileModel.fromJson(data);
          debugPrint('=====> Profile loaded: ${userProfile.value?.name}');
        } else {
          debugPrint('❌ Invalid response format');
        }
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('❌ Error fetching profile: $e');
      debugPrint('❌ Stack trace: $s');
    } finally {
      profileLoading(false);
      debugPrint('=====> Profile loading complete. Loading: ${profileLoading.value}, Profile: ${userProfile.value?.name}');
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await getProfile();
  }

  /// =========================================>  Update user profile   ===============================>
  Future<void> updateProfile({
    required Map<String, String> body,
    required List<MultipartBody> multipartBody,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      profileLoading(true);

      debugPrint('=====> Updating Profile...');
      debugPrint('=====> Body: $body');
      debugPrint('=====> Files: ${multipartBody.length}');

      final response = await ApiClient.patchMultipartData(
        ApiConstants.updateProfileEndPoint,
        body,
        multipartBody: multipartBody,
      );

      debugPrint('=========> Update Profile Response: ${response.statusCode}');
      debugPrint('*********${jsonEncode(response.body)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        
        if (resBody != null && resBody['status'] == 'success') {
          // Refresh profile data
          await getProfile();
          onSuccess();
        } else {
          onError(resBody?['message'] ?? 'Failed to update profile');
        }
      } else {
        onError(response.body?['message'] ?? 'Failed to update profile');
      }
    } catch (e, s) {
      debugPrint('❌ Error updating profile: $e');
      debugPrint('❌ Stack trace: $s');
      onError('Failed to update profile. Please try again.');
    } finally {
      profileLoading(false);
    }
  }
}
