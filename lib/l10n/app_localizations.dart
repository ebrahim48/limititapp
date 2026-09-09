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
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('it'),
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

  /// Notification permission title
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// Notification permission description
  ///
  /// In en, this message translates to:
  /// **'Allows LimitIt to send notifications about app limits'**
  String get notificationPermissionDesc;

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

  /// App provider label
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// PIN settings screen title
  ///
  /// In en, this message translates to:
  /// **'PIN Settings'**
  String get pinSettings;

  /// Empty PIN list message
  ///
  /// In en, this message translates to:
  /// **'No PINs Created'**
  String get noPinsCreated;

  /// Create first PIN hint
  ///
  /// In en, this message translates to:
  /// **'Create your first PIN to protect apps'**
  String get createYourFirstPin;

  /// Create PIN button
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get createPin;

  /// Update PIN button
  ///
  /// In en, this message translates to:
  /// **'Update PIN'**
  String get updatePin;

  /// Update pin number title
  ///
  /// In en, this message translates to:
  /// **'Update Pin Number'**
  String get updatePinNumber;

  /// Enter new PIN hint
  ///
  /// In en, this message translates to:
  /// **'Enter new PIN number'**
  String get enterNewPinNumber;

  /// Updating button text
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updating;

  /// Delete PIN dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete PIN'**
  String get deletePin;

  /// Delete PIN confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this PIN? This action cannot be undone.'**
  String get deletePinConfirmation;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

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

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account warning message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.'**
  String get deleteAccountWarning;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Password required error message
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Label for app count (singular)
  ///
  /// In en, this message translates to:
  /// **'app'**
  String get app;

  /// Label for apps count (plural)
  ///
  /// In en, this message translates to:
  /// **'apps'**
  String get apps;

  /// Error message when plans fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans'**
  String get failedToLoadPlans;

  /// Success message when monitoring starts
  ///
  /// In en, this message translates to:
  /// **'App monitoring started successfully!'**
  String get monitoringStartedSuccess;

  /// Error message when monitoring fails to start
  ///
  /// In en, this message translates to:
  /// **'Failed to start monitoring. Please try again.'**
  String get failedToStartMonitoring;

  /// takeBackYourTime
  ///
  /// In en, this message translates to:
  /// **'Take back your time'**
  String get takeBackYourTime;

  /// getStartedSubtitle
  ///
  /// In en, this message translates to:
  /// **'Protect the apps that distract you and build better digital habits.'**
  String get getStartedSubtitle;

  /// featureProtectTitle
  ///
  /// In en, this message translates to:
  /// **'Protect your apps'**
  String get featureProtectTitle;

  /// featureProtectSubtitle
  ///
  /// In en, this message translates to:
  /// **'Set limits, time blocks and mindful pauses.'**
  String get featureProtectSubtitle;

  /// featureInsightTitle
  ///
  /// In en, this message translates to:
  /// **'See real insights'**
  String get featureInsightTitle;

  /// featureInsightSubtitle
  ///
  /// In en, this message translates to:
  /// **'Track screen time and how much you saved.'**
  String get featureInsightSubtitle;

  /// featureGoalTitle
  ///
  /// In en, this message translates to:
  /// **'Hit your goals'**
  String get featureGoalTitle;

  /// featureGoalSubtitle
  ///
  /// In en, this message translates to:
  /// **'Build streaks and stay motivated every day.'**
  String get featureGoalSubtitle;

  /// continueWithApple
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// continueWithGoogle
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// continueWithEmail
  ///
  /// In en, this message translates to:
  /// **'Continue with Email'**
  String get continueWithEmail;

  /// socialLoginComingSoon
  ///
  /// In en, this message translates to:
  /// **'Social sign-in is not available yet.'**
  String get socialLoginComingSoon;

  /// passwordRule
  ///
  /// In en, this message translates to:
  /// **'Password: 8 characters min, letters & digits required'**
  String get passwordRule;

  /// emailInvalid
  ///
  /// In en, this message translates to:
  /// **'Please check your email'**
  String get emailInvalid;

  /// welcomeBack
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// forgetPasswordSubtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a verification code.'**
  String get forgetPasswordSubtitle;

  /// verifyOtpSubtitle
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to'**
  String get verifyOtpSubtitle;

  /// resendIn
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// resend
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// resetPasswordSubtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a new password to secure your account.'**
  String get resetPasswordSubtitle;

  /// resetSuccessSubtitle
  ///
  /// In en, this message translates to:
  /// **'You can now log in with your new password.'**
  String get resetSuccessSubtitle;

  /// appProtection
  ///
  /// In en, this message translates to:
  /// **'App protection'**
  String get appProtection;

  /// yourProtectedApps
  ///
  /// In en, this message translates to:
  /// **'Your protected apps'**
  String get yourProtectedApps;

  /// todayYouveAvoided
  ///
  /// In en, this message translates to:
  /// **'Today you\'ve avoided'**
  String get todayYouveAvoided;

  /// impulsiveOpenings
  ///
  /// In en, this message translates to:
  /// **'impulsive openings'**
  String get impulsiveOpenings;

  /// blocked
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// maxOpenings
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxOpenings;

  /// day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// noProtectionsYet
  ///
  /// In en, this message translates to:
  /// **'No protections yet'**
  String get noProtectionsYet;

  /// noProtectionsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Add your first app and start taking back your time.'**
  String get noProtectionsSubtitle;

  /// addProtection
  ///
  /// In en, this message translates to:
  /// **'Add protection'**
  String get addProtection;

  /// statistics
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// premium
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// searchApp
  ///
  /// In en, this message translates to:
  /// **'Search app'**
  String get searchApp;

  /// searchForAnApp
  ///
  /// In en, this message translates to:
  /// **'Search for an app…'**
  String get searchForAnApp;

  /// suggestions
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// results
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// noAppsFound
  ///
  /// In en, this message translates to:
  /// **'No apps found'**
  String get noAppsFound;

  /// noUsageDataYet
  ///
  /// In en, this message translates to:
  /// **'No usage data yet'**
  String get noUsageDataYet;

  /// usageStatsUnavailable
  ///
  /// In en, this message translates to:
  /// **'iOS does not share app usage with other apps, so there is nothing to chart here.'**
  String get usageStatsUnavailable;

  /// usageAccessNeeded
  ///
  /// In en, this message translates to:
  /// **'Grant usage access to see how long you spend in each app.'**
  String get usageAccessNeeded;

  /// appDetectionLimited
  ///
  /// In en, this message translates to:
  /// **'iOS only lets us detect known apps. Search for the app you want to limit.'**
  String get appDetectionLimited;

  /// couldNotLoadApps
  ///
  /// In en, this message translates to:
  /// **'Could not load your apps.'**
  String get couldNotLoadApps;

  /// editProtection
  ///
  /// In en, this message translates to:
  /// **'Edit protection'**
  String get editProtection;

  /// newProtection
  ///
  /// In en, this message translates to:
  /// **'New protection'**
  String get newProtection;

  /// protection
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get protection;

  /// howLongShouldThePauseBe
  ///
  /// In en, this message translates to:
  /// **'How long should the pause be?'**
  String get howLongShouldThePauseBe;

  /// pauseStepHint
  ///
  /// In en, this message translates to:
  /// **'This is the time you\'ll wait before the app opens.'**
  String get pauseStepHint;

  /// whatsYourDailyLimit
  ///
  /// In en, this message translates to:
  /// **'What\'s your daily limit?'**
  String get whatsYourDailyLimit;

  /// setAMaximumTimePerDay
  ///
  /// In en, this message translates to:
  /// **'Set a maximum time per day.'**
  String get setAMaximumTimePerDay;

  /// hoursLabel
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursLabel;

  /// minutesLabel
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutesLabel;

  /// howManyTimesPerDay
  ///
  /// In en, this message translates to:
  /// **'How many times per day?'**
  String get howManyTimesPerDay;

  /// setMaximumOpeningsPerDay
  ///
  /// In en, this message translates to:
  /// **'Set the maximum number of openings per day.'**
  String get setMaximumOpeningsPerDay;

  /// openingsPerDay
  ///
  /// In en, this message translates to:
  /// **'openings per day'**
  String get openingsPerDay;

  /// whenDoYouWantToBlockIt
  ///
  /// In en, this message translates to:
  /// **'When do you want to block it?'**
  String get whenDoYouWantToBlockIt;

  /// selectTimePeriodToBlock
  ///
  /// In en, this message translates to:
  /// **'Select the time period to block.'**
  String get selectTimePeriodToBlock;

  /// blockedTime
  ///
  /// In en, this message translates to:
  /// **'Blocked time'**
  String get blockedTime;

  /// review
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// protectionTypeLabel
  ///
  /// In en, this message translates to:
  /// **'Protection type'**
  String get protectionTypeLabel;

  /// settingLabel
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settingLabel;

  /// activate
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// delayExplainer
  ///
  /// In en, this message translates to:
  /// **'You will see a countdown before this app opens.'**
  String get delayExplainer;

  /// dailyLimitExplainer
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified when you reach your daily limit.'**
  String get dailyLimitExplainer;

  /// openingLimitExplainer
  ///
  /// In en, this message translates to:
  /// **'You can modify this anytime.'**
  String get openingLimitExplainer;

  /// timeBlockExplainer
  ///
  /// In en, this message translates to:
  /// **'This app will be blocked during the selected time.'**
  String get timeBlockExplainer;

  /// appIsNowProtected
  ///
  /// In en, this message translates to:
  /// **'{app} is now protected!'**
  String appIsNowProtected(String app);

  /// smallPauseBigChange
  ///
  /// In en, this message translates to:
  /// **'Small pause, big change.'**
  String get smallPauseBigChange;

  /// oneStepCloserToBetterHabits
  ///
  /// In en, this message translates to:
  /// **'You\'ve taken one step closer to better digital habits.'**
  String get oneStepCloserToBetterHabits;

  /// done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// addAnother
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnother;

  /// secondsLong
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String secondsLong(int count);

  /// openingsPerDayValue
  ///
  /// In en, this message translates to:
  /// **'{count} openings / day'**
  String openingsPerDayValue(int count);

  /// whatWouldYouLikeToDo
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// chooseAFunctionToGetStarted
  ///
  /// In en, this message translates to:
  /// **'Choose a function to get started.'**
  String get chooseAFunctionToGetStarted;

  /// delayAppOpening
  ///
  /// In en, this message translates to:
  /// **'Delay app opening'**
  String get delayAppOpening;

  /// delayAppOpeningHint
  ///
  /// In en, this message translates to:
  /// **'Take a mindful pause before opening an app.'**
  String get delayAppOpeningHint;

  /// dailyTimeLimitFunctionHint
  ///
  /// In en, this message translates to:
  /// **'Set a maximum time per day.'**
  String get dailyTimeLimitFunctionHint;

  /// openingLimit
  ///
  /// In en, this message translates to:
  /// **'Opening limit'**
  String get openingLimit;

  /// openingLimitHint
  ///
  /// In en, this message translates to:
  /// **'Limit how many times you can open an app.'**
  String get openingLimitHint;

  /// timeBlockFunctionHint
  ///
  /// In en, this message translates to:
  /// **'Block apps during certain hours.'**
  String get timeBlockFunctionHint;

  /// recommended
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// pauseDuration
  ///
  /// In en, this message translates to:
  /// **'Pause duration'**
  String get pauseDuration;

  /// secondsShort
  ///
  /// In en, this message translates to:
  /// **'{count} sec'**
  String secondsShort(int count);

  /// dailyTimeLimit
  ///
  /// In en, this message translates to:
  /// **'Daily time limit'**
  String get dailyTimeLimit;

  /// dailyTimeLimitHint
  ///
  /// In en, this message translates to:
  /// **'Allow a set amount of time each day'**
  String get dailyTimeLimitHint;

  /// maxOpeningsLabel
  ///
  /// In en, this message translates to:
  /// **'Max openings'**
  String get maxOpeningsLabel;

  /// maxOpeningsHint
  ///
  /// In en, this message translates to:
  /// **'Limit how many times you can open it'**
  String get maxOpeningsHint;

  /// timeBlock
  ///
  /// In en, this message translates to:
  /// **'Time block'**
  String get timeBlock;

  /// timeBlockHint
  ///
  /// In en, this message translates to:
  /// **'Block the app during a time range'**
  String get timeBlockHint;

  /// from
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// to
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// moreOptions
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// customizeMessage
  ///
  /// In en, this message translates to:
  /// **'Customize message'**
  String get customizeMessage;

  /// customizeDays
  ///
  /// In en, this message translates to:
  /// **'Customize days'**
  String get customizeDays;

  /// previewPause
  ///
  /// In en, this message translates to:
  /// **'Preview pause'**
  String get previewPause;

  /// defaultLabel
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// deleteProtection
  ///
  /// In en, this message translates to:
  /// **'Delete protection'**
  String get deleteProtection;

  /// deleteProtectionQuestion
  ///
  /// In en, this message translates to:
  /// **'Delete protection?'**
  String get deleteProtectionQuestion;

  /// saveChanges
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// activateProtection
  ///
  /// In en, this message translates to:
  /// **'Activate protection'**
  String get activateProtection;

  /// editMessage
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// message
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// messageHint
  ///
  /// In en, this message translates to:
  /// **'Focus on what matters.'**
  String get messageHint;

  /// selectDaysToApply
  ///
  /// In en, this message translates to:
  /// **'Select days to apply this protection.'**
  String get selectDaysToApply;

  /// everyDay
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// weekdays
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdays;

  /// weekends
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekends;

  /// custom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// pauseActive
  ///
  /// In en, this message translates to:
  /// **'Pause active'**
  String get pauseActive;

  /// remainingTime
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get remainingTime;

  /// openNow
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNow;

  /// deleteProtectionMessage
  ///
  /// In en, this message translates to:
  /// **'This protection for {appName} will be permanently removed.'**
  String deleteProtectionMessage(String appName);

  /// appIsCurrentlyPaused
  ///
  /// In en, this message translates to:
  /// **'{appName} is currently paused.'**
  String appIsCurrentlyPaused(String appName);

  /// today
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// timeSaved
  ///
  /// In en, this message translates to:
  /// **'Time saved'**
  String get timeSaved;

  /// blockedOpens
  ///
  /// In en, this message translates to:
  /// **'Blocked opens'**
  String get blockedOpens;

  /// goalStreak
  ///
  /// In en, this message translates to:
  /// **'Goal streak'**
  String get goalStreak;

  /// weeklyUsage
  ///
  /// In en, this message translates to:
  /// **'Weekly usage'**
  String get weeklyUsage;

  /// trend
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// goals
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// monthlyReport
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// unlockYourStats
  ///
  /// In en, this message translates to:
  /// **'Unlock your stats'**
  String get unlockYourStats;

  /// unlockYourStatsSubtitle
  ///
  /// In en, this message translates to:
  /// **'See exactly how much time you take back every week.'**
  String get unlockYourStatsSubtitle;

  /// lockedFeatureTimeSaved
  ///
  /// In en, this message translates to:
  /// **'Time saved, day by day'**
  String get lockedFeatureTimeSaved;

  /// lockedFeatureTrends
  ///
  /// In en, this message translates to:
  /// **'Weekly and monthly trends'**
  String get lockedFeatureTrends;

  /// lockedFeatureGoals
  ///
  /// In en, this message translates to:
  /// **'Goal streaks and history'**
  String get lockedFeatureGoals;

  /// lockedFeatureReports
  ///
  /// In en, this message translates to:
  /// **'Full monthly reports'**
  String get lockedFeatureReports;

  /// unlockWithPremium
  ///
  /// In en, this message translates to:
  /// **'Unlock with Premium'**
  String get unlockWithPremium;

  /// week
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// month
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// thisWeek
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get thisWeek;

  /// thisMonth
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get thisMonth;

  /// savedByApp
  ///
  /// In en, this message translates to:
  /// **'Saved by app'**
  String get savedByApp;

  /// nothingSavedYet
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get nothingSavedYet;

  /// inUse
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;

  /// mostUsed
  ///
  /// In en, this message translates to:
  /// **'Most used'**
  String get mostUsed;

  /// totalScreenTime
  ///
  /// In en, this message translates to:
  /// **'Total screen time'**
  String get totalScreenTime;

  /// noUsageYet
  ///
  /// In en, this message translates to:
  /// **'No usage recorded yet'**
  String get noUsageYet;

  /// screenTimeReduction
  ///
  /// In en, this message translates to:
  /// **'Screen time reduction'**
  String get screenTimeReduction;

  /// vsLastWeek
  ///
  /// In en, this message translates to:
  /// **'vs. last week'**
  String get vsLastWeek;

  /// vsLastMonth
  ///
  /// In en, this message translates to:
  /// **'vs. last month'**
  String get vsLastMonth;

  /// screenTimeHours
  ///
  /// In en, this message translates to:
  /// **'Screen time (hours)'**
  String get screenTimeHours;

  /// insight
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get insight;

  /// insightPositive
  ///
  /// In en, this message translates to:
  /// **'You\'ve consistently reduced screen time. Your digital mindfulness is improving! Keep protecting those apps.'**
  String get insightPositive;

  /// insightNeutral
  ///
  /// In en, this message translates to:
  /// **'Keep going — a few more protected days and the trend will start to bend.'**
  String get insightNeutral;

  /// dailyGoal
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// noGoalSet
  ///
  /// In en, this message translates to:
  /// **'No goal set'**
  String get noGoalSet;

  /// dailyScreenTimeLimit
  ///
  /// In en, this message translates to:
  /// **'daily screen time limit'**
  String get dailyScreenTimeLimit;

  /// daysGoalWasMet
  ///
  /// In en, this message translates to:
  /// **'Days goal was met'**
  String get daysGoalWasMet;

  /// noHistoryYet
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// streaks
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get streaks;

  /// currentStreak
  ///
  /// In en, this message translates to:
  /// **'current streak'**
  String get currentStreak;

  /// bestStreak
  ///
  /// In en, this message translates to:
  /// **'best streak'**
  String get bestStreak;

  /// usageReduction
  ///
  /// In en, this message translates to:
  /// **'Usage reduction'**
  String get usageReduction;

  /// monthProgress
  ///
  /// In en, this message translates to:
  /// **'Month progress'**
  String get monthProgress;

  /// continueYourMonth
  ///
  /// In en, this message translates to:
  /// **'Continue your month'**
  String get continueYourMonth;

  /// usedToday
  ///
  /// In en, this message translates to:
  /// **'{value} used today'**
  String usedToday(String value);

  /// daysCount
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// daysCompleted
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} days completed'**
  String daysCompleted(int done, int total);

  /// choosePlan
  ///
  /// In en, this message translates to:
  /// **'Choose your plan'**
  String get choosePlan;

  /// limitItPremium
  ///
  /// In en, this message translates to:
  /// **'LimitIt Premium'**
  String get limitItPremium;

  /// premiumSubtitle
  ///
  /// In en, this message translates to:
  /// **'Everything you need to build a calmer relationship with your phone.'**
  String get premiumSubtitle;

  /// premiumFeatureUnlimitedTitle
  ///
  /// In en, this message translates to:
  /// **'Unlimited protections'**
  String get premiumFeatureUnlimitedTitle;

  /// premiumFeatureUnlimitedSubtitle
  ///
  /// In en, this message translates to:
  /// **'Protect as many apps as you want'**
  String get premiumFeatureUnlimitedSubtitle;

  /// premiumFeatureStatsTitle
  ///
  /// In en, this message translates to:
  /// **'Full statistics'**
  String get premiumFeatureStatsTitle;

  /// premiumFeatureStatsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Trends, goals and monthly reports'**
  String get premiumFeatureStatsSubtitle;

  /// premiumFeatureScheduleTitle
  ///
  /// In en, this message translates to:
  /// **'Advanced schedules'**
  String get premiumFeatureScheduleTitle;

  /// premiumFeatureScheduleSubtitle
  ///
  /// In en, this message translates to:
  /// **'Time blocks and custom days'**
  String get premiumFeatureScheduleSubtitle;

  /// premiumFeatureBackupTitle
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get premiumFeatureBackupTitle;

  /// premiumFeatureBackupSubtitle
  ///
  /// In en, this message translates to:
  /// **'Keep your setup safe'**
  String get premiumFeatureBackupSubtitle;

  /// premiumFeatureNoAdsTitle
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get premiumFeatureNoAdsTitle;

  /// premiumFeatureNoAdsSubtitle
  ///
  /// In en, this message translates to:
  /// **'A clean, distraction-free app'**
  String get premiumFeatureNoAdsSubtitle;

  /// restorePurchases
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// yearly
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// perYear
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get perYear;

  /// perMonth
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// perWeek
  ///
  /// In en, this message translates to:
  /// **'/ week'**
  String get perWeek;

  /// paymentPending
  ///
  /// In en, this message translates to:
  /// **'Payment pending…'**
  String get paymentPending;

  /// purchaseCancelled
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled'**
  String get purchaseCancelled;

  /// checkingPurchases
  ///
  /// In en, this message translates to:
  /// **'Checking for existing purchases…'**
  String get checkingPurchases;

  /// youreAllSet
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get youreAllSet;

  /// youreAllSetSubtitle
  ///
  /// In en, this message translates to:
  /// **'Your Premium features are now active. Enjoy every one of them.'**
  String get youreAllSetSubtitle;

  /// startUsingPremium
  ///
  /// In en, this message translates to:
  /// **'Start using Premium'**
  String get startUsingPremium;

  /// manageSubscription
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// activeSubscription
  ///
  /// In en, this message translates to:
  /// **'Active subscription'**
  String get activeSubscription;

  /// active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// renewsOn
  ///
  /// In en, this message translates to:
  /// **'Renews on'**
  String get renewsOn;

  /// options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// changePlan
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get changePlan;

  /// changePlanSubtitle
  ///
  /// In en, this message translates to:
  /// **'Switch between monthly and yearly'**
  String get changePlanSubtitle;

  /// billingHistory
  ///
  /// In en, this message translates to:
  /// **'Billing history'**
  String get billingHistory;

  /// billingHistorySubtitle
  ///
  /// In en, this message translates to:
  /// **'See past invoices'**
  String get billingHistorySubtitle;

  /// cancelSubscription
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSubscription;

  /// yesCancelSubscription
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel subscription'**
  String get yesCancelSubscription;

  /// keepMyPlan
  ///
  /// In en, this message translates to:
  /// **'Keep my plan'**
  String get keepMyPlan;

  /// youllLoseAccessTo
  ///
  /// In en, this message translates to:
  /// **'You\'ll lose access to'**
  String get youllLoseAccessTo;

  /// cancelKeepsAccess
  ///
  /// In en, this message translates to:
  /// **'Your Premium access stays active until the end of your billing period.'**
  String get cancelKeepsAccess;

  /// cancelStoreNote
  ///
  /// In en, this message translates to:
  /// **'Recurring billing is managed by the App Store / Google Play. Turn off auto-renew there to avoid future charges.'**
  String get cancelStoreNote;

  /// subscriptionCancelled
  ///
  /// In en, this message translates to:
  /// **'Subscription cancelled'**
  String get subscriptionCancelled;

  /// subscriptionCancelledSubtitle
  ///
  /// In en, this message translates to:
  /// **'Your Premium access will remain active until the end of your billing period.'**
  String get subscriptionCancelledSubtitle;

  /// youCanResubscribeAnytime
  ///
  /// In en, this message translates to:
  /// **'You can resubscribe anytime.'**
  String get youCanResubscribeAnytime;

  /// goToHome
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goToHome;

  /// cancelKeepsAccessUntil
  ///
  /// In en, this message translates to:
  /// **'Your Premium access stays active until {date}.'**
  String cancelKeepsAccessUntil(String date);

  /// premiumMember
  ///
  /// In en, this message translates to:
  /// **'Premium member'**
  String get premiumMember;

  /// freePlan
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get freePlan;

  /// openingsBlocked
  ///
  /// In en, this message translates to:
  /// **'Openings blocked'**
  String get openingsBlocked;

  /// appProtections
  ///
  /// In en, this message translates to:
  /// **'App protections'**
  String get appProtections;

  /// reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// privacy
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// helpAndFaq
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpAndFaq;

  /// backupAndRestore
  ///
  /// In en, this message translates to:
  /// **'Backup & restore'**
  String get backupAndRestore;

  /// aboutLimitIt
  ///
  /// In en, this message translates to:
  /// **'About LimitIt'**
  String get aboutLimitIt;

  /// remindersSubtitle
  ///
  /// In en, this message translates to:
  /// **'Stay mindful with gentle nudges at the right moments.'**
  String get remindersSubtitle;

  /// daily
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// dailyCheckIn
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// dailyCheckInSubtitle
  ///
  /// In en, this message translates to:
  /// **'Morning mindfulness reminder'**
  String get dailyCheckInSubtitle;

  /// reminderTime
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// goalAlert
  ///
  /// In en, this message translates to:
  /// **'Goal alert'**
  String get goalAlert;

  /// goalAlertSubtitle
  ///
  /// In en, this message translates to:
  /// **'Notify when near daily limit'**
  String get goalAlertSubtitle;

  /// weeklyReportReminder
  ///
  /// In en, this message translates to:
  /// **'Weekly report'**
  String get weeklyReportReminder;

  /// weeklyReportReminderSubtitle
  ///
  /// In en, this message translates to:
  /// **'Every Monday morning'**
  String get weeklyReportReminderSubtitle;

  /// breakReminder
  ///
  /// In en, this message translates to:
  /// **'Break reminder'**
  String get breakReminder;

  /// breakReminderSubtitle
  ///
  /// In en, this message translates to:
  /// **'Remind after 30 min of use'**
  String get breakReminderSubtitle;

  /// remindersDeliveryNote
  ///
  /// In en, this message translates to:
  /// **'Reminders are delivered as push notifications. Make sure notifications are enabled in your device settings.'**
  String get remindersDeliveryNote;

  /// helpAndSupport
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpAndSupport;

  /// faq
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// faqSubtitle
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqSubtitle;

  /// contactSupport
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// contactSupportSubtitle
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our team'**
  String get contactSupportSubtitle;

  /// reportAProblem
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get reportAProblem;

  /// reportAProblemSubtitle
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong'**
  String get reportAProblemSubtitle;

  /// faqQ1
  ///
  /// In en, this message translates to:
  /// **'How does a protection work?'**
  String get faqQ1;

  /// faqA1
  ///
  /// In en, this message translates to:
  /// **'When you open a protected app, LimitIt shows a mindful pause before letting it through — and blocks it once the limit is reached.'**
  String get faqA1;

  /// faqQ2
  ///
  /// In en, this message translates to:
  /// **'Is my usage data private?'**
  String get faqQ2;

  /// faqA2
  ///
  /// In en, this message translates to:
  /// **'Usage and protections stay on your device. Only your account details reach our servers.'**
  String get faqA2;

  /// faqQ3
  ///
  /// In en, this message translates to:
  /// **'Why do I need usage access?'**
  String get faqQ3;

  /// faqA3
  ///
  /// In en, this message translates to:
  /// **'Android needs that permission to tell LimitIt which app is in the foreground, so limits can be applied.'**
  String get faqA3;

  /// faqQ4
  ///
  /// In en, this message translates to:
  /// **'How do I cancel Premium?'**
  String get faqQ4;

  /// faqA4
  ///
  /// In en, this message translates to:
  /// **'Open Premium → Manage subscription → Cancel subscription. Auto-renew is switched off in the App Store or Google Play.'**
  String get faqA4;

  /// createBackup
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// createBackupSubtitle
  ///
  /// In en, this message translates to:
  /// **'Save your protections to your account.'**
  String get createBackupSubtitle;

  /// backUpNow
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNow;

  /// restoreBackup
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// restoreBackupSubtitle
  ///
  /// In en, this message translates to:
  /// **'Recover your protections from a backup.'**
  String get restoreBackupSubtitle;

  /// restore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// noBackupFound
  ///
  /// In en, this message translates to:
  /// **'No backup found'**
  String get noBackupFound;

  /// version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// aboutLimitItBody
  ///
  /// In en, this message translates to:
  /// **'Built to help you take control of your digital habits and live a more focused life.'**
  String get aboutLimitItBody;

  /// logOutOfLimitIt
  ///
  /// In en, this message translates to:
  /// **'Log out of LimitIt?'**
  String get logOutOfLimitIt;

  /// logOutSubtitle
  ///
  /// In en, this message translates to:
  /// **'Your protections and data stay saved. You can log back in any time.'**
  String get logOutSubtitle;

  /// yesLogOut
  ///
  /// In en, this message translates to:
  /// **'Yes, log out'**
  String get yesLogOut;

  /// noDataAvailable
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// backupCreated
  ///
  /// In en, this message translates to:
  /// **'Backup created — {count} protections saved'**
  String backupCreated(int count);

  /// backupRestored
  ///
  /// In en, this message translates to:
  /// **'Restored {count} protections'**
  String backupRestored(int count);

  /// lastBackup
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String lastBackup(String date);

  /// copyrightLine
  ///
  /// In en, this message translates to:
  /// **'© {year} LimitIt'**
  String copyrightLine(int year);

  /// or
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// dontHaveAnAccount
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// byContinuingYouAgree
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms of Service and Privacy Policy.'**
  String get byContinuingYouAgree;

  /// takeBackControlOfYourScreenTime
  ///
  /// In en, this message translates to:
  /// **'Take back control of your screen time'**
  String get takeBackControlOfYourScreenTime;

  /// Warning
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Attention
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attention;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Undo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// selected
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// Limits
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get limits;

  /// Loading Ad...
  ///
  /// In en, this message translates to:
  /// **'Loading Ad...'**
  String get loadingAd;

  /// Your Apps
  ///
  /// In en, this message translates to:
  /// **'Your Apps'**
  String get yourApps;

  /// Grant Permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Grant Permissions
  ///
  /// In en, this message translates to:
  /// **'Grant Permissions'**
  String get grantPermissions;

  /// Permissions Required
  ///
  /// In en, this message translates to:
  /// **'Permissions Required'**
  String get permissionsRequired;

  /// View Profile
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Failed to load profile
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// Name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No apps to save
  ///
  /// In en, this message translates to:
  /// **'No apps to save'**
  String get noAppsToSave;

  /// Saved limits for {count} apps
  ///
  /// In en, this message translates to:
  /// **'Saved limits for {count} apps'**
  String savedLimitsForApps(int count);

  /// Error saving limits: {error}
  ///
  /// In en, this message translates to:
  /// **'Error saving limits: {error}'**
  String errorSavingLimits(String error);

  /// No motivational phrases available
  ///
  /// In en, this message translates to:
  /// **'No motivational phrases available'**
  String get noMotivationalPhrasesAvailable;

  /// No motivational phrases found
  ///
  /// In en, this message translates to:
  /// **'No motivational phrases found'**
  String get noMotivationalPhrasesFound;

  /// No apps available
  ///
  /// In en, this message translates to:
  /// **'No apps available'**
  String get noAppsAvailable;

  /// Timer settings updated successfully!
  ///
  /// In en, this message translates to:
  /// **'Timer settings updated successfully!'**
  String get timerSettingsUpdated;

  /// Error loading app limit: {error}
  ///
  /// In en, this message translates to:
  /// **'Error loading app limit: {error}'**
  String errorLoadingAppLimit(String error);

  /// App limit updated successfully!
  ///
  /// In en, this message translates to:
  /// **'App limit updated successfully!'**
  String get appLimitUpdated;

  /// Failed to update app limit
  ///
  /// In en, this message translates to:
  /// **'Failed to update app limit'**
  String get failedToUpdateAppLimit;

  /// Error saving app limit: {error}
  ///
  /// In en, this message translates to:
  /// **'Error saving app limit: {error}'**
  String errorSavingAppLimit(String error);

  /// Limit for {appName} deleted successfully!
  ///
  /// In en, this message translates to:
  /// **'Limit for {appName} deleted successfully!'**
  String limitDeletedForApp(String appName);

  /// Limit deleted successfully!
  ///
  /// In en, this message translates to:
  /// **'Limit deleted successfully!'**
  String get limitDeletedSuccessfully;

  /// Failed to delete limit
  ///
  /// In en, this message translates to:
  /// **'Failed to delete limit'**
  String get failedToDeleteLimit;

  /// Pro Feature
  ///
  /// In en, this message translates to:
  /// **'Pro Feature'**
  String get proFeature;

  /// pro
  ///
  /// In en, this message translates to:
  /// **'pro'**
  String get pro;

  /// No blocked apps yet. Block apps from the home screen to set schedules.
  ///
  /// In en, this message translates to:
  /// **'No blocked apps yet. Block apps from the home screen to set schedules.'**
  String get noBlockedAppsYet;

  /// No blocked apps
  ///
  /// In en, this message translates to:
  /// **'No blocked apps'**
  String get noBlockedApps;

  /// Apps you block will appear here
  ///
  /// In en, this message translates to:
  /// **'Apps you block will appear here'**
  String get blockedAppsWillAppearHere;

  /// No more notifications
  ///
  /// In en, this message translates to:
  /// **'No more notifications'**
  String get noMoreNotifications;

  /// Delete Notification
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotification;

  /// Are you sure you want to delete this notification?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get deleteNotificationConfirm;

  /// Mark All as Read
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// Mark all notifications as read?
  ///
  /// In en, this message translates to:
  /// **'Mark all notifications as read?'**
  String get markAllAsReadConfirm;

  /// Clear All Notifications
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// This will permanently delete all notifications.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all notifications.'**
  String get clearAllNotificationsConfirm;

  /// Clear All
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No apps found on this device
  ///
  /// In en, this message translates to:
  /// **'No apps found on this device'**
  String get noAppsFoundOnDevice;

  /// New passwords do not match
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password must be at least 6 characters
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Old Password
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// Re-Enter New Password
  ///
  /// In en, this message translates to:
  /// **'Re-Enter New Password'**
  String get reEnterNewPassword;

  /// Activating your subscription...
  ///
  /// In en, this message translates to:
  /// **'Activating your subscription...'**
  String get activatingSubscription;

  /// Subscription Activated!
  ///
  /// In en, this message translates to:
  /// **'Subscription Activated!'**
  String get subscriptionActivated;

  /// You are now subscribed to
  /// {plan}
  ///
  /// In en, this message translates to:
  /// **'You are now subscribed to\n{plan}'**
  String youAreNowSubscribedTo(String plan);

  /// No subscription plans available
  ///
  /// In en, this message translates to:
  /// **'No subscription plans available'**
  String get noSubscriptionPlans;

  /// Take full control of your screen time
  ///
  /// In en, this message translates to:
  /// **'Take full control of your screen time'**
  String get takeFullControlOfScreenTime;

  /// MOST POPULAR
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// PIN Code
  ///
  /// In en, this message translates to:
  /// **'PIN Code'**
  String get pinCode;

  /// PIN code not available from server
  ///
  /// In en, this message translates to:
  /// **'PIN code not available from server'**
  String get pinCodeNotAvailable;

  /// You are Free Member
  /// Now
  ///
  /// In en, this message translates to:
  /// **'You are Free Member\nNow'**
  String get youAreFreeMemberNow;

  /// Tap to select for detox
  ///
  /// In en, this message translates to:
  /// **'Tap to select for detox'**
  String get tapToSelectForDetox;

  /// Daily Usage
  ///
  /// In en, this message translates to:
  /// **'Daily Usage'**
  String get dailyUsage;

  /// Remove Screen Time
  /// Limit?
  ///
  /// In en, this message translates to:
  /// **'Remove Screen Time\nLimit?'**
  String get removeScreenTimeLimit;

  /// Screen time Today
  ///
  /// In en, this message translates to:
  /// **'Screen time Today'**
  String get screenTimeToday;

  /// Starting monitoring service...
  ///
  /// In en, this message translates to:
  /// **'Starting monitoring service...'**
  String get startingMonitoringService;

  /// Failed to start monitoring service
  ///
  /// In en, this message translates to:
  /// **'Failed to start monitoring service'**
  String get failedToStartMonitoringService;

  /// This app cannot be blocked. Please use real app data.
  ///
  /// In en, this message translates to:
  /// **'This app cannot be blocked. Please use real app data.'**
  String get cannotBlockApp;

  /// Failed to block {appName}
  ///
  /// In en, this message translates to:
  /// **'Failed to block {appName}'**
  String failedToBlockApp(String appName);

  /// Failed to unblock {appName}
  ///
  /// In en, this message translates to:
  /// **'Failed to unblock {appName}'**
  String failedToUnblockApp(String appName);

  /// Updated Locally
  ///
  /// In en, this message translates to:
  /// **'Updated Locally'**
  String get updatedLocally;

  /// Checking for existing purchases...
  ///
  /// In en, this message translates to:
  /// **'Checking for existing purchases...'**
  String get checkingForExistingPurchases;

  /// Joined in {date}
  ///
  /// In en, this message translates to:
  /// **'Joined in {date}'**
  String joinedIn(String date);

  /// App usage tracking is only available on Android devices
  ///
  /// In en, this message translates to:
  /// **'App usage tracking is only available on Android devices'**
  String get appUsageAndroidOnly;

  /// Detox mode is only available on Android devices
  ///
  /// In en, this message translates to:
  /// **'Detox mode is only available on Android devices'**
  String get detoxModeAndroidOnly;

  /// PIN Lock is only available on Android devices
  ///
  /// In en, this message translates to:
  /// **'PIN Lock is only available on Android devices'**
  String get pinLockAndroidOnly;

  /// Permission denied. Please grant usage access permission in settings
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Please grant usage access permission in settings'**
  String get permissionDeniedUsageAccess;

  /// Please grant usage access permission
  ///
  /// In en, this message translates to:
  /// **'Please grant usage access permission'**
  String get pleaseGrantUsageAccess;

  /// Error loading app usage data: {error}
  ///
  /// In en, this message translates to:
  /// **'Error loading app usage data: {error}'**
  String errorLoadingAppUsage(String error);

  /// Error loading apps: {error}
  ///
  /// In en, this message translates to:
  /// **'Error loading apps: {error}'**
  String errorLoadingApps(String error);

  /// Joined recently
  ///
  /// In en, this message translates to:
  /// **'Joined recently'**
  String get joinedRecently;

  /// Please enter your name
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// Please enter your phone number
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhone;

  /// Please enter your email
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Please enter OTP
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get pleaseEnterOtp;

  /// Please confirm your password
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// Password Not Matching
  ///
  /// In en, this message translates to:
  /// **'Password Not Matching'**
  String get passwordNotMatching;

  /// Update Password
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// Failed to save app limits
  ///
  /// In en, this message translates to:
  /// **'Failed to save app limits'**
  String get failedToSaveAppLimits;

  /// Please select at least one app for detox mode
  ///
  /// In en, this message translates to:
  /// **'Please select at least one app for detox mode'**
  String get pleaseSelectAtLeastOneAppDetox;

  /// Error saving detox mode: {error}
  ///
  /// In en, this message translates to:
  /// **'Error saving detox mode: {error}'**
  String errorSavingDetoxMode(String error);

  /// Unknown App
  ///
  /// In en, this message translates to:
  /// **'Unknown App'**
  String get unknownApp;

  /// This feature is only available in the Pro version.
  ///
  /// In en, this message translates to:
  /// **'This feature is only available in the Pro version.'**
  String get proFeatureMessage;

  /// PIN lock settings saved successfully
  ///
  /// In en, this message translates to:
  /// **'PIN lock settings saved successfully'**
  String get pinLockSettingsSaved;

  /// Please enable PIN lock to continue
  ///
  /// In en, this message translates to:
  /// **'Please enable PIN lock to continue'**
  String get pleaseEnablePinLock;

  /// Please select at least one app to protect
  ///
  /// In en, this message translates to:
  /// **'Please select at least one app to protect'**
  String get pleaseSelectAtLeastOneAppToProtect;

  /// No app selected
  ///
  /// In en, this message translates to:
  /// **'No app selected'**
  String get noAppSelected;

  /// Schedules saved successfully!
  ///
  /// In en, this message translates to:
  /// **'Schedules saved successfully!'**
  String get schedulesSavedSuccessfully;

  /// Please enter a PIN code
  ///
  /// In en, this message translates to:
  /// **'Please enter a PIN code'**
  String get pleaseEnterPinCode;

  /// PIN code must be 4 digits
  ///
  /// In en, this message translates to:
  /// **'PIN code must be 4 digits'**
  String get pinCodeMustBe4Digits;

  /// Purchase error: {error}
  ///
  /// In en, this message translates to:
  /// **'Purchase error: {error}'**
  String purchaseError(String error);

  /// Could not start purchase: {error}
  ///
  /// In en, this message translates to:
  /// **'Could not start purchase: {error}'**
  String couldNotStartPurchase(String error);

  /// Could not start purchase. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Could not start purchase. Please try again.'**
  String get couldNotStartPurchaseRetry;

  /// Purchase failed: {error}
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseFailed(String error);

  /// Subscription failed
  ///
  /// In en, this message translates to:
  /// **'Subscription failed'**
  String get subscriptionFailed;

  /// Subscription activation failed
  ///
  /// In en, this message translates to:
  /// **'Subscription activation failed'**
  String get subscriptionActivationFailed;

  /// Restore failed: {error}
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// Server error: {error}
  ///
  /// In en, this message translates to:
  /// **'Server error: {error}'**
  String serverErrorWithMessage(String error);

  /// Subscriptions auto-renew unless cancelled at least 24 hours
  /// before the end of the current period.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions auto-renew unless cancelled at least 24 hours\nbefore the end of the current period.'**
  String get subscriptionAutoRenewNote;

  /// Start Time
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// End Time
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// Please enter {field}
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String pleaseEnterField(String field);

  /// Limit: {session} • {opens} opens
  ///
  /// In en, this message translates to:
  /// **'Limit: {session} • {opens} opens'**
  String limitSummary(String session, String opens);

  /// Ad-free experience
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get planFeatureAdFree;

  /// Standard reports
  ///
  /// In en, this message translates to:
  /// **'Standard reports'**
  String get planFeatureStandardReports;

  /// Email support
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get planFeatureEmailSupport;

  /// Everything in Basic
  ///
  /// In en, this message translates to:
  /// **'Everything in Basic'**
  String get planFeatureEverythingInBasic;

  /// Advanced analytics
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get planFeatureAdvancedAnalytics;

  /// Priority support
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get planFeaturePrioritySupport;

  /// Unlimited app limits
  ///
  /// In en, this message translates to:
  /// **'Unlimited app limits'**
  String get planFeatureUnlimitedAppLimits;

  /// To block apps, you need to grant Overlay and Accessibility permissions. Would you like to go to the permissions setup screen?
  ///
  /// In en, this message translates to:
  /// **'To block apps, you need to grant Overlay and Accessibility permissions. Would you like to go to the permissions setup screen?'**
  String get toBlockAppsGrantPermissions;

  /// {appName} is now blocked
  ///
  /// In en, this message translates to:
  /// **'{appName} is now blocked'**
  String appIsNowBlocked(String appName);

  /// {appName} is now unblocked
  ///
  /// In en, this message translates to:
  /// **'{appName} is now unblocked'**
  String appIsNowUnblocked(String appName);

  /// No usage today
  ///
  /// In en, this message translates to:
  /// **'No usage today'**
  String get noUsageToday;

  /// No plans available
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// Failed to fetch plans
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch plans'**
  String get failedToFetchPlans;

  /// Failed to fetch plans: {error}
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch plans: {error}'**
  String failedToFetchPlansWithError(String error);

  /// Invalid response format
  ///
  /// In en, this message translates to:
  /// **'Invalid response format'**
  String get invalidResponseFormat;

  /// Something went wrong. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Signup failed. Please check your connection.
  ///
  /// In en, this message translates to:
  /// **'Signup failed. Please check your connection.'**
  String get signupFailed;

  /// Verification failed
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// Error verifying user: {error}
  ///
  /// In en, this message translates to:
  /// **'Error verifying user: {error}'**
  String errorVerifyingUser(String error);

  /// Connection error. Please check your internet and try again.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet and try again.'**
  String get connectionErrorCheckInternet;

  /// Email not verified. Please verify your email.
  ///
  /// In en, this message translates to:
  /// **'Email not verified. Please verify your email.'**
  String get emailNotVerified;

  /// We've sent an OTP to your email. Please verify your email.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent an OTP to your email. Please verify your email.'**
  String get otpSentToEmail;

  /// Login failed. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginFailed;

  /// Network error. Please check your connection and try again.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get networkErrorCheckConnection;

  /// Server error! Please try later
  ///
  /// In en, this message translates to:
  /// **'Server error! Please try later'**
  String get serverErrorTryLater;

  /// Failed to change password
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// Failed to update profile
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Failed to update profile. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile. Please try again.'**
  String get failedToUpdateProfileRetry;

  /// Server error. Please try again later.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverErrorTryAgainLater;

  /// Server error. PIN saved locally and will sync when server is available.
  ///
  /// In en, this message translates to:
  /// **'Server error. PIN saved locally and will sync when server is available.'**
  String get pinSavedLocallyServerError;

  /// Bad gateway. PIN saved locally and will sync later.
  ///
  /// In en, this message translates to:
  /// **'Bad gateway. PIN saved locally and will sync later.'**
  String get pinSavedLocallyBadGateway;

  /// Service unavailable. PIN saved locally and will sync later.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. PIN saved locally and will sync later.'**
  String get pinSavedLocallyServiceUnavailable;

  /// Server error ({code}). PIN saved locally.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code}). PIN saved locally.'**
  String pinSavedLocallyServerErrorCode(String code);

  /// Failed to create PIN lock.
  ///
  /// In en, this message translates to:
  /// **'Failed to create PIN lock.'**
  String get failedToCreatePinLock;

  /// Failed to create PIN lock. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Failed to create PIN lock. Please try again.'**
  String get failedToCreatePinLockRetry;

  /// Network error. PIN saved locally.
  ///
  /// In en, this message translates to:
  /// **'Network error. PIN saved locally.'**
  String get networkErrorPinSavedLocally;

  /// Connection error. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get connectionErrorTryAgain;

  /// PIN updated locally. Server sync will be available soon.
  ///
  /// In en, this message translates to:
  /// **'PIN updated locally. Server sync will be available soon.'**
  String get pinUpdatedLocally;

  /// Failed to update PIN
  ///
  /// In en, this message translates to:
  /// **'Failed to update PIN'**
  String get failedToUpdatePin;

  /// Failed to delete PIN
  ///
  /// In en, this message translates to:
  /// **'Failed to delete PIN'**
  String get failedToDeletePin;

  /// Network error. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkErrorTryAgain;

  /// Breathe. Focus. Choose.
  ///
  /// In en, this message translates to:
  /// **'Breathe. Focus. Choose.'**
  String get messageSuggestion1;

  /// Discipline is freedom.
  ///
  /// In en, this message translates to:
  /// **'Discipline is freedom.'**
  String get messageSuggestion2;

  /// Less screen, more life.
  ///
  /// In en, this message translates to:
  /// **'Less screen, more life.'**
  String get messageSuggestion3;

  /// Your future is created by what you do today.
  ///
  /// In en, this message translates to:
  /// **'Your future is created by what you do today.'**
  String get messageSuggestion4;

  /// LimitIt - Usage Report
  ///
  /// In en, this message translates to:
  /// **'LimitIt - Usage Report'**
  String get reportTitle;

  /// Generated on: {date} at {time}
  ///
  /// In en, this message translates to:
  /// **'Generated on: {date} at {time}'**
  String reportGeneratedOn(String date, String time);

  /// Today's Summary
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get reportTodaysSummary;

  /// Total Apps Used
  ///
  /// In en, this message translates to:
  /// **'Total Apps Used'**
  String get reportTotalAppsUsed;

  /// Total Time
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get reportTotalTime;

  /// Avg per App
  ///
  /// In en, this message translates to:
  /// **'Avg per App'**
  String get reportAvgPerApp;

  /// Daily Usage Breakdown
  ///
  /// In en, this message translates to:
  /// **'Daily Usage Breakdown'**
  String get reportDailyUsageBreakdown;

  /// Usage Time
  ///
  /// In en, this message translates to:
  /// **'Usage Time'**
  String get reportUsageTime;

  /// App Name
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get reportAppName;

  /// Tips for Better Digital Balance
  ///
  /// In en, this message translates to:
  /// **'Tips for Better Digital Balance'**
  String get reportTips;

  /// Stay focused, take control of your time
  ///
  /// In en, this message translates to:
  /// **'Stay focused, take control of your time'**
  String get reportFooterTagline;

  /// Generated by LimitIt App
  ///
  /// In en, this message translates to:
  /// **'Generated by LimitIt App'**
  String get reportGeneratedBy;

  /// Can't connect to the internet!
  ///
  /// In en, this message translates to:
  /// **'Can\'t connect to the internet!'**
  String get cantConnectToInternet;

  /// No internet connection
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// Server error
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// Request timed out. Please try again.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get requestTimeout;

  /// Unknown error
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Processing...
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// • Set daily limits for social media apps
  ///
  /// In en, this message translates to:
  /// **'• Set daily limits for social media apps'**
  String get reportTip1;

  /// • Take regular breaks using the Pomodoro technique
  ///
  /// In en, this message translates to:
  /// **'• Take regular breaks using the Pomodoro technique'**
  String get reportTip2;

  /// • Use Detox Mode during focus time
  ///
  /// In en, this message translates to:
  /// **'• Use Detox Mode during focus time'**
  String get reportTip3;

  /// • Review your usage reports weekly
  ///
  /// In en, this message translates to:
  /// **'• Review your usage reports weekly'**
  String get reportTip4;

  /// • Enable PIN lock to prevent impulsive usage
  ///
  /// In en, this message translates to:
  /// **'• Enable PIN lock to prevent impulsive usage'**
  String get reportTip5;

  /// Almost all good writing begins with terrible first efforts. You need to start somewhere
  ///
  /// In en, this message translates to:
  /// **'Almost all good writing begins with terrible first efforts. You need to start somewhere'**
  String get defaultQuote1;

  /// God gives every bird its food, but He does not throw it into its nest
  ///
  /// In en, this message translates to:
  /// **'God gives every bird its food, but He does not throw it into its nest'**
  String get defaultQuote2;

  /// An effort made for the happiness of others lifts above ourselves
  ///
  /// In en, this message translates to:
  /// **'An effort made for the happiness of others lifts above ourselves'**
  String get defaultQuote3;

  /// storeUnavailable
  ///
  /// In en, this message translates to:
  /// **'The App Store is unavailable right now. Please try again later.'**
  String get storeUnavailable;

  /// planNotAvailable
  ///
  /// In en, this message translates to:
  /// **'This plan is not available for purchase right now. Please try another plan or check back later.'**
  String get planNotAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
