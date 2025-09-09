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
        GMSServices.provideAPIKey("AIzaSyAx0HpzU9SSQHKba8wsl-i_z-Gid5Sa9kQ")
    
    // 註冊 Flutter 插件
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
