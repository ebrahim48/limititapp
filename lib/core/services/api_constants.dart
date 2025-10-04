class ApiConstants{

  static const String baseUrl = "https://jakuan8080.syedbipul.me/api/v1";
  static const String imageBaseUrl = "https://jakuan8080.syedbipul.me";







  static const String signUpEndPoint = "/auth/register";
  static const String loginUpEndPoint = "/auth/login";
  static const String changePassword = "/auth/change-password";
  static const String verifyEmailEndPoint = "/auth/verify-email";
  static const String forgotPasswordEndPoint = "/auth/forgot-password";
  static const String resetPasswordEndPoint = "/auth/reset-password";
  static const String resendOtpEndPoint = "/auth/resend-otp";


  static const String getAllTagsEndPoint = "/tag/tags";
  static String updateTagEndPoint(String id) => "/tag/tags/$id";
  static const String uploadEndPoint = "/story/story";
  static const String getLatestFormEndPoint = "/story/story";
  static const String getWorkingDaysEndPoint = "/story/working-days";
  static const String getStoryStepsEndPoint = "/story/story-steps";
  static String getStorySingleEndPoint(String id) => "/story/story/$id";
  static  String getMyStoryEndPoint(String page) =>  "/story/stories?page=$page";
  static  String getStoryLibraryEndPoint = "/story/libraryData";
  static  String bookMarkEndPoint = "/story/bookmark";
  static  String userProfileEndPoint = "/user/profile";
  static  String userUpdateProfileEndPoint = "/user/profile";
  static  String deleteProfileEndPoint = "/user/profile";
  static  String feedbackEndPoint = "/feedback/feedbacks";
  static  String privacyEndPoint = "/setting/privacy-policy";
  static  String aboutEndPoint = "/setting/about-us";
  static  String termsEndPoint = "/setting/terms-conditions";

}