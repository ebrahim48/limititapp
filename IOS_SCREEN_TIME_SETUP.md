# iOS: showing apps and their usage

## Why iOS looks different from Android

On Android we enumerate the launcher and read `UsageStatsManager`, so we can
build the list ourselves. iOS has no equivalent, and no amount of Flutter code
changes that:

- There is **no API to list installed apps**. `canOpenURL` only answers for
  schemes hardcoded in `LSApplicationQueriesSchemes`.
- `FamilyActivityPicker` returns **opaque tokens**, not bundle ids or names.
- Per-app screen time is only readable inside a **DeviceActivityReport
  extension**, which runs in its own sandbox.

What iOS *does* allow is displaying that information in views it renders for
us. That is what this change adds:

| What the user sees | How it is drawn | Can Dart read it? |
|---|---|---|
| Picked apps, real icon + name | SwiftUI `Label(token)` in `ScreenTimePlatformViews.swift`, embedded as a `UiKitView` | No |
| Per-app screen time + opens | `DeviceActivityReport` rendered by the extension in `ios/ScreenTimeReport/` | No |

The numbers never cross into our process. They can be shown, not exported —
so an iOS "usage" chart built from Dart data is not possible.

## Already wired up (no action needed)

- `ios/Runner/ScreenTimePlatformViews.swift` — the two platform views, plus
  `hasUsageReportExtension` so Dart can tell whether the report ships.
- `ios/Runner/AppDelegate.swift` — registers them.
- `lib/core/presentations/screens/protection/screen_time_native_views.dart` —
  the Flutter side.
- `ios_screen_time_view.dart` — shows the picked-apps list, and the usage card
  when the extension is present.

The picked-apps list works as soon as you rebuild. The usage card needs the
extension target below; until it exists the screen says so instead of showing
an empty box.

## Adding the report extension (Xcode, ~5 minutes)

The sources are written already; only the target has to be created, because a
target carries signing settings that cannot be generated from here.

1. Open `ios/Runner.xcworkspace` (the workspace, not the project).
2. **File → New → Target… → Device Activity Report Extension**.
   - Product Name: `ScreenTimeReport` (the name matters — `hasUsageReportExtension`
     looks for it).
   - Embed in Application: `Runner`. Activate the scheme when prompted.
3. Xcode creates a `ScreenTimeReport` group with its own template files.
   **Delete them** (Move to Trash), then drag in the four files from
   `ios/ScreenTimeReport/`:
   `ScreenTimeReportExtension.swift`, `AppUsageReport.swift`,
   `AppUsageView.swift`, `Info.plist` — target membership `ScreenTimeReport`
   only. Point *Build Settings → Info.plist File* at the one you dragged in.
4. Select the `ScreenTimeReport` target → **Signing & Capabilities**:
   - same team as `Runner`;
   - bundle id `com.limitit.digitalbalance.ScreenTimeReport`;
   - **+ Capability → Family Controls** (or set
     `CODE_SIGN_ENTITLEMENTS = ScreenTimeReport/ScreenTimeReport.entitlements`,
     which is in `ios/ScreenTimeReport/`);
   - iOS Deployment Target 16.0 or later.
5. Build and run on a real device. The simulator reports no screen time.

## App Store note

`com.apple.developer.family-controls` is a restricted entitlement. Development
builds work with a normal provisioning profile, but distribution needs Apple's
approval on both the app and the extension:
https://developer.apple.com/contact/request/family-controls-distribution

## Troubleshooting

- **Usage card says the extension is missing** — the target's product name is
  not `ScreenTimeReport`, or it is not embedded in `Runner`.
- **Usage list is empty on device** — Screen Time has to have been on long
  enough to have data; a freshly enrolled device reports nothing for the
  current day.
- **Picked apps show as blank rows** — the shared `ScreenTimeBridge.selection`
  was not restored; check that Screen Time authorization is still approved in
  Settings → Screen Time.
