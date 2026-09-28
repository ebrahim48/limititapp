import Flutter
import UIKit

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import SwiftUI
#endif

#if canImport(DeviceActivity)
import DeviceActivity
#endif

/// Native views Flutter embeds inside the iOS "protect apps" screen.
///
/// Both exist because Apple never hands app identities to our code:
///  - `selectionListView` draws the picked apps' real icons and names from the
///    opaque tokens. Only SwiftUI can resolve a token into a label, so the rows
///    have to be drawn natively and handed to Flutter as a platform view.
///  - `usageReportView` embeds `DeviceActivityReport`, the only way to show
///    per-app screen time. Its contents are rendered by a separate app
///    extension in a sandbox we cannot read from — we get a picture, never the
///    numbers.
enum ScreenTimePlatformViews {
    static let selectionListView = "com.limitit.digitalbalance/screen_time_selection"
    static let usageReportView = "com.limitit.digitalbalance/screen_time_usage"

    static func register(with registry: FlutterPluginRegistry) {
        guard let registrar = registry.registrar(forPlugin: "LimitItScreenTimeViews") else { return }

        registrar.register(
            ScreenTimeViewFactory(kind: .selection),
            withId: selectionListView
        )
        registrar.register(
            ScreenTimeViewFactory(kind: .usage),
            withId: usageReportView
        )
    }

    /// `true` when the DeviceActivityReport extension is bundled with this
    /// build. Without it `DeviceActivityReport` renders an empty rectangle, so
    /// Dart asks first and falls back to plain counts.
    static var hasUsageReportExtension: Bool {
        guard
            #available(iOS 16.0, *),
            let plugins = Bundle.main.builtInPlugInsURL,
            let entries = try? FileManager.default.contentsOfDirectory(
                at: plugins,
                includingPropertiesForKeys: nil
            )
        else { return false }

        return entries.contains { entry in
            entry.pathExtension == "appex"
                && entry.deletingPathExtension().lastPathComponent.contains("ScreenTimeReport")
        }
    }
}

final class ScreenTimeViewFactory: NSObject, FlutterPlatformViewFactory {
    enum Kind {
        case selection
        case usage
    }

    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        ScreenTimeHostedView(frame: frame, kind: kind, arguments: args as? [String: Any])
    }
}

final class ScreenTimeHostedView: NSObject, FlutterPlatformView {
    private let container: UIView
    // Hosting controllers are kept alive for as long as the platform view is:
    // dropping one tears its SwiftUI tree down mid-flight.
    private var hosting: UIViewController?

    init(frame: CGRect, kind: ScreenTimeViewFactory.Kind, arguments: [String: Any]?) {
        container = UIView(frame: frame)
        container.backgroundColor = .clear
        super.init()

        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            let controller: UIViewController
            switch kind {
            case .selection:
                controller = UIHostingController(
                    rootView: SelectedAppsList(
                        selection: ScreenTimeBridge.shared.selection
                    )
                )
            case .usage:
                let days = (arguments?["days"] as? NSNumber)?.intValue ?? 1
                controller = UIHostingController(rootView: UsageReportView(days: days))
            }

            controller.view.backgroundColor = .clear
            controller.view.frame = container.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.addSubview(controller.view)
            hosting = controller
        }
        #endif
    }

    func view() -> UIView { container }
}

#if canImport(FamilyControls)

/// The picked apps, with the icons and names only SwiftUI can resolve.
///
/// `Label(token)` is the whole trick: the token stays opaque to us, but the
/// system draws the app behind it. Reading the text back out is not possible.
@available(iOS 16.0, *)
struct SelectedAppsList: View {
    let selection: FamilyActivitySelection

    private var applications: [ApplicationToken] { Array(selection.applicationTokens) }
    private var categories: [ActivityCategoryToken] { Array(selection.categoryTokens) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(applications, id: \.self) { token in
                row { Label(token) }
            }
            ForEach(categories, id: \.self) { token in
                row { Label(token) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .labelStyle(.titleAndIcon)
            .font(.system(size: 15, weight: .medium))
            .lineLimit(1)
            .frame(height: ScreenTimeMetrics.rowHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }
}

/// Row geometry shared with Dart, which has to reserve the right height for
/// the platform view before the native side has laid anything out.
enum ScreenTimeMetrics {
    static let rowHeight: CGFloat = 44
}

#endif

#if canImport(DeviceActivity)

@available(iOS 16.0, *)
extension DeviceActivityReport.Context {
    /// Must match the context the report extension declares.
    static let appUsage = Self("App Usage")
}

/// Per-app screen time, drawn by the report extension.
///
/// The view is a sandboxed remote view: it renders the numbers but never
/// exposes them to this process, which is exactly why the usage list cannot be
/// rebuilt in Flutter.
@available(iOS 16.0, *)
struct UsageReportView: View {
    let days: Int

    private var filter: DeviceActivityFilter {
        let calendar = Calendar.current
        let end = Date()
        let start = calendar.date(byAdding: .day, value: -(max(days, 1) - 1), to: end) ?? end

        return DeviceActivityFilter(
            segment: .daily(
                during: DateInterval(
                    start: calendar.startOfDay(for: start),
                    end: end
                )
            ),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }

    var body: some View {
        DeviceActivityReport(.appUsage, filter: filter)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#endif
