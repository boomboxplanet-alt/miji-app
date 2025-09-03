# 🔥 Firebase 依賴包安裝指南

## 📦 需要安裝的依賴包

### 1. **更新 pubspec.yaml**

在您的 `pubspec.yaml` 文件中添加以下依賴：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase 核心功能
  firebase_core: ^2.24.2
  
  # Firebase 認證
  firebase_auth: ^4.15.3
  
  # Google 登入
  google_sign_in: ^6.1.6
  
  # Cloud Firestore 數據庫
  cloud_firestore: ^4.13.6
  
  # Firebase 存儲 (可選)
  firebase_storage: ^11.5.6
  
  # Firebase 分析 (可選)
  firebase_analytics: ^10.7.4
  
  # 其他現有依賴...
  provider: ^6.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  google_maps_flutter: ^2.5.3
  geolocator: ^10.1.0
```

### 2. **安裝依賴**

```bash
# 清理舊的依賴
flutter clean

# 獲取新的依賴
flutter pub get

# 檢查依賴狀態
flutter pub deps
```

### 3. **平台特定配置**

#### Android
確保 `android/app/build.gradle.kts` 包含：

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // 如果需要 Google Services 插件，取消註釋下面這行
    // id("com.google.gms.google-services")
}
```

#### iOS
確保 `ios/Podfile` 包含：

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

### 4. **依賴包說明**

| 依賴包 | 版本 | 用途 |
|--------|------|------|
| `firebase_core` | ^2.24.2 | Firebase 核心功能，必須首先安裝 |
| `firebase_auth` | ^4.15.3 | 用戶認證、登入登出 |
| `google_sign_in` | ^6.1.6 | Google 帳號登入 |
| `cloud_firestore` | ^4.13.6 | 雲端數據庫 |
| `firebase_storage` | ^11.5.6 | 文件存儲 (可選) |
| `firebase_analytics` | ^10.7.4 | 用戶行為分析 (可選) |

### 5. **版本兼容性**

- **Flutter**: 3.16.0 或更高
- **Dart**: 3.2.0 或更高
- **iOS**: 12.0 或更高
- **Android**: API 21 (Android 5.0) 或更高

### 6. **安裝後檢查**

```bash
# 檢查依賴是否正確安裝
flutter doctor

# 嘗試構建項目
flutter build apk --debug
flutter build ios --no-codesign
flutter build web
```

### 7. **常見問題**

#### 依賴衝突
```bash
# 清理並重新安裝
flutter clean
flutter pub cache repair
flutter pub get
```

#### 版本不兼容
- 檢查 Flutter 版本: `flutter --version`
- 檢查 Dart 版本: `dart --version`
- 參考 [Firebase Flutter 兼容性表](https://firebase.flutter.dev/docs/overview/#supported-platforms)

#### 平台特定錯誤
- **Android**: 檢查 Gradle 版本和插件配置
- **iOS**: 檢查 Pod 版本和 Xcode 配置
- **Web**: 檢查 Firebase SDK 版本

## 🚀 下一步

安裝依賴後，您需要：

1. **配置 Firebase 項目**
2. **下載配置文件**
3. **測試 Firebase 連接**
4. **實現具體功能**

參考 `FIREBASE_SETUP_GUIDE.md` 完成完整配置！
