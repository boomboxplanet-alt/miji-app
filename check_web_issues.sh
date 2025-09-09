#!/bin/bash

echo "🔍 Flutter Web 問題診斷器"
echo "================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}1. 檢查 Flutter 版本...${NC}"
flutter --version

echo -e "\n${BLUE}2. 檢查項目狀態...${NC}"
flutter doctor

echo -e "\n${BLUE}3. 檢查依賴...${NC}"
flutter pub deps

echo -e "\n${BLUE}4. 檢查 Web 支持...${NC}"
flutter devices

echo -e "\n${BLUE}5. 嘗試構建 Web...${NC}"
if flutter build web --release; then
    echo -e "${GREEN}✅ Web 構建成功！${NC}"
    echo -e "${BLUE}6. 檢查構建文件...${NC}"
    ls -la build/web/
else
    echo -e "${RED}❌ Web 構建失敗！${NC}"
    echo -e "${YELLOW}💡 請檢查上面的錯誤信息${NC}"
fi

echo -e "\n${BLUE}7. 檢查端口使用情況...${NC}"
echo "端口 8000:"
lsof -i :8000 2>/dev/null || echo "未使用"
echo "端口 8080:"
lsof -i :8080 2>/dev/null || echo "未使用"

echo -e "\n${GREEN}診斷完成！${NC}"
