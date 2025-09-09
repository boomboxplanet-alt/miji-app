#!/bin/bash

echo "🚀 啟動 Flutter Web 應用程式..."

# 設置超時時間（秒）
TIMEOUT=60

echo "⏱️  設置超時時間：${TIMEOUT} 秒"

# 使用 timeout 命令運行 Flutter，如果超時則自動停止
timeout $TIMEOUT flutter run -d chrome --web-port=8080 --release

# 檢查退出狀態
if [ $? -eq 124 ]; then
    echo "⏰ 超時！應用程式可能還在啟動中..."
    echo "🔄 請檢查瀏覽器是否已打開 http://localhost:8080"
elif [ $? -eq 0 ]; then
    echo "✅ 應用程式啟動成功！"
else
    echo "❌ 應用程式啟動失敗，退出碼：$?"
    echo "🔍 請檢查錯誤信息"
fi
