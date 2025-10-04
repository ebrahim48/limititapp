import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String splashScreen = "/splashScreen";
  static const String onBoardingScreen = "/onBoardingScreen";

  /// =============================> Auth ================================>

  static const String signUpScreen = "/signUpScreen";
  static const String logInScreen = "/logInScreen";
  static const String forgetPasswordScreen = "/forgetPasswordScreen";
  static const String verifyScreen = "/verifyScreen";
  static const String resetPasswordScreen = "/resetPasswordScreen";
  static const String termsServicesScreen = "/termsServicesScreen";
  static const String privacyPolicyScreen = "/privacyPolicyScreen";

  /// ============================> Home ================================>

  static const String homeScreen = "/homeScreen";
  static const String startCreateStoryScreen = "/startCreateStoryScreen";
  static const String nextCreateStoryScreen = "/nextCreateStoryScreen";
  static const String bottomNavbarScreen = "/bottomNavbarScreen";
  static const String everyStoryScreen = "/everyStoryScreen";
  static const String uploadCreateStoryScreen = "/uploadCreateStoryScreen";
  static const String recordStoryScreen = "/recordStoryScreen";
  static const String videoCreateStoryScreen = "/videoCreateStoryScreen";
  static const String storyScreen = "/storyScreen";
  static const String createPostStoryScreen = "/createPostStoryScreen";
  static const String storyAudioScreen = "/storyAudioScreen";
  static const String storyAudioBookScreen = "/storyAudioBookScreen";
  static const String storyImageScreen = "/storyImageScreen";
  static const String storyImageDetailsScreen = "/storyImageDetailsScreen";
  static const String storyVideoScreen = "/storyVideoScreen";
  static const String storyVideoDetailsScreen = "/storyVideoDetailsScreen";
  static const String libraryScreen = "/libraryScreen";
  static const String bookmarkScreen = "/bookmarkScreen";
  static const String downloadScreen = "/downloadScreen";
  static const String profileScreen = "/profileScreen";
  static const String personalScreen = "/personalScreen";
  static const String personalScreenUpdate = "/personalScreenUpdate";
  static const String systemSettingScreen = "/systemSettingScreen";
  static const String feedbackScreen = "/feedbackScreen";
  static const String permissionScreen = "/permissionScreen";
  static const String aboutScreen = "/aboutScreen";
  static const String questionHelpScreen = "/questionHelpScreen";
  static const String recordVideoListPageScreen = "/recordVideoListPageScreen";
  static const String recordVideoPlayerScreen = "/recordVideoPlayerScreen";
  static const String audioRecordAddPostDetailsScreen = "/audioRecordAddPostDetailsScreen";
  static const String videoRecordAddPostDetailsScreen = "/videoRecordAddPostDetailsScreen";

  static final GoRouter goRouter = GoRouter(
    initialLocation: splashScreen,
    routes: [
      // GoRoute(
      //   path: splashScreen,
      //   name: splashScreen,
      //   builder: (context, state) => const SplashScreen(),
      //   redirect: (context, state) {
      //     Future.delayed(const Duration(seconds: 3), () async {
      //       var role = await PrefsHelper.getString(AppConstants.role);
      //       var token = await PrefsHelper.getString(AppConstants.bearerToken);
      //       if (token != "") {
      //         /// ===============Role Check =============>>>
      //         if (role == "user") {
      //           AppRoutes.goRouter.replaceNamed(AppRoutes.bottomNavbarScreen);
      //         }
      //       } else {
      //         AppRoutes.goRouter.replaceNamed(AppRoutes.onBoardingScreen);
      //       }
      //     });
      //
      //     return;
      //   },
      // ),
      //
      // ///<<<=============>>> ONBOARDING SCREEN <<<===============>>>
      // GoRoute(
      //   path: onBoardingScreen,
      //   name: onBoardingScreen,
      //   pageBuilder:
      //       (context, state) =>
      //           _customTransitionPage(OnboardingScreen(), state),
      // ),
      //
      // /// =============================================================> Auth  =================================================>
      //
      // ///<<<=============>>> Sign Up SCREEN <<<===============>>>
      // GoRoute(
      //   path: signUpScreen,
      //   name: signUpScreen,
      //   pageBuilder:
      //       (context, state) => _customTransitionPage(SignUpScreen(), state),
      // ),
      //
      // ///<<<=============>>> Log In <<<===============>>>
      // GoRoute(
      //   path: logInScreen,
      //   name: logInScreen,
      //   pageBuilder:
      //       (context, state) => _customTransitionPage(LoginScreen(), state),
      // ),
      //
      // ///<<<=============>>> Forget Password Screen  <<<===============>>>
      // GoRoute(
      //   path: forgetPasswordScreen,
      //   name: forgetPasswordScreen,
      //   builder: (context, state) {
      //     String email = state.extra as String;
      //     return ForgetPasswordScreen(email: email);
      //   },
      //   // pageBuilder: (context, state) =>
      //   //     _customTransitionPage(ForgetPasswordScreen(), state),
      // ),
      //
      // ///<<<=============>>> Verify Screen  <<<===============>>>
      // GoRoute(
      //   path: verifyScreen,
      //   name: verifyScreen,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     final screenType = extra['screenType']?.toString() ?? '';
      //     final email = extra['email']?.toString() ?? '';
      //     final token = extra['token']?.toString() ?? '';
      //     return VerifyScreen(
      //       screenType: screenType,
      //       email: email,
      //       token: token,
      //     );
      //   },
      // ),
      //
      // ///<<<=============>>> Reset Password Screen  <<<===============>>>
      // GoRoute(
      //   path: resetPasswordScreen,
      //   name: resetPasswordScreen,
      //   pageBuilder:
      //       (context, state) =>
      //           _customTransitionPage(ResetPasswordScreen(), state),
      // ),
      //
      // ///<<<=============>>> Terms Services Screen  <<<===============>>>
      // GoRoute(
      //   path: termsServicesScreen,
      //   name: termsServicesScreen,
      //   pageBuilder:
      //       (context, state) =>
      //           _customTransitionPage(TermsServicesScreen(), state),
      // ),
      //
      // ///<<<=============>>> Privacy Policy Screen  <<<===============>>>
      // GoRoute(
      //   path: privacyPolicyScreen,
      //   name: privacyPolicyScreen,
      //   pageBuilder:
      //       (context, state) =>
      //           _customTransitionPage(PrivacyPolicyScreen(), state),
      // ),
      //
      // /// =============================================================> Home =================================================>
      //
      // ///<<<=============>>>  Home Screen  <<<===============>>>
      // GoRoute(
      //   path: homeScreen,
      //   name: homeScreen,
      //   pageBuilder:
      //       (context, state) => _customTransitionPage(HomeScreen(), state),
      // ),




    ],
  );

  static Page<dynamic> _customTransitionPage(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
