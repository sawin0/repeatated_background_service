import Flutter
import UIKit
import flutter_background_service_ios


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    SwiftFlutterBackgroundServicePlugin.taskIdentifier = "dev.flutter.background.refresh"

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
