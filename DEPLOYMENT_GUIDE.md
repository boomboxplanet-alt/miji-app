# 🚀 秘跡miji 部署指南

## 📋 項目信息
- **項目名稱**: 秘跡miji
- **項目 ID**: viralnav-314c7
- **項目編號**: 613934957452
- **Google Maps API 金鑰**: AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58

## ✅ 當前狀態

### 已完成的配置：
- ✅ Google Maps API 金鑰已配置
- ✅ Firebase 項目已設置
- ✅ 資料庫結構已設計
- ✅ 應用程式 Provider 錯誤已修復
- ✅ 完整版本已成功啟動

### 運行中的服務：
- **完整版本**: http://localhost:8083 ✅
- **簡化版本**: http://localhost:8082 ✅

## 🔧 Firebase 配置步驟

### 1. Firebase Console 設置

1. **訪問 Firebase Console**
   - 前往 [Firebase Console](https://console.firebase.google.com/)
   - 選擇項目 "秘跡miji" (viralnav-314c7)

2. **啟用 Authentication**
   ```
   Authentication > Sign-in method > Google > 啟用
   ```

3. **啟用 Firestore Database**
   ```
   Firestore Database > 創建資料庫 > 測試模式
   ```

4. **設置安全規則**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

### 2. 獲取 Firebase 配置

1. **Web 應用配置**
   ```
   Project Settings > General > Your apps > Web app
   複製 firebaseConfig 對象
   ```

2. **更新 web/firebase-config.js**
   ```javascript
   const firebaseConfig = {
     apiKey: "AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58",
     authDomain: "viralnav-314c7.firebaseapp.com",
     projectId: "viralnav-314c7",
     storageBucket: "viralnav-314c7.appspot.com",
     messagingSenderId: "613934957452",
     appId: "your_actual_app_id_here"
   };
   ```

### 3. 初始化資料庫

1. **運行初始化腳本**
   ```bash
   # 安裝 Firebase Admin SDK
   npm install firebase-admin
   
   # 運行初始化腳本
   node firebase_init.js
   ```

2. **手動創建系統設定**
   ```javascript
   // 在 Firebase Console > Firestore 中創建
   systemSettings/app_version: {
     key: "app_version",
     value: "1.0.0",
     type: "string",
     description: "應用程式版本",
     isPublic: true
   }
   ```

## 🌐 Web 部署

### 1. 構建生產版本
```bash
flutter build web --release
```

### 2. 部署到 Firebase Hosting
```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 登入 Firebase
firebase login

# 初始化 Firebase Hosting
firebase init hosting

# 部署
firebase deploy
```

### 3. 部署到其他平台

#### Vercel
```bash
# 安裝 Vercel CLI
npm install -g vercel

# 部署
vercel --prod
```

#### Netlify
```bash
# 構建
flutter build web --release

# 上傳 build/web 目錄到 Netlify
```

## 📱 移動端部署

### Android
```bash
# 構建 APK
flutter build apk --release

# 構建 App Bundle
flutter build appbundle --release
```

### iOS
```bash
# 構建 iOS
flutter build ios --release
```

## 🔐 安全配置

### 1. API 金鑰限制
- 在 Google Cloud Console 中設置 API 金鑰限制
- 限制為您的域名和應用包名

### 2. Firebase 安全規則
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /messages/{messageId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.authorId;
    }
  }
}
```

### 3. 環境變量
```bash
# 創建 .env 文件
GOOGLE_MAPS_API_KEY=AIzaSyB5EIX3h6jLAF7C_5_fsE_lOQUjTMr7J58
FIREBASE_PROJECT_ID=viralnav-314c7
FIREBASE_MESSAGING_SENDER_ID=613934957452
```

## 📊 監控和維護

### 1. Firebase 監控
- 設置預算警報
- 監控 API 使用量
- 檢查錯誤日誌

### 2. 性能優化
- 啟用 Firestore 索引
- 優化查詢性能
- 監控應用性能

### 3. 備份策略
- 定期備份 Firestore 資料
- 版本控制代碼
- 配置文件備份

## 🚨 故障排除

### 常見問題

1. **白屏問題**
   - 檢查 Firebase 配置
   - 確認 API 金鑰有效
   - 檢查瀏覽器控制台錯誤

2. **Provider 錯誤**
   - 確認所有 Provider 已註冊
   - 檢查 import 語句
   - 驗證依賴項

3. **Firebase 連接問題**
   - 檢查網路連接
   - 確認 Firebase 項目設置
   - 驗證安全規則

### 調試命令
```bash
# 檢查 Flutter 環境
flutter doctor -v

# 分析代碼
flutter analyze

# 清理構建
flutter clean
flutter pub get

# 檢查依賴
flutter pub deps
```

## 📞 技術支持

### 文檔資源
- [Flutter 文檔](https://flutter.dev/docs)
- [Firebase 文檔](https://firebase.google.com/docs)
- [Google Maps API 文檔](https://developers.google.com/maps/documentation)

### 社區支持
- [Flutter 社區](https://flutter.dev/community)
- [Firebase 社區](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

## 🎯 下一步計劃

1. **功能完善**
   - 實現完整的訊息系統
   - 添加地圖互動功能
   - 完善用戶認證流程

2. **性能優化**
   - 優化地圖加載速度
   - 實現離線功能
   - 添加緩存機制

3. **用戶體驗**
   - 添加動畫效果
   - 優化響應式設計
   - 實現深色模式

4. **擴展功能**
   - 添加推送通知
   - 實現社交功能
   - 集成 AI 功能

---

## 🎉 恭喜！

您的 秘跡miji 應用程式已經成功配置並運行！

- **完整版本**: http://localhost:8083
- **簡化版本**: http://localhost:8082
- **資料庫結構**: 已設計完成
- **Firebase 配置**: 已準備就緒

現在您可以開始開發和測試應用程式的各種功能了！
