# POS UMKM — Panduan Integrasi & Dokumentasi API

Dokumentasi ini menjelaskan secara rinci endpoint API, parameter request, format data payload, dan response JSON yang dapat digunakan untuk melakukan operasi CRUD (Create, Read, Update, Delete) dari aplikasi Desktop C#.

---

## 🔐 1. Endpoint Autentikasi (Login)

### Login Pengguna
Menerima payload berupa JSON atau Form-Urlencoded.

* **URL:** `POST /api/login`
* **Auth Required:** No
* **Request Body (`application/json` atau `application/x-www-form-urlencoded`):**
```json
{
  "username": "admin",
  "password": "password123"
}
```

* **Response (Success - 200 OK):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "id": 1,
    "username": "admin",
    "name": "Administrator",
    "role": "admin",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

* **Response (Failure - 401 Unauthorized):**
```json
{
  "success": false,
  "message": "Username atau password salah",
  "error": null
}
```

> 💡 **Informasi Autentikasi:**
> Untuk semua endpoint yang bertanda 🔐 **Auth Required**, Anda harus menyertakan JWT token di header request:
> `Authorization: Bearer <token>`

---

## 📦 2. Manajemen Produk (CRUD `/api/products`)

Representasi Model Data Produk:
* **`id`** (Integer) — ID unik produk
* **`name`** (String) — Nama produk
* **`cost_price`** (Double) — Harga modal/pokok
* **`selling_price`** (Double) — Harga jual ke konsumen
* **`stock`** (Integer) — Stok fisik produk (untuk produk tanpa resep)
* **`category`** (String) — Kategori (contoh: "Minuman", "Makanan", "Snack")
* **`image`** (String) — Base64 string gambar produk (opsional)
* **`has_recipe`** (Boolean) — `true` jika produk dibuat dari bahan baku (stok dihitung otomatis dari resep)

### A. List Semua Produk
* **URL:** `GET /api/products`
* **Auth Required:** No
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Kopi Susu Premium",
      "cost_price": 8000,
      "selling_price": 15000,
      "stock": 50,
      "category": "Minuman",
      "image": "data:image/png;base64,...",
      "has_recipe": false,
      "created_at": "2026-05-21T07:06:03Z",
      "updated_at": "2026-05-21T07:06:03Z"
    }
  ]
}
```

### B. Detail Produk Tunggal
* **URL:** `GET /api/products/:id`
* **Auth Required:** No
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": {
    "id": 1,
    "name": "Kopi Susu Premium",
    "cost_price": 8000,
    "selling_price": 15000,
    "stock": 50,
    "category": "Minuman",
    "image": "...",
    "has_recipe": false
  }
}
```

### C. Tambah Produk Baru
* **URL:** `POST /api/products`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:**
```json
{
  "name": "Es Teh Manis",
  "cost_price": 1500,
  "selling_price": 5000,
  "stock": 100,
  "category": "Minuman",
  "image": ""
}
```
* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Produk berhasil ditambahkan",
  "data": {
    "id": 6,
    "name": "Es Teh Manis",
    "cost_price": 1500,
    "selling_price": 5000,
    "stock": 100,
    "category": "Minuman",
    "image": "",
    "has_recipe": false,
    "created_at": "2026-05-21T07:15:00Z",
    "updated_at": "2026-05-21T07:15:00Z"
  }
}
```

### D. Update Data Produk
* **URL:** `PUT /api/products/:id`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:**
```json
{
  "name": "Es Teh Manis Jumbo",
  "cost_price": 2000,
  "selling_price": 6000,
  "stock": 80,
  "category": "Minuman",
  "image": ""
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Produk berhasil diperbarui",
  "data": {
    "id": 6,
    "name": "Es Teh Manis Jumbo",
    "cost_price": 2000,
    "selling_price": 6000,
    "stock": 80,
    "category": "Minuman",
    "image": ""
  }
}
```

### E. Hapus Produk
* **URL:** `DELETE /api/products/:id`
* **Auth Required:** Yes (🔐 Admin Only)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Produk berhasil dihapus",
  "data": null
}
```

---

## 🌾 3. Manajemen Bahan Baku (CRUD `/api/materials`)

Representasi Model Data Bahan Baku:
* **`id`** (Integer) — ID unik bahan baku
* **`name`** (String) — Nama bahan baku
* **`stock`** (Double) — Jumlah stok bahan baku
* **`unit`** (String) — Satuan ukur (contoh: "gram", "ml", "pcs")
* **`price_per_unit`** (Double) — Harga beli per satuan unit
* **`min_stock`** (Double) — Batas minimum stok sebelum ditandai kritis
* **`supplier`** (String) — Nama supplier bahan

### A. List Bahan Baku
* **URL:** `GET /api/materials`
* **Auth Required:** No
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Biji Kopi Arabica",
      "stock": 5000,
      "unit": "gram",
      "price_per_unit": 30,
      "min_stock": 500,
      "supplier": "Supplier Kopi Lokal"
    }
  ]
}
```

### B. Tambah Bahan Baku Baru
* **URL:** `POST /api/materials`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:**
```json
{
  "name": "Sirup Vanila",
  "stock": 1000,
  "unit": "ml",
  "cost_per_unit": 50,
  "min_stock": 100,
  "supplier": "Distributor Sirup"
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Bahan baku berhasil ditambahkan",
  "data": {
    "id": 6,
    "name": "Sirup Vanila",
    "stock": 1000,
    "unit": "ml",
    "price_per_unit": 50,
    "min_stock": 100,
    "supplier": "Distributor Sirup"
  }
}
```

### C. Update Bahan Baku
* **URL:** `PUT /api/materials/:id`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:** (Sama seperti payload POST)
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Bahan baku berhasil diperbarui",
  "data": { ... }
}
```

### D. Restock Bahan Baku (Tambah Stok Tambahan)
* **URL:** `POST /api/materials/:id/restock`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:**
```json
{
  "added_stock": 500,
  "cost_per_unit": 45
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Restock bahan baku berhasil",
  "data": {
    "id": 6,
    "name": "Sirup Vanila",
    "stock": 1500,
    "price_per_unit": 45
  }
}
```

### E. Hapus Bahan Baku
* **URL:** `DELETE /api/materials/:id`
* **Auth Required:** Yes (🔐 Admin Only)

---

## 🧾 4. Transaksi Kasir (CRUD / Create Transaksi `/api/transactions`)

Endpoint ini digunakan untuk memproses pesanan dan mencatat penjualan. Transaksi akan mengurangi stok produk (jika non-resep) atau mengurangi stok bahan baku (jika produk menggunakan resep) secara otomatis.

### A. Buat Transaksi Penjualan Baru
* **URL:** `POST /api/transactions`
* **Auth Required:** No (Bisa diakses dari POS kasir mana saja)
* **Request Body:**
```json
{
  "cash_received": 50000,
  "payment_method": "CASH",
  "cashier_name": "Kasir Budi",
  "notes": "Pesanan meja nomor 5",
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 2,
      "quantity": 1
    }
  ]
}
```

* **Response (201 Created):**
```json
{
  "success": true,
  "message": "Transaksi berhasil disimpan",
  "data": {
    "id": 101,
    "total_amount": 42000,
    "total_profit": 21000,
    "cash_received": 50000,
    "change_amount": 8000,
    "payment_method": "CASH",
    "cashier_name": "Kasir Budi",
    "notes": "Pesanan meja nomor 5",
    "created_at": "2026-05-21T07:20:00Z"
  }
}
```

### B. Ambil List Semua Riwayat Transaksi
* **URL:** `GET /api/transactions`
* **Auth Required:** No

### C. Ambil Struk / Kertas Kasir (Format Cetak HTML)
Berguna jika printer desktop ingin mencetak layout struk belanja secara langsung.
* **URL:** `GET /api/transactions/:id/receipt/print`
* **Auth Required:** No
* **Response:** Text HTML siap cetak (`text/html`).

---

## 💸 5. Manajemen Pengeluaran Operasional (CRUD `/api/expenses`)

Mencatat biaya-biaya di luar bahan baku (seperti sewa ruko, listrik, gaji karyawan).

### A. Tambah Pengeluaran Baru
* **URL:** `POST /api/expenses`
* **Auth Required:** Yes (🔐 Auth Required)
* **Request Body:**
```json
{
  "date": "2026-05-21",
  "category": "Operasional",
  "description": "Pembayaran tagihan listrik ruko",
  "amount": 350000
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Pengeluaran berhasil disimpan",
  "data": {
    "id": 12,
    "date": "2026-05-21T00:00:00Z",
    "category": "Operasional",
    "description": "Pembayaran tagihan listrik ruko",
    "amount": 350000,
    "created_by": "admin"
  }
}
```

### B. List Pengeluaran
* **URL:** `GET /api/expenses`
* **Auth Required:** No

### C. Ringkasan Pengeluaran
* **URL:** `GET /api/expenses/summary`
* **Auth Required:** No
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": {
    "total_amount": 1250000,
    "by_category": {
      "Operasional": 350000,
      "Gaji": 900000
    },
    "count": 5
  }
}
```

---

## 🍳 6. Manajemen Resep / Formula Produk (CRUD `/api/recipes`)

### Simpan atau Update Resep Produk
Menghubungkan produk dengan bahan baku serta kuantitas pemakaian.
* **URL:** `POST /api/recipes`
* **Auth Required:** Yes (🔐 Admin Only)
* **Request Body:**
```json
{
  "product_id": 1,
  "recipes": [
    {
      "material_id": 1,
      "quantity_used": 15.5,
      "notes": "15.5 gram biji kopi"
    },
    {
      "material_id": 2,
      "quantity_used": 120,
      "notes": "120 ml susu UHT"
    }
  ]
}
```
* **Response (200 OK):**
```json
{
  "success": true,
  "message": "Resep berhasil disimpan",
  "data": null
}
```
