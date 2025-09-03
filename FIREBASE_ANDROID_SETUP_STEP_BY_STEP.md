# 📱 Android Firebase 設置步驟指南

## 🎯 **目標**
在 Firebase Console 中添加 Android 應用程式並下載真實配置文件。

## 📋 **步驟 1: 前往 Firebase Console**

1. 打開瀏覽器，前往 [Firebase Console](https://console.firebase.google.com/)
2. 使用您的 Google 帳戶登入
3. 選擇項目 **"Miji"** (項目 ID: miji-61985)

## 📱 **步驟 2: 添加 Android 應用程式**

### 2.1 點擊 "添加應用程式"
- 在項目概覽頁面，點擊 **"添加應用程式"** 按鈕
- 選擇 **Android** 圖標

### 2.2 輸入應用程式信息
- **Android 套件名稱**: `com.example.miji_app`
- **應用程式暱稱** (可選): `Miji App`
- **SHA-1 憑證指紋** (可選，暫時跳過)

### 2.3 點擊 "註冊應用程式"

## 📥 **步驟 3: 下載配置文件**

### 3.1 下載 google-services.json
- 點擊 **"下載 google-services.json"** 按鈕
- 將文件保存到您的電腦

### 3.2 放置配置文件
- 將下載的 `google-services.json` 文件
- 複製到項目目錄: `android/app/google-services.json`
- **重要**: 替換現有的模板文件

## ✅ **步驟 4: 驗證配置**

### 4.1 檢查文件位置
```
android/
└── app/
    └── google-services.json  ← 新下載的真實文件
```

### 4.2 檢查文件內容
打開 `google-services.json`，確認包含：
- `project_id`: "miji-61985"
- `package_name`: "com.example.miji_app"
- `client_id`: 真實的 Client ID

## 🔧 **步驟 5: 測試構建**

### 5.1 清理並重新構建
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 5.2 檢查構建日誌
- 確認沒有 Firebase 相關錯誤
- 確認 Google Services 插件正常工作

## 🎉 **完成檢查清單**

- [ ] 在 Firebase Console 添加了 Android 應用程式
- [ ] 下載了 `google-services.json` 文件
- [ ] 將文件放置到 `android/app/` 目錄
- [ ] 替換了模板配置文件
- [ ] 測試構建成功
- [ ] 沒有 Firebase 相關錯誤

## 🚨 **常見問題**

### Q: 找不到 "添加應用程式" 按鈕？
A: 確保您在項目概覽頁面，不是設置頁面。

### Q: 包名錯誤？
A: 確保輸入的是 `com.example.miji_app`，不是 `com.example.mijiApp`

### Q: 構建失敗？
A: 檢查 `google-services.json` 是否正確放置，並運行 `flutter clean`

---

**下一步**: 完成 Android 配置後，我們將設置 iOS 應用程式。
