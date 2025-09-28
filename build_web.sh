#!/bin/bash

# Flutter Web 構建腳本
echo "🚀 開始構建 Flutter Web 應用程式..."

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean

# 獲取依賴
echo "📦 獲取依賴..."
flutter pub get

# 構建 Web 應用程式
echo "🔨 構建 Web 應用程式..."
flutter build web --release

echo "✅ 構建完成！"
echo "📁 構建文件位於: build/web/"
echo "🌐 您可以使用以下命令在本地測試:"
echo "   cd build/web && python3 -m http.server 8000"
echo "   然後訪問: http://localhost:8000"
