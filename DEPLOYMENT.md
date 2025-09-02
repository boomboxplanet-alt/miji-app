# 🚀 秘跡 Miji 部署指南

本指南將幫助你將 秘跡 Miji 應用程序部署到 GitHub Pages，實現線上測試。

## 📋 前置要求

- ✅ Flutter SDK 3.24.0 或更高版本
- ✅ Git 已安裝並配置
- ✅ GitHub 帳戶
- ✅ 基本的命令行操作知識

## 🌟 部署步驟

### 步驟 1: 創建 GitHub 倉庫

1. 訪問 [GitHub](https://github.com) 並登錄你的帳戶
2. 點擊右上角的 "+" 號，選擇 "New repository"
3. 填寫倉庫信息：
   - **Repository name**: `miji-app`
   - **Description**: `秘跡 Miji - 地理位置社交應用`
   - **Visibility**: Public
   - **不要**勾選任何初始化選項
4. 點擊 "Create repository"

### 步驟 2: 推送代碼到 GitHub

```bash
# 推送代碼到 GitHub
git push -u origin main
```

### 步驟 3: 啟用 GitHub Pages

1. 在 GitHub 倉庫頁面，點擊 "Settings" 標籤
2. 在左側菜單中找到 "Pages"
3. 在 "Source" 部分，選擇 "Deploy from a branch"
4. 選擇 "main" 分支
5. 點擊 "Save"

### 步驟 4: 配置 GitHub Actions 自動部署

GitHub Actions 工作流已經配置好，會自動部署到 GitHub Pages。

## 🔧 本地測試

在部署之前，你可以在本地測試 Web 版本：

```bash
# 運行部署腳本
./deploy.sh

# 或者手動執行
flutter clean
flutter pub get
flutter build web --base-href "/miji-app/"
flutter run -d chrome
```

## 🌐 訪問應用

部署完成後，你的應用將在以下地址可用：
**https://boomboxplanet.github.io/miji-app/**

## 📱 功能測試清單

部署完成後，請測試以下功能：

### ✅ 基本功能
- [ ] 應用程序正常加載
- [ ] 地圖界面顯示正常
- [ ] 位置權限請求正常
- [ ] 用戶界面響應正常

### ✅ 核心功能
- [ ] 地圖縮放和拖拽
- [ ] 位置獲取
- [ ] 訊息發送（如果配置了後端）
- [ ] 設置頁面

### ✅ 響應式設計
- [ ] 桌面瀏覽器顯示正常
- [ ] 移動設備適配
- [ ] 不同屏幕尺寸適配

## 🐛 常見問題

### Q: 應用程序無法加載
**A**: 檢查以下幾點：
- GitHub Pages 是否已啟用
- 分支是否正確設置為 main
- 構建是否成功

### Q: 地圖無法顯示
**A**: 檢查 Google Maps API 配置：
- 確保 API Key 已配置
- 檢查 API 限制和配額

### Q: 樣式顯示異常
**A**: 檢查以下幾點：
- 構建是否成功
- 靜態資源路徑是否正確
- 瀏覽器緩存是否已清理

## 🔄 更新部署

當你修改代碼後，只需要推送新的提交：

```bash
git add .
git commit -m "更新: 描述你的更改"
git push origin main
```

GitHub Actions 會自動重新構建和部署。

## 📞 獲取幫助

如果遇到問題，請：

1. 檢查 GitHub Actions 日誌
2. 查看瀏覽器控制台錯誤
3. 檢查 Flutter 構建日誌
4. 在 GitHub 上創建 Issue

## 🎉 恭喜！

完成以上步驟後，你的 秘跡 Miji 應用程序就成功部署到線上了！

---

**秘跡 Miji** - 讓每一次相遇都成為美好的回憶 ✨
