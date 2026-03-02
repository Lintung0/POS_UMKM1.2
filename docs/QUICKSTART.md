# Quick Start Guide - POS UMKM

## 🚀 Langkah Cepat Menjalankan Aplikasi

### 1. Jalankan Backend

```bash
cd backend
go run main.go
```

**Output yang diharapkan:**
```
✅ Migrated model Product successfully
✅ Migrated model RawMaterial successfully
✅ Migrated model User successfully
✅ Migrated model Recipe successfully
✅ Migrated model Transaction successfully
✅ Migrated model TransactionDetail successfully
✅ Database migration completed
🚀 Server starting on http://localhost:8081
📊 API Health Check: http://localhost:8081/health
🔗 API Base URL: http://localhost:8081/api
```

### 2. Jalankan Frontend (Terminal Baru)

```bash
cd frontend
npm run dev
```

**Output yang diharapkan:**
```
  VITE v4.5.14  ready in XXX ms

  ➜  Local:   http://localhost:3000/
  ➜  Network: use --host to expose
```

### 3. Akses Aplikasi

Buka browser dan akses: **http://localhost:3000**

### 4. Login

**Admin (Full Access):**
- Username: `admin`
- Password: `admin123`

**Kasir (Dashboard & POS Only):**
- Username: `kasir`
- Password: `kasir123`

## 📱 Fitur yang Tersedia

### Untuk Admin:
1. **Dashboard** - Lihat ringkasan penjualan dan analytics
2. **Kasir** - Proses transaksi penjualan
3. **Produk** - Kelola produk (CRUD + Resep)
4. **Bahan Baku** - Kelola bahan baku & stok
5. **Laporan** - Lihat laporan transaksi, harian, bulanan
6. **Pengaturan** - Konfigurasi sistem

### Untuk Kasir:
1. **Dashboard** - Lihat ringkasan penjualan
2. **Kasir** - Proses transaksi penjualan

## 🧪 Test Aplikasi

### 1. Tambah Bahan Baku
- Klik menu **Bahan Baku**
- Klik **Tambah Bahan**
- Isi form (contoh: Tepung, kg, 100, 10, 15000)
- Klik **Simpan**

### 2. Tambah Produk
- Klik menu **Produk**
- Klik **Tambah Produk**
- Isi form (contoh: Roti Tawar, Roti, 25000, 15000, 50)
- Klik **Simpan**

### 3. Tambah Resep ke Produk
- Di halaman **Produk**, klik icon Chef Hat (🧑‍🍳) pada produk
- Klik **Tambah Bahan**
- Pilih bahan baku dan masukkan jumlah
- Klik **Tambah**

### 4. Proses Transaksi
- Klik menu **Kasir**
- Pilih produk yang ingin dijual
- Klik **Bayar**
- Masukkan jumlah bayar
- Klik **Proses Pembayaran**

### 5. Lihat Laporan
- Klik menu **Laporan**
- Pilih tab **Transaksi** untuk melihat semua transaksi
- Klik icon mata (👁️) untuk detail transaksi
- Pilih tab **Laporan Harian** atau **Laporan Bulanan** untuk analytics

## 🔧 Troubleshooting

### Backend tidak bisa dijalankan
```bash
cd backend
go mod tidy
go run main.go
```

### Frontend tidak bisa dijalankan
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run dev
```

### Port sudah digunakan

**Backend (8081):**
```bash
# Cari process yang menggunakan port 8081
lsof -i :8081
# Kill process
kill -9 <PID>
```

**Frontend (3000):**
```bash
# Cari process yang menggunakan port 3000
lsof -i :3000
# Kill process
kill -9 <PID>
```

### CORS Error
Pastikan backend sudah berjalan di `http://localhost:8081` dan frontend di `http://localhost:3000`

## 📊 Health Check

### Backend Health Check
```bash
curl http://localhost:8081/health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "POS UMKM API",
  "version": "1.0.0",
  "timestamp": "2026-01-14T06:00:00+07:00"
}
```

### Test API Endpoint
```bash
# Get all products
curl http://localhost:8081/api/products

# Login
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 🎯 Tips Penggunaan

1. **Stok Otomatis:** Saat transaksi, stok produk akan otomatis berkurang
2. **Low Stock Alert:** Bahan baku dengan stok di bawah minimum akan ditandai
3. **Search:** Gunakan search box untuk mencari produk/bahan dengan cepat
4. **Filter:** Filter transaksi berdasarkan tanggal di halaman laporan
5. **Responsive:** Aplikasi bisa digunakan di mobile dan desktop

## 📝 Default Data

Aplikasi akan membuat database baru dengan struktur tabel otomatis. Tidak ada data default, silakan tambahkan data melalui UI.

## 🆘 Butuh Bantuan?

- Cek file `README.md` untuk dokumentasi lengkap
- Cek file `FRONTEND_COMPLETION.md` untuk detail fitur frontend
- Lihat struktur API di bagian API Endpoints

---

**Selamat menggunakan POS UMKM!** 🎉
