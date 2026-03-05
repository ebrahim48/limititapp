class ApiConstants{

  static const String baseUrl = "https://api.limitit.eu/api/v1";
  static const String imageBaseUrl = "https://api.limitit.eu";







  static const String registerEndPoint = "/users/register";
  static const String loginEndPoint = "/users/sign-in";
  static const String changePasswordEndPoint = "/users/change-password";
  static const String verifyEmailEndPoint = "/users/verify-code";
  static const String forgotPasswordEndPoint = "/users/forgot-password";
  static const String resetPasswordEndPoint = "/users/set-password";
  static const String resendOtpEndPoint = "/users/resend-otp";

  static const String aboutUsPoint = "/settings/about-us";
  static const String privacyPolicyPoint = "/settings/privacy-policy";
  static const String termsConditionPoint = "/settings/terms-condition";


  static const String getProfileEndPoint = "/settings/get-login-user";
  static const String updateProfileEndPoint = "/users/profile";
  static const String motivationalPhrasesEndPoint = "/motivation?page=1&limit=10";
  static const String getAllAdsEndPoint = "/ads?page=1&limit=10";



}