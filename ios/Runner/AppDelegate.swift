import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private static let deviceAppsChannelName = "com.limitit.digitalbalance/device_apps"

  private var deviceAppsChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerDeviceAppsChannel(engineBridge.pluginRegistry)

    ScreenTimeChannel.register(with: engineBridge.pluginRegistry) { [weak self] in
      self?.window?.rootViewController
    }

    // Apple resolves app icons and usage only inside SwiftUI, so those rows are
    // drawn natively and embedded in the Flutter tree.
    ScreenTimePlatformViews.register(with: engineBridge.pluginRegistry)
  }

  /// Lets Dart ask which of a known set of apps is present on this device.
  private func registerDeviceAppsChannel(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LimitItDeviceApps") else { return }

    let channel = FlutterMethodChannel(
      name: AppDelegate.deviceAppsChannelName,
      binaryMessenger: registrar.messenger()
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "detectInstalled":
        let arguments = call.arguments as? [String: Any]
        let schemes = arguments?["schemes"] as? [String] ?? []
        result(AppDelegate.installedSchemes(among: schemes))
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    deviceAppsChannel = channel
  }

  /// iOS gives no API to enumerate installed apps. `canOpenURL` is the only
  /// detection it allows, and it answers only for schemes declared in
  /// `LSApplicationQueriesSchemes` (Info.plist) — so the catalogue there and
  /// the one in Dart have to stay in sync.
  private static func installedSchemes(among schemes: [String]) -> [String] {
    return schemes.filter { scheme in
      guard let url = URL(string: "\(scheme)://") else { return false }
      return UIApplication.shared.canOpenURL(url)
    }
  }
}
