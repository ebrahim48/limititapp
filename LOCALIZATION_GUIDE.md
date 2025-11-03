# Localization Guide

## How to Use Localization in Your App

All strings have been added to the localization files (English and Italian). Here's how to use them:

### Method 1: Using the Extension (Recommended)

```dart
import 'package:limit_it_app/core/helpers/localization_helper.dart';

// In your widget with context:
Text(context.l10n.welcomeToLimitIt)
Text(context.l10n.getStarted)
```

### Method 2: Using AppLocalizations Directly

```dart
import 'package:limit_it_app/l10n/app_localizations.dart';

// In your widget with context:
Text(AppLocalizations.of(context)!.welcomeToLimitIt)
Text(AppLocalizations.of(context)!.getStarted)
```

### Method 3: Using AppString Helper

```dart
import 'package:limit_it_app/core/constants/app_strings.dart';

// In your widget with context:
Text(AppString.of(context).welcomeToLimitIt)
Text(AppString.of(context).getStarted)
```

## Migration Guide

Replace all occurrences of `AppString.constantName` with `context.l10n.camelCaseName` or `AppString.of(context).camelCaseName`

### Old Code → New Code Mapping:

| Old Code | New Code |
|----------|----------|
| `AppString.select` | `context.l10n.selectYourLanguage` |
| `AppString.start` | `context.l10n.getStarted` |
| `AppString.welcomeLimitIt` | `context.l10n.welcomeToLimitIt` |
| `AppString.starting` | `context.l10n.startingToday` |
| `AppString.signUp` | `context.l10n.signUpYourAccount` |
| `AppString.enter` | `context.l10n.enterYourDetails` |
| `AppString.firstName` | `context.l10n.firstName` |
| `AppString.email` | `context.l10n.email` |
| `AppString.password` | `context.l10n.password` |
| `AppString.setNewPassword` | `context.l10n.setNewPassword` |
| `AppString.conPassword` | `context.l10n.confirmPassword` |
| `AppString.conNewPassword` | `context.l10n.confirmNewPassword` |
| `AppString.creating` | `context.l10n.byCreatingAccount` |
| `AppString.terms` | `context.l10n.termsAndConditions` |
| `AppString.passMatch` | `context.l10n.passwordMatched` |
| `AppString.privacy` | `context.l10n.privacyPolicy` |
| `AppString.already` | `context.l10n.alreadyHaveAccount` |
| `AppString.login` | `context.l10n.login` |
| `AppString.signUps` | `context.l10n.signUp` |
| `AppString.loginYour` | `context.l10n.logInYourAccount` |
| `AppString.allSet` | `context.l10n.allSetPasswordUpdated` |
| `AppString.loginYourSecurity` | `context.l10n.logInSecurely` |
| `AppString.forgetPass` | `context.l10n.forgetPassword` |
| `AppString.forgetPassWord` | `context.l10n.forgetPasswordTitle` |
| `AppString.resetPassWord` | `context.l10n.resetPassword` |
| `AppString.getOtp` | `context.l10n.getOtp` |
| `AppString.verifyOtp` | `context.l10n.verifyOtp` |
| `AppString.verify` | `context.l10n.verify` |
| `AppString.didnt` | `context.l10n.didntGetCode` |
| `AppString.backlog` | `context.l10n.backToLogin` |
| `AppString.takeControl` | `context.l10n.takeControl` |
| `AppString.backHome` | `context.l10n.backToHome` |
| `AppString.getStarted` | `context.l10n.getStarted` |
| `AppString.iAccept` | `context.l10n.iAcceptPrivacy` |
| `AppString.dataProtection` | `context.l10n.privacyDataProtection` |
| `AppString.usage` | `context.l10n.usageDataStaysOnDevice` |
| `AppString.we` | `context.l10n.noPersonalInfoCollection` |
| `AppString.gdpr` | `context.l10n.gdprCompliance` |
| `AppString.trans` | `context.l10n.transparentPermissions` |
| `AppString.selectApp` | `context.l10n.selectAppsToManage` |
| `AppString.usageLimit` | `context.l10n.setUsageLimit` |
| `AppString.dailyScreen` | `context.l10n.totalDailyScreenTime` |
| `AppString.all` | `context.l10n.all` |
| `AppString.saveContinue` | `context.l10n.saveContinue` |
| `AppString.timerSettings` | `context.l10n.timerSettings` |
| `AppString.preOpening` | `context.l10n.preOpeningCountdown` |
| `AppString.save` | `context.l10n.save` |
| `AppString.motivational` | `context.l10n.motivationalPhrases` |
| `AppString.successLimit` | `context.l10n.allSetAppLimit` |

## Files to Update:

1. `/lib/core/presentations/screens/auth/limitItScreenTime/set_usage_limit_screen.dart`
2. `/lib/core/presentations/screens/auth/limitItScreenTime/select_apps_manage.dart`
3. `/lib/core/presentations/screens/auth/verify/verify_screen.dart`
4. `/lib/core/presentations/screens/auth/forget/forget_password_screen.dart`
5. `/lib/core/presentations/screens/auth/signup/sign_up_screen.dart`
6. `/lib/core/presentations/screens/auth/signin/sign_in _screen.dart`
7. `/lib/core/presentations/screens/splash/splash_screen.dart`
8. `/lib/core/presentations/screens/onboarding/onboarding_screen.dart`
9. `/lib/core/presentations/screens/limits/edit_usage_limit.dart`
10. `/lib/core/presentations/screens/limits/edit_timer_settings.dart`
11. `/lib/core/presentations/screens/auth/reset/reset_successfully_screen.dart`
12. `/lib/core/presentations/screens/auth/reset/reset_password_screen.dart`
13. `/lib/core/presentations/screens/auth/limitItScreenTime/timer_success_message.dart`
14. `/lib/core/presentations/screens/auth/limitItScreenTime/timer_settings_screen.dart`
15. `/lib/core/presentations/screens/auth/limitItScreenTime/limit_privacy.dart`

## Steps for Each File:

1. Add import: `import 'package:limit_it_app/core/helpers/localization_helper.dart';`
2. Replace all `AppString.xxx` with `context.l10n.xxx` using the mapping table above
3. If the screen is stateful, wrap the build method content with `Obx()` if not already reactive
4. Test the screen in both English and Italian

## Testing:

1. Run the app
2. Go to Language Screen
3. Switch between English and Italian
4. Verify all text changes properly
