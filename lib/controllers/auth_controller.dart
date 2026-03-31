import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import '../core/app_constants/app_constants.dart';



class AuthController extends GetxController {

  bool isChecked = false;
  bool isCheckboxError = false;
  RxBool isObscure = true.obs;
  RxBool isObscureConfirmPassword = true.obs;
  RxString loginErrorMessage = ''.obs;

  toggleIsObscure() {
    isObscure.value = !isObscure.value;
  }

  toggleIsObscureConfirmPassword() {
    isObscureConfirmPassword.value = !isObscureConfirmPassword.value;
  }



  RxBool signUpLoading = false.obs;
  RxString signUpError = ''.obs;

  ///========================================== Sing up ==================================<>

  Future<void> handleSignUp({
    required String name,
    required String email,
    required String password,
    bool isPrivacy = false,
    String role = "USER",
    required BuildContext context,
    required String screenType,
  }) async {
    try {
      signUpLoading(true);
      signUpError('');

      final body = {
        "name": name,
        "email": email,
        "password": password,
        "isPrivacy": isPrivacy,
        "role": role,
      };

      final response = await ApiClient.postData(
        ApiConstants.registerEndPoint,
        jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        final data = resBody["data"];
        final email = data["email"];
        final token = data["oneTimeCode"].toString();

        await PrefsHelper.setString(AppConstants.bearerToken, token);

        // ToastMessageHelper.showToastMessage(
        //   "A verification email has been sent to $email",
        // );

        // Check if context is still mounted before navigation
        if (context.mounted) {
          context.pushNamed(
            AppRoutes.verifyScreen,
            extra: {
              "screenType": screenType,
              "email": email,
              "token": token,
            },
          );
        }
      } else {
        signUpError(response.body["message"] ?? "Something went wrong. Please try again.");
      }
    } catch (e) {
      signUpError("Signup failed. Please check your connection.");
    } finally {
      signUpLoading(false);
    }
  }


  ///========================================Verify Email===========================================<>
  RxBool verfyLoading = false.obs;

  Future<void> verfyEmail(
      String code,
      String email, {
        required String screenType,
        required BuildContext context,
      }) async {
    try {
      verfyLoading(true);

      final body = {
        "email": email,
        "code": code,
      };

      final response = await ApiClient.postData(
        ApiConstants.verifyEmailEndPoint,
        jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.body;
        final token = res["token"] ?? "";

        await PrefsHelper.setString(AppConstants.bearerToken, token);



        if (screenType == 'signup') {
          if (context.mounted) {
            context.go(AppRoutes.logInScreen);
          }
        } else if (screenType == 'forgot') {
          if (context.mounted) {
            context.go(AppRoutes.resetPasswordScreen);
          }
        }
      } else {
        ToastMessageHelper.showToastMessage(
          response.body["message"] ?? "Verification failed",
          title: 'Attention',
        );
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage("Error verifying user: $e");
    } finally {
      verfyLoading(false);
    }
  }


/// =============================================< Login +++++++++++++++++++++++++++++++++++++++++++



  RxBool loginLoading = false.obs;



  Future<void> handleLogIn(
      String email, String password,
      {required BuildContext context}) async {
    loginLoading.value = true;
    loginErrorMessage.value = '';

    var headers = {'Content-Type': 'application/json'};
    var body = {
      "email": email,
      "password": password,
    };

    try {
      var response = await ApiClient.postData(
        ApiConstants.loginEndPoint,
        jsonEncode(body),
        headers: headers,
      );

      debugPrint("========================${response.statusCode} \n ${response.body}");

      // Handle timeout or connection errors
      if (response.statusCode == 1) {
        loginLoading.value = false;
        loginErrorMessage.value = "Connection error. Please check your internet and try again.";
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.body['data'];

        debugPrint("=====> Login Response Data: $data");

        /// Access token save - try multiple possible field names
        var token = data["token"]?.toString()
                 ?? data["accessToken"]?.toString()
                 ?? data["refreshToken"]?.toString()
                 ?? "";

        debugPrint("=====> Token extracted: ${token.isEmpty ? "EMPTY" : token.substring(0, 20)}...");

        await PrefsHelper.setString(AppConstants.bearerToken, token);
        await PrefsHelper.setString(AppConstants.role, data['role'].toString());

        /// Save user details
        await PrefsHelper.setString(AppConstants.email, email);
        await PrefsHelper.setString(AppConstants.userId, data['_id'].toString());

        var role = data['role'].toString().toLowerCase();
        debugPrint("========================================= role : $role");

        loginLoading.value = false;
        loginErrorMessage.value = '';

        if (role == "user" || role == "usr") {
          await PrefsHelper.setBool(AppConstants.isLogged, true);
          if (context.mounted) {
            context.go(AppRoutes.limitPrivacyProtectionScreen);
          }
        } else {
          final message = response.body["message"];

          if (message == "Email not verified. Please verify your email.") {
            loginErrorMessage.value = "We've sent an OTP to your email. Please verify your email.";
          } else if (message == "⛔ Wrong password! ⛔") {
            loginErrorMessage.value = message;
          } else {
            await PrefsHelper.setBool(AppConstants.isLogged, true);
            if (context.mounted) {
              context.go(AppRoutes.limitPrivacyProtectionScreen);
            }
          }
        }
      } else {
        final errorMessage = response.body?["message"] ?? "Login failed. Please try again.";
        loginLoading.value = false;
        loginErrorMessage.value = errorMessage;
      }
    } catch (e) {
      debugPrint("=====> Login error: $e");
      loginLoading.value = false;
      loginErrorMessage.value = "Network error. Please check your connection and try again.";
    }
  }

  ///===========================================> Forgot Password ====================================================<>
  RxBool forgotLoading = false.obs;
  Future<void>handleForgot(String email, screenType, {required BuildContext context}) async {
    forgotLoading.value = true;
    var body = {"email": email};
    var response = await ApiClient.postData(
      ApiConstants.forgotPasswordEndPoint,
      jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.body["data"];
      String? token;

      if (responseData is String) {
        token = responseData;
      } else if (responseData is Map<String, dynamic>) {
        token = responseData["token"]?.toString() ?? responseData["oneTimeCode"]?.toString();
      }

      if (token != null) {
        await PrefsHelper.setString(AppConstants.bearerToken, token);
      } else {
        debugPrint("❌ Token missing in forgot response.");
      }

      if (screenType == "forgot") {
        if (context.mounted) {
          context.pushNamed(AppRoutes.verifyScreen, extra: {
            "screenType": "forgot",
            "email": email,
          });
        }
      }

      forgotLoading.value = false;
    } else {
      forgotLoading.value = false;
      ToastMessageHelper.showToastMessage(response.body["message"]);
    }
  }

  ///===============Set Password================<>

  RxBool setPasswordLoading = false.obs;

  setPassword(String token,password,{required BuildContext context}) async {
    setPasswordLoading(true);
    var body = {
      "token": token.toString().trim(),
      "password": password.toString().trim()
    };

    var response = await ApiClient.postData(
        ApiConstants.resetPasswordEndPoint, jsonEncode(body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (context.mounted) {
        context.pushNamed(AppRoutes.logInScreen);
      }
      // ToastMessageHelper.showToastMessage('${response.body["message"]}');
      debugPrint("======>>> successful");
      setPasswordLoading(false);
    } else if(response.statusCode == 1){
      setPasswordLoading(false);
      ToastMessageHelper.showToastMessage("Server error! \n Please try later");
    } else {
      setPasswordLoading(false);
      ToastMessageHelper.showToastMessage('${response.body["message"]}',title: 'attention');
    }
  }


  // ///===============Resend================<>
  //
  // RxBool resendLoading = false.obs;
  //
  // reSendOtp() async {
  //   resendLoading(true);
  //   String token = await PrefsHelper.getString(AppConstants.bearerToken);
  //   var headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //   var body = {};
  //   var response = await ApiClient.postData(
  //     ApiConstants.resendOtpEndPoint,
  //     jsonEncode(body),
  //     headers: headers,
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     final newToken = response.body["data"]["resetPasswordToken"] ?? response.body["data"]["verificationToken"];
  //     if (newToken != null) {
  //       await PrefsHelper.setString(AppConstants.bearerToken, newToken);
  //     } else {
  //       debugPrint("❌ Token missing in resendOtp response.");
  //     }
  //
  //     ToastMessageHelper.showToastMessage('You have got an one time code to your email');
  //     print("======>>> successful");
  //     resendLoading(false);
  //   } else {
  //     ToastMessageHelper.showToastMessage("${response.body["message"]}");
  //     resendLoading(false);
  //   }
  // }
  //
  //
  //
  //
  //
  ///===============Change Password================<>

  RxBool changePasswordLoading = false.obs;
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    try {
      changePasswordLoading(true);

      var body = {
        "currentPassword": currentPassword,
        "newPassword": newPassword,
      };

      debugPrint('=====> Changing password...');
      debugPrint('=====> Body: $body');

      final response = await ApiClient.postData(
        ApiConstants.changePasswordEndPoint, 
        jsonEncode(body),
      );

      debugPrint('=========> Response Status: ${response.statusCode}');
      debugPrint('=========> Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        
        if (resBody['status'] == 'success') {
          debugPrint('======>>> Password changed successful');
          
          // Navigate back to Settings screen
          if (context.mounted) {
            // Pop change password screen
            Navigator.pop(context);
            
            // Show success message and navigate to settings
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pop(context); // Go back to Settings
              }
            });
          }
        } else {
          ToastMessageHelper.showToastMessage(resBody['message'] ?? 'Failed to change password');
        }
        
        changePasswordLoading(false);
      } else {
        final errorMessage = response.body?['message'] ?? 'Server error! Please try later';
        ToastMessageHelper.showToastMessage(errorMessage);
        changePasswordLoading(false);
      }
    } catch (e) {
      debugPrint('❌ Change password error: $e');
      ToastMessageHelper.showToastMessage('Server error! Please try later');
      changePasswordLoading(false);
    }
  }
  //
  ///=============== Delete Account ================<>

  RxBool deleteLoading = false.obs;

  Future<void> deleteAccount({
    required String password,
    required BuildContext context,
  }) async {
    try {
      deleteLoading(true);

      final body = {
        "password": password,
      };

      debugPrint('=====> Deleting account...');
      debugPrint('=====> Body: $body');

      final response = await ApiClient.postData(
        ApiConstants.deleteEndPoint,
        jsonEncode(body),
      );

      debugPrint('========> Response Status: ${response.statusCode}');
      debugPrint('========> Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final resBody = response.body;

        if (resBody['status'] == 'success') {
          debugPrint('======>>> Account deleted successfully');

          // Clear all stored data
          await PrefsHelper.remove(AppConstants.bearerToken);
          await PrefsHelper.remove(AppConstants.userId);
          await PrefsHelper.remove(AppConstants.email);
          await PrefsHelper.remove(AppConstants.role);
          await PrefsHelper.setBool(AppConstants.isLogged, false);

          if (context.mounted) {
            Get.offAllNamed(AppRoutes.logInScreen);
          }
        } else {
          // No toast - just navigate to login
          if (context.mounted) {
            Get.offAllNamed(AppRoutes.logInScreen);
          }
        }
      } else if (response.statusCode == 401) {
        // Handle already deleted account or unauthorized
        final resBody = response.body;
        final message = resBody?['message'] ?? 'Unauthorized';
        
        if (message.contains('deleted')) {
          // Account was already deleted, clear local data
          await PrefsHelper.remove(AppConstants.bearerToken);
          await PrefsHelper.remove(AppConstants.userId);
          await PrefsHelper.remove(AppConstants.email);
          await PrefsHelper.remove(AppConstants.role);
          await PrefsHelper.setBool(AppConstants.isLogged, false);
          
          if (context.mounted) {
            Get.offAllNamed(AppRoutes.logInScreen);
          }
        } else {

        }
      } else {

      }
    } catch (e) {
      debugPrint('❌ Delete account error: $e');

    } finally {
      deleteLoading(false);
    }
  }
}