import UIKit
import Flutter
import GoogleMaps
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 配置 Firebase
    FirebaseApp.configure()
    
    // 配置 Google Maps
    GMSServices.provideAPIKey("AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58")
    
    // 註冊 Flutter 插件
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
