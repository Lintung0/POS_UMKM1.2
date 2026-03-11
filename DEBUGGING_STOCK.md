# 🔧 DEBUGGING GUIDE - STOK TIDAK BERKURANG

## 🎯 LANGKAH-LANGKAH DEBUGGING

### 1. CEK DATABASE - Apakah produk punya resep?

```bash
cd /home/kirek/code/POS_UMKM-master
./verify-stock.sh
```

**Yang harus dicek:**
- Apakah produk punya `has_recipe = 1`?
- Apakah ada data di tabel `recipes`?
- Apakah `recipe_count > 0`?

**Jika has_recipe = 0 padahal ada resep:**
```bash
./fix-has-recipe.sh
```

---

### 2. CEK BACKEND LOG - Apakah kode dijalankan?

**Restart backend dengan mode verbose:**
```bash
cd backend
go run main.go
```

**Saat transaksi, perhatikan log:**
```
DEBUG: Product ID=1, Name=Telur Dadar, HasRecipe=true, RecipeCount=2
DEBUG: Mengurangi bahan baku untuk produk Telur Dadar
DEBUG: Material ID=1, Name=Telur, CurrentStock=100.00, Needed=4.00
DEBUG: Berhasil kurangi material Telur sebanyak 4.00
```

**Jika tidak ada log DEBUG:**
- Produk tidak punya resep
- Atau `HasRecipe = false`

---

### 3. TEST MANUAL DI DATABASE

**Cek produk Telur Dadar:**
```sql
SELECT * FROM products WHERE name LIKE '%Telur%';
```

Expected:
```
id | name        | has_recipe | stock
1  | Telur Dadar | 1          | 0
```

**Cek resep Telur Dadar:**
```sql
SELECT 
    r.*,
    p.name AS produk,
    m.name AS bahan
FROM recipes r
JOIN products p ON r.product_id = p.id
JOIN materials m ON r.material_id = m.id
WHERE p.name LIKE '%Telur%';
```

Expected:
```
product_id | material_id | quantity_used | produk      | bahan
1          | 1           | 2.00          | Telur Dadar | Telur
1          | 2           | 10.00         | Telur Dadar | Minyak
```

**Cek stok bahan baku SEBELUM transaksi:**
```sql
SELECT name, stock, unit FROM materials;
```

Catat angkanya!

---

### 4. LAKUKAN TRANSAKSI

1. Buka kasir: http://localhost:3000/kasir
2. Tambah "Telur Dadar" 2 porsi
3. Proses pembayaran
4. **PERHATIKAN TERMINAL BACKEND** untuk log DEBUG

---

### 5. CEK HASIL SETELAH TRANSAKSI

**Cek stok bahan baku SESUDAH:**
```sql
SELECT name, stock, unit, updated_at FROM materials ORDER BY updated_at DESC;
```

**Expected:**
- Telur: 100 - 4 = 96 ✅
- Minyak: 500 - 20 = 480 ✅
- `updated_at` harus berubah!

**Jika stok TIDAK berkurang:**
- Cek log backend untuk error
- Cek apakah transaksi di-commit
- Cek apakah ada rollback

---

## 🐛 KEMUNGKINAN MASALAH

### Masalah 1: has_recipe = 0 padahal ada resep

**Solusi:**
```bash
./fix-has-recipe.sh
```

### Masalah 2: Recipes tidak ter-load

**Cek di backend log:**
```
DEBUG: Product ID=1, Name=Telur Dadar, HasRecipe=true, RecipeCount=0
```

Jika `RecipeCount=0` padahal ada resep di database:
- Ada masalah di Preload
- Cek foreign key relationship

**Fix:**
```sql
-- Cek foreign key
SELECT 
    r.id,
    r.product_id,
    r.material_id,
    p.name AS produk,
    m.name AS bahan
FROM recipes r
LEFT JOIN products p ON r.product_id = p.id
LEFT JOIN materials m ON r.material_id = m.id;
```

### Masalah 3: Material stock tidak update

**Cek di backend log:**
```
DEBUG: Berhasil kurangi material Telur sebanyak 4.00
```

Jika ada log ini tapi stok tidak berkurang:
- Transaksi di-rollback setelahnya
- Cek error setelah log ini

**Cek transaksi database:**
```sql
-- Cek apakah transaksi berhasil disimpan
SELECT * FROM transactions ORDER BY created_at DESC LIMIT 1;

-- Cek detail transaksi
SELECT * FROM transaction_details WHERE transaction_id = [last_id];
```

Jika transaksi TIDAK ada di database:
- Transaksi di-rollback
- Cek error di backend log

---

## ✅ CHECKLIST DEBUGGING

- [ ] Jalankan `./verify-stock.sh` - cek struktur data
- [ ] Jalankan `./fix-has-recipe.sh` - fix flag has_recipe
- [ ] Restart backend - lihat log
- [ ] Catat stok bahan baku SEBELUM transaksi
- [ ] Lakukan transaksi di kasir
- [ ] Perhatikan log DEBUG di terminal backend
- [ ] Cek stok bahan baku SESUDAH transaksi
- [ ] Bandingkan SEBELUM vs SESUDAH

---

## 🔍 QUERY DEBUGGING LENGKAP

```sql
-- 1. Cek produk dengan resep
SELECT 
    p.id,
    p.name,
    p.has_recipe,
    p.stock AS stok_produk,
    COUNT(r.id) AS jumlah_resep
FROM products p
LEFT JOIN recipes r ON p.id = r.product_id
GROUP BY p.id
HAVING jumlah_resep > 0;

-- 2. Cek resep detail dengan stok bahan
SELECT 
    p.name AS produk,
    m.name AS bahan,
    r.quantity_used AS per_porsi,
    m.stock AS stok_bahan,
    m.unit,
    FLOOR(m.stock / r.quantity_used) AS bisa_buat_porsi
FROM recipes r
JOIN products p ON r.product_id = p.id
JOIN materials m ON r.material_id = m.id;

-- 3. Cek transaksi terakhir dengan detail
SELECT 
    t.id,
    t.created_at,
    t.total_amount,
    td.product_name,
    td.qty,
    td.total_price
FROM transactions t
JOIN transaction_details td ON t.id = td.transaction_id
ORDER BY t.created_at DESC
LIMIT 10;

-- 4. Cek history update material (jika ada trigger/log)
SELECT 
    name,
    stock,
    updated_at
FROM materials
ORDER BY updated_at DESC;
```

---

## 🚀 QUICK FIX

Jika masih tidak berfungsi setelah semua langkah di atas:

```bash
# 1. Fix database
cd /home/kirek/code/POS_UMKM-master
./fix-has-recipe.sh

# 2. Restart backend
cd backend
# Ctrl+C untuk stop
go run main.go

# 3. Restart frontend
cd frontend
# Ctrl+C untuk stop
npm run dev

# 4. Clear browser cache
# Tekan Ctrl+Shift+R di browser

# 5. Test lagi
```

---

## 📞 JIKA MASIH GAGAL

Kirim informasi ini:
1. Output dari `./verify-stock.sh`
2. Log dari terminal backend saat transaksi
3. Screenshot error (jika ada)
4. Query result dari SQL debugging

---

**Created:** 9 Maret 2026  
**Status:** Ready for Debugging
