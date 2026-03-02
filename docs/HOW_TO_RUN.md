# 🚀 POS UMKM - Cara Menjalankan

## ⚡ Quick Start (Paling Mudah)

### Terminal 1 - Backend
```bash
./run-backend.sh
```

### Terminal 2 - Frontend  
```bash
./run-frontend.sh
```

Script akan otomatis membersihkan port yang digunakan sebelum menjalankan aplikasi.

---

## 🔧 Manual (Jika Script Tidak Berfungsi)

### 1. Bersihkan Port Dulu
```bash
# Kill port 8082 (backend)
lsof -ti:8082 | xargs kill -9

# Kill port 3000 (frontend)
lsof -ti:3000 | xargs kill -9
```

### 2. Jalankan Backend
```bash
cd backend
go run main.go
```

### 3. Jalankan Frontend (Terminal Baru)
```bash
cd frontend
npm run dev
```

---

## 🌐 URL Aplikasi

- **Frontend:** http://localhost:3000
- **Backend:** http://localhost:8082

## 🔐 Login

**Admin:**
- Username: `admin`
- Password: `admin123`

**Kasir:**
- Username: `kasir`  
- Password: `kasir123`

---

## 🐛 Troubleshooting

### Error: "address already in use"

**Solusi:**
```bash
# Cek process yang menggunakan port
lsof -i:8082  # untuk backend
lsof -i:3000  # untuk frontend

# Kill process
lsof -ti:8082 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

### Backend tidak bisa connect

1. Pastikan Go sudah terinstall: `go version`
2. Pastikan dependencies sudah terinstall: `cd backend && go mod tidy`
3. Cek apakah port 8082 kosong: `lsof -i:8082`

### Frontend tidak bisa connect

1. Pastikan Node.js sudah terinstall: `node --version`
2. Pastikan dependencies sudah terinstall: `cd frontend && npm install`
3. Pastikan backend sudah running
4. Cek apakah port 3000 kosong: `lsof -i:3000`

---

## 🛑 Stop Aplikasi

```bash
# Stop backend
pkill -f 'go run main.go'

# Stop frontend
pkill -f 'vite'

# Atau kill port langsung
lsof -ti:8082 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

---

## ✅ Fitur Aplikasi

- ✅ Dashboard Analytics
- ✅ Kasir/POS  
- ✅ Manajemen Produk (CRUD)
- ✅ Manajemen Bahan Baku (CRUD)
- ✅ Manajemen Resep
- ✅ Transaksi & Pembayaran
- ✅ Laporan (Transaksi, Harian, Bulanan)
- ✅ Pengaturan (UI Only)

---

**Happy Coding!** 🎉
