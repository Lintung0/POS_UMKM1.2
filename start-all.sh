#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Lin-POS Startup Script 🚀      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Kill backend port
echo -e "${YELLOW}🔍 Checking backend port 8082...${NC}"
BACKEND_PID=$(lsof -ti:8082)
if [ ! -z "$BACKEND_PID" ]; then
    echo -e "${YELLOW}⚠️  Killing process on port 8082 (PID: $BACKEND_PID)${NC}"
    kill -9 $BACKEND_PID
    sleep 1
    echo -e "${GREEN}✅ Backend port cleared${NC}"
else
    echo -e "${GREEN}✅ Backend port is free${NC}"
fi

# Kill frontend port
echo -e "${YELLOW}🔍 Checking frontend port 3000...${NC}"
FRONTEND_PID=$(lsof -ti:3000)
if [ ! -z "$FRONTEND_PID" ]; then
    echo -e "${YELLOW}⚠️  Killing process on port 3000 (PID: $FRONTEND_PID)${NC}"
    kill -9 $FRONTEND_PID
    sleep 1
    echo -e "${GREEN}✅ Frontend port cleared${NC}"
else
    echo -e "${GREEN}✅ Frontend port is free${NC}"
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Starting Backend...${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"

# Start backend in background
cd backend
nohup go run main.go > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}✅ Backend started (PID: $BACKEND_PID)${NC}"
echo -e "${GREEN}📊 Backend: http://localhost:8082${NC}"
cd ..

sleep 3

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 Starting Frontend...${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"

# Start frontend in background
cd frontend
nohup npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}✅ Frontend started (PID: $FRONTEND_PID)${NC}"
echo -e "${GREEN}🌐 Frontend: http://localhost:3000${NC}"
cd ..

echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Lin-POS Started Successfully!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Logs:${NC}"
echo -e "   Backend:  tail -f logs/backend.log"
echo -e "   Frontend: tail -f logs/frontend.log"
echo ""
echo -e "${YELLOW}🛑 To stop:${NC}"
echo -e "   ./stop.sh"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"
