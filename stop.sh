#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      🛑 Lin-POS Stop Script 🛑        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Kill backend
echo -e "${YELLOW}🔍 Stopping backend (port 8082)...${NC}"
BACKEND_PID=$(lsof -ti:8082)
if [ ! -z "$BACKEND_PID" ]; then
    kill -9 $BACKEND_PID
    echo -e "${GREEN}✅ Backend stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Backend not running${NC}"
fi

# Kill frontend
echo -e "${YELLOW}🔍 Stopping frontend (port 3000)...${NC}"
FRONTEND_PID=$(lsof -ti:3000)
if [ ! -z "$FRONTEND_PID" ]; then
    kill -9 $FRONTEND_PID
    echo -e "${GREEN}✅ Frontend stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend not running${NC}"
fi

echo ""
echo -e "${GREEN}✅ Lin-POS stopped successfully!${NC}"
