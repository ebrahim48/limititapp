import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftUI

extension DeviceActivityReport.Context {
    /// Must match the context the host app asks for in `UsageReportView`.
    static let appUsage = Self("App Usage")
}

struct AppUsageRow: Identifiable {
    let id: String
    let token: ApplicationToken?
    let name: String
    let duration: TimeInterval
    let pickups: Int
}

struct AppUsageSummary {
    let total: TimeInterval
    let rows: [AppUsageRow]

    static let empty = AppUsageSummary(total: 0, rows: [])
}

/// Folds the raw activity stream into "app → time + pickups", the shape the
/// Android side already shows.
struct AppUsageReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .appUsage
    let content: (AppUsageSummary) -> AppUsageView

    func makeConfiguration(
        representing data: DeviceActivityResults<DeviceActivityData>
    ) async -> AppUsageSummary {
        // The same app shows up once per segment, so totals are accumulated per
        // bundle id rather than appended.
        var totals: [String: AppUsageRow] = [:]
        var grandTotal: TimeInterval = 0

        for await result in data {
            for await segment in result.activitySegments {
                grandTotal += segment.totalActivityDuration

                for await category in segment.categories {
                    for await app in category.applications {
                        let application = app.application
                        let key = application.bundleIdentifier
                            ?? application.localizedDisplayName
                            ?? UUID().uuidString

                        let existing = totals[key]
                        totals[key] = AppUsageRow(
                            id: key,
                            token: application.token,
                            name: application.localizedDisplayName ?? "Unknown app",
                            duration: (existing?.duration ?? 0) + app.totalActivityDuration,
                            pickups: (existing?.pickups ?? 0) + app.numberOfPickups
                        )
                    }
                }
            }
        }

        let rows = totals.values
            .filter { $0.duration > 0 }
            .sorted { $0.duration > $1.duration }

        return AppUsageSummary(total: grandTotal, rows: Array(rows))
    }
}
