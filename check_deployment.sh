#!/bin/bash

echo "🔍 檢查 秘跡 Miji 部署狀態..."

# 檢查 GitHub Pages 狀態
echo "📊 檢查 GitHub Pages 狀態..."
PAGES_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://boomboxplanet-alt.github.io/miji-app/")

if [ "$PAGES_STATUS" = "200" ]; then
    echo "✅ GitHub Pages 已啟用並運行正常！"
    echo "🌍 應用地址: https://boomboxplanet-alt.github.io/miji-app/"
else
    echo "❌ GitHub Pages 未啟用或部署失敗 (HTTP $PAGES_STATUS)"
    echo ""
    echo "📋 需要手動啟用 GitHub Pages："
    echo "1. 訪問: https://github.com/boomboxplanet-alt/miji-app/settings/pages"
    echo "2. Source: 選擇 'Deploy from a branch'"
    echo "3. Branch: 選擇 'main'"
    echo "4. 點擊 'Save'"
fi

echo ""

# 檢查 GitHub Actions 狀態
echo "📊 檢查 GitHub Actions 狀態..."
LATEST_RUN=$(curl -s "https://api.github.com/repos/boomboxplanet-alt/miji-app/actions/runs" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ "$LATEST_RUN" = "success" ]; then
    echo "✅ GitHub Actions 最新運行成功！"
elif [ "$LATEST_RUN" = "failure" ]; then
    echo "❌ GitHub Actions 最新運行失敗！"
    echo "🔗 查看詳情: https://github.com/boomboxplanet-alt/miji-app/actions"
else
    echo "⚠️  GitHub Actions 狀態: $LATEST_RUN"
fi

echo ""

# 檢查本地構建
echo "📊 檢查本地構建狀態..."
if [ -d "build/web" ]; then
    echo "✅ 本地 Web 構建存在"
    echo "📁 構建目錄: build/web/"
    echo "📄 主要文件:"
    ls -la build/web/ | head -10
else
    echo "❌ 本地 Web 構建不存在"
    echo "💡 運行 './manual_deploy.sh' 來構建"
fi

echo ""
echo "🎯 下一步行動："
echo "1. 在 GitHub 上啟用 GitHub Pages"
echo "2. 等待自動部署完成"
echo "3. 訪問 https://boomboxplanet-alt.github.io/miji-app/ 測試"
