import DeviceActivity
import SwiftUI

/// The only way iOS lets an app show per-app screen time.
///
/// `DeviceActivityReport` in the host app is a remote view: the rows below are
/// rendered inside this extension's sandbox and composited into our UI. The
/// host process never sees the durations, the app names or the tokens — that
/// one-way flow is what Apple trades for access to the data at all.
@main
struct ScreenTimeReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        AppUsageReport { summary in
            AppUsageView(summary: summary)
        }
    }
}
