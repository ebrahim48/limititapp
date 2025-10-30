import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import '../core/app_constants/app_constants.dart';
import '../core/constants/app_colors.dart';



class AuthController extends GetxController {

  bool isChecked = false;
  bool isCheckboxError = false;
  RxBool isObscure = true.obs;
  RxBool isObscureConfirmPassword = true.obs;

  toggleIsObscure() {
    isObscure.value = !isObscure.value;
  }

  toggleIsObscureConfirmPassword() {
    isObscureConfirmPassword.value = !isObscureConfirmPassword.value;
  }



  RxBool signUpLoading = false.obs;

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

        ToastMessageHelper.showToastMessage(
          "A verification email has been sent to $email",
        );

        context.pushNamed(
          AppRoutes.verifyScreen,
          extra: {
            "screenType": screenType,
            "email": email,
            "token": token,
          },
        );
      } else {
        final msg = response.body["message"] ?? "Attention";
        ToastMessageHelper.showToastMessage(msg);
      }
    } catch (e) {
      ToastMessageHelper.showToastMessage("Signup failed: $e");
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

        ToastMessageHelper.showToastMessage(res["message"] ?? "Verification successful");


        if (screenType == 'signup') {
          context.go(AppRoutes.logInScreen);
        } else if (screenType == 'forgot') {
          context.go(AppRoutes.resetPasswordScreen);
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

    var headers = {'Content-Type': 'application/json'};
    var body = {
      "email": email,
      "password": password,
    };

    var response = await ApiClient.postData(
      ApiConstants.loginEndPoint,
      jsonEncode(body),
      headers: headers,
    );

    loginLoading.value = false;

    print("========================${response.statusCode} \n ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = response.body['data'];



      /// Access token save
      var token = data["token"].toString();

      await PrefsHelper.setString(AppConstants.bearerToken, token,);
      await PrefsHelper.setString(AppConstants.role, data['role'].toString());

      /// Save user details
      await PrefsHelper.setString(AppConstants.email, email);
      await PrefsHelper.setString(AppConstants.userId, data['_id'].toString());

      var role = data['role'].toString().toLowerCase();
      print("========================================= role : $role");

      if (role == "user" || role == "usr") {
        await PrefsHelper.setBool(AppConstants.isLogged, true);
        context.go(AppRoutes.limitPrivacyProtectionScreen);
        ToastMessageHelper.showToastMessage("You are logged in",title: 'Success');
      } else {
        final message = response.body["message"];

        if (message == "Email not verified. Please verify your email.") {
          ToastMessageHelper.showToastMessage(
            "We've sent an OTP to your email. Please verify your email.",
          );
        } else if (message == "⛔ Wrong password! ⛔") {
          ToastMessageHelper.showToastMessage(message);
        } else {
          await PrefsHelper.setBool(AppConstants.isLogged, true);
          context.go(AppRoutes.limitPrivacyProtectionScreen);
          ToastMessageHelper.showToastMessage(
            message ?? "You are logged in",
            title: 'Success');
        }
      }

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
        context.pushNamed(AppRoutes.verifyScreen, extra: {
          "screenType": "forgot",
          "email": email,
        });
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
      context.pushNamed(AppRoutes.logInScreen);
      ToastMessageHelper.showToastMessage('${response.body["message"]}');
      print("======>>> successful");
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
  // ///===============Change Password================<>
  //
  // RxBool changePasswordLoading = false.obs;
  // changePassword(String currentPassword, password ,confirmPassword ) async {
  //   changePasswordLoading(true);
  //   var body = {
  //     "currentPassword": "$currentPassword",
  //     "password": "$password",
  //     "confirmPassword" : "$confirmPassword"
  //   };
  //
  //   var response =
  //   await ApiClient.postData(ApiConstants.changePassword, jsonEncode(body));
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     ToastMessageHelper.showToastMessage('Password Changed Successful');
  //     print("======>>> successful");
  //     changePasswordLoading(false);
  //   } else if(response.statusCode == 1){
  //     changePasswordLoading(false);
  //     ToastMessageHelper.showToastMessage("Server error! \n Please try later");
  //   } else {
  //     ToastMessageHelper.showToastMessage(response.body['message']);
  //     changePasswordLoading(false);
  //   }
  // }
  //
  // ///=============== Delete Account ================<>
  //
  //
  // var deleteLoading = false.obs;
  // userDelete(BuildContext context) async {
  //
  //   deleteLoading(true);
  //   var response = await ApiClient.deleteData(
  //       ApiConstants.deleteEndPoint);
  //   if (response.statusCode == 200) {
  //     ToastMessageHelper.showToastMessage('Account Delete Successfully');
  //     context.pushNamed(AppRoutes.logInScreen);
  //   } else {
  //     deleteLoading(false);
  //   }
  //
  // }

}