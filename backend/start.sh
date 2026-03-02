#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Checking port 8082...${NC}"

# Check if port 8082 is in use
PID=$(lsof -ti:8082)

if [ ! -z "$PID" ]; then
    echo -e "${YELLOW}⚠️  Port 8082 is in use by PID: $PID${NC}"
    echo -e "${YELLOW}🔪 Killing process...${NC}"
    kill -9 $PID
    sleep 1
    echo -e "${GREEN}✅ Process killed${NC}"
else
    echo -e "${GREEN}✅ Port 8082 is free${NC}"
fi

echo -e "${GREEN}🚀 Starting backend...${NC}"
echo ""

# Run backend
go run main.go
