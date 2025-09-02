#!/bin/bash

echo "🚀 手動部署 秘跡 Miji 到 GitHub Pages..."

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安裝，請先安裝 Flutter SDK"
    exit 1
fi

echo "✅ Flutter 環境檢查完成"

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean

# 獲取依賴
echo "📦 獲取依賴..."
flutter pub get

# 構建 Web 版本
echo "🌐 構建 Web 版本..."
flutter build web --base-href "/miji-app/"

# 檢查構建是否成功
if [ $? -eq 0 ]; then
    echo "✅ Web 版本構建成功！"
    echo ""
    echo "📁 構建文件位於: build/web/"
    echo ""
    echo "📋 手動部署步驟："
    echo "1. 在 GitHub 上啟用 GitHub Pages"
    echo "2. 選擇 main 分支作為源分支"
    echo "3. 等待部署完成"
    echo ""
    echo "🌍 部署完成後，應用將在以下地址可用："
    echo "   https://boomboxplanet-alt.github.io/miji-app/"
    echo ""
    echo "💡 如果 GitHub Actions 失敗，可以手動上傳 build/web/ 目錄的內容"
else
    echo "❌ Web 版本構建失敗"
    exit 1
fi
