# Database Relations Fix - POS UMKM

## Perubahan yang Telah Dibuat

### 1. Model RawMaterial (`backend/models/material.go`)
```go
type RawMaterial struct {
    // ... fields lainnya
    Recipes []Recipe `gorm:"foreignKey:MaterialID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"recipes,omitempty"`
}
```
**Perubahan:** Ditambahkan relasi Has Many ke Recipe dengan constraint CASCADE.

### 2. Model Product (`backend/models/product.go`)
```go
type Product struct {
    // ... fields lainnya
    Recipes            []Recipe            `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"recipes,omitempty"`
    TransactionDetails []TransactionDetail `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"transaction_details,omitempty"`
}
```
**Perubahan:** 
- Ditambahkan constraint CASCADE untuk relasi ke Recipe
- Ditambahkan relasi Has Many ke TransactionDetail dengan constraint RESTRICT

### 3. Model Recipe (`backend/models/recipe.go`)
```go
type Recipe struct {
    ID           uint        `gorm:"primaryKey" json:"id"`
    ProductID    uint        `gorm:"not null;index" json:"product_id"`
    MaterialID   uint        `gorm:"not null;index" json:"material_id"`
    // ... fields lainnya
    Product      Product     `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"product,omitempty"`
    Material     RawMaterial `gorm:"foreignKey:MaterialID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"material,omitempty"`
}
```
**Perubahan:**
- Ditambahkan index pada ProductID dan MaterialID
- Ditambahkan constraint CASCADE untuk kedua foreign key
- Menghapus pointer (*) pada relasi Product dan Material
- Memindahkan constraint dari field definition ke relasi definition

### 4. Model Transaction & TransactionDetail (`backend/models/transaction.go`)
```go
type Transaction struct {
    // ... fields lainnya
    Details []TransactionDetail `gorm:"foreignKey:TransactionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"details,omitempty"`
}

type TransactionDetail struct {
    ID            uint        `gorm:"primaryKey" json:"id"`
    TransactionID uint        `gorm:"not null;index" json:"transaction_id"`
    ProductID     uint        `gorm:"not null;index" json:"product_id"`
    // ... fields lainnya
    Transaction   Transaction `gorm:"foreignKey:TransactionID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE" json:"transaction,omitempty"`
    Product       Product     `gorm:"foreignKey:ProductID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT" json:"product,omitempty"`
}
```
**Perubahan:**
- Ditambahkan index pada TransactionID dan ProductID
- Ditambahkan constraint CASCADE untuk Transaction relation
- Ditambahkan constraint RESTRICT untuk Product relation (mencegah penghapusan product yang masih ada di transaksi)
- Menghapus pointer (*) pada relasi

## Keuntungan Perubahan

### 1. Foreign Key Constraints Otomatis
- GORM akan membuat foreign key constraints fisik di MySQL
- Data integrity terjamin di level database

### 2. Cascade Operations
- Ketika Product dihapus, Recipe terkait akan ikut terhapus
- Ketika RawMaterial dihapus, Recipe terkait akan ikut terhapus
- Ketika Transaction dihapus, TransactionDetail terkait akan ikut terhapus

### 3. Data Protection
- Product tidak bisa dihapus jika masih ada di TransactionDetail (RESTRICT)
- Mencegah data inconsistency

### 4. Performance Optimization
- Index pada foreign key fields untuk query yang lebih cepat
- Relasi yang lebih efisien tanpa pointer overhead

## Cara Menjalankan

1. **Jalankan aplikasi:**
   ```bash
   cd backend
   go run main.go
   ```

2. **AutoMigrate akan otomatis:**
   - Membuat tabel dengan foreign key constraints
   - Menambahkan index pada foreign key fields
   - Mengatur cascade dan restrict rules

3. **Verifikasi di MySQL:**
   ```sql
   SHOW CREATE TABLE recipes;
   SHOW CREATE TABLE transaction_details;
   ```

## Fitur yang Sekarang Berfungsi

### ✅ Recipe Mapping
- Setiap Product bisa memiliki multiple Recipe
- Setiap Recipe terhubung ke RawMaterial dan Product
- Foreign key constraints memastikan data consistency

### ✅ Stock Bahan Baku
- RawMaterial terhubung ke Recipe
- Bisa tracking penggunaan bahan baku per produk
- Cascade delete memastikan data cleanup

### ✅ Transaction Management
- TransactionDetail terhubung ke Product dan Transaction
- RESTRICT constraint mencegah penghapusan Product yang masih digunakan
- Data integrity terjamin

## Testing

Untuk testing relasi database, jalankan:
```bash
./test_db_relations.sh
```

Atau jalankan aplikasi utama dan cek log migration untuk memastikan semua tabel dan constraint terbuat dengan benar.
