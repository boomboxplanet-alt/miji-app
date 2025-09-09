#!/bin/bash

echo "🚀 開始啟動 Flutter Web 應用程式..."

# 檢查 Flutter 是否可用
if ! command -v flutter &> /dev/null; then
    echo "❌ 錯誤：Flutter 未安裝或不在 PATH 中"
    exit 1
fi

# 清理之前的構建
echo "🧹 清理之前的構建..."
flutter clean

# 獲取依賴
echo "📦 安裝依賴..."
flutter pub get

# 構建 Web 版本
echo "🔨 構建 Web 版本..."
if flutter build web --release; then
    echo "✅ Web 版本構建成功！"
    
    # 啟動本地服務器
    echo "🌐 啟動本地服務器..."
    echo "📱 應用程式將在 http://localhost:8000 上運行"
    echo "🔄 按 Ctrl+C 停止服務器"
    
    # 使用 Python 的簡單 HTTP 服務器（如果可用）
    if command -v python3 &> /dev/null; then
        cd build/web && python3 -m http.server 8000
    elif command -v python &> /dev/null; then
        cd build/web && python -m SimpleHTTPServer 8000
    else
        echo "⚠️  未找到 Python，請手動打開 build/web 目錄中的 index.html"
        echo "📁 或者安裝 Python 來啟動本地服務器"
        open build/web/index.html
    fi
else
    echo "❌ Web 版本構建失敗！"
    echo "🔍 請檢查錯誤信息並修復問題"
    exit 1
fi
