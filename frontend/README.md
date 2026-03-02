# POS UMKM Frontend

Modern React.js frontend untuk sistem kasir pintar UMKM dengan auto stock management.

## 🚀 Features

### ✅ **Sesuai Video Explainer**
- **Scene 1**: Login system dengan demo accounts
- **Scene 3**: Complete transaction workflow dengan cart management
- **Scene 5**: Real-time dashboard dengan analytics
- **Scene 7**: Mobile responsive design
- **Scene 8**: Modern React.js tech stack

### 🎯 **Core Features**
- **Smart Cashier System**: Product selection, cart management, payment processing
- **Real-time Dashboard**: Sales analytics, profit tracking, top products
- **Auto Stock Management**: Automatic stock deduction after transactions
- **Recipe-based Inventory**: Material consumption tracking
- **Mobile Responsive**: Works on desktop, tablet, and mobile
- **Modern UI/UX**: Clean design with Tailwind CSS

## 🛠️ Tech Stack

- **Frontend**: React.js 18 + Vite
- **Styling**: Tailwind CSS
- **Icons**: Lucide React
- **HTTP Client**: Axios
- **Notifications**: React Hot Toast
- **State Management**: React Context API

## 📦 Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

## 🔧 Configuration

Frontend automatically connects to backend API at `http://localhost:8081/api`

## 👤 Demo Accounts

### Admin Account
- Username: `admin`
- Password: `admin123`
- Access: Full dashboard + management features

### Kasir Account  
- Username: `kasir`
- Password: `kasir123`
- Access: Cashier system + basic dashboard

## 📱 Pages & Components

### Pages
- **LoginPage**: Authentication with demo accounts
- **DashboardPage**: Business analytics and quick actions
- **CashierPage**: POS system with product selection and cart

### Components
- **MainLayout**: App shell with sidebar navigation
- **Sidebar**: Responsive navigation menu
- **PaymentModal**: Transaction processing with cash/card options

### Context
- **AuthContext**: User authentication state
- **CartContext**: Shopping cart management

## 🎨 Design System

### Colors
- Primary: `#2563eb` (Blue)
- Success: `#10b981` (Green)
- Warning: `#f59e0b` (Orange)
- Danger: `#ef4444` (Red)

### Typography
- Font: Inter (Google Fonts)
- Clean, modern sans-serif design

## 📊 API Integration

Frontend integrates with all backend endpoints:

```javascript
// Products
GET /api/products - Product listing
POST /api/products - Create product

// Transactions  
POST /api/transactions - Process payment
GET /api/transactions/:id/receipt - Generate receipt

// Dashboard
GET /api/dashboard/summary - Business metrics
GET /api/dashboard/top-products - Best sellers
GET /api/dashboard/sales-trend - Sales analytics

// Auth
POST /api/auth/login - User authentication
```

## 🚀 Development

```bash
# Start frontend (port 3000)
npm run dev

# Start backend (port 8081)  
cd ../backend && go run main.go

# Access application
http://localhost:3000
```

## 📱 Mobile Responsive

- **Desktop**: Full dashboard with sidebar
- **Tablet**: Collapsible sidebar, optimized layout
- **Mobile**: Mobile-first design, touch-friendly interface

## 🎯 Video Explainer Compliance

✅ **Scene 2**: Modern tablet/smartphone interface  
✅ **Scene 3**: Complete transaction workflow  
✅ **Scene 4**: Recipe mapping visualization  
✅ **Scene 5**: Real-time dashboard updates  
✅ **Scene 6**: Performance benefits showcase  
✅ **Scene 7**: Multi-device responsive design  
✅ **Scene 8**: React.js + Tailwind CSS tech stack  

## 🔮 Future Enhancements

- [ ] Product management pages
- [ ] Material management interface  
- [ ] Advanced reporting dashboard
- [ ] Receipt printing integration
- [ ] Offline mode support
- [ ] Multi-language support

---

**Ready for UMKM deployment! 🚀**
