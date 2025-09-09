#!/bin/bash

echo "🚀 構建簡化版 Flutter Web 應用程式"
echo "=================================="

# 顏色定義
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 備份原始文件
echo -e "${YELLOW}📁 備份原始文件...${NC}"
cp pubspec.yaml pubspec.yaml.backup
cp lib/main.dart lib/main.dart.backup

# 使用簡化版本
echo -e "${YELLOW}🔄 切換到簡化版本...${NC}"
cp pubspec_simple.yaml pubspec.yaml
cp lib/main_simple.dart lib/main.dart

# 清理項目
echo -e "${YELLOW}🧹 清理項目...${NC}"
flutter clean

# 獲取依賴
echo -e "${YELLOW}📦 安裝依賴...${NC}"
flutter pub get

# 構建 Web 版本
echo -e "${YELLOW}🔨 構建 Web 版本...${NC}"
if flutter build web --release; then
    echo -e "${GREEN}✅ Web 版本構建成功！${NC}"
    
    # 啟動服務器
    echo -e "${GREEN}🌐 啟動 Web 服務器...${NC}"
    echo -e "${GREEN}📱 應用程式將在 http://localhost:8000 上運行${NC}"
    echo -e "${YELLOW}🔄 按 Ctrl+C 停止服務器${NC}"
    
    cd build/web && python3 -m http.server 8000
else
    echo -e "${RED}❌ Web 版本構建失敗！${NC}"
    
    # 恢復原始文件
    echo -e "${YELLOW}🔄 恢復原始文件...${NC}"
    cp pubspec.yaml.backup pubspec.yaml
    cp lib/main.dart.backup lib/main.dart
    
    echo -e "${RED}💡 請檢查錯誤信息並修復問題${NC}"
    exit 1
fi
