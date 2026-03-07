class ApiConstants{


  static const String baseUrl = "https://jakuan5000.syedbipul.me/api/v1";
  static const String imageBaseUrl = "https://jakuan5000.syedbipul.me";



  // static const String baseUrl = "https://api.limitit.eu/api/v1";
  // static const String imageBaseUrl = "https://api.limitit.eu";




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
  static const String deleteEndPoint = "/users/delete";
  static const String notificationEndPoint = "/notification?page=1&limit=10";
  static const String notificationUnreadEndPoint = "/notification/unread-count";
  static const String notificationMarkReadEndPoint = "/notification/{{notificationId}}/read";
  static const String notificationMarkAllReadEndPoint = "/notification/read-all";
  static const String notificationSingleDeleteEndPoint = "/notification/{{notificationId}}";
  static const String notificationAllClearEndPoint = "/notification/clear";
  static const String pinLockCreateEndPoint = "/pins";

  static String pinUpdateEndPoint(String pinId) => "/pins/$pinId";
  static String pinDeleteEndPoint(String pinId) => "/pins/$pinId";

  static String pinUpdateAlternativeEndPoint(String pinId) => "/pins/update/$pinId";
  static String pinDeleteAlternativeEndPoint(String pinId) => "/pins/delete/$pinId";

}