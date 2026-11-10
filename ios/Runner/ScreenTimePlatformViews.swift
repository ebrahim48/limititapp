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
    static let appLabelView = "com.limitit.digitalbalance/screen_time_app_label"

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
        registrar.register(
            ScreenTimeViewFactory(kind: .appLabel),
            withId: appLabelView
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
        case appLabel
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
                // `ruleId` shows a saved protection's apps, `draft` the wizard's
                // pick; neither means the Block-now selection.
                let bridge = ScreenTimeBridge.shared
                let selection: FamilyActivitySelection
                if let ruleId = arguments?["ruleId"] as? String {
                    selection = bridge.selection(forRule: ruleId) ?? FamilyActivitySelection()
                } else if arguments?["draft"] as? Bool == true {
                    selection = bridge.draftSelection
                } else {
                    selection = bridge.selection
                }
                controller = UIHostingController(
                    rootView: SelectedAppsList(selection: selection)
                )
            case .usage:
                let days = (arguments?["days"] as? NSNumber)?.intValue ?? 1
                controller = UIHostingController(rootView: UsageReportView(days: days))
            case .appLabel:
                // A saved rule's apps; before Activate creates the rule, the
                // wizard's pending pick stands in for it.
                let bridge = ScreenTimeBridge.shared
                let ruleId = arguments?["ruleId"] as? String
                let selection = ruleId.flatMap { bridge.selection(forRule: $0) }
                    ?? bridge.draftSelection
                controller = UIHostingController(
                    rootView: ProtectionAppLabel(
                        selection: selection,
                        style: ProtectionAppLabel.Style(arguments: arguments)
                    )
                )
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

/// One protection's first app (or category), drawn either as its real icon or
/// as its real name — the two things Flutter can never read from a token.
/// A pick of several shows the first one plus "+N".
@available(iOS 16.0, *)
struct ProtectionAppLabel: View {
    struct Style {
        enum Mode { case icon, title }

        let mode: Mode
        let fontSize: CGFloat
        let weight: Font.Weight
        let color: Color
        let centered: Bool

        init(arguments: [String: Any]?) {
            mode = (arguments?["mode"] as? String) == "title" ? .title : .icon
            fontSize = CGFloat((arguments?["fontSize"] as? NSNumber)?.doubleValue ?? 15)
            switch (arguments?["weight"] as? NSNumber)?.intValue ?? 500 {
            case ..<450: weight = .regular
            case ..<550: weight = .medium
            case ..<650: weight = .semibold
            default: weight = .bold
            }
            let argb = (arguments?["color"] as? NSNumber)?.uint32Value ?? 0xFF1A1A1A
            color = Color(
                .sRGB,
                red: Double((argb >> 16) & 0xFF) / 255,
                green: Double((argb >> 8) & 0xFF) / 255,
                blue: Double(argb & 0xFF) / 255,
                opacity: Double((argb >> 24) & 0xFF) / 255
            )
            centered = arguments?["centered"] as? Bool ?? false
        }
    }

    let selection: FamilyActivitySelection
    let style: Style

    private var applications: [ApplicationToken] { Array(selection.applicationTokens) }
    private var categories: [ActivityCategoryToken] { Array(selection.categoryTokens) }
    private var extra: Int { max(applications.count + categories.count - 1, 0) }

    var body: some View {
        GeometryReader { proxy in
            content(side: min(proxy.size.width, proxy.size.height))
                .frame(
                    width: proxy.size.width,
                    height: proxy.size.height,
                    alignment: style.mode == .icon || style.centered ? .center : .leading
                )
        }
    }

    @ViewBuilder
    private func content(side: CGFloat) -> some View {
        switch style.mode {
        case .icon:
            first(labelStyle: .iconOnly)
                // A token's icon is sized like a text glyph; scale it up to
                // fill the tile Flutter reserved.
                .font(.system(size: side * 0.8))
                .scaleEffect(1.25)
        case .title:
            HStack(spacing: 4) {
                first(labelStyle: .titleOnly)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if extra > 0 {
                    Text("+\(extra)").fixedSize()
                }
            }
            .font(.system(size: style.fontSize, weight: style.weight))
            .foregroundColor(style.color)
        }
    }

    @ViewBuilder
    private func first<S: LabelStyle>(labelStyle: S) -> some View {
        if let token = applications.first {
            Label(token).labelStyle(labelStyle)
        } else if let token = categories.first {
            Label(token).labelStyle(labelStyle)
        } else {
            EmptyView()
        }
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
