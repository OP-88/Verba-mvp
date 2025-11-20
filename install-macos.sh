#!/bin/bash
# Verba macOS Installer
# Run with: bash install-macos.sh

set -e

echo "========================================"
echo "  Verba - Offline AI Meeting Assistant"
echo "  macOS Installer v1.0.0"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check Homebrew
echo -e "${GREEN}🔍 Checking Homebrew...${NC}"
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ Homebrew not found${NC}"
    echo -e "${YELLOW}   Install Homebrew from: https://brew.sh/${NC}"
    echo -e "${YELLOW}   Run: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    echo ""
    exit 1
fi
echo -e "${GREEN}✅ Homebrew found${NC}"
echo ""

# Check/Install Python 3.11+
echo -e "${GREEN}🔍 Checking Python...${NC}"
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
    
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -ge 11 ]; then
        echo -e "${GREEN}✅ Python $PYTHON_VERSION found${NC}"
    else
        echo -e "${YELLOW}⚠️  Python $PYTHON_VERSION found, but 3.11+ required${NC}"
        echo -e "${CYAN}📦 Installing Python 3.11...${NC}"
        brew install python@3.11
    fi
else
    echo -e "${YELLOW}⚠️  Python not found${NC}"
    echo -e "${CYAN}📦 Installing Python 3.11...${NC}"
    brew install python@3.11
fi
echo ""

# Check/Install Node.js
echo -e "${GREEN}🔍 Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        echo -e "${GREEN}✅ Node.js v$(node --version | cut -d'v' -f2) found${NC}"
    else
        echo -e "${YELLOW}⚠️  Node.js $NODE_VERSION found, but 18+ required${NC}"
        echo -e "${CYAN}📦 Installing Node.js...${NC}"
        brew install node
    fi
else
    echo -e "${YELLOW}⚠️  Node.js not found${NC}"
    echo -e "${CYAN}📦 Installing Node.js...${NC}"
    brew install node
fi
echo ""

# Check/Install ffmpeg
echo -e "${GREEN}🔍 Checking ffmpeg...${NC}"
if command -v ffmpeg &> /dev/null; then
    echo -e "${GREEN}✅ ffmpeg found${NC}"
else
    echo -e "${YELLOW}⚠️  ffmpeg not found${NC}"
    echo -e "${CYAN}📦 Installing ffmpeg...${NC}"
    brew install ffmpeg
fi
echo ""

# Setup Backend
echo -e "${GREEN}📦 Setting up backend...${NC}"
cd backend

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

cd ..
echo -e "${GREEN}✅ Backend setup complete${NC}"
echo ""

# Setup Frontend
echo -e "${GREEN}📦 Setting up frontend...${NC}"
cd frontend
npm install

cd ..
echo -e "${GREEN}✅ Frontend setup complete${NC}"
echo ""

# Make start script executable
chmod +x start_verba.sh

echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "========================================"
echo -e "${CYAN}  To start Verba, run:${NC}"
echo -e "  ${YELLOW}./start_verba.sh${NC}"
echo "========================================"
echo ""
echo -e "${CYAN}  Then open: ${YELLOW}http://localhost:5173${NC}"
echo ""
