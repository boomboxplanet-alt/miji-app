#!/bin/bash

echo "🌐 啟動 秘跡 Miji Web 版本..."

# 檢查 Flutter 是否安裝
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安裝，請先安裝 Flutter SDK"
    exit 1
fi

echo "✅ Flutter 環境檢查完成"

# 清理並重新構建
echo "🧹 清理之前的構建..."
flutter clean

echo "📦 獲取依賴..."
flutter pub get

echo "🌐 啟動 Web 版本..."
echo "📱 應用將在瀏覽器中打開"
echo "🔗 本地地址: http://localhost:8080"
echo ""
echo "💡 提示: 按 Ctrl+C 停止服務器"

# 啟動 Web 版本
flutter run -d chrome --web-port=8080
