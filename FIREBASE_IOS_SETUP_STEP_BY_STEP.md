# 🍎 iOS Firebase 設置步驟指南

## 🎯 **目標**
在 Firebase Console 中添加 iOS 應用程式並下載真實配置文件。

## 📋 **步驟 1: 前往 Firebase Console**

1. 打開瀏覽器，前往 [Firebase Console](https://console.firebase.google.com/)
2. 使用您的 Google 帳戶登入
3. 選擇項目 **"Miji"** (項目 ID: miji-61985)

## 📱 **步驟 2: 添加 iOS 應用程式**

### 2.1 點擊 "添加應用程式"
- 在項目概覽頁面，點擊 **"添加應用程式"** 按鈕
- 選擇 **iOS** 圖標

### 2.2 輸入應用程式信息
- **iOS 套件 ID**: `com.example.miji_app`
- **應用程式暱稱** (可選): `Miji App`
- **App Store ID** (可選，暫時跳過)

### 2.3 點擊 "註冊應用程式"

## 📥 **步驟 3: 下載配置文件**

### 3.1 下載 GoogleService-Info.plist
- 點擊 **"下載 GoogleService-Info.plist"** 按鈕
- 將文件保存到您的電腦

### 3.2 放置配置文件
- 將下載的 `GoogleService-Info.plist` 文件
- 複製到項目目錄: `ios/Runner/GoogleService-Info.plist`
- **重要**: 替換現有的模板文件

## ✅ **步驟 4: 驗證配置**

### 4.1 檢查文件位置
```
ios/
└── Runner/
    └── GoogleService-Info.plist  ← 新下載的真實文件
```

### 4.2 檢查文件內容
打開 `GoogleService-Info.plist`，確認包含：
- `PROJECT_ID`: "miji-61985"
- `BUNDLE_ID`: "com.example.miji_app"
- `CLIENT_ID`: 真實的 Client ID
- `REVERSED_CLIENT_ID`: 用於 URL Schemes

## 🔧 **步驟 5: 解決依賴問題**

### 5.1 更新 Flutter 插件版本
編輯 `pubspec.yaml`，更新版本：
```yaml
dependencies:
  google_sign_in: ^7.0.0  # 更新到最新版本
  firebase_auth: ^5.0.0   # 更新到最新版本
  firebase_core: ^3.0.0   # 更新到最新版本
```

### 5.2 清理並重新安裝依賴
```bash
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install
cd ..
```

### 5.3 測試 iOS 構建
```bash
flutter build ios --no-codesign
```

## 🎉 **完成檢查清單**

- [ ] 在 Firebase Console 添加了 iOS 應用程式
- [ ] 下載了 `GoogleService-Info.plist` 文件
- [ ] 將文件放置到 `ios/Runner/` 目錄
- [ ] 替換了模板配置文件
- [ ] 更新了 Flutter 插件版本
- [ ] 解決了依賴衝突
- [ ] 測試構建成功

## 🚨 **常見問題**

### Q: 找不到 "添加應用程式" 按鈕？
A: 確保您在項目概覽頁面，不是設置頁面。

### Q: Bundle ID 錯誤？
A: 確保輸入的是 `com.example.miji_app`，不是 `com.example.mijiApp`

### Q: 依賴版本衝突？
A: 更新 Flutter 插件到最新版本，並運行 `pod deintegrate`

### Q: 構建失敗？
A: 檢查 `GoogleService-Info.plist` 是否正確放置，並運行 `flutter clean`

---

**下一步**: 完成 iOS 配置後，我們將設置 Web 應用程式。
