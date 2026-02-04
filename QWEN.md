## Qwen Added Memories
- The limit_it_app is a Flutter application designed to help users manage and limit their app usage time. Key features include:

1. App usage tracking using Android's UsageStats API
2. App blocking functionality with real-time monitoring via AccessibilityService
3. Time-based limits for daily app usage and session duration
4. Multi-language support (English/Italian)
5. Dark/light theme support
6. Ad integration (banner and interstitial ads)
7. User authentication system
8. Onboarding flow with permissions setup
9. Home screen showing app usage statistics
10. Limits management screen for setting app restrictions
11. Reports screen for viewing usage analytics
12. Settings screen with various options

The app uses a hybrid approach combining Flutter for the UI layer with native Android code for app monitoring and blocking functionality. It requires special permissions (overlay and accessibility) to function properly. The architecture includes services for app usage tracking, app blocking, and data storage using SharedPreferences.
- The limit_it_app is a Flutter application designed to help users manage and limit their app usage time. Key features include: 1) App usage tracking using Android's UsageStats API, 2) App blocking functionality with real-time monitoring via AccessibilityService, 3) Time-based limits for daily app usage and session duration, 4) Multi-language support (English/Italian), 5) Dark/light theme support, 6) Ad integration (banner and interstitial ads), 7) User authentication system, 8) Onboarding flow with permissions setup, 9) Home screen showing app usage statistics, 10) Limits management screen for setting app restrictions, 11) Reports screen for viewing usage analytics, 12) Settings screen with various options. The app uses a hybrid approach combining Flutter for the UI layer with native Android code for app monitoring and blocking functionality. It requires special permissions (overlay and accessibility) to function properly. The architecture includes services for app usage tracking, app blocking, and data storage using SharedPreferences.
