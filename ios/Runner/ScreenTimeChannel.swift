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
            bridge.presentPicker(from: presenter) { picked in
                // `nil` means the user cancelled; the stored selection stands.
                result(picked ? bridge.summary() : nil)
            }

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
    func presentPicker(
        from viewController: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        var host: UIHostingController<ActivityPickerView>?

        let view = ActivityPickerView(
            selection: selection,
            onDone: { [weak self] picked in
                self?.selection = picked
                self?.persist()
                // Keep the shield in step with the new selection.
                if UserDefaults.standard.bool(forKey: self?.shieldedKey ?? "") {
                    self?.applyShield()
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
    func summary() -> [String: Any] {
        [
            "applications": selection.applicationTokens.count,
            "categories": selection.categoryTokens.count,
            "webDomains": selection.webDomainTokens.count,
            "shielded": UserDefaults.standard.bool(forKey: shieldedKey),
        ]
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
