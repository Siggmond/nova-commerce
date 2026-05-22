import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.novacommerce.nova_commerce/platform_app_locale"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { call, result in
        if call.method != "setLocale" {
          result(FlutterMethodNotImplemented)
          return
        }

        let args = call.arguments as? [String: Any]
        let tag = (args?["languageTag"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if tag.isEmpty {
          UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
          UserDefaults.standard.set([tag], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        result(nil)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
