import Flutter
import UIKit

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "focuszen/app_blocker", binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "isSupported":
          result(FocusZenFamilyControlsManager.shared.isSupported())
        case "requestAuthorization":
          FocusZenFamilyControlsManager.shared.requestAuthorization { ok in result(ok) }
        case "startBlocking":
          let args = call.arguments as? [String: Any]
          let durationSeconds = args?["durationSeconds"] as? Int ?? 0
          FocusZenFamilyControlsManager.shared.startBlocking(from: controller, durationSeconds: durationSeconds) { res in
            switch res {
            case .success:
              result(nil)
            case .failure(let err):
              result(FlutterError(code: "BLOCK_FAILED", message: err.localizedDescription, details: nil))
            }
          }
        case "stopBlocking":
          FocusZenFamilyControlsManager.shared.stopBlocking()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    FocusZenFamilyControlsManager.shared.clearIfExpired()
  }
}
