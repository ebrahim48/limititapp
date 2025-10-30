import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/presentations/screens/Home/home_screen.dart';
import 'package:limit_it_app/core/presentations/screens/Home/profile/view_profile_screen.dart';
import 'package:limit_it_app/core/presentations/screens/Home/profile/view_update_profile_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/forget/forget_password_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/limitItScreenTime/limit_privacy.dart';
import 'package:limit_it_app/core/presentations/screens/auth/limitItScreenTime/select_apps_manage.dart';
import 'package:limit_it_app/core/presentations/screens/auth/limitItScreenTime/set_usage_limit_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/limitItScreenTime/timer_settings_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/limitItScreenTime/timer_success_message.dart';
import 'package:limit_it_app/core/presentations/screens/auth/reset/reset_password_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/reset/reset_successfully_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/signin/sign_in%20_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/signup/sign_up_screen.dart';
import 'package:limit_it_app/core/presentations/screens/auth/verify/verify_screen.dart';
import 'package:limit_it_app/core/presentations/screens/bottomnavbar/bottom_navbar_screen.dart';
import 'package:limit_it_app/core/presentations/screens/limits/detox_mode_screen.dart';
import 'package:limit_it_app/core/presentations/screens/limits/edit_timer_settings.dart';
import 'package:limit_it_app/core/presentations/screens/limits/edit_usage_limit.dart';
import 'package:limit_it_app/core/presentations/screens/limits/limit_screen_time.dart';
import 'package:limit_it_app/core/presentations/screens/limits/limits_screen.dart';
import 'package:limit_it_app/core/presentations/screens/limits/pin_lock_screen.dart';
import 'package:limit_it_app/core/presentations/screens/limits/schedules_limits_screen.dart';
import 'package:limit_it_app/core/presentations/screens/limits/set_pin_number_screen.dart';
import 'package:limit_it_app/core/presentations/screens/notifications/notifications_screen.dart';
import 'package:limit_it_app/core/presentations/screens/onboarding/language_screen.dart';
import 'package:limit_it_app/core/presentations/screens/onboarding/onboarding_screen.dart';
import 'package:limit_it_app/core/presentations/screens/onboarding/onboarding_start_screen.dart';
import 'package:limit_it_app/core/presentations/screens/reports/reports_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/about_us_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/change_password.dart';
import 'package:limit_it_app/core/presentations/screens/settings/motivation_phrases.dart';
import 'package:limit_it_app/core/presentations/screens/settings/privacy_policy_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/save_motivation_phrases.dart';
import 'package:limit_it_app/core/presentations/screens/settings/settings_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/subscription_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/terms_screen.dart';
import 'package:limit_it_app/core/presentations/screens/settings/upgrade_premium.dart';
import 'package:limit_it_app/core/presentations/screens/splash/splash_screen.dart';


class AppRoutes {
  static const String splashScreen = "/splashScreen";
  static const String onBoardingScreen = "/onBoardingScreen";
  static const String languageScreen = "/languageScreen";
  static const String onBoardingStartScreen = "/onBoardingStartScreen";

  /// =============================> Auth ================================>

  static const String signUpScreen = "/signUpScreen";
  static const String logInScreen = "/logInScreen";
  static const String forgetPasswordScreen = "/forgetPasswordScreen";
  static const String verifyScreen = "/verifyScreen";
  static const String resetPasswordScreen = "/resetPasswordScreen";
  static const String resetSuccessFullyScreen = "/resetSuccessFullyScreen";
  static const String termsServicesScreen = "/termsServicesScreen";
  static const String privacyPolicyScreen = "/privacyPolicyScreen";
  static const String limitPrivacyProtectionScreen = "/limitPrivacyProtectionScreen";
  static const String selectAppsManageScreen = "/selectAppsManageScreen";
  static const String setUsageLimitScreen = "/setUsageLimitScreen";
  static const String timerSettingsScreen = "/timerSettingsScreen";
  static const String timerSuccessScreen = "/timerSuccessScreen";

  /// ============================> Home ================================>

  static const String homeScreen = "/homeScreen";
  static const String bottomNavBarScreen = "/bottomNavBarScreen";
  static const String limitsScreen = "/limitsScreen";
  static const String limitScreenTime = "/limitScreenTime";
  static const String editUsageLimitScreen = "/editUsageLimitScreen";
  static const String editTimerSettingsScreen = "/editTimerSettingsScreen";
  static const String schedulesLimitsScreen = "/schedulesLimitsScreen";
  static const String pinLockLimitsScreen = "/pinLockLimitsScreen";
  static const String setPinNumberScreen = "/setPinNumberScreen";
  static const String detoxModeScreen = "/detoxModeScreen";
  static const String reportsScreen = "/reportsScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String motivationPhrasesScreen = "/motivationPhrasesScreen";
  static const String saveMotivationPhrasesScreen = "/saveMotivationPhrasesScreen";
  static const String subscriptionScreen = "/subscriptionScreen";
  static const String upgradePremiumScreen = "/upgradePremiumScreen";
  static const String changePasswordScreen = "/changePasswordScreen";
  static const String aboutUsScreen = "/aboutUsScreen";
  static const String viewProfileScreen = "/viewProfileScreen";
  static const String editProfileScreen = "/editProfileScreen";
  static const String notificationsScreen = "/notificationsScreen";




  static final GoRouter goRouter = GoRouter(
    initialLocation: splashScreen,
    routes: [
      GoRoute(
        path: splashScreen,
        name: splashScreen,
        builder: (context, state) => const SplashScreen(),
        redirect: (context, state) {
          Future.delayed(const Duration(seconds: 3), () async {
              AppRoutes.goRouter.replaceNamed(AppRoutes.onBoardingScreen);
            }
          );

          return;
        },
      ),

      ///<<<=============>>> ONBOARDING SCREEN <<<===============>>>
      GoRoute(
        path: onBoardingScreen,
        name: onBoardingScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(OnboardingScreen(), state),
      ),

      ///<<<=============>>> Language SCREEN <<<===============>>>
      GoRoute(
        path: languageScreen,
        name: languageScreen,
        pageBuilder:
            (context, state) =>
            _customTransitionPage(LanguageScreen(), state),
      ),


      ///<<<=============>>> ONBOARDING Start SCREEN <<<===============>>>
      GoRoute(
        path: onBoardingStartScreen,
        name: onBoardingStartScreen,
        pageBuilder:
            (context, state) =>
            _customTransitionPage(OnboardingStartScreen(), state),
      ),

      /// =============================================================> Auth  =================================================>

      ///<<<=============>>> Sign Up SCREEN <<<===============>>>
      GoRoute(
        path: signUpScreen,
        name: signUpScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(SignUpScreen(), state),
      ),

      ///<<<=============>>> Log In <<<===============>>>
      GoRoute(
        path: logInScreen,
        name: logInScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(LoginInScreen(), state),
      ),

      ///<<<=============>>> Forget Password Screen  <<<===============>>>
      GoRoute(
        path: forgetPasswordScreen,
        name: forgetPasswordScreen,
        builder: (context, state) {
          String email = state.extra as String;
          return ForgetPasswordScreen(email: email);
        },

      ),

      ///<<<=============>>> Verify Screen  <<<===============>>>
      GoRoute(
        path: verifyScreen,
        name: verifyScreen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final screenType = extra['screenType']?.toString() ?? '';
          final email = extra['email']?.toString() ?? '';
          final token = extra['token']?.toString() ?? '';
          return VerifyScreen(
            screenType: screenType,
            email: email,
            token: token,
          );
        },

      ),

      ///<<<=============>>> Reset Password Screen  <<<===============>>>
      GoRoute(
        path: resetPasswordScreen,
        name: resetPasswordScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(ResetPasswordScreen(), state),
      ),

      ///<<<=============>>> Reset Successfully Password Screen  <<<===============>>>
      GoRoute(
        path: resetSuccessFullyScreen,
        name: resetSuccessFullyScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(ResetSuccessFullyScreen(), state),
      ),
      ///<<<=============>>>LimitPrivacyProtectionScreen <<<===============>>>
      GoRoute(
        path: limitPrivacyProtectionScreen,
        name: limitPrivacyProtectionScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(LimitPrivacyProtectionScreen(), state),
      ),
      ///<<<=============>>>selectAppsManageScreen <<<===============>>>

      GoRoute(
        path: selectAppsManageScreen,
        name: selectAppsManageScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SelectAppsManageScreen(), state),
      ),

      ///<<<=============>>>setUsageLimitScreen <<<===============>>>

      GoRoute(
        path: setUsageLimitScreen,
        name: setUsageLimitScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SetUsageLimitScreen(), state),
      ),

      ///<<<=============>>>Timer Settings Screen <<<===============>>>

      GoRoute(
        path: timerSettingsScreen,
        name: timerSettingsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(TimerSettingsScreen(), state),
      ),

      ///<<<=============>>>Timer Success Screen <<<===============>>>
      GoRoute(
        path: timerSuccessScreen,
        name: timerSuccessScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(TimerSuccessScreen(), state),
      ),
      ///<<<=============>>> Home Screen <<<===============>>>

      GoRoute(
        path: homeScreen,
        name: homeScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(HomeScreen(), state),
      ),
      ///<<<=============>>> Bottom  Screen <<<===============>>>
      GoRoute(
        path: bottomNavBarScreen,
        name: bottomNavBarScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(BottomNavBarScreen(), state),
      ),

      ///<<<=============>>> Home Screen <<<===============>>>
      GoRoute(
        path: limitsScreen,
        name: limitsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(LimitsScreen(), state),
      ),

      ///<<<=============>>> Limit Screen Time  <<<===============>>>
      GoRoute(
        path: limitScreenTime,
        name: limitScreenTime,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(LimitScreenTime(), state),
      ),

      ///<<<=============>>> EditTimer Settings Screen  <<<===============>>>
      GoRoute(
        path: editTimerSettingsScreen,
        name: editTimerSettingsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(EditTimerSettingsScreen(), state),
      ),


      GoRoute(
        path: editUsageLimitScreen,
        name: editUsageLimitScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(EditUsageLimitScreen(), state),
      ),

      ///<<<=============>>> Schedules Limits Screen  <<<===============>>>
      GoRoute(
        path: schedulesLimitsScreen,
        name: schedulesLimitsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SchedulesLimitsScreen(), state),
      ),
      ///<<<=============>>> Pin Lock Limits Screen  <<<===============>>>


      GoRoute(
        path: pinLockLimitsScreen,
        name: pinLockLimitsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(PinLockLimitsScreen(), state),
      ),

      ///<<<=============>>> Set Pin Number Screen  <<<===============>>>

      GoRoute(
        path: setPinNumberScreen,
        name: setPinNumberScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SetPinNumberScreen(), state),
      ),

      ///<<<=============>>> Detox Mode Screen  <<<===============>>>

      GoRoute(
        path: detoxModeScreen,
        name: detoxModeScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(DetoxModeScreen(), state),
      ),

      ///<<<=============>>> Reports Screen  <<<===============>>>

      GoRoute(
        path: reportsScreen,
        name: reportsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(ReportsScreen(), state),
      ),

      ///<<<=============>>> Settings Screen  <<<===============>>>

      GoRoute(
        path: settingsScreen,
        name: settingsScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SettingsScreen(), state),
      ),

      ///<<<=============>>> Motivation Phrases Screen  <<<===============>>>

      GoRoute(
        path: motivationPhrasesScreen,
        name: motivationPhrasesScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(MotivationPhrasesScreen(), state),
      ),

      ///<<<=============>>> Save Motivation Phrases Screen  <<<===============>>>

      GoRoute(
        path: saveMotivationPhrasesScreen,
        name: saveMotivationPhrasesScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SaveMotivationPhrasesScreen(), state),
      ),

      ///<<<=============>>> Subscription Screen  <<<===============>>>

      GoRoute(
        path: subscriptionScreen,
        name: subscriptionScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(SubscriptionScreen(), state),
      ),

      ///<<<=============>>> Upgrade Premium Screen  <<<===============>>>


      GoRoute(
        path: upgradePremiumScreen,
        name: upgradePremiumScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(UpgradePremiumScreen(), state),
      ),

      ///<<<=============>>> Change Password Screen  <<<===============>>>

      GoRoute(
        path: changePasswordScreen,
        name: changePasswordScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(ChangePasswordScreen(), state),
      ),



      ///<<<=============>>> Terms Services Screen  <<<===============>>>
      GoRoute(
        path: termsServicesScreen,
        name: termsServicesScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(TermsServicesScreen(), state),
      ),

      ///<<<=============>>> Privacy Policy Screen  <<<===============>>>
      GoRoute(
        path: privacyPolicyScreen,
        name: privacyPolicyScreen,
        pageBuilder:
            (context, state) =>
                _customTransitionPage(PrivacyPolicyScreen(), state),
      ),

      ///// ===========================================================> About Us  =================================================>

      GoRoute(
        path: aboutUsScreen,
        name: aboutUsScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(AboutUsScreen(), state),
      ),

      ///// ===========================================================> View Profile Screen  =================================================>

      GoRoute(
        path: viewProfileScreen,
        name: viewProfileScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(ViewProfileScreen(), state),
      ),

      ///// ===========================================================> Edit Profile Screen  =================================================>

      GoRoute(
        path: editProfileScreen,
        name: editProfileScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(EditProfileScreen(), state),
      ),


      GoRoute(
        path: notificationsScreen,
        name: notificationsScreen,
        pageBuilder:
            (context, state) => _customTransitionPage(NotificationsScreen(), state),
      ),




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
