import Flutter
import UIKit

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import SwiftUI
#endif

/// Bridge to Apple's Screen Time APIs — the only sanctioned way to block apps
/// on iOS.
///
/// Three platform facts shape everything here:
///  - iOS has no API to enumerate installed apps, so the user picks them in
///    Apple's own `FamilyActivityPicker`.
///  - The picker hands back **opaque tokens**, never bundle ids or names. We
///    can count the selection but can never show which apps it holds.
///  - Shielding those tokens is what blocks the apps, and iOS draws the block
///    screen itself. A custom screen needs a ShieldConfiguration app
///    extension; the default system shield works without one.
enum ScreenTimeChannel {
    static let name = "com.limitit.digitalbalance/screen_time"

    static func register(
        with registry: FlutterPluginRegistry,
        rootViewController: @escaping () -> UIViewController?
    ) {
        guard let registrar = registry.registrar(forPlugin: "LimitItScreenTime") else { return }

        let channel = FlutterMethodChannel(
            name: name,
            binaryMessenger: registrar.messenger()
        )

        channel.setMethodCallHandler { call, result in
            handle(call: call, result: result, rootViewController: rootViewController)
        }
    }

    private static func handle(
        call: FlutterMethodCall,
        result: @escaping FlutterResult,
        rootViewController: @escaping () -> UIViewController?
    ) {
        #if canImport(FamilyControls)
        guard #available(iOS 16.0, *) else {
            result(unsupported(call.method))
            return
        }

        let bridge = ScreenTimeBridge.shared

        switch call.method {
        case "isSupported":
            result(true)

        case "hasUsageReport":
            result(ScreenTimePlatformViews.hasUsageReportExtension)

        case "isAuthorized":
            result(bridge.isAuthorized)

        case "requestAuthorization":
            Task {
                do {
                    try await bridge.requestAuthorization()
                    await MainActor.run { result(true) }
                } catch {
                    await MainActor.run {
                        result(
                            FlutterError(
                                code: "AUTHORIZATION_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            )
                        )
                    }
                }
            }

        case "pickApps":
            guard let presenter = rootViewController() else {
                result(
                    FlutterError(
                        code: "NO_VIEW_CONTROLLER",
                        message: "No view controller to present the picker from",
                        details: nil
                    )
                )
                return
            }
            let draft = (call.arguments as? [String: Any])?["draft"] as? Bool ?? false
            bridge.presentPicker(from: presenter, draft: draft) { picked in
                // `nil` means the user cancelled; the stored selection stands.
                result(picked ? bridge.summary(draft: draft) : nil)
            }

        case "syncRules":
            let rules = (call.arguments as? [String: Any])?["rules"] as? [[String: Any]] ?? []
            result(bridge.syncRules(rules))

        case "applyShield":
            bridge.applyShield()
            result(bridge.summary())

        case "clearShield":
            bridge.clearShield()
            result(bridge.summary())

        case "summary":
            result(bridge.summary())

        default:
            result(FlutterMethodNotImplemented)
        }
        #else
        result(unsupported(call.method))
        #endif
    }

    /// Below iOS 16 (or without the framework) every call answers honestly
    /// rather than pretending the feature is there.
    private static func unsupported(_ method: String) -> Any? {
        switch method {
        case "isSupported", "isAuthorized", "hasUsageReport":
            return false
        case "summary":
            return ["applications": 0, "categories": 0, "webDomains": 0, "shielded": false]
        default:
            return nil
        }
    }
}

#if canImport(FamilyControls)

@available(iOS 16.0, *)
final class ScreenTimeBridge {
    static let shared = ScreenTimeBridge()

    private let store = ManagedSettingsStore()
    private let selectionKey = "limitit.screenTime.selection"
    private let shieldedKey = "limitit.screenTime.shielded"

    /// Readable so the SwiftUI platform views can draw labels for the tokens.
    private(set) var selection = FamilyActivitySelection()

    /// Apps picked in the add-protection wizard, waiting for the rule that
    /// `syncRules` creates when the user hits Activate.
    private(set) var draftSelection = FamilyActivitySelection()

    private init() {
        restore()
    }

    var isAuthorized: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    /// Apple's picker, presented as a sheet. Returns `true` when the user
    /// confirmed a selection.
    ///
    /// A `draft` pick starts empty and only fills `draftSelection`, leaving the
    /// Block-now selection and its shield alone.
    func presentPicker(
        from viewController: UIViewController,
        draft: Bool = false,
        completion: @escaping (Bool) -> Void
    ) {
        var host: UIHostingController<ActivityPickerView>?

        let view = ActivityPickerView(
            selection: draft ? FamilyActivitySelection() : selection,
            onDone: { [weak self] picked in
                guard let self else { return }
                if draft {
                    self.draftSelection = picked
                } else {
                    self.selection = picked
                    self.persist()
                    // Keep the shield in step with the new selection.
                    if UserDefaults.standard.bool(forKey: self.shieldedKey) {
                        self.applyShield()
                    }
                }
                host?.dismiss(animated: true) { completion(true) }
            },
            onCancel: {
                host?.dismiss(animated: true) { completion(false) }
            }
        )

        let controller = UIHostingController(rootView: view)
        host = controller
        viewController.present(controller, animated: true)
    }

    func applyShield() {
        store.shield.applications =
            selection.applicationTokens.isEmpty ? nil : selection.applicationTokens

        store.shield.applicationCategories =
            selection.categoryTokens.isEmpty
            ? nil
            : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)

        store.shield.webDomains =
            selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        UserDefaults.standard.set(true, forKey: shieldedKey)
    }

    func clearShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.clearAllSettings()

        UserDefaults.standard.set(false, forKey: shieldedKey)
    }

    /// Counts only — the tokens never reveal which apps they stand for.
    func summary(draft: Bool = false) -> [String: Any] {
        let picked = draft ? draftSelection : selection
        return [
            "applications": picked.applicationTokens.count,
            "categories": picked.categoryTokens.count,
            "webDomains": picked.webDomainTokens.count,
            "shielded": !draft && UserDefaults.standard.bool(forKey: shieldedKey),
        ]
    }

    /// The apps behind one protection, for the native list view.
    func selection(forRule id: String) -> FamilyActivitySelection? {
        RuleStore.rule(id: id)?.selection
    }

    /// Mirrors Dart's iOS protections into the rules the extensions enforce.
    ///
    /// Dart sends its whole list after every change, so a rule missing from it
    /// was deleted. A rule seen for the first time takes the wizard's
    /// `draftSelection`; with none waiting it is skipped, since there are no
    /// apps to attach it to. Only rules whose schedule changed are restarted —
    /// restarting a daily limit would reset the usage counted so far today.
    ///
    /// Returns the ids now enforced.
    func syncRules(_ payload: [[String: Any]]) -> [String] {
        let existing = Dictionary(
            RuleStore.all().map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        var next: [LimitRule] = []

        for map in payload {
            guard
                let id = map["id"] as? String,
                let kind = ProtectionKind(rawValue: map["type"] as? String ?? "")
            else { continue }

            let picked: FamilyActivitySelection
            if let old = existing[id] {
                picked = old.selection
            } else if !draftSelection.applicationTokens.isEmpty
                || !draftSelection.categoryTokens.isEmpty
                || !draftSelection.webDomainTokens.isEmpty {
                picked = draftSelection
                draftSelection = FamilyActivitySelection()
            } else {
                continue
            }

            next.append(
                LimitRule(
                    id: id,
                    kind: kind,
                    selection: picked,
                    isActive: map["isActive"] as? Bool ?? true,
                    activeDays: map["activeDays"] as? [String] ?? [],
                    delaySeconds: (map["delaySeconds"] as? NSNumber)?.intValue ?? 0,
                    dailyLimitMinutes: (map["dailyLimitMinutes"] as? NSNumber)?.intValue ?? 0,
                    maxOpens: (map["maxOpens"] as? NSNumber)?.intValue ?? 0,
                    blockStart: map["blockStart"] as? String,
                    blockEnd: map["blockEnd"] as? String,
                    message: map["message"] as? String
                )
            )
        }

        let kept = Set(next.map(\.id))
        for id in existing.keys where !kept.contains(id) {
            RuleScheduler.stop(id)
            RuleStore.forgetState(id)
        }

        // Saved first: the monitor may fire as soon as a schedule starts.
        RuleStore.save(next)
        for rule in next {
            if let old = existing[rule.id], old.hasSameSchedule(as: rule) { continue }
            RuleScheduler.start(rule)
        }

        return next.map(\.id)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        UserDefaults.standard.set(data, forKey: selectionKey)
    }

    private func restore() {
        guard
            let data = UserDefaults.standard.data(forKey: selectionKey),
            let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }
        selection = decoded
    }
}

@available(iOS 16.0, *)
struct ActivityPickerView: View {
    @State var selection: FamilyActivitySelection

    let onDone: (FamilyActivitySelection) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Choose apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { onCancel() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { onDone(selection) }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

#endif
