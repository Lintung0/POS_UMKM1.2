# Fix: Upload Gambar Produk

## Masalah
Saat menambahkan produk dengan gambar, muncul error:
```
Error 1406 (22001): Data too long for column 'image' at row 1
```

## Penyebab
Kolom `image` di tabel `products` menggunakan tipe `VARCHAR(255)` yang terlalu kecil untuk menyimpan gambar dalam format base64. Gambar base64 bisa mencapai puluhan ribu karakter.

## Solusi
Mengubah tipe kolom `image` dari `VARCHAR(255)` menjadi `LONGTEXT`:

```sql
ALTER TABLE products MODIFY COLUMN image LONGTEXT;
```

## Testing
Berhasil menambahkan produk dengan gambar:
- ✅ PNG 1x1 pixel (~100 bytes base64)
- ✅ JPEG 10x10 pixel (~500 bytes base64)
- ✅ PNG 50x50 pixel (~2KB base64)

## File yang Diubah
1. `/database/fix_image_column.sql` - Migration SQL
2. `/backend/models/product.go` - Update model definition

## Cara Menjalankan Migration
```bash
mysql -h 127.0.0.1 -u root -proot pos_umkm < database/fix_image_column.sql
```

## Catatan
- LONGTEXT dapat menyimpan hingga 4GB data
- Gambar disimpan dalam format base64 (data:image/png;base64,...)
- Ukuran maksimal file gambar di frontend: 2MB (sudah ada validasi)
- Base64 encoding meningkatkan ukuran file ~33%, jadi 2MB file = ~2.7MB base64

## Tanggal Fix
11 Maret 2026
