#!/bin/bash

echo "🚀 開始部署 秘跡 Miji 應用程序..."

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安裝，請先安裝 Flutter SDK"
    exit 1
fi

# 檢查 Git 是否安裝
if ! command -v git &> /dev/null; then
    echo "❌ Git 未安裝，請先安裝 Git"
    exit 1
fi

echo "✅ 環境檢查完成"

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean

# 獲取依賴
echo "📦 獲取依賴..."
flutter pub get

# 分析代碼
echo "🔍 分析代碼..."
flutter analyze

# 構建 Web 版本
echo "🌐 構建 Web 版本..."
flutter build web --base-href "/miji-app/"

# 檢查構建是否成功
if [ $? -eq 0 ]; then
    echo "✅ Web 版本構建成功！"
    echo ""
    echo "📁 構建文件位於: build/web/"
    echo "🌍 部署到 GitHub Pages 後，應用將在以下地址可用："
    echo "   https://boomboxplanet.github.io/miji-app/"
    echo ""
    echo "📋 下一步："
    echo "1. 在 GitHub 上創建 miji-app 倉庫"
    echo "2. 推送代碼: git push -u origin main"
    echo "3. 在倉庫設置中啟用 GitHub Pages"
    echo "4. 選擇 main 分支作為源分支"
else
    echo "❌ Web 版本構建失敗"
    exit 1
fi
