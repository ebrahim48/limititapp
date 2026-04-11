# Polar Shop — Eco Product Scanner

A mobile application focused on environmental sustainability that allows users to scan product barcodes to access environmental impact information. The app enables users to check product eco-scores, compare environmental footprints, and make informed decisions to reduce their environmental impact.

---

## Features

### User Account Management
- **Create Account** — New users can register with their email and name.
- **Login / Logout** — Secure access to user accounts with email and password.
- **Forgot Password** — Password recovery through email verification.
- **Account Verification** — Email verification via OTP (One-Time Password) for security.
- **Password Reset** — Ability to change passwords securely.
- **Profile Management** — Update personal information and view account details.

---

### Product Scanning & Environmental Impact
- **Barcode Scanner** — Intuitive camera interface to scan product barcodes instantly.
- **Environmental Data** — Instant access to eco-scores, CO₂ emissions, and carbon footprint per product.
- **Product Comparison** — Compare multiple products side-by-side to evaluate environmental impact.
- **Alternative Suggestions** — Discover eco-friendly alternatives to products with higher environmental impact.
- **Scan History** — Track previously scanned products for future reference.

---

### Personal Environmental Tracking
- **Impact Dashboard** — Visual representation of personal environmental contributions.
- **Statistics Tracking** — Monitor metrics like plastic saved and CO₂ emissions reduced over time.
- **Scanning Activity** — Review recent scans and environmental impact trends.

---

### Recommendations & Alternatives
- **AI-Powered Recommendations** — Intelligent suggestions for environmentally friendly products.
- **Category-Based Alternatives** — Find better alternatives within specific product categories.
- **Eco-Score Comparisons** — Easily identify products with better environmental ratings.

---

### Community Engagement
- **Educational Resources** — Learn about environmental impact and sustainable living practices.
- **Donation Platform** — Support environmental causes through an integrated donation system.
- **Social Sharing** — Share environmental achievements and tips with others.

---

### Personalization & Settings
- **Customizable Profile** — Manage personal information and preferences.
- **App Settings** — Adjust app behavior according to user preferences.
- **Information Pages** — Access to privacy policies, terms of service, and about information.

---

### Additional Features
- **Onboarding Experience** — Guided setup for new users to understand app functionality.
- **Intuitive Navigation** — Easy-to-use interface with clear navigation between features.
- **Offline Functionality** — Basic features available without internet connection.

---

## Purpose

This application aims to empower consumers to make environmentally conscious purchasing decisions by providing instant access to product environmental impact data. By making this information readily available, users can contribute to reducing their carbon footprint and supporting sustainable products.

---

## Target Audience

- Environmentally conscious consumers
- People wanting to reduce their ecological footprint
- Shoppers looking for sustainable product alternatives
- Anyone interested in understanding product environmental impact

---

## Benefits

- Make informed purchasing decisions based on environmental impact
- Discover greener alternatives to everyday products
- Track personal environmental contributions over time
- Learn about sustainable consumption practices
- Encourage others to adopt eco-friendly habits

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Navigation | GoRouter |
| Local Storage | SharedPreferences |
| Barcode Scanning | `mobile_scanner` / `flutter_barcode_scanner` |
| AI Recommendations | REST API Integration |
| Image Loading | `cached_network_image` |
| Localization | Flutter Gen + `intl` |
| OTP Verification | `pin_code_fields` |
| Network Check | `internet_connection_checker_plus` |
| Social Sharing | `share_plus` |

---

## Platform Support

| Platform | Support |
|---|---|
| Android | Full support |
| iOS | Full support |

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.7.0`
- Android Studio or VS Code
- Android device/emulator (API 21+) or iOS device/simulator (iOS 13+)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd polar_shop_app

# Install dependencies
flutter pub get

# Generate assets
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Required Permissions

**Android:**
- `CAMERA` — For barcode scanning
- `INTERNET` — For fetching product environmental data
- `VIBRATE` — For scan feedback

**iOS:**
- `NSCameraUsageDescription` — For barcode scanning

---

## Project Structure

```
lib/
├── controllers/          # GetX controllers (auth, scan, profile, stats, etc.)
├── core/
│   ├── config/           # App themes, routes
│   ├── constants/        # Colors, strings, data helpers
│   ├── helpers/          # Utility helpers (localization, toast, network)
│   ├── models/           # Data models (product, eco-score, user, etc.)
│   ├── presentations/
│   │   ├── screens/      # All app screens (home, scanner, settings, auth, etc.)
│   │   └── widgets/      # Reusable UI components
│   └── services/         # Business logic services (scan, API, storage)
└── global/
    └── custom_assets/    # Generated asset references (flutter_gen)
```

---

Made with ❤️ for a greener planet
