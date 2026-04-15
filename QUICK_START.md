# 🚀 QUICK START GUIDE - POS UMKM

## ⚡ Mulai Cepat (5 Menit)

### 1️⃣ Setup (Pertama Kali)
```bash
cd /home/kirek/code/POS_UMKM-master
./setup.sh
```

### 2️⃣ Jalankan Aplikasi
```bash
./start-app.sh
```

### 3️⃣ Buka Browser
```
http://localhost:3000
```

---

## 📋 Prerequisites

- ✅ Node.js (v16+)
- ✅ Go (v1.19+)
- ✅ MySQL (v8.0+)
- ✅ npm atau yarn

---

## 🔧 Commands Penting

### Development
```bash
# Setup environment
./setup.sh

# Start aplikasi
./start-app.sh

# Stop aplikasi
Ctrl + C
```

### Production
```bash
# Build untuk production
./build-production.sh

# Output:
# - frontend/dist/
# - backend/pos-umkm-server
```

### Manual Start
```bash
# Backend
cd backend && go run main.go

# Frontend (terminal baru)
cd frontend && npm run dev
```

---

## 🗄️ Database Setup

### Otomatis (via setup.sh)
```bash
./setup.sh
# Ikuti prompt untuk create database
```

### Manual
```bash
# Login ke MySQL
mysql -u root -p

# Create database
CREATE DATABASE pos_umkm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Import schema (jika ada)
USE pos_umkm;
SOURCE database/schema.sql;
```

---

## 🔑 Default Login

Sesuaikan dengan data di database Anda:
```
Username: admin
Password: [sesuai database]
```

---

## 📁 Struktur Project

```
POS_UMKM-master/
├── frontend/           # React + Vite
│   ├── src/
│   │   ├── pages/     # Halaman aplikasi
│   │   ├── components/# Komponen reusable
│   │   ├── context/   # Context providers
│   │   └── utils/     # Utilities & API
│   └── package.json
│
├── backend/           # Go + Gin
│   ├── controllers/   # Business logic
│   ├── models/        # Database models
│   ├── routes/        # API routes
│   ├── middleware/    # Auth, CORS, etc
│   └── main.go
│
├── database/          # SQL schemas
├── docs/             # Documentation
├── setup.sh          # Setup script
├── start-app.sh      # Start script
└── build-production.sh # Build script
```

---

## 🌐 Endpoints

### Frontend
- Development: `http://localhost:3000`
- Production: Sesuai deployment

### Backend
- API Base: `http://localhost:8080/api`
- Health Check: `http://localhost:8080/health`

---

## 🎯 Fitur Utama

1. **Dashboard** - Overview & statistik
2. **Kasir** - Point of Sale
3. **Produk** - Manajemen produk
4. **Bahan Baku** - Manajemen material
5. **Resep** - Resep produk
6. **Laporan** - Reports & analytics
7. **Analisis Profit** - Profit analysis
8. **Pengaturan** - Settings

---

## 🐛 Troubleshooting Cepat

### Port sudah digunakan
```bash
# Kill port 3000
lsof -ti:3000 | xargs kill -9

# Kill port 8080
lsof -ti:8080 | xargs kill -9
```

### Database connection error
```bash
# Check MySQL running
sudo systemctl status mysql

# Start MySQL
sudo systemctl start mysql

# Update backend/.env dengan credentials yang benar
```

### Module not found
```bash
# Frontend
cd frontend && npm install

# Backend
cd backend && go mod download
```

---

## 📚 Dokumentasi Lengkap

- **PRODUCTION_CHECKLIST.md** - Production deployment
- **FIXING_REPORT.md** - Detailed technical report
- **README.md** - Project overview

---

## 🆘 Butuh Bantuan?

1. Cek PRODUCTION_CHECKLIST.md untuk troubleshooting
2. Cek FIXING_REPORT.md untuk detail teknis
3. Cek logs di terminal untuk error messages

---

## ✅ Checklist Sebelum Deploy

- [ ] Database sudah setup
- [ ] Backend .env sudah dikonfigurasi
- [ ] Semua dependencies terinstall
- [ ] Test login berhasil
- [ ] Test semua fitur utama
- [ ] Build production berhasil
- [ ] Security checklist completed

---

**Happy Coding! 🎉**
