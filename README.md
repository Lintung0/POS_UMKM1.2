# POS UMKM - Point of Sale System

Sistem Point of Sale (POS) lengkap untuk UMKM dengan fitur manajemen produk, bahan baku, transaksi, dan laporan.

## 🚀 Fitur Utama

### Frontend (React + Vite)
- ✅ **Dashboard Analytics** - Ringkasan penjualan, grafik, dan statistik
- ✅ **Kasir/POS** - Interface kasir dengan keranjang belanja dan pembayaran
- ✅ **Manajemen Produk** - CRUD produk dengan kategori dan stok
- ✅ **Manajemen Bahan Baku** - CRUD bahan baku dengan alert stok rendah
- ✅ **Manajemen Resep** - Komposisi bahan untuk setiap produk
- ✅ **Laporan** - Transaksi, laporan harian, dan bulanan
- ✅ **Pengaturan** - Konfigurasi toko, profil, notifikasi, dan keamanan
- ✅ **Authentication** - Login admin dan kasir
- ✅ **Responsive Design** - Optimized untuk desktop dan mobile

### Backend (Go + Gin + GORM)
- ✅ **RESTful API** - Endpoint lengkap untuk semua fitur
- ✅ **Database SQLite** - Database ringan dengan auto-migration
- ✅ **CORS Support** - Cross-origin resource sharing
- ✅ **Error Handling** - Response error yang konsisten
- ✅ **Logging** - Request logging dan monitoring
- ✅ **Health Check** - Endpoint untuk monitoring sistem

## 📁 Struktur Proyek

```
pos-umkm/
├── backend/                 # Go Backend
│   ├── config/             # Database configuration
│   ├── controllers/        # API controllers
│   ├── models/            # Database models
│   ├── routes/            # API routes
│   ├── utils/             # Utility functions
│   ├── main.go            # Main application
│   ├── go.mod             # Go dependencies
│   └── .env               # Environment variables
├── frontend/               # React Frontend
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── context/       # React contexts
│   │   ├── utils/         # Utility functions
│   │   ├── App.jsx        # Main app component
│   │   └── main.jsx       # Entry point
│   ├── package.json       # Dependencies
│   └── vite.config.js     # Vite configuration
└── database/              # Database schema
    └── init.sql           # Initial database setup
```

## 🛠️ Teknologi

### Backend
- **Go 1.25+** - Programming language
- **Gin** - Web framework
- **GORM** - ORM untuk database
- **SQLite** - Database
- **godotenv** - Environment variables

### Frontend
- **React 18** - UI framework
- **Vite** - Build tool
- **Tailwind CSS** - Styling
- **React Router** - Navigation
- **Axios** - HTTP client
- **Lucide React** - Icons
- **React Hot Toast** - Notifications

## 🚀 Cara Menjalankan

### Prerequisites
- Go 1.25+
- Node.js 18+
- npm atau yarn
- MySQL 8.0+

### Quick Start (Recommended)
```bash
# Start semua services
./start.sh

# Test semua endpoint
./test.sh

# Stop semua services
./stop.sh
```

### Manual Start

#### Backend
```bash
cd backend
go mod tidy
go run main.go
```
Server akan berjalan di `http://localhost:8082`

#### Frontend
```bash
cd frontend
npm install
npm run dev
```
Frontend akan berjalan di `http://localhost:3000` (atau port lain jika sudah digunakan)

## 🔐 Login Credentials

### Admin
- Username: `admin`
- Password: `admin123`
- Akses: Semua fitur

### Kasir
- Username: `kasir`
- Password: `kasir123`
- Akses: Dashboard dan Kasir

## 📊 API Endpoints

### Authentication
- `POST /api/auth/login` - Login user

### Products
- `GET /api/products` - Get all products
- `GET /api/products/:id` - Get product by ID
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product
- `GET /api/products/:id/recipes` - Get product recipes

### Materials
- `GET /api/materials` - Get all materials
- `GET /api/materials/low-stock` - Get low stock materials
- `POST /api/materials` - Create material
- `PUT /api/materials/:id` - Update material

### Recipes
- `GET /api/recipes/product/:product_id` - Get recipes by product
- `POST /api/recipes` - Save recipes
- `DELETE /api/recipes/:id` - Delete recipe

### Transactions
- `GET /api/transactions` - Get all transactions
- `GET /api/transactions/:id` - Get transaction by ID
- `POST /api/transactions` - Create transaction
- `GET /api/transactions/:id/receipt` - Get receipt
- `GET /api/transactions/report/daily` - Daily report
- `GET /api/transactions/report/monthly` - Monthly report

### Dashboard
- `GET /api/dashboard/summary` - Dashboard summary
- `GET /api/dashboard/top-products` - Top selling products
- `GET /api/dashboard/sales-trend` - Sales trend

## 🗄️ Database Schema

### Products
- id, name, category, price, cost, stock, description

### RawMaterials
- id, name, unit, stock, min_stock, cost_per_unit

### Recipes
- id, product_id, material_id, quantity

### Transactions
- id, customer_name, total_amount, payment_method, created_at

### TransactionDetails
- id, transaction_id, product_name, quantity, price, subtotal

### Users
- id, username, password, name, role

## 🎯 Fitur Unggulan

1. **Real-time Stock Management** - Stok otomatis berkurang saat transaksi
2. **Recipe Management** - Kelola komposisi bahan untuk setiap produk
3. **Low Stock Alerts** - Peringatan otomatis untuk stok rendah
4. **Comprehensive Reports** - Laporan harian, bulanan, dan per transaksi
5. **Multi-role Access** - Admin dan kasir dengan hak akses berbeda
6. **Responsive Design** - Dapat digunakan di desktop dan mobile
7. **Print Receipt** - Cetak struk transaksi
8. **Dashboard Analytics** - Visualisasi data penjualan

## 🔧 Konfigurasi

### Environment Variables (.env)
```env
DB_TYPE=sqlite
DB_NAME=pos_umkm.db
SERVER_PORT=8081
GIN_MODE=debug
JWT_SECRET=MYJWTKEY12345
```

## 📝 Development Notes

- Database menggunakan auto-migration GORM
- Frontend menggunakan Context API untuk state management
- API menggunakan JSON response format yang konsisten
- Error handling terintegrasi dengan toast notifications
- Build production ready dengan optimasi Vite

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 📄 License

MIT License - Bebas digunakan untuk keperluan komersial dan non-komersial.

---

**POS UMKM** - Solusi lengkap untuk manajemen toko UMKM modern 🏪
