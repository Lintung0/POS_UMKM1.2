# Setup MySQL untuk POS UMKM

## 1. Install MySQL (Jika Belum)

### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
```

### macOS:
```bash
brew install mysql
brew services start mysql
```

### Windows:
Download dari: https://dev.mysql.com/downloads/mysql/

## 2. Create Database

### Opsi 1: Menggunakan MySQL CLI
```bash
mysql -u root -p
```

Kemudian jalankan:
```sql
CREATE DATABASE pos_umkm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### Opsi 2: Menggunakan Script
```bash
mysql -u root -p < database/create_database.sql
```

## 3. Konfigurasi Database

Edit file `backend/.env`:

```env
# Database Configuration (MySQL)
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password_here
DB_NAME=pos_umkm

# Server Configuration
SERVER_PORT=8082
GIN_MODE=debug

# JWT Configuration
JWT_SECRET=MYJWTKEY12345
```

**PENTING:** Ganti `DB_PASSWORD` dengan password MySQL Anda!

## 4. Test Koneksi

```bash
mysql -u root -p -e "SHOW DATABASES;" | grep pos_umkm
```

Jika muncul `pos_umkm`, berarti database sudah dibuat.

## 5. Jalankan Backend

```bash
cd backend
go run main.go
```

Backend akan otomatis membuat tables menggunakan GORM auto-migration.

## 6. Verify Tables

```bash
mysql -u root -p pos_umkm -e "SHOW TABLES;"
```

Seharusnya muncul tables:
- products
- raw_materials
- recipes
- transactions
- transaction_details
- users

## Troubleshooting

### Error: "Access denied for user 'root'@'localhost'"

**Solusi:**
```bash
# Reset password MySQL
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_new_password';
FLUSH PRIVILEGES;
EXIT;
```

Kemudian update `DB_PASSWORD` di `.env`

### Error: "Unknown database 'pos_umkm'"

**Solusi:**
```bash
mysql -u root -p -e "CREATE DATABASE pos_umkm;"
```

### Error: "Can't connect to MySQL server"

**Solusi:**
```bash
# Cek apakah MySQL running
sudo systemctl status mysql

# Jika tidak running, start MySQL
sudo systemctl start mysql
```

### Ingin Kembali ke SQLite?

Edit `backend/.env`:
```env
DB_TYPE=sqlite
DB_NAME=pos_umkm.db
```

---

**Setelah setup selesai, jalankan:**
```bash
./run-backend.sh
```
