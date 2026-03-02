# 🚀 Lin-POS - Quick Start Scripts

Scripts untuk memudahkan development Lin-POS dengan auto-kill port!

---

## 📝 Available Scripts

### 1. **Start Backend Only**
```bash
cd backend
./start.sh
```
- Auto-kill port 8082 jika sedang digunakan
- Start backend dengan `go run main.go`

### 2. **Start Frontend Only**
```bash
cd frontend
./start.sh
```
- Auto-kill port 3000 jika sedang digunakan
- Start frontend dengan `npm run dev`

### 3. **Start Both (Backend + Frontend)**
```bash
./start-all.sh
```
- Auto-kill port 8082 dan 3000
- Start backend dan frontend di background
- Logs tersimpan di folder `logs/`

### 4. **Stop All**
```bash
./stop.sh
```
- Stop backend (port 8082)
- Stop frontend (port 3000)

---

## 🎯 Recommended Workflow

### Development:
```bash
# Start everything
./start-all.sh

# Check logs
tail -f logs/backend.log
tail -f logs/frontend.log

# Stop when done
./stop.sh
```

### Backend Only:
```bash
cd backend
./start.sh
```

### Frontend Only:
```bash
cd frontend
./start.sh
```

---

## 📊 Access URLs

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8082
- **Health Check:** http://localhost:8082/health
- **Database:** http://localhost:8081 (phpMyAdmin)

---

## 🔧 Troubleshooting

### Port Already in Use?
Scripts akan otomatis kill process yang menggunakan port!

### Manual Kill:
```bash
# Kill backend
lsof -ti:8082 | xargs kill -9

# Kill frontend
lsof -ti:3000 | xargs kill -9
```

### Check Running Processes:
```bash
# Check port 8082
lsof -i:8082

# Check port 3000
lsof -i:3000
```

---

## 📝 Login Credentials

### Admin:
- Username: `admin`
- Password: `admin123`

### Kasir:
- Username: `kasir`
- Password: `kasir123`

---

## 🎉 Features

- ✅ Auto-kill port sebelum start
- ✅ Colored output untuk readability
- ✅ Background process dengan logs
- ✅ Easy start/stop commands
- ✅ No more "address already in use" error!

---

**Happy Coding! 🚀**
