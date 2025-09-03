# 🔧 iOS 依賴問題終極解決方案

## 🚨 **問題分析**
iOS 構建失敗的根本原因：
1. **AppAuth 版本衝突**: GoogleSignIn 8.0 需要 AppAuth >= 1.7.3 且 < 2.0
2. **GoogleUtilities 版本衝突**: Firebase 需要 ~> 7.x，GoogleSignIn 需要 ~> 8.x
3. **Flutter 插件版本不匹配**: 當前版本與 iOS 原生依賴不兼容

## ✅ **解決方案 1: 降級 Google Sign-In (推薦)**

### 1.1 更新 pubspec.yaml
```yaml
dependencies:
  google_sign_in: ^6.1.6  # 降級到兼容版本
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
```

### 1.2 執行更新
```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### 1.3 測試構建
```bash
flutter build ios --no-codesign
```

## 🔧 **解決方案 2: 手動指定 Pod 版本**

### 2.1 編輯 ios/Podfile
在 `post_install` 區塊添加：
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # 設置最低部署目標版本
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
    
    # 手動指定版本
    if target.name == 'GoogleSignIn'
      target.build_configurations.each do |config|
        config.build_settings['PODS_VERSION'] = '7.0.0'
      end
    end
  end
end
```

### 2.2 清理並重新安裝
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

## 🚀 **解決方案 3: 使用 Flutter 3.16+ (長期解決)**

### 3.1 升級 Flutter
```bash
flutter upgrade
flutter --version  # 確認版本 >= 3.16.0
```

### 3.2 更新依賴到最新版本
```yaml
dependencies:
  google_sign_in: ^7.0.0
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
```

### 3.3 清理並重新安裝
```bash
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

## 🎯 **推薦執行順序**

1. **先嘗試解決方案 1** (降級 Google Sign-In)
2. **如果失敗，嘗試解決方案 2** (手動指定版本)
3. **最後考慮解決方案 3** (升級 Flutter)

## 🚨 **注意事項**

- 降級 Google Sign-In 可能會影響某些新功能
- 手動指定版本可能導致其他兼容性問題
- 升級 Flutter 需要測試整個應用程式

## 📱 **預期結果**

成功後應該看到：
- iOS 構建成功
- 沒有 CocoaPods 依賴衝突
- 所有 Firebase 功能正常工作

---

**建議**: 從解決方案 1 開始，這是最安全的方法。
