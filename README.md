# Limit It — Screen Time & App Blocker

A Flutter application that helps users monitor and control their smartphone usage, set app limits, and build healthier digital habits.

---

## Features

### Dashboard (Home)
- **Screen Time Overview** — Real-time total daily screen time displayed via an interactive slider/progress bar.
- **Daily Usage Card** — Shows per-app usage breakdown with time spent for today.
- **Your Apps** — Lists all installed apps with live usage data fetched via the Android Usage Stats API.
- **Announcements** — In-app announcement/banner cards fetched from the server.
- **Google Mobile Ads** — Banner ads integrated on the home screen.

---

### Limits
- **Screen Time Limit** — Set a daily screen time cap for specific apps. Edit usage limits and timer settings (e.g., warning intervals, grace periods).
- **Schedules** — Create recurring time-based schedules to block or restrict app usage automatically.
- **Detox Mode** *(Pro)* — Select multiple apps and block them completely to help you focus. Supports select-all, real-time app list from the device, and persists blocked state.
- **Pin Lock** *(Pro)* — Protect app settings with a custom PIN so others cannot change your limits.

---

### Reports
- **Usage Reports** — View historical screen time data and per-app usage statistics.
- **PDF Export** — Generate and share usage reports as PDF files using the `pdf` and `printing` packages.

---

### Notifications
- **Notification Center** — In-app notification screen listing all received alerts and reminders.

---

### Settings
- **Subscription / In-App Purchase** — Upgrade to Premium to unlock Pro features (Detox Mode, Pin Lock) via `in_app_purchase`.
- **Motivation Phrases** — View and save motivational phrases to stay encouraged.
- **PIN Settings** — Set, change, or reset the app's PIN lock.
- **Change Password** — Update your account password.
- **Theme Support** — Light/Dark theme toggle.
- **Language / Localization** — Multi-language support via Flutter localization. Language can be selected from the onboarding flow or settings.
- **Terms & Conditions** — In-app terms of service page.
- **Privacy Policy** — In-app privacy policy page.
- **About Us** — App information and team details.
- **Delete Account** — Request account deletion from within the app.

---

### Authentication
- **Sign Up / Sign In** — Email and password-based authentication.
- **OTP / PIN Verification** — Verify account via a PIN code sent to email or phone.
- **Forgot Password** — Request a password reset link.
- **Reset Password** — Set a new password via a secure reset flow.
- **Phone Number Picker** — Country-code-aware phone number input.

---

### Onboarding
- **Onboarding Screens** — Multi-step introduction to the app's key features with smooth page indicators.
- **Language Selection** — Choose preferred language before starting.
- **Usage Limit Setup** — Guided setup to configure initial app usage limits during onboarding.
- **Permission Setup** — Step-by-step guide to grant required Android permissions (Usage Access, Overlay, etc.).

---

### Profile
- **View Profile** — See account name, avatar, and usage stats.
- **Edit Profile** — Update name, profile picture (image picker), and other details.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Navigation | GoRouter |
| Local Storage | SharedPreferences |
| App Usage Tracking | `usage_stats` (Android) |
| App Blocking | Native Android Overlay Service |
| In-App Purchase | `in_app_purchase` |
| Ads | Google Mobile Ads |
| PDF Generation | `pdf` + `printing` |
| Image Loading | `cached_network_image` |
| Localization | Flutter Gen + `intl` |
| Permissions | `permission_handler` |
| Installed Apps | `installed_apps` |
| Network Check | `internet_connection_checker_plus` |

---

## Platform Support

| Platform | Support |
|---|---|
| Android | Full support |
| iOS | Partial (App usage tracking not available on iOS) |

> Detox Mode, Screen Time tracking, and App Blocking require Android's **Usage Access** permission.

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.7.0`
- Android Studio or VS Code
- Android device or emulator (API 21+)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd limit_it_app

# Install dependencies
flutter pub get

# Generate assets
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Required Android Permissions

Grant the following permissions on your Android device for full functionality:

- **Usage Access** — `Settings > Digital Wellbeing / Usage Access`
- **Display Over Other Apps** — Required for app blocking overlay
- **Notification Permission** — For usage limit alerts

---

## Project Structure

```
lib/
├── controllers/          # GetX controllers (ads, notifications, profile, etc.)
├── core/
│   ├── config/           # App themes, routes
│   ├── constants/        # Colors, strings, data helpers
│   ├── helpers/          # Utility helpers (localization, toast, network)
│   ├── models/           # Data models
│   ├── presentations/
│   │   ├── screens/      # All app screens (home, limits, settings, auth, etc.)
│   │   └── widgets/      # Reusable UI components
│   └── services/         # Business logic services (app blocking, storage, usage)
└── global/
    └── custom_assets/    # Generated asset references (flutter_gen)
```
