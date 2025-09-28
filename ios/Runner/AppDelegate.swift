import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Firebase 已移除，使用 Supabase 替代
    
    // 配置 Google Maps
    GMSServices.provideAPIKey("AIzaSyAx0HpzU9SSQHKba8wsl-i_z-Gid5Sa9kQ")
    
    // 註冊 Flutter 插件
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
