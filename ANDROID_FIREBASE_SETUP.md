# 🤖 Android Firebase 配置指南

## 📱 Android 平台 Firebase 配置

### ✅ **已完成的配置**

1. **Google Services 插件**
   - 在 `android/settings.gradle.kts` 中添加了插件聲明
   - 在 `android/app/build.gradle.kts` 中應用了插件

2. **Firebase 依賴**
   - 添加了 Firebase BoM (Bill of Materials)
   - 配置了 Firebase Analytics 依賴

### 🔧 **配置文件位置**

#### 1. **google-services.json**
- **位置**: `android/app/google-services.json`
- **來源**: Firebase Console → Android 應用 → 下載配置文件

#### 2. **build.gradle.kts 配置**
- **根級別**: `android/settings.gradle.kts`
- **應用級別**: `android/app/build.gradle.kts`

### 📋 **配置步驟**

#### 步驟 1: 下載配置文件
1. 在 Firebase Console 中
2. 選擇您的項目 "Miji"
3. 點擊 **"添加應用程式"** → **Android**
4. 填寫信息：
   - Android 套件名稱: `com.example.miji_app`
   - 應用程式暱稱: `秘跡 Miji`
5. 下載 `google-services.json`

#### 步驟 2: 放置配置文件
```bash
# 將下載的文件放到正確位置
cp ~/Downloads/google-services.json android/app/
```

#### 步驟 3: 驗證配置
```bash
# 清理並重新構建
flutter clean
flutter pub get
flutter build apk --debug
```

### 🚨 **重要注意事項**

#### 1. **包名必須匹配**
- Firebase Console 中的包名: `com.example.miji_app`
- `android/app/build.gradle.kts` 中的 `applicationId`: `com.example.miji_app`
- `google-services.json` 中的 `package_name`: `com.example.miji_app`

#### 2. **插件順序**
```kotlin
plugins {
    id("com.android.application")           // 1. Android 插件
    id("kotlin-android")                   // 2. Kotlin 插件
    id("dev.flutter.flutter-gradle-plugin") // 3. Flutter 插件
    id("com.google.gms.google-services")   // 4. Google Services 插件
}
```

#### 3. **依賴管理**
- 使用 Firebase BoM 管理版本
- 不要手動指定 Firebase 依賴版本
- 讓 BoM 自動處理版本兼容性

### 🧪 **測試配置**

#### 1. **構建測試**
```bash
# 檢查 Android 構建
flutter build apk --debug

# 檢查是否有錯誤
flutter doctor
```

#### 2. **運行測試**
```bash
# 在 Android 設備/模擬器上運行
flutter run

# 檢查 Firebase 初始化日誌
# 應該看到: "Firebase 初始化成功"
```

### 🔍 **故障排除**

#### 1. **插件找不到**
```bash
# 清理 Gradle 緩存
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 2. **配置文件錯誤**
- 檢查 `google-services.json` 是否在正確位置
- 驗證包名是否匹配
- 確認文件沒有損壞

#### 3. **依賴衝突**
```bash
# 檢查依賴樹
flutter pub deps

# 清理並重新安裝
flutter clean
flutter pub cache repair
flutter pub get
```

### 📚 **參考資源**

- [Firebase Android 設置指南](https://firebase.google.com/docs/android/setup)
- [Flutter Firebase 文檔](https://firebase.flutter.dev/docs/overview/)
- [Google Services 插件文檔](https://developers.google.com/android/guides/google-services-plugin)

---

**下一步**: 下載 `google-services.json` 並放置到 `android/app/` 目錄中！
