# 🚀 秘跡 MIJI 應用程式部署指南

## 📋 部署選項

### 1. Vercel 部署 (推薦)

#### 步驟：
1. 訪問 [Vercel](https://vercel.com)
2. 使用 GitHub 帳號登入
3. 導入此倉庫：`boomboxplanet-alt/miji-app`
4. 選擇分支：`supabase-migration-20250928`
5. 構建設置：
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`

#### 環境變數：
```
SUPABASE_URL=https://btmfruykvyncefdbaqyz.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ0bWZydXlrdnluY2VmZGJhcXl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg3NzYyNzgsImV4cCI6MjA3NDM1MjI3OH0.lezj2jl5Hy-TEV-ZqxbN7VzRLJtcwohs5tOhzqAFuQs
```

### 2. GitHub Pages 部署

#### 步驟：
1. 在 GitHub 倉庫中啟用 GitHub Pages
2. 選擇 `gh-pages` 分支作為來源
3. 每次推送到 `supabase-migration-20250928` 分支時會自動部署

### 3. 本地構建和測試

#### 使用構建腳本：
```bash
./build_web.sh
```

#### 手動構建：
```bash
# 清理
flutter clean

# 獲取依賴
flutter pub get

# 構建 Web 應用程式
flutter build web --release

# 本地測試
cd build/web
python3 -m http.server 8000
# 訪問: http://localhost:8000
```

## 🔧 配置說明

### Supabase 配置
- **URL**: `https://btmfruykvyncefdbaqyz.supabase.co`
- **認證**: 已整合 Supabase 認證
- **資料庫**: PostgreSQL (需要創建必要表)
- **儲存**: Supabase Storage
- **分析**: 自定義事件追蹤

### 功能狀態
- ✅ **Supabase 整合**: 完成
- ✅ **認證系統**: 訪客模式可用
- ⚠️ **Google 登入**: 需要 OAuth 配置
- ⚠️ **資料庫表**: 需要創建必要表
- ✅ **UI/UX**: 完整功能

## 🌐 部署後測試

1. **基本功能測試**:
   - 應用程式載入
   - 地圖顯示
   - 任務列表
   - 設定頁面

2. **認證測試**:
   - 訪客模式登入
   - 用戶狀態管理

3. **Supabase 連接測試**:
   - 使用登入頁面的「測試」按鈕
   - 檢查控制台日誌

## 📱 支援平台

- ✅ **Web**: 完全支援
- ✅ **Android**: 支援 (需要 Google Maps API 金鑰)
- ✅ **iOS**: 支援 (需要 Google Maps API 金鑰)

## 🐛 已知問題

1. **Google 登入**: 暫時使用訪客模式
2. **資料庫表**: 需要手動創建
3. **位置服務**: 在 Web 上需要 HTTPS

## 🔄 更新流程

1. 修改代碼
2. 提交到 `supabase-migration-20250928` 分支
3. 自動觸發部署
4. 測試線上版本

## 📞 支援

如有問題，請檢查：
1. 控制台錯誤日誌
2. Supabase 連接狀態
3. 網路連接
4. 瀏覽器相容性
