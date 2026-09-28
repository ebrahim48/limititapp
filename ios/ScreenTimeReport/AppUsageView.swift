import DeviceActivity
import FamilyControls
import ManagedSettings
import SwiftUI

/// The usage list the host app embeds. Styling is kept close to the Flutter
/// cards so the remote view does not read as a foreign rectangle.
struct AppUsageView: View {
    let summary: AppUsageSummary

    var body: some View {
        if summary.rows.isEmpty {
            Text("No screen time recorded yet.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(summary.rows) { row in
                        HStack(spacing: 12) {
                            if let token = row.token {
                                // Label resolves the icon; the plain name below
                                // keeps the row readable when it cannot.
                                Label(token)
                                    .labelStyle(.iconOnly)
                                    .frame(width: 32, height: 32)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(row.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .lineLimit(1)
                                Text("\(format(row.duration)) · \(row.pickups) opens")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        Divider().padding(.leading, 60)
                    }
                }
            }
        }
    }

    private func format(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 { return "\(minutes) min" }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
    }
}
