# 🌐 Web Firebase 設置步驟指南

## 🎯 **目標**
在 Firebase Console 中添加 Web 應用程式並配置真實的 Firebase 設置。

## 📋 **步驟 1: 前往 Firebase Console**

1. 打開瀏覽器，前往 [Firebase Console](https://console.firebase.google.com/)
2. 使用您的 Google 帳戶登入
3. 選擇項目 **"Miji"** (項目 ID: miji-61985)

## 🌐 **步驟 2: 添加 Web 應用程式**

### 2.1 點擊 "添加應用程式"
- 在項目概覽頁面，點擊 **"添加應用程式"** 按鈕
- 選擇 **Web** 圖標 (</>)

### 2.2 輸入應用程式信息
- **應用程式暱稱**: `Miji Web App`
- **Firebase Hosting** (可選): 暫時不啟用

### 2.3 點擊 "註冊應用程式"

## 📥 **步驟 3: 獲取配置代碼**

### 3.1 複製配置代碼
Firebase 會顯示類似這樣的配置代碼：
```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "miji-61985.firebaseapp.com",
  projectId: "miji-61985",
  storageBucket: "miji-61985.appspot.com",
  messagingSenderId: "508695711441",
  appId: "1:508695711441:web:..."
};
```

### 3.2 更新 web/firebase-config.js
將真實的配置代碼複製到 `web/firebase-config.js` 文件中。

## ✅ **步驟 4: 驗證配置**

### 4.1 檢查文件內容
打開 `web/firebase-config.js`，確認包含：
- `apiKey`: 真實的 API 金鑰
- `authDomain`: "miji-61985.firebaseapp.com"
- `projectId`: "miji-61985"
- `appId`: 真實的應用程式 ID

### 4.2 檢查 web/index.html
確認 `web/index.html` 中引用了正確的文件：
```html
<script src="firebase-config.js"></script>
```

## 🔧 **步驟 5: 測試 Web 構建**

### 5.1 清理並重新構建
```bash
flutter clean
flutter pub get
flutter build web
```

### 5.2 檢查構建日誌
- 確認沒有 Firebase 相關錯誤
- 確認 Web 構建成功

## 🎉 **完成檢查清單**

- [ ] 在 Firebase Console 添加了 Web 應用程式
- [ ] 獲取了真實的 Firebase 配置代碼
- [ ] 更新了 `web/firebase-config.js` 文件
- [ ] 確認了 `web/index.html` 引用正確
- [ ] 測試 Web 構建成功
- [ ] 沒有 Firebase 相關錯誤

## 🚨 **常見問題**

### Q: 找不到 "添加應用程式" 按鈕？
A: 確保您在項目概覽頁面，不是設置頁面。

### Q: 配置代碼不顯示？
A: 點擊 "註冊應用程式" 後，配置代碼會自動顯示。

### Q: Web 構建失敗？
A: 檢查 `firebase-config.js` 語法是否正確，並運行 `flutter clean`

### Q: Firebase 服務不工作？
A: 確認已啟用 Authentication 和 Firestore 服務

---

**下一步**: 完成所有平台配置後，我們將啟用 Firebase 服務。
