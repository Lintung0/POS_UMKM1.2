# Login Credentials - POS UMKM

## 🔐 Default User Accounts

### Administrator
- **Username**: `admin`
- **Password**: `admin123`
- **Role**: Admin (Full Access)

### Kasir
- **Username**: `kasir`
- **Password**: `kasir123`
- **Role**: Cashier (Limited Access)

## 🚀 How to Login

1. Open: http://localhost:3000
2. Enter username and password
3. Click "Masuk" button

## ✅ Fixed Issues

1. **Password Hashing**: Fixed bcrypt password verification
2. **Demo Buttons**: Removed demo account buttons from login page
3. **Dark Theme**: Added dark theme support to login page
4. **Authentication Flow**: Fixed login → dashboard redirect

## 🔧 Technical Details

- Passwords are now properly hashed with bcrypt
- JWT tokens are generated for authentication
- Frontend proxy routes API calls correctly
- Authentication state is managed properly

## 🎯 Access Levels

### Admin Can:
- Manage products and recipes
- Manage raw materials
- View all reports and analytics
- Access system settings
- Manage users (if implemented)

### Kasir Can:
- Process transactions
- View basic reports
- Access cashier interface
- View product information

## 🔒 Security Notes

- Change default passwords in production
- Passwords are hashed with bcrypt
- JWT tokens expire after configured time
- Session management through localStorage
