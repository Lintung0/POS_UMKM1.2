# 🔧 PERBAIKAN SISTEM STOK - TESTING GUIDE

## 📋 MASALAH YANG DITEMUKAN

**Issue:** Stok tidak berkurang setelah transaksi di kasir

**Root Cause:**
1. **Konflik Logika:** Validasi stok menggunakan bahan baku, tapi pengurangan stok menggunakan product.stock
2. **Missing Fields:** Backend tidak mengirim `available_stock` dan `has_recipe` ke frontend
3. **Logic Error:** Sistem tidak membedakan produk dengan resep vs tanpa resep saat pengurangan stok

---

## ✅ PERBAIKAN YANG DILAKUKAN

### 1. Backend - Transaction Controller
**File:** `backend/controllers/transaction_controller.go`

**Perubahan:**
```go
// SEBELUM: Hanya mengurangi product.stock
result := tx.Model(&product).Update("stock", gorm.Expr("stock - ?", item.Quantity))

// SESUDAH: Membedakan produk dengan/tanpa resep
if len(product.Recipes) > 0 {
    // Produk dengan resep: kurangi bahan baku
    for _, recipe := range product.Recipes {
        totalMaterialNeeded := recipe.QuantityUsed * float64(item.Quantity)
        tx.Model(&models.Material{}).
            Where("id = ? AND stock >= ?", recipe.MaterialID, totalMaterialNeeded).
            Update("stock", gorm.Expr("stock - ?", totalMaterialNeeded))
    }
} else {
    // Produk tanpa resep: kurangi stok produk jadi
    tx.Model(&product).
        Where("id = ? AND stock >= ?", product.ID, item.Quantity).
        Update("stock", gorm.Expr("stock - ?", item.Quantity))
}
```

**Logika Baru:**
- ✅ Produk **dengan resep** → kurangi **bahan baku**
- ✅ Produk **tanpa resep** → kurangi **stok produk**
- ✅ Atomic update dengan row locking
- ✅ Validasi stok sebelum pengurangan

---

### 2. Backend - Product Model
**File:** `backend/models/product.go`

**Perubahan:**
```go
type ProductResponse struct {
    // ... fields lain
    Stock          int  `json:"stock"`           // Stok produk jadi
    AvailableStock int  `json:"available_stock"` // ✅ ADDED
    HasRecipe      bool `json:"has_recipe"`      // ✅ ADDED
}
```

---

### 3. Backend - Product Controller
**File:** `backend/controllers/product_controller.go`

**Perubahan:**
```go
// GetAllProducts - sekarang mengirim available_stock dan has_recipe
productResponses = append(productResponses, models.ProductResponse{
    Stock:          product.Stock,
    AvailableStock: availableStock,  // ✅ ADDED
    HasRecipe:      hasRecipe,       // ✅ ADDED
})
```

---

## 🧪 TESTING CHECKLIST

### Persiapan Testing
- [ ] Backend running di port 8080
- [ ] Frontend running di port 3000
- [ ] Database MySQL running
- [ ] Ada data produk dengan resep (contoh: Telur Dadar)
- [ ] Ada data bahan baku (contoh: Telur, Minyak)

---

### Test Case 1: Produk DENGAN Resep (Telur Dadar)

**Setup:**
1. Buat produk "Telur Dadar" dengan resep:
   - Telur: 2 butir
   - Minyak: 10 ml
2. Pastikan stok bahan baku:
   - Telur: 100 butir
   - Minyak: 500 ml

**Test Steps:**
1. Buka halaman Kasir
2. Cek stok awal Telur Dadar (harus dihitung dari bahan baku)
   - Expected: 50 porsi (100 telur / 2 = 50)
3. Tambahkan 2 Telur Dadar ke keranjang
4. Proses pembayaran
5. Cek hasil:
   - [ ] Transaksi berhasil
   - [ ] Stok bahan baku berkurang:
     - Telur: 100 - 4 = 96 butir ✅
     - Minyak: 500 - 20 = 480 ml ✅
   - [ ] Stok Telur Dadar di kasir update otomatis
   - [ ] Available stock sekarang: 48 porsi (96/2)

**Verifikasi Database:**
```sql
-- Cek stok bahan baku
SELECT name, stock, unit FROM materials WHERE name IN ('Telur', 'Minyak');

-- Cek transaksi
SELECT * FROM transactions ORDER BY created_at DESC LIMIT 1;

-- Cek detail transaksi
SELECT * FROM transaction_details WHERE transaction_id = [last_transaction_id];
```

---

### Test Case 2: Produk TANPA Resep (Minuman Kemasan)

**Setup:**
1. Buat produk "Aqua 600ml" tanpa resep
2. Set stok: 50 botol

**Test Steps:**
1. Buka halaman Kasir
2. Cek stok awal Aqua (harus dari product.stock)
   - Expected: 50 botol
3. Tambahkan 5 Aqua ke keranjang
4. Proses pembayaran
5. Cek hasil:
   - [ ] Transaksi berhasil
   - [ ] Stok produk berkurang: 50 - 5 = 45 ✅
   - [ ] Stok di kasir update otomatis
   - [ ] Bahan baku tidak terpengaruh

**Verifikasi Database:**
```sql
-- Cek stok produk
SELECT name, stock FROM products WHERE name = 'Aqua 600ml';
```

---

### Test Case 3: Stok Tidak Cukup

**Test Steps:**
1. Produk dengan stok 2
2. Coba beli 5 unit
3. Expected:
   - [ ] Error message: "Stok tidak cukup"
   - [ ] Transaksi dibatalkan
   - [ ] Stok tidak berubah

---

### Test Case 4: Mixed Cart (Dengan & Tanpa Resep)

**Test Steps:**
1. Tambahkan ke keranjang:
   - 2x Telur Dadar (dengan resep)
   - 3x Aqua (tanpa resep)
2. Proses pembayaran
3. Expected:
   - [ ] Bahan baku Telur Dadar berkurang
   - [ ] Stok Aqua berkurang
   - [ ] Semua stok update dengan benar

---

### Test Case 5: Concurrent Transactions

**Test Steps:**
1. Buka 2 tab browser
2. Kedua tab tambahkan produk yang sama
3. Proses pembayaran bersamaan
4. Expected:
   - [ ] Salah satu transaksi berhasil
   - [ ] Transaksi lain gagal jika stok tidak cukup
   - [ ] Tidak ada race condition
   - [ ] Stok konsisten

---

### Test Case 6: Refresh & Real-time Update

**Test Steps:**
1. Buka halaman Kasir
2. Catat stok produk
3. Lakukan transaksi
4. Expected:
   - [ ] Stok di kasir update otomatis (tanpa refresh manual)
   - [ ] Stok di halaman Produk juga update
   - [ ] Available stock dihitung ulang

---

## 🔍 MONITORING & DEBUGGING

### Check Backend Logs
```bash
# Lihat log transaksi
tail -f backend/logs/app.log

# Atau jika running di terminal
# Perhatikan output saat transaksi
```

### Check Database Real-time
```sql
-- Monitor stok bahan baku
SELECT name, stock, unit, updated_at 
FROM materials 
ORDER BY updated_at DESC;

-- Monitor stok produk
SELECT name, stock, has_recipe, updated_at 
FROM products 
ORDER BY updated_at DESC;

-- Monitor transaksi
SELECT id, total_amount, created_at 
FROM transactions 
ORDER BY created_at DESC 
LIMIT 10;
```

### Check Frontend Console
```javascript
// Buka Developer Tools (F12)
// Tab Console
// Perhatikan:
// - API calls ke /api/transactions
// - Response data
// - Stock updates
```

---

## 📊 EXPECTED BEHAVIOR

### Produk DENGAN Resep:
```
Transaksi → Kurangi Bahan Baku → Update Available Stock
```

### Produk TANPA Resep:
```
Transaksi → Kurangi Product Stock → Update Stock
```

### Flow Lengkap:
```
1. User add to cart
2. User checkout
3. Backend validasi stok
4. Backend kurangi stok (bahan baku atau produk)
5. Backend simpan transaksi
6. Frontend refresh data
7. Stok update di UI
```

---

## ❌ TROUBLESHOOTING

### Stok masih tidak berkurang?
1. Cek backend logs untuk error
2. Cek database connection
3. Cek apakah transaksi di-commit
4. Cek apakah ada error di transaction_controller.go

### Stok berkurang tapi UI tidak update?
1. Cek apakah `fetchProducts()` dipanggil setelah transaksi
2. Cek network tab di browser
3. Cek response dari API `/api/products`

### Error "Stok tidak cukup" padahal stok ada?
1. Cek apakah produk punya resep
2. Cek stok bahan baku
3. Cek perhitungan `GetAvailableStock()`

---

## ✅ SUCCESS CRITERIA

Sistem dianggap berhasil jika:
- ✅ Stok berkurang setelah transaksi
- ✅ Produk dengan resep mengurangi bahan baku
- ✅ Produk tanpa resep mengurangi stok produk
- ✅ UI update otomatis tanpa refresh manual
- ✅ Tidak ada race condition
- ✅ Validasi stok berfungsi dengan benar
- ✅ Error handling yang jelas

---

**Testing Date:** 9 Maret 2026  
**Status:** Ready for Testing  
**Priority:** HIGH - Critical Business Logic
