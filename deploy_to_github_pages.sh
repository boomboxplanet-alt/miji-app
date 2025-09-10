#!/bin/bash

echo "🚀 開始部署秘跡 Miji 到 GitHub Pages..."

# 檢查是否在正確的分支
current_branch=$(git branch --show-current)
echo "📍 當前分支: $current_branch"

# 構建 Flutter Web 應用
echo "🔨 構建 Flutter Web 應用..."
flutter clean
flutter pub get
flutter build web --release --base-href /miji-app/

if [ $? -ne 0 ]; then
    echo "❌ 構建失敗！"
    exit 1
fi

echo "✅ 構建成功！"

# 切換到 gh-pages 分支
echo "🔄 切換到 gh-pages 分支..."
git checkout gh-pages 2>/dev/null || git checkout -b gh-pages

# 複製構建文件到根目錄
echo "📁 複製構建文件..."
cp -r build/web/* .

# 添加所有文件
git add .

# 提交更改
echo "💾 提交更改..."
git commit -m "Deploy: 更新秘跡 Miji 應用 $(date '+%Y-%m-%d %H:%M:%S')"

# 推送到 GitHub
echo "🚀 推送到 GitHub Pages..."
git push origin gh-pages

# 切換回原分支
git checkout $current_branch

echo "🎉 部署完成！"
echo "🌐 應用將在以下網址可用："
echo "   https://boomboxplanet-alt.github.io/miji-app/"
echo ""
echo "⏰ 請等待 1-2 分鐘讓 GitHub Pages 更新"
