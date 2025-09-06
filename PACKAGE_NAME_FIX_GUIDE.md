# 🔧 包名修正指南

## 🚨 **問題描述**

Firebase 配置文件中的包名與 Android 項目實際包名不一致：

- **Firebase 配置**: `com.example.mijiApp`
- **Android 項目**: `com.example.miji_app`

這會導致 Firebase 無法正常工作。

## ✅ **解決方案 1: 更新 Firebase Console (推薦)**

### 1.1 前往 Firebase Console
1. 打開 [Firebase Console](https://console.firebase.google.com/)
2. 選擇項目 "Miji" (miji-61985)
3. 點擊左側選單的 "Project settings" (⚙️ 圖標)

### 1.2 更新 Android 應用程式
1. 在 "Your apps" 區塊找到 Android 應用程式
2. 點擊 "Edit" (鉛筆圖標)
3. 將 "Android package name" 從 `com.example.mijiApp` 改為 `com.example.miji_app`
4. 點擊 "Save"

### 1.3 重新下載配置
1. 點擊 "Download google-services.json"
2. 用新文件替換 `android/app/google-services.json`

## 🔧 **解決方案 2: 更新 Android 項目**

### 2.1 更新 build.gradle.kts
```kotlin
android {
    namespace = "com.example.mijiApp"
    // ...
    defaultConfig {
        applicationId = "com.example.mijiApp"
        // ...
    }
}
```

### 2.2 更新 AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.mijiApp">
```

### 2.3 更新包名結構
需要重命名 `android/app/src/main/kotlin/com/example/miji_app/` 目錄為 `mijiApp`

## 🎯 **推薦選擇**

**選擇解決方案 1**，因為：
- `com.example.miji_app` 更符合 Android 命名規範
- 不需要修改現有代碼結構
- 更安全，不會影響其他配置

## 🚨 **注意事項**

- 修改包名後需要重新測試應用程式
- 如果已經發布到 Google Play，包名不能更改
- 確保所有配置文件都使用相同的包名

---

**建議**: 先嘗試解決方案 1，如果無法修改 Firebase Console，再考慮解決方案 2。
