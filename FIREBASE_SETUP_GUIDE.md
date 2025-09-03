# 🔥 Firebase 完整配置指南

## 📋 配置清單

### ✅ 已完成
- [x] Google Maps API 金鑰配置 (所有平台)
- [x] Firebase 服務類創建
- [x] 配置文件模板創建
- [x] 主程序 Firebase 初始化

### ❌ 需要完成
- [ ] Firebase Console 項目創建
- [ ] 真實配置文件下載和放置
- [ ] 依賴包安裝
- [ ] 測試驗證

## 🚀 快速配置步驟

### 1. **Firebase Console 設置**

#### 步驟 1: 創建項目
1. 訪問 [Firebase Console](https://console.firebase.google.com/)
2. 點擊 **"創建項目"**
3. 項目名稱: `miji-app`
4. 啟用 Google Analytics (可選)
5. 點擊 **"創建項目"**

#### 步驟 2: 添加 Android 應用
1. 點擊 **"添加應用程式"** → **Android**
2. Android 套件名稱: `com.example.mijiApp`
3. 應用程式暱稱: `秘跡 Miji`
4. 點擊 **"註冊應用程式"**
5. 下載 `google-services.json`

#### 步驟 3: 添加 iOS 應用
1. 點擊 **"添加應用程式"** → **iOS**
2. iOS Bundle ID: `com.example.mijiApp`
3. 應用程式暱稱: `秘跡 Miji`
4. 點擊 **"註冊應用程式"**
5. 下載 `GoogleService-Info.plist`

#### 步驟 4: 添加 Web 應用
1. 點擊 **"添加應用程式"** → **Web**
2. 應用程式暱稱: `秘跡 Miji Web`
3. 點擊 **"註冊應用程式"**
4. 複製配置代碼

### 2. **文件放置**

#### Android
```bash
# 將 google-services.json 放到以下位置
cp google-services.json android/app/
```

#### iOS
```bash
# 將 GoogleService-Info.plist 放到以下位置
cp GoogleService-Info.plist ios/Runner/
```

#### Web
```bash
# 將 firebase-config.js.example 重命名並更新配置
cp web/firebase-config.js.example web/firebase-config.js
# 編輯 web/firebase-config.js，填入真實配置
```

### 3. **依賴包安裝**

#### 更新 pubspec.yaml
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
  cloud_firestore: ^4.13.6
```

#### 安裝依賴
```bash
flutter pub get
```

### 4. **平台特定配置**

#### Android
- 確保 `android/app/build.gradle` 包含 Google Services 插件
- 確保 `android/build.gradle` 包含 Google Services 類路徑

#### iOS
- 在 Xcode 中添加 `GoogleService-Info.plist`
- 配置 URL Schemes (使用 REVERSED_CLIENT_ID)

#### Web
- 在 `web/index.html` 中添加 Firebase SDK
- 初始化 Firebase 配置

## 🔧 配置文件模板

### Android: google-services.json
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_STORAGE_BUCKET"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_MOBILE_SDK_APP_ID",
        "android_client_info": {
          "package_name": "com.example.mijiApp"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_OAUTH_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58"
        }
      ]
    }
  ]
}
```

### iOS: GoogleService-Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CLIENT_ID</key>
    <string>YOUR_CLIENT_ID</string>
    <key>REVERSED_CLIENT_ID</key>
    <string>YOUR_REVERSED_CLIENT_ID</string>
    <key>API_KEY</key>
    <string>AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58</string>
    <key>PROJECT_ID</key>
    <string>YOUR_PROJECT_ID</string>
</dict>
</plist>
```

### Web: firebase-config.js
```javascript
const firebaseConfig = {
  apiKey: "AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};
```

## 🧪 測試驗證

### 1. **構建測試**
```bash
# Android
flutter build apk --debug

# iOS
flutter build ios --no-codesign

# Web
flutter build web
```

### 2. **運行測試**
```bash
# 檢查 Firebase 連接
flutter run --debug

# 查看控制台輸出
# 應該看到: "Firebase 初始化成功"
```

### 3. **功能測試**
- [ ] Google 登入
- [ ] 用戶認證狀態
- [ ] 地圖顯示
- [ ] 數據存儲

## 🚨 常見問題

### 1. **配置文件找不到**
- 確保文件在正確位置
- 檢查文件名拼寫
- 重新運行 `flutter clean && flutter pub get`

### 2. **依賴包衝突**
- 檢查 Flutter 和 Firebase 版本兼容性
- 更新到最新穩定版本
- 清理並重新安裝依賴

### 3. **平台特定錯誤**
- Android: 檢查 Google Services 插件
- iOS: 檢查 Bundle ID 和配置文件
- Web: 檢查 Firebase SDK 加載

## 📞 需要幫助？

如果遇到問題，請：
1. 檢查錯誤日誌
2. 確認配置文件正確
3. 驗證依賴包版本
4. 參考 [Firebase 官方文檔](https://firebase.google.com/docs)

---

**注意**: 請將示例配置文件中的 `YOUR_*` 替換為真實的 Firebase 配置值！
