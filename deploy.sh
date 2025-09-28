#!/bin/bash

echo "🚀 開始部署秘跡 MIJI 應用程式到 Vercel..."

# 檢查是否已安裝 Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "📦 安裝 Vercel CLI..."
    npm install -g vercel
fi

# 構建應用程式
echo "🔨 構建 Flutter Web 應用程式..."
flutter clean
flutter pub get
flutter build web --release

# 部署到 Vercel
echo "🌐 部署到 Vercel..."
vercel --prod

echo "✅ 部署完成！"
echo "🔗 您的應用程式現在可以在網路上訪問了！"
