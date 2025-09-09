#!/bin/bash

echo "🧠 智能 Flutter Web 啟動器"
echo "================================"

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 檢查 Flutter
check_flutter() {
    echo -e "${BLUE}🔍 檢查 Flutter 環境...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter 未安裝或不在 PATH 中${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Flutter 可用${NC}"
}

# 檢查依賴
check_dependencies() {
    echo -e "${BLUE}📦 檢查項目依賴...${NC}"
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}❌ 未找到 pubspec.yaml，請在 Flutter 項目根目錄運行${NC}"
        exit 1
    fi
    
    # 檢查缺失的 assets 目錄
    if [ ! -d "assets/audio" ]; then
        echo -e "${YELLOW}⚠️  創建缺失的 assets/audio 目錄${NC}"
        mkdir -p assets/audio
    fi
    
    if [ ! -d "assets/icons" ]; then
        echo -e "${YELLOW}⚠️  創建缺失的 assets/icons 目錄${NC}"
        mkdir -p assets/icons
    fi
}

# 清理和安裝依賴
setup_project() {
    echo -e "${BLUE}🧹 清理項目...${NC}"
    flutter clean
    
    echo -e "${BLUE}📥 安裝依賴...${NC}"
    flutter pub get
}

# 構建 Web 版本
build_web() {
    echo -e "${BLUE}🔨 構建 Web 版本...${NC}"
    if flutter build web --release; then
        echo -e "${GREEN}✅ Web 版本構建成功！${NC}"
        return 0
    else
        echo -e "${RED}❌ Web 版本構建失敗！${NC}"
        return 1
    fi
}

# 啟動服務器
start_server() {
    local port=8000
    
    echo -e "${BLUE}🌐 啟動 Web 服務器...${NC}"
    
    # 檢查端口是否被佔用
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${YELLOW}⚠️  端口 $port 已被佔用，嘗試端口 8001${NC}"
        port=8001
    fi
    
    # 啟動服務器
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}🚀 使用 Python3 啟動服務器${NC}"
        echo -e "${GREEN}📱 應用程式將在 http://localhost:$port 上運行${NC}"
        echo -e "${YELLOW}🔄 按 Ctrl+C 停止服務器${NC}"
        cd build/web && python3 -m http.server $port
    elif command -v python &> /dev/null; then
        echo -e "${GREEN}🚀 使用 Python 啟動服務器${NC}"
        echo -e "${GREEN}📱 應用程式將在 http://localhost:$port 上運行${NC}"
        echo -e "${YELLOW}🔄 按 Ctrl+C 停止服務器${NC}"
        cd build/web && python -m SimpleHTTPServer $port
    else
        echo -e "${YELLOW}⚠️  未找到 Python，嘗試打開瀏覽器${NC}"
        open build/web/index.html
    fi
}

# 主函數
main() {
    check_flutter
    check_dependencies
    setup_project
    
    if build_web; then
        start_server
    else
        echo -e "${RED}❌ 構建失敗，無法啟動服務器${NC}"
        echo -e "${YELLOW}💡 請檢查錯誤信息並修復問題${NC}"
        exit 1
    fi
}

# 運行主函數
main
