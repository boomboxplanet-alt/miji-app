# 秘跡 Miji - 地理位置社交應用

一個基於 Flutter 開發的創新地理位置社交應用，讓用戶能夠在特定位置發送和接收訊息。

## 🌟 特色功能

- **📍 地理位置訊息** - 基於位置的訊息發送和接收
- **🎯 智能範圍控制** - 可自定義的訊息傳播範圍
- **⏰ 自動銷毀** - 訊息在指定時間後自動消失
- **🤖 AI 助手** - 智能內容生成和優化
- **🎨 美觀界面** - 現代化的漸變設計風格
- **📱 跨平台支持** - 支持 iOS、Android 和 Web

## 🚀 技術架構

- **前端框架**: Flutter 3.24.0
- **狀態管理**: Provider
- **地圖服務**: Google Maps Flutter
- **本地存儲**: Hive
- **認證服務**: Firebase Auth
- **部署平台**: GitHub Pages

## 🛠️ 安裝和運行

### 環境要求
- Flutter SDK 3.24.0 或更高版本
- Dart SDK 3.0.0 或更高版本
- Android Studio / VS Code

### 安裝步驟
```bash
# 克隆項目
git clone https://github.com/boomboxplanet/miji-app.git

# 進入項目目錄
cd miji-app

# 安裝依賴
flutter pub get

# 運行應用
flutter run
```

### Web 部署
```bash
# 構建 Web 版本
flutter build web

# 部署到 GitHub Pages
# 推送代碼到 main 分支即可自動部署
```

## 📱 使用說明

1. **獲取位置** - 應用會請求位置權限來獲取您的當前位置
2. **發送訊息** - 在地圖上選擇位置，輸入內容並發送
3. **設定範圍** - 自定義訊息的傳播範圍和存活時間
4. **查看訊息** - 瀏覽地圖上其他用戶發送的訊息
5. **完成任務** - 通過完成任務獲得額外的權限獎勵

## 🔧 配置說明

### Google Maps API
在 `android/app/src/main/AndroidManifest.xml` 中添加您的 Google Maps API Key：
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### Firebase 配置
1. 在 Firebase Console 創建新項目
2. 下載 `google-services.json` 到 `android/app/`
3. 下載 `GoogleService-Info.plist` 到 `ios/Runner/`

## 📄 許可證

本項目採用 MIT 許可證 - 詳見 [LICENSE](LICENSE) 文件

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

## 📞 聯繫方式

- 項目地址: [GitHub](https://github.com/boomboxplanet/miji-app)
- 在線演示: [GitHub Pages](https://boomboxplanet.github.io/miji-app/)

---

**秘跡 Miji** - 讓每一次相遇都成為美好的回憶 ✨
