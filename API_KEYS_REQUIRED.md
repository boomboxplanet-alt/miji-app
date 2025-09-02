# 🔑 API 金鑰配置指南

## 📋 概述
本文檔詳細說明秘跡 Miji 應用需要哪些 API 金鑰才能實現真實上線功能。

## 🚀 必需的 API 金鑰

### 1. **Google Maps API 金鑰** ⭐⭐⭐⭐⭐
**用途**: 地圖顯示、地理位置服務、路線規劃
**獲取方式**: [Google Cloud Console](https://console.cloud.google.com/)

#### 配置步驟:
1. 訪問 [Google Cloud Console](https://console.cloud.google.com/)
2. 創建新項目或選擇現有項目
3. 啟用以下 API:
   - Maps SDK for Android
   - Maps SDK for iOS  
   - Maps JavaScript API
   - Geocoding API
   - Places API
4. 創建憑證 → API 金鑰
5. 設置 API 金鑰限制（建議限制為您的應用包名）

#### 配置位置:
```xml
<!-- Android: android/app/src/main/AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

```swift
// iOS: ios/Runner/AppDelegate.swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

```html
<!-- Web: web/index.html -->
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_GOOGLE_MAPS_API_KEY"></script>
```

### 2. **Firebase 配置** ⭐⭐⭐⭐⭐
**用途**: 用戶認證、實時數據庫、雲端存儲、推送通知
**獲取方式**: [Firebase Console](https://console.firebase.google.com/)

#### 配置步驟:
1. 訪問 [Firebase Console](https://console.firebase.google.com/)
2. 創建新項目
3. 添加應用:
   - Android 應用 (包名: com.example.miji_app)
   - iOS 應用 (Bundle ID: com.example.mijiApp)
   - Web 應用
4. 下載配置文件:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
   - Web 配置代碼 → `web/index.html`

#### 啟用的服務:
- Authentication (Google Sign-In)
- Cloud Firestore
- Cloud Storage
- Cloud Functions (可選)
- Cloud Messaging (推送通知)

### 3. **Google Sign-In Client ID** ⭐⭐⭐⭐
**用途**: Google 登入功能
**獲取方式**: Firebase Console → Authentication → Sign-in method → Google

#### 配置位置:
```html
<!-- web/index.html -->
<meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
```

## 🔧 可選的 API 金鑰

### 4. **Google Translate API 金鑰** ⭐⭐⭐
**用途**: 多語言翻譯服務
**獲取方式**: [Google Cloud Console](https://console.cloud.google.com/)

#### 配置步驟:
1. 在 Google Cloud Console 中啟用 Cloud Translation API
2. 創建 API 金鑰
3. 配置到 `lib/services/translation_service.dart`

```dart
// lib/services/translation_service.dart
static const String apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
```

### 5. **OpenAI API 金鑰** ⭐⭐
**用途**: AI 內容生成、智能回覆
**獲取方式**: [OpenAI Platform](https://platform.openai.com/)

#### 配置步驟:
1. 註冊 OpenAI 帳戶
2. 獲取 API 金鑰
3. 配置到 AI 服務中

## 💰 預估成本

### Google Maps API
- **免費額度**: 每月 $200 免費額度
- **地圖加載**: $5/1000 次
- **地理位置**: $5/1000 次
- **路線規劃**: $5/1000 次

### Firebase
- **免費額度**: 相當慷慨
- **認證**: 免費
- **數據庫**: 1GB 存儲 + 50,000 讀取/日免費
- **存儲**: 5GB 免費

### Google Translate API
- **免費額度**: 每月 500,000 字符免費
- **超出**: $20/100萬字符

## 🚨 安全注意事項

1. **不要將 API 金鑰提交到 Git**
   - 使用環境變量
   - 添加到 `.gitignore`
   - 使用 CI/CD 密鑰管理

2. **設置 API 金鑰限制**
   - 限制為您的應用包名
   - 設置 IP 地址限制
   - 啟用 API 金鑰輪換

3. **監控使用量**
   - 設置預算警報
   - 監控 API 調用次數
   - 定期檢查安全日誌

## 📱 平台特定配置

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>此應用需要訪問您的位置來顯示附近的訊息</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>此應用需要訪問您的位置來顯示附近的訊息</string>
```

### Web
```html
<!-- web/index.html -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="theme-color" content="#6366F1">
```

## 🔄 部署檢查清單

- [ ] Google Maps API 金鑰已配置
- [ ] Firebase 配置文件已下載並放置
- [ ] Google Sign-In Client ID 已配置
- [ ] API 金鑰限制已設置
- [ ] 環境變量已配置（如需要）
- [ ] 安全規則已設置
- [ ] 預算警報已啟用

## 📞 技術支持

如果在配置過程中遇到問題，請參考:
- [Google Cloud 文檔](https://cloud.google.com/docs)
- [Firebase 文檔](https://firebase.google.com/docs)
- [Flutter 文檔](https://flutter.dev/docs)

## 💡 建議

1. **先使用免費額度測試** - 確保功能正常後再考慮付費計劃
2. **設置預算警報** - 避免意外費用
3. **使用環境變量** - 區分開發和生產環境
4. **定期檢查使用量** - 優化 API 調用
5. **備份配置** - 保存所有配置文件
