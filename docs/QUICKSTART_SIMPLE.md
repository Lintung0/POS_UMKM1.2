# 🚀 Quick Start - POS UMKM

## Cara Menjalankan Aplikasi

### Opsi 1: Menggunakan Script (Recommended)
```bash
./start.sh
```

### Opsi 2: Manual

**Terminal 1 - Backend:**
```bash
cd backend
go run main.go
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

## 🌐 URL Aplikasi

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8082
- **Health Check:** http://localhost:8082/health

## 🔐 Login

**Admin:**
- Username: `admin`
- Password: `admin123`

**Kasir:**
- Username: `kasir`
- Password: `kasir123`

## 🛑 Stop Aplikasi

```bash
# Kill backend
pkill -f 'go run main.go'

# Kill frontend
pkill -f 'vite'

# Atau kill port langsung
lsof -ti:8082 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

## 📝 Logs

```bash
# Backend log
tail -f /tmp/pos-backend.log

# Frontend log
tail -f /tmp/pos-frontend.log
```

## ✅ Fitur yang Tersedia

- ✅ Dashboard Analytics
- ✅ Kasir/POS
- ✅ Manajemen Produk (CRUD)
- ✅ Manajemen Bahan Baku (CRUD)
- ✅ Manajemen Resep
- ✅ Laporan (Transaksi, Harian, Bulanan)
- ✅ Pengaturan (UI Only)

## 🐛 Troubleshooting

**Port sudah digunakan:**
```bash
# Cek process yang menggunakan port
lsof -i:8082
lsof -i:3000

# Kill process
lsof -ti:8082 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

**Backend tidak bisa connect:**
- Pastikan port 8082 tidak digunakan aplikasi lain
- Cek log: `tail -f /tmp/pos-backend.log`

**Frontend tidak bisa connect ke backend:**
- Pastikan backend sudah running
- Cek API URL di `frontend/src/utils/api.js` (harus port 8082)

---

**Happy Coding!** 🎉
