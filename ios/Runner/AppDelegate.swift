// import UIKit
// import Flutter
// import flutter_downloader
//
// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GeneratedPluginRegistrant.register(with: self)
//     FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }
//
// private func registerPlugins(registry: FlutterPluginRegistry) {
//     if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//     }
// }


import UIKit
import Flutter
import FirebaseCore
import GoogleSignIn
import flutter_downloader

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Handle Google Sign-In
    GIDSignIn.sharedInstance.restorePreviousSignIn()

    // Flutter Downloader setup
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}
