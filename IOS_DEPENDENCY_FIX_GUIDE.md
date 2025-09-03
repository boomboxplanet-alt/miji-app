# 🔧 iOS 依賴問題解決指南

## 🚨 **問題描述**
iOS 構建時出現依賴版本衝突：
- AppAuth 版本不兼容
- GoogleUtilities 版本衝突
- google_sign_in_ios 插件版本過舊

## ✅ **解決方案**

### 1. 更新 Flutter 依賴版本
已更新 `pubspec.yaml`：
```yaml
firebase_core: ^3.0.0
firebase_auth: ^5.0.0
google_sign_in: ^7.0.0
cloud_firestore: ^5.0.0
```

### 2. 清理並重新安裝
```bash
flutter clean
flutter pub get
```

### 3. 清理 iOS 依賴
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
```

### 4. 測試構建
```bash
flutter build ios --no-codesign
```

## 🎯 **預期結果**
- 依賴版本衝突解決
- iOS 構建成功
- 沒有 CocoaPods 錯誤

## 🚨 **如果仍有問題**
可能需要手動指定 Pod 版本或使用 Podfile 覆蓋。
