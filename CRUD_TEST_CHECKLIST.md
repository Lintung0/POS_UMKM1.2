# 🧪 CRUD OPERATIONS TEST CHECKLIST

## ✅ TESTING SEMUA CRUD

### 1. PRODUCTS (Produk)
- [ ] **CREATE** - Tambah produk baru
  - Buka /produk
  - Klik "Tambah Produk"
  - Isi form
  - Simpan
  - Expected: Produk muncul di list

- [ ] **READ** - Lihat list produk
  - Buka /produk
  - Expected: List produk tampil

- [ ] **UPDATE** - Edit produk
  - Klik icon edit
  - Ubah data
  - Simpan
  - Expected: Data berubah

- [ ] **DELETE** - Hapus produk
  - Klik icon delete
  - Konfirmasi
  - Expected: Produk terhapus
  - ⚠️ Jika error: Produk mungkin punya resep atau transaksi

---

### 2. MATERIALS (Bahan Baku)
- [ ] **CREATE** - Tambah bahan baku
  - Buka /bahan-baku
  - Klik "Tambah Bahan Baku"
  - Isi form
  - Simpan
  - Expected: Bahan baku muncul di list

- [ ] **READ** - Lihat list bahan baku
  - Buka /bahan-baku
  - Expected: List bahan baku tampil

- [ ] **UPDATE** - Edit bahan baku
  - Klik icon edit
  - Ubah data
  - Simpan
  - Expected: Data berubah

- [ ] **DELETE** - Hapus bahan baku
  - Klik icon delete
  - Konfirmasi
  - Expected: Bahan baku terhapus
  - ⚠️ Jika error: Bahan baku digunakan di resep

- [ ] **RESTOCK** - Tambah stok
  - Klik "Restock"
  - Masukkan jumlah
  - Simpan
  - Expected: Stok bertambah

---

### 3. RECIPES (Resep)
- [ ] **CREATE** - Tambah resep
  - Buka /produk
  - Klik icon resep pada produk
  - Tambah bahan baku
  - Simpan
  - Expected: Resep tersimpan

- [ ] **READ** - Lihat resep produk
  - Klik icon resep
  - Expected: List resep tampil

- [ ] **DELETE** - Hapus resep
  - Klik icon delete pada resep
  - Expected: Resep terhapus

---

### 4. EXPENSES (Pengeluaran)
- [ ] **CREATE** - Tambah pengeluaran
  - Buka /pengeluaran
  - Klik "Tambah Pengeluaran"
  - Isi form
  - Simpan
  - Expected: Pengeluaran muncul di list

- [ ] **READ** - Lihat list pengeluaran
  - Buka /pengeluaran
  - Expected: List pengeluaran tampil

- [ ] **UPDATE** - Edit pengeluaran
  - Klik icon edit
  - Ubah data
  - Simpan
  - Expected: Data berubah

- [ ] **DELETE** - Hapus pengeluaran
  - Klik icon delete
  - Konfirmasi
  - Expected: Pengeluaran terhapus

---

### 5. TRANSACTIONS (Transaksi)
- [ ] **CREATE** - Buat transaksi
  - Buka /kasir
  - Tambah produk ke cart
  - Proses pembayaran
  - Expected: Transaksi berhasil, stok berkurang

- [ ] **READ** - Lihat transaksi
  - Buka /laporan
  - Expected: List transaksi tampil

---

## 🐛 COMMON ERRORS & SOLUTIONS

### Error: Redirect ke Login saat Delete
**Penyebab:** 
- Token expired
- User bukan admin
- Interceptor terlalu agresif

**Solusi:**
✅ Sudah diperbaiki di api.js
- Interceptor sekarang cek error message
- Hanya redirect jika benar-benar auth error

### Error: "Tidak dapat dihapus karena masih digunakan"
**Penyebab:**
- Foreign key constraint
- Data masih digunakan di tabel lain

**Contoh:**
- Bahan baku digunakan di resep → Hapus resep dulu
- Produk punya transaksi → Tidak bisa dihapus

**Solusi:**
- Hapus data terkait terlebih dahulu
- Atau gunakan soft delete

### Error: "Unauthorized" atau "Forbidden"
**Penyebab:**
- User bukan admin
- Token tidak valid

**Solusi:**
- Login ulang
- Pastikan user role = admin

---

## 🔍 DEBUGGING TIPS

### Cek Console Browser (F12)
```javascript
// Cek token
localStorage.getItem('token')

// Cek user
JSON.parse(localStorage.getItem('user'))

// Cek role
JSON.parse(localStorage.getItem('user')).role
```

### Cek Backend Log
```bash
# Terminal backend akan show error
# Perhatikan status code:
# 401 = Unauthorized (auth error)
# 403 = Forbidden (not admin)
# 400 = Bad Request (constraint error)
# 500 = Server Error
```

### Test dengan cURL
```bash
# Get token dari localStorage
TOKEN="your_token_here"

# Test delete material
curl -X DELETE \
  http://localhost:8080/api/materials/1 \
  -H "Authorization: Bearer $TOKEN"

# Expected response:
# Success: {"success": true, "message": "..."}
# Error: {"success": false, "message": "..."}
```

---

## ✅ EXPECTED BEHAVIOR

### DELETE Success
```
1. User klik delete
2. Konfirmasi muncul
3. User klik OK
4. Loading indicator
5. Toast success: "Data berhasil dihapus"
6. Data hilang dari list
7. Page tetap di halaman yang sama ✅
```

### DELETE Failed (Constraint)
```
1. User klik delete
2. Konfirmasi muncul
3. User klik OK
4. Loading indicator
5. Toast error: "Tidak dapat dihapus karena masih digunakan"
6. Data tetap ada
7. Page tetap di halaman yang sama ✅
```

### DELETE Failed (Auth)
```
1. User klik delete
2. Konfirmasi muncul
3. User klik OK
4. Loading indicator
5. Redirect ke /login ❌ (SEHARUSNYA TIDAK)
```

**SETELAH FIX:**
```
1. User klik delete
2. Konfirmasi muncul
3. User klik OK
4. Loading indicator
5. Toast error: "Unauthorized" atau "Forbidden"
6. Page tetap di halaman yang sama ✅
```

---

## 📊 TEST MATRIX

| Operation | Products | Materials | Recipes | Expenses | Transactions |
|-----------|----------|-----------|---------|----------|--------------|
| CREATE    | ✅       | ✅        | ✅      | ✅       | ✅           |
| READ      | ✅       | ✅        | ✅      | ✅       | ✅           |
| UPDATE    | ✅       | ✅        | ❌      | ✅       | ❌           |
| DELETE    | ✅       | ✅        | ✅      | ✅       | ❌           |

Note: 
- Recipes tidak punya UPDATE (delete & create ulang)
- Transactions tidak bisa UPDATE/DELETE (audit trail)

---

## 🚀 QUICK TEST

```bash
# 1. Login sebagai admin
# 2. Test setiap CRUD operation
# 3. Cek console untuk error
# 4. Cek backend log
# 5. Verifikasi database

# Jika ada error:
# - Screenshot error message
# - Copy console log
# - Copy backend log
# - Kirim untuk debugging
```

---

**Created:** 9 Maret 2026  
**Status:** Ready for Testing  
**Priority:** HIGH
