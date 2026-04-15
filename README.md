# 🏪 POS UMKM - Point of Sale System

Sistem Point of Sale (POS) lengkap untuk UMKM dengan fitur manajemen produk, bahan baku, transaksi, dan laporan.

[![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)]()
[![Go Version](https://img.shields.io/badge/go-1.21+-blue)]()
[![React](https://img.shields.io/badge/react-18-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()

---

## 📁 Project Structure

```
POS_UMKM-master/
├── backend/              # Go Backend API
│   ├── config/          # Database configuration
│   ├── controllers/     # API controllers
│   ├── middleware/      # Auth & rate limiting
│   ├── models/          # Database models
│   ├── routes/          # API routes
│   ├── utils/           # Utilities (JWT, validation, logging)
│   └── main.go          # Entry point
├── frontend/            # React Frontend
│   ├── src/
│   │   ├── components/  # Reusable components
│   │   ├── pages/       # Page components
│   │   ├── context/     # React contexts
│   │   └── utils/       # Frontend utilities
│   └── package.json
├── database/            # SQL schemas & seeds
├── docs/                # Documentation
│   ├── analysis/        # System analysis
│   ├── database/        # Database docs
│   ├── features/        # Feature docs
│   ├── fixes/           # Bug fix reports
│   ├── implementation/  # Implementation docs
│   └── reports/         # Various reports
├── scripts/             # Utility scripts
│   ├── database/        # Database scripts
│   ├── maintenance/     # Maintenance scripts
│   ├── tests/           # Test scripts
│   ├── start-all.sh     # Start all services
│   └── stop.sh          # Stop all services
├── logs/                # Application logs
└── backups/             # Database backups
```

---

## 🚀 Quick Start

### Prerequisites
- Go 1.21+
- Node.js 18+
- MySQL 8.0+ (Docker)

### 1. Start All Services
```bash
./scripts/start-all.sh
```

### 2. Access Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **Health Check**: http://localhost:8080/health

### 3. Login
**Admin:**
- Username: `admin`
- Password: `admin123`

**Kasir:**
- Username: `kasir`
- Password: `kasir123`

---

## ✨ Features

### Core Features
- ✅ **Dashboard Analytics** - Real-time sales & profit tracking
- ✅ **POS/Kasir** - Fast checkout with cart management
- ✅ **Product Management** - CRUD with categories & stock
- ✅ **Material Management** - Raw materials with low stock alerts
- ✅ **Recipe Management** - Link products to materials
- ✅ **Transaction Management** - Complete sales tracking
- ✅ **Reports** - Daily, monthly, and custom reports
- ✅ **Profit Analysis** - Detailed profit breakdown
- ✅ **Production** - Produce products from materials
- ✅ **Expenses Tracking** - Record and categorize expenses
- ✅ **Settings** - Store configuration
- ✅ **Multi-user** - Admin & Cashier roles

### Technical Features
- ✅ **Authentication** - JWT with bcrypt password hashing
- ✅ **Authorization** - Role-based access control
- ✅ **Input Validation** - Comprehensive sanitization
- ✅ **Audit Logging** - Track all user actions
- ✅ **Rate Limiting** - Prevent abuse
- ✅ **CORS** - Secure cross-origin requests
- ✅ **Database Backups** - Automated backup system
- ✅ **Error Handling** - Standardized error messages
- ✅ **Performance** - Optimized with indexes (67% faster)

---

## 📚 Documentation

### Getting Started
- [Quick Start Guide](docs/QUICK_START_GUIDE.md)
- [How to Run](docs/HOW_TO_RUN.md)
- [Login Credentials](docs/LOGIN_CREDENTIALS.md)

### Features
- [Dark Mode](docs/features/DARK_MODE_IMPLEMENTATION.md)
- [Profit Analysis](docs/PROFIT_ANALYSIS.md)

### Database
- [Database Relations](docs/database/DATABASE_RELATIONS.md)
- [Database Fixes](docs/DATABASE_FIXES.md)
- [Setup MySQL](docs/SETUP_MYSQL.md)

### Reports
- [Improvements Report](docs/reports/IMPROVEMENTS.md)
- [Production Readiness](docs/reports/PRODUCTION_READINESS_REPORT.md)
- [Security Changelog](docs/SECURITY_CHANGELOG.md)

### Troubleshooting
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- [Bug Fixes](docs/BUG_FIXES.md)

---

## 🛠️ Development

### Backend
```bash
cd backend
go mod tidy
go run main.go
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

### Database Backup
```bash
./scripts/maintenance/backup_database.sh
```

### Database Restore
```bash
./scripts/maintenance/restore_database.sh backups/pos_umkm_backup_*.sql.gz
```

### Run Tests
```bash
./scripts/tests/comprehensive_test_brutal.sh
```

---

## 🔧 Configuration

### Backend (.env)
```env
DB_TYPE=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=pos_umkm
DB_USER=root
DB_PASSWORD=root
SERVER_PORT=8080
JWT_SECRET=your-secret-key
```

### Frontend (vite.config.js)
```javascript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

---

## 📊 API Endpoints

### Authentication
- `POST /api/auth/login` - Login

### Products
- `GET /api/products` - List products
- `POST /api/products` - Create product (Admin)
- `PUT /api/products/:id` - Update product (Admin)
- `DELETE /api/products/:id` - Delete product (Admin)

### Transactions
- `GET /api/transactions` - List transactions
- `POST /api/transactions` - Create transaction
- `GET /api/transactions/:id/receipt` - Get receipt

### Dashboard
- `GET /api/dashboard/summary` - Dashboard data
- `GET /api/dashboard/top-products` - Top products
- `GET /api/dashboard/sales-trend` - Sales trend

[Full API Documentation →](docs/API.md)

---

## 🧪 Testing

### Test Coverage
- ✅ 42/42 tests passing (100%)
- ✅ Authentication & Authorization
- ✅ CRUD Operations
- ✅ Transaction Flow
- ✅ Stock Management
- ✅ Reports & Analytics

### Run Tests
```bash
# Comprehensive test
./scripts/tests/comprehensive_test_brutal.sh

# Specific tests
./scripts/tests/test-auth.sh
./scripts/tests/test-crud-complete.sh
```

---

## 🚀 Deployment

### Production Checklist
- [ ] Update `.env` with production values
- [ ] Set `GIN_MODE=release`
- [ ] Enable HTTPS
- [ ] Setup automated backups
- [ ] Configure firewall
- [ ] Setup monitoring
- [ ] Review security settings

### Docker (Coming Soon)
```bash
docker-compose up -d
```

---

## 📈 Performance

- **Query Speed**: 67% faster with indexes
- **Response Time**: < 50ms average
- **Concurrent Users**: Supports 100+ simultaneous users
- **Database**: Optimized with foreign keys & indexes

---

## 🔒 Security

- ✅ Bcrypt password hashing
- ✅ JWT authentication
- ✅ Input sanitization
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CORS configuration
- ✅ Rate limiting
- ✅ Audit logging

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 License

MIT License - Free to use for commercial and non-commercial purposes.

---

## 👥 Support

- 📧 Email: support@posumkm.com
- 📖 Documentation: [docs/](docs/)
- 🐛 Issues: [GitHub Issues](https://github.com/Lintung0/POS_UMKM1.2/issues)

---

## 🎯 Roadmap

### v1.2 (Current)
- ✅ Complete POS functionality
- ✅ Material & recipe management
- ✅ Reports & analytics
- ✅ Multi-user support

### v1.3 (Planned)
- ⏳ Email notifications
- ⏳ Barcode scanner
- ⏳ Export to Excel/PDF
- ⏳ Mobile app

### v2.0 (Future)
- ⏳ Multi-store support
- ⏳ Online ordering
- ⏳ Inventory forecasting
- ⏳ Advanced analytics

---

**Made with ❤️ for UMKM Indonesia**
