# Fitur Analisis Keuntungan (Profit Analysis)

## 📊 Fitur Baru yang Ditambahkan

### Backend API Endpoints
- `GET /api/profit/summary` - Ringkasan keuntungan total
- `GET /api/profit/products` - Analisis keuntungan per produk  
- `GET /api/profit/trend` - Tren keuntungan harian (7 hari terakhir)

### Frontend Components
- **Halaman Analisis Profit** (`/profit`) - Dashboard lengkap analisis keuntungan
- **Menu Sidebar** - Tambahan menu "Analisis Profit" dengan ikon TrendingUp
- **Quick Action** - Tombol akses cepat di dashboard utama

## 🎯 Fitur Utama

### 1. Ringkasan Keuntungan
- Total Pendapatan
- Total Biaya (berdasarkan cost_price produk)
- Keuntungan Bersih
- Margin Keuntungan (%)
- Jumlah Transaksi

### 2. Analisis per Produk
- Produk terlaris
- Pendapatan per produk
- Biaya per produk
- Keuntungan per produk
- Margin keuntungan per produk

### 3. Tren Harian
- Grafik keuntungan 7 hari terakhir
- Perbandingan pendapatan vs biaya
- Profit harian

## 🔧 Parameter Query

### Filter Tanggal
```
GET /api/profit/summary?start_date=2026-01-01&end_date=2026-01-31
GET /api/profit/products?start_date=2026-01-01&end_date=2026-01-31
```

## 📱 Cara Menggunakan

1. **Akses melalui Sidebar**: Klik menu "Analisis Profit"
2. **Akses melalui Dashboard**: Klik tombol "Analisis Profit" di Quick Actions
3. **Filter Periode**: Gunakan date picker untuk memilih rentang tanggal
4. **View Data**: Lihat ringkasan, tabel produk, dan tren harian

## 💡 Perhitungan

### Keuntungan per Produk
```
Keuntungan = (Selling Price - Cost Price) × Quantity Sold
Margin = (Keuntungan / Total Revenue) × 100%
```

### Total Keuntungan
```
Total Revenue = Sum of all transaction amounts
Total Cost = Sum of (Cost Price × Quantity) for all sold products  
Total Profit = Total Revenue - Total Cost
Profit Margin = (Total Profit / Total Revenue) × 100%
```

## 🎨 UI Features

- **Responsive Design** - Bekerja di desktop dan mobile
- **Real-time Data** - Data terupdate otomatis
- **Color Coding** - Hijau untuk profit, merah untuk loss
- **Currency Formatting** - Format Rupiah Indonesia
- **Date Filtering** - Filter berdasarkan periode

## 🔒 Akses

Fitur ini dapat diakses oleh:
- ✅ Admin (full access)
- ✅ Kasir (read-only)

Tidak memerlukan perubahan database schema, menggunakan data yang sudah ada.
