# Troubleshooting & Solutions

## Masalah yang Telah Diselesaikan

### 1. Port 8082 Already in Use ✅
**Problem:** Server tidak bisa start karena port sudah digunakan
```
listen tcp :8082: bind: address already in use
```

**Solution:**
```bash
# Cek proses yang menggunakan port
lsof -i :8082

# Hentikan proses
kill -9 <PID>

# Atau gunakan script stop.sh
./stop.sh
```

### 2. Go Module Dependency Warning ✅
**Problem:** `github.com/golang-jwt/jwt/v5 should be direct`

**Solution:**
- Pindahkan dependency dari `indirect` ke `direct` di `go.mod`
- Jalankan `go mod tidy`

### 3. SQL Syntax Error (MSSQL Extension) ✅
**Problem:** VSCode MSSQL extension menampilkan error pada file SQL MySQL

**Solution:**
- File SQL sudah benar untuk MySQL
- Error hanya muncul di editor karena extension MSSQL
- Tidak perlu diubah, file berfungsi dengan baik

## Quick Commands

### Start System
```bash
./start.sh
```

### Stop System
```bash
./stop.sh
```

### Test System
```bash
./test.sh
```

### Manual Start

**Backend:**
```bash
cd backend
go run main.go
```

**Frontend:**
```bash
cd frontend
npm run dev
```

### Check Logs
```bash
# Backend logs
tail -f /tmp/pos-backend.log

# Frontend logs
tail -f /tmp/pos-frontend.log
```

### Check Running Processes
```bash
# Backend
lsof -i :8082

# Frontend
ps aux | grep vite
```

## Test Results ✅

Semua endpoint telah ditest dan berfungsi dengan baik:

1. ✅ Health Check - `/health`
2. ✅ Authentication - `/api/auth/login`
3. ✅ Products API - `/api/products`
4. ✅ Materials API - `/api/materials`
5. ✅ Recipes API - `/api/recipes`
6. ✅ Transactions API - `/api/transactions`
7. ✅ Dashboard API - `/api/dashboard/*`
8. ✅ Frontend - React + Vite

## System Status

- **Backend:** Running on http://localhost:8082
- **Frontend:** Running on http://localhost:3002
- **Database:** MySQL (pos_umkm)
- **Status:** All systems operational ✅

## Login Credentials

**Admin:**
- Username: `admin`
- Password: `admin123`

**Kasir:**
- Username: `kasir`
- Password: `kasir123`
