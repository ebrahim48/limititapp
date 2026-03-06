import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('it')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'LimitIt'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App usage screen title
  ///
  /// In en, this message translates to:
  /// **'App Usage'**
  String get appUsage;

  /// Daily limit label
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get dailyLimit;

  /// Time spent label
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get timeSpent;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// About section label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Select language prompt
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectYourLanguage;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Welcome message with app name
  ///
  /// In en, this message translates to:
  /// **'Welcome to LimitIt'**
  String get welcomeToLimitIt;

  /// Motivational message on start screen
  ///
  /// In en, this message translates to:
  /// **'Starting today, let\'s focus better and\naccomplish your dreams'**
  String get startingToday;

  /// Sign up screen title
  ///
  /// In en, this message translates to:
  /// **'Sign up your account'**
  String get signUpYourAccount;

  /// Sign up instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your details below to continue'**
  String get enterYourDetails;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Set new password label
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm new password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Terms acceptance prefix
  ///
  /// In en, this message translates to:
  /// **'By creating an account, I accept the '**
  String get byCreatingAccount;

  /// Terms and conditions link
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Password match confirmation
  ///
  /// In en, this message translates to:
  /// **'Password Matched ✓'**
  String get passwordMatched;

  /// Privacy Policy screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Login prompt for existing users
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **' Login'**
  String get login;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Login screen title
  ///
  /// In en, this message translates to:
  /// **'Log in your account'**
  String get logInYourAccount;

  /// Password update success message
  ///
  /// In en, this message translates to:
  /// **'All set !\nPassword Successfully Updated'**
  String get allSetPasswordUpdated;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Log in Securely to access your full app'**
  String get logInSecurely;

  /// Forget password link
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// Forget password screen title
  ///
  /// In en, this message translates to:
  /// **'Forget Password'**
  String get forgetPasswordTitle;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Get OTP button
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get getOtp;

  /// Verify OTP screen title
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// Resend code prompt
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get didntGetCode;

  /// Back to login button
  ///
  /// In en, this message translates to:
  /// **'Back to Log in'**
  String get backToLogin;

  /// App tagline
  ///
  /// In en, this message translates to:
  /// **'Take Control of your digital habits'**
  String get takeControl;

  /// Back to home button
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Privacy acceptance checkbox
  ///
  /// In en, this message translates to:
  /// **'I accept the privacy policy and terms of Service'**
  String get iAcceptPrivacy;

  /// Privacy section title
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Protection'**
  String get privacyDataProtection;

  /// Privacy point 1
  ///
  /// In en, this message translates to:
  /// **'Your usage data stays on your device'**
  String get usageDataStaysOnDevice;

  /// Privacy point 2
  ///
  /// In en, this message translates to:
  /// **'We don\'t collect personal information'**
  String get noPersonalInfoCollection;

  /// Privacy point 3
  ///
  /// In en, this message translates to:
  /// **'GDPR compliance is our priority'**
  String get gdprCompliance;

  /// Privacy point 4
  ///
  /// In en, this message translates to:
  /// **'Transparent Permission requests'**
  String get transparentPermissions;

  /// App selection screen title
  ///
  /// In en, this message translates to:
  /// **'Select Apps to Manage'**
  String get selectAppsToManage;

  /// Usage limit screen title
  ///
  /// In en, this message translates to:
  /// **'Set Usage Limit'**
  String get setUsageLimit;

  /// Daily screen time label
  ///
  /// In en, this message translates to:
  /// **'Total Daily Screen Time'**
  String get totalDailyScreenTime;

  /// All items filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Save and continue button
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveContinue;

  /// Timer settings title
  ///
  /// In en, this message translates to:
  /// **'Timer Settings'**
  String get timerSettings;

  /// Countdown duration label
  ///
  /// In en, this message translates to:
  /// **'Pre - Opening Countdown\nDuration'**
  String get preOpeningCountdown;

  /// Motivational phrases section
  ///
  /// In en, this message translates to:
  /// **'Motivational Phrases'**
  String get motivationalPhrases;

  /// App limit success message
  ///
  /// In en, this message translates to:
  /// **'All set !\nYou have Successfully Set App Limit'**
  String get allSetAppLimit;

  /// Reports screen title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Most used apps section
  ///
  /// In en, this message translates to:
  /// **'Most Used Apps'**
  String get mostUsedApps;

  /// Download report button
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// Loading text when generating report
  ///
  /// In en, this message translates to:
  /// **'Generating Report...'**
  String get generatingReport;

  /// Subtitle when generating report
  ///
  /// In en, this message translates to:
  /// **'Preparing your report with real-time data'**
  String get preparingYourReport;

  /// Success title for report download
  ///
  /// In en, this message translates to:
  /// **'Report Downloaded'**
  String get reportDownloaded;

  /// Success message for report download
  ///
  /// In en, this message translates to:
  /// **'Your usage report is ready to share or print'**
  String get reportReadyToShare;

  /// Error message when report download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download report. Please try again'**
  String get failedToDownloadReport;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// About us menu item
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;
  String get delete;
  String get pinSettings;
  /// Terms & Conditions screen title
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// Empty notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// Empty notifications description
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when something new arrives'**
  String get notifyWhenNewArrives;

  /// Detox mode screen title
  ///
  /// In en, this message translates to:
  /// **'Detox Mode'**
  String get detoxMode;

  /// Select all checkbox
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Save detox mode button
  ///
  /// In en, this message translates to:
  /// **'Save Detox Mode'**
  String get saveDetoxMode;

  /// Setup permissions screen title
  ///
  /// In en, this message translates to:
  /// **'Setup Permissions'**
  String get setupPermissions;

  /// Grant permissions header
  ///
  /// In en, this message translates to:
  /// **'Grant Required Permissions'**
  String get grantRequiredPermissions;

  /// Permissions explanation
  ///
  /// In en, this message translates to:
  /// **'LimitIt needs these permissions to monitor and block apps when limits are reached.'**
  String get permissionsDescription;

  /// Overlay permission title
  ///
  /// In en, this message translates to:
  /// **'Overlay Permission'**
  String get overlayPermission;

  /// Overlay permission description
  ///
  /// In en, this message translates to:
  /// **'Allows LimitIt to display blocking screen over other apps'**
  String get overlayPermissionDesc;

  /// Accessibility service title
  ///
  /// In en, this message translates to:
  /// **'Accessibility Service'**
  String get accessibilityService;

  /// Accessibility service description
  ///
  /// In en, this message translates to:
  /// **'Monitors which apps you open to enforce limits'**
  String get accessibilityServiceDesc;

  /// Start monitoring button
  ///
  /// In en, this message translates to:
  /// **'Start Monitoring'**
  String get startMonitoring;

  /// Grant permissions prompt
  ///
  /// In en, this message translates to:
  /// **'Grant All Permissions First'**
  String get grantAllPermissionsFirst;

  /// Grant button
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// Sign up now button
  ///
  /// In en, this message translates to:
  /// **'Sign Up Now'**
  String get signUpNow;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Take Control of Your\nScreen Time'**
  String get takeControlScreenTime;

  /// Onboarding page 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Regain Control of Your Digital Life'**
  String get regainControl;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Limit the Apps That\nDistract You'**
  String get limitDistractingApps;

  /// Onboarding page 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose Which Apps to Limit'**
  String get chooseAppsToLimit;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Smart Scheduling &\nDaily Resets'**
  String get smartScheduling;

  /// Onboarding page 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Create Your Perfect Schedule'**
  String get createPerfectSchedule;

  /// Onboarding page 4 title
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress\n& Improve'**
  String get trackYourProgress;

  /// Onboarding page 4 subtitle
  ///
  /// In en, this message translates to:
  /// **'Stay Motivated with Weekly Reports'**
  String get stayMotivated;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Update profile button
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Edit timer settings screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Timer Settings'**
  String get editTimerSettings;

  /// Less button
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// More button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Update screen time button
  ///
  /// In en, this message translates to:
  /// **'Update ScreenTime'**
  String get updateScreenTime;

  /// Pin lock screen title
  ///
  /// In en, this message translates to:
  /// **'PinLock'**
  String get pinLock;

  /// Edit usage limit screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Usage Limit'**
  String get editUsageLimit;

  /// Daily opens limit label
  ///
  /// In en, this message translates to:
  /// **'Daily Opens Limit'**
  String get dailyOpensLimit;

  /// Session duration label
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get sessionDuration;

  /// Motivation quotes hint
  ///
  /// In en, this message translates to:
  /// **'Enter Motivation Quotes'**
  String get enterMotivationQuotes;

  /// Author name hint
  ///
  /// In en, this message translates to:
  /// **'Enter author name'**
  String get enterAuthorName;

  /// Save motivation button
  ///
  /// In en, this message translates to:
  /// **'Save Motivation'**
  String get saveMotivation;

  /// Set pin number screen title
  ///
  /// In en, this message translates to:
  /// **'Set Pin Number'**
  String get setPinNumber;

  /// Enter pin number hint
  ///
  /// In en, this message translates to:
  /// **'Enter the Pin Number'**
  String get enterPinNumber;

  /// Save pin number button
  ///
  /// In en, this message translates to:
  /// **'Save Pin Number'**
  String get savePinNumber;

  /// Privacy policy acceptance error
  ///
  /// In en, this message translates to:
  /// **'Please accept Privacy Policy'**
  String get pleaseAcceptPrivacyPolicy;

  /// Screen time screen title
  ///
  /// In en, this message translates to:
  /// **'Screen Time'**
  String get screenTime;

  /// Empty screen time message
  ///
  /// In en, this message translates to:
  /// **'No screen time limits set yet'**
  String get noScreenTimeLimits;

  /// Add new screen time button
  ///
  /// In en, this message translates to:
  /// **'Add New ScreenTime'**
  String get addNewScreenTime;

  /// App selection error
  ///
  /// In en, this message translates to:
  /// **'Please select at least one app'**
  String get pleaseSelectAtLeastOneApp;

  /// Continue button with count
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWithApps;

  /// Continue button with app count
  ///
  /// In en, this message translates to:
  /// **'Continue ({count} apps Selected)'**
  String continueWithAppsCount(int count);

  /// Subscription menu item
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Change password menu item
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Notification menu item
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Log out button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// Log out dialog title
  ///
  /// In en, this message translates to:
  /// **'Ready to Log out ?'**
  String get readyToLogOut;

  /// No apps selected message
  ///
  /// In en, this message translates to:
  /// **'No apps selected. Please go back and select apps.'**
  String get noAppsSelected;

  /// Saving button text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Schedules screen title
  ///
  /// In en, this message translates to:
  /// **'Schedules'**
  String get schedules;

  /// App block lists section
  ///
  /// In en, this message translates to:
  /// **'App Block Lists'**
  String get appBlockLists;

  /// Save app block button
  ///
  /// In en, this message translates to:
  /// **'Save App Block'**
  String get saveAppBlock;

  /// Add motivation button
  ///
  /// In en, this message translates to:
  /// **'Add Motivation'**
  String get addMotivation;

  /// Upgrade to premium screen title
  ///
  /// In en, this message translates to:
  /// **'Upgrade to premium'**
  String get upgradeToPremium;

  /// Premium plan title
  ///
  /// In en, this message translates to:
  /// **'Premium Monthly Plan'**
  String get premiumMonthlyPlan;

  /// Price per month
  ///
  /// In en, this message translates to:
  /// **'€1/month'**
  String get pricePerMonth;

  /// Subscribe now button
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// Confirm subscription dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get confirmSubscription;

  /// Subscription confirmation message
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Premium Monthly Plan for €1/month?'**
  String get subscriptionConfirmMessage;

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// Subscription success message
  ///
  /// In en, this message translates to:
  /// **'Subscription successful!'**
  String get subscriptionSuccessful;

  /// Failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// Error message when saving settings fails
  ///
  /// In en, this message translates to:
  /// **'Error saving settings. Please try again.'**
  String get errorSavingSettings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
