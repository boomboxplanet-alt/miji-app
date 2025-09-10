# 秘跡 Miji - 部署指南

## 🚀 GitHub Pages 部署

### 方法1：自動部署（推薦）

1. **啟用 GitHub Pages**
   - 前往 GitHub 倉庫：https://github.com/boomboxplanet-alt/miji-app
   - 點擊 Settings > Pages
   - Source 選擇 "GitHub Actions"

2. **推送代碼觸發部署**
   ```bash
   git push origin main
   # 或
   git push origin miji_v1.1
   ```

3. **訪問應用**
   - 部署完成後，應用將在以下網址可用：
   - https://boomboxplanet-alt.github.io/miji-app/

### 方法2：手動部署

1. **運行部署腳本**
   ```bash
   ./deploy_to_github_pages.sh
   ```

2. **手動步驟**
   ```bash
   # 構建應用
   flutter build web --release
   
   # 切換到 gh-pages 分支
   git checkout gh-pages
   
   # 複製構建文件
   cp -r build/web/* .
   
   # 提交並推送
   git add .
   git commit -m "Deploy: 更新應用"
   git push origin gh-pages
   ```

## 🔧 Google OAuth 配置

### 在 Google Cloud Console 中配置

1. **前往 Google Cloud Console**
   - https://console.cloud.google.com/
   - 選擇項目：`miji-61985`

2. **配置 OAuth 客戶端**
   - APIs & Services > Credentials
   - 編輯 Web 客戶端：`508695711441-r97p5ql81s4u77sirfc04dni20hu53u0.apps.googleusercontent.com`

3. **添加授權的 JavaScript 來源**
   ```
   https://boomboxplanet-alt.github.io
   http://localhost:8080
   http://localhost:3000
   ```

4. **添加授權的重定向 URI**
   ```
   https://boomboxplanet-alt.github.io/miji-app/
   http://localhost:8080
   ```

## 📱 功能特色

- ✅ Google 登入整合
- ✅ 澳門地圖導航
- ✅ AI 聊天機器人
- ✅ 訊息系統
- ✅ 用戶資料管理
- ✅ 響應式設計

## 🛠️ 開發環境

### 本地開發

```bash
# 安裝依賴
flutter pub get

# 運行開發服務器
flutter run -d web-server --web-port 8080
```

### 構建生產版本

```bash
# 清理並構建
flutter clean
flutter pub get
flutter build web --release
```

## 📝 更新日誌

### v1.1 - Google 登入整合
- 添加 Google Sign-In 功能
- 修復 Firebase 兼容性問題
- 創建簡化認證服務
- 更新 UI 和用戶體驗
- 準備 GitHub Pages 部署

## 🔗 相關連結

- **GitHub 倉庫**: https://github.com/boomboxplanet-alt/miji-app
- **GitHub Pages**: https://boomboxplanet-alt.github.io/miji-app/
- **Google Cloud Console**: https://console.cloud.google.com/