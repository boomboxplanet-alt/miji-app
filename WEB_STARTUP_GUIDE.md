# Flutter Web 啟動指南

## 🚀 啟動方法

### 方法 1：使用智能啟動腳本（最推薦）
```bash
./start_web_smart.sh
```
- 🧠 自動檢測和修復問題
- 🧹 自動清理和構建
- 🌐 智能端口選擇
- 🎨 彩色輸出和進度顯示

### 方法 2：使用穩定腳本
```bash
./start_web_stable.sh
```
- 自動清理和構建
- 使用 Python HTTP 服務器
- 在 http://localhost:8000 運行

### 方法 3：使用簡單腳本（帶超時控制）
```bash
./start_web_simple.sh
```
- 設置 60 秒超時
- 自動停止卡住的進程
- 在 http://localhost:8080 運行

### 方法 4：問題診斷
```bash
./check_web_issues.sh
```
- 🔍 全面檢查 Flutter 環境
- 📊 顯示詳細診斷信息
- 💡 提供問題解決建議

### 方法 5：手動啟動（調試用）
```bash
# 構建 Web 版本
flutter build web --release

# 啟動調試模式（可能卡住）
flutter run -d chrome
```

## 🔧 問題解決

### 問題：Flutter 啟動時卡住
**原因：**
- 編譯錯誤未顯示
- 依賴衝突
- 瀏覽器連接問題

**解決方案：**
1. 使用 `./start_web_smart.sh` 腳本（最推薦）
2. 使用 `./check_web_issues.sh` 診斷問題
3. 檢查終端輸出是否有錯誤
4. 按 `Ctrl+C` 停止，然後使用 `flutter build web` 檢查構建

### 問題：找不到 assets 目錄
**解決方案：**
腳本會自動創建缺失的目錄，或手動創建：
```bash
mkdir -p assets/audio assets/icons
```

### 問題：Provider 錯誤
**解決方案：**
確保 `main.dart` 中包含了所有必要的 Provider：
- `AppState`
- `LocationProvider`
- `MessageProvider`
- `LocationService`
- `MessageService`
- `AIBotService`

### 問題：端口被佔用
**解決方案：**
智能腳本會自動選擇可用端口，或手動檢查：
```bash
lsof -i :8000
lsof -i :8080
```

## 📱 測試應用程式

1. 打開瀏覽器訪問顯示的 URL（通常是 http://localhost:8000 或 8001）
2. 點擊"開始探索"按鈕
3. 允許位置權限（模擬位置：澳門）
4. 測試地圖功能和 AI 機器人

## 🛠️ 開發建議

- 🚀 **優先使用 `./start_web_smart.sh`**，避免手動啟動時卡住
- 🔍 遇到問題時使用 `./check_web_issues.sh` 診斷
- 🧹 在修改代碼後使用腳本自動清理
- 📊 使用 `flutter analyze` 檢查代碼問題
- 🌐 構建成功後使用腳本啟動服務器

## 📋 腳本功能對比

| 腳本 | 自動修復 | 超時控制 | 端口檢測 | 彩色輸出 | 推薦度 |
|------|----------|----------|----------|----------|--------|
| `start_web_smart.sh` | ✅ | ✅ | ✅ | ✅ | ⭐⭐⭐⭐⭐ |
| `start_web_stable.sh` | ✅ | ❌ | ❌ | ❌ | ⭐⭐⭐⭐ |
| `start_web_simple.sh` | ❌ | ✅ | ❌ | ❌ | ⭐⭐⭐ |
| `check_web_issues.sh` | ❌ | ❌ | ❌ | ✅ | 🔍診斷用 |
