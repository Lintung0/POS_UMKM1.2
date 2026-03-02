# 🎯 FINAL IMPLEMENTATION PLAN - Lin-POS

**Status:** ✅ APPROVED & READY TO CODE  
**Target:** Sistem POS UMKM dengan Dynamic Stock, Smart Alerts & Professional Receipt

---

## 📋 KEPUTUSAN FINAL (CONFIRMED)

### ✅ **PRIORITAS IMPLEMENTASI:**

```
WEEK 1: CORE FEATURES
├─ Day 1-3: Dynamic Stock Logic ⚠️ PRIORITAS 1
├─ Day 4-5: Low Stock Alert 🔔 PRIORITAS 2
└─ Day 5:   Settings Backend ⚙️ (2-3 jam)

WEEK 2: POLISH & REPORTS
├─ Day 1-2: Receipt Printing 🖨️ (pakai settings)
├─ Day 3-4: Export Reports 📊
└─ Day 5:   Testing & Polish ✨
```

---

## 🚀 FASE 1: DYNAMIC STOCK LOGIC (Day 1-3)

### **Objective:**
Stok dihitung dari bahan baku secara real-time (bukan dari field stock produk)

### **Implementation:**

#### 1. Add Method di Product Model
```go
// backend/models/product.go

// GetAvailableStock menghitung stok tersedia dari bahan baku
func (p *Product) GetAvailableStock(db *gorm.DB) int {
    // Jika produk tidak punya recipe, gunakan stock field
    if len(p.Recipes) == 0 {
        return p.Stock
    }
    
    // Load recipes dengan materials
    db.Preload("Recipes.Material").First(&p, p.ID)
    
    // Hitung berapa banyak produk yang bisa dibuat dari bahan baku
    minStock := 999999
    for _, recipe := range p.Recipes {
        if recipe.QuantityUsed <= 0 {
            continue
        }
        canMake := int(recipe.Material.Stock / recipe.QuantityUsed)
        if canMake < minStock {
            minStock = canMake
        }
    }
    
    if minStock == 999999 {
        return 0
    }
    return minStock
}
```

#### 2. Update Product Controller
```go
// backend/controllers/product_controller.go

func (pc *ProductController) GetAllProducts(c *gin.Context) {
    var products []models.Product
    
    result := config.DB.
        Preload("Recipes.Material").
        Find(&products)
    
    // Add available_stock to response
    var productResponses []gin.H
    for _, product := range products {
        availableStock := product.GetAvailableStock(config.DB)
        
        productResponses = append(productResponses, gin.H{
            "id":              product.ID,
            "name":            product.Name,
            "cost_price":      product.CostPrice,
            "selling_price":   product.SellingPrice,
            "stock":           product.Stock,
            "available_stock": availableStock, // NEW!
            "category":        product.Category,
            "has_recipe":      len(product.Recipes) > 0,
        })
    }
    
    c.JSON(200, utils.SuccessResponse("Success", gin.H{
        "products": productResponses,
    }))
}
```

#### 3. Update Transaction Validation
```go
// backend/controllers/transaction_controller.go

// Di CreateTransaction, update validasi stok:
for _, item := range req.Items {
    var product models.Product
    config.DB.Preload("Recipes.Material").First(&product, item.ProductID)
    
    // Hitung available stock
    availableStock := product.GetAvailableStock(tx)
    
    if availableStock < item.Quantity {
        tx.Rollback()
        msg := fmt.Sprintf("Stok %s tidak cukup. Tersedia: %d, Dibutuhkan: %d",
            product.Name, availableStock, item.Quantity)
        return c.JSON(400, utils.ErrorResponse(msg, nil))
    }
    
    // ... rest of transaction logic
}
```

#### 4. Update Frontend Display
```javascript
// frontend/src/pages/CashierPage.jsx

<div className="card">
  <h3>{product.name}</h3>
  <p className="text-sm">
    {product.has_recipe ? (
      <span className="text-blue-600">
        Stok: {product.available_stock} unit (dari bahan baku)
      </span>
    ) : (
      <span>Stok: {product.stock} unit</span>
    )}
  </p>
  <button 
    disabled={product.available_stock <= 0}
    onClick={() => handleAddToCart(product)}
  >
    {product.available_stock <= 0 ? 'Stok Habis' : 'Tambah'}
  </button>
</div>
```

**Estimasi:** 2-3 hari (termasuk testing)

---

## 🔔 FASE 2: LOW STOCK ALERT (Day 4-5)

### **Objective:**
Alert otomatis saat bahan baku menipis (< threshold)

### **Implementation:**

#### 1. Update Material Model
```go
// backend/models/material.go

// IsLowStock cek apakah stok di bawah threshold
func (m *RawMaterial) IsLowStock(threshold float64) bool {
    percentage := (m.Stock / m.MinStock) * 100
    return percentage < threshold
}

// GetStockLevel return level: danger, warning, safe
func (m *RawMaterial) GetStockLevel(threshold float64) string {
    percentage := (m.Stock / m.MinStock) * 100
    if percentage < threshold {
        return "danger"
    } else if percentage < 80 {
        return "warning"
    }
    return "safe"
}
```

#### 2. Create Low Stock Alert Component
```javascript
// frontend/src/components/LowStockAlert.jsx

import React, { useState, useEffect } from 'react';
import { AlertTriangle } from 'lucide-react';
import { materialsAPI } from '../utils/api';

const LowStockAlert = () => {
  const [lowStockMaterials, setLowStockMaterials] = useState([]);
  
  useEffect(() => {
    fetchLowStock();
  }, []);
  
  const fetchLowStock = async () => {
    const response = await materialsAPI.getLowStock();
    setLowStockMaterials(response.data.data);
  };
  
  if (lowStockMaterials.length === 0) return null;
  
  return (
    <div className="bg-red-50 border-l-4 border-red-500 p-4 mb-6">
      <div className="flex items-center">
        <AlertTriangle className="w-5 h-5 text-red-500 mr-3" />
        <div>
          <h3 className="font-semibold text-red-800">
            Peringatan Stok Rendah!
          </h3>
          <p className="text-sm text-red-700">
            {lowStockMaterials.length} bahan baku perlu direstock
          </p>
        </div>
      </div>
      <ul className="mt-3 space-y-1">
        {lowStockMaterials.map(material => (
          <li key={material.id} className="text-sm text-red-700">
            • {material.name}: {material.stock} {material.unit} 
            (min: {material.min_stock})
          </li>
        ))}
      </ul>
    </div>
  );
};

export default LowStockAlert;
```

#### 3. Add Alert to Dashboard
```javascript
// frontend/src/pages/DashboardPage.jsx

import LowStockAlert from '../components/LowStockAlert';

const DashboardPage = () => {
  return (
    <div>
      <h1>Dashboard</h1>
      
      {/* Low Stock Alert */}
      <LowStockAlert />
      
      {/* Rest of dashboard */}
    </div>
  );
};
```

#### 4. Add Warning di Kasir Page
```javascript
// frontend/src/pages/CashierPage.jsx

const handleAddToCart = (product) => {
  // Check if product has low stock materials
  if (product.has_recipe && product.available_stock < 10) {
    toast.warning(
      `⚠️ Stok ${product.name} tinggal ${product.available_stock} unit!`,
      { duration: 3000 }
    );
  }
  
  addItem(product);
};
```

**Estimasi:** 1-2 hari

---

## ⚙️ FASE 3: SETTINGS BACKEND (Day 5, 2-3 jam)

### **Objective:**
Settings untuk Store Info, Alert Threshold, Receipt, Tax

### **Settings Structure:**
```json
{
  "store_name": "Kedai Kopi Lin",
  "store_address": "Jl. Sudirman No. 123, Jakarta",
  "store_phone": "081234567890",
  "store_email": "info@kedaikopilin.com",
  
  "stock_alert_enabled": true,
  "stock_alert_threshold": 50,
  
  "receipt_footer_text": "Terima kasih sudah mampir, Bro!",
  "receipt_show_cashier": true,
  "receipt_show_tax": false,
  
  "tax_enabled": false,
  "tax_percentage": 10,
  "service_charge_enabled": false,
  "service_charge_percentage": 5
}
```

### **Implementation:**

#### 1. Update User Model
```go
// backend/models/user.go
import "gorm.io/datatypes"

type User struct {
    // ... existing fields
    Settings datatypes.JSON `gorm:"type:json" json:"settings"`
}
```

#### 2. Create Settings Controller
```go
// backend/controllers/settings_controller.go
package controllers

import (
    "backend/config"
    "backend/models"
    "backend/utils"
    "github.com/gin-gonic/gin"
    "gorm.io/datatypes"
)

type SettingsController struct{}

func (sc *SettingsController) GetSettings(c *gin.Context) {
    userID := c.GetUint("user_id")
    
    var user models.User
    if err := config.DB.First(&user, userID).Error; err != nil {
        c.JSON(404, utils.ErrorResponse("User tidak ditemukan", err))
        return
    }
    
    // Default settings
    if user.Settings == nil {
        defaultSettings := map[string]interface{}{
            "store_name":    "UMKM Store",
            "store_address": "Jl. Contoh No. 123",
            "store_phone":   "081234567890",
            "stock_alert_threshold": 50,
            "receipt_footer_text": "Terima kasih!",
            "tax_enabled": false,
            "tax_percentage": 10,
        }
        user.Settings = datatypes.JSON(utils.ToJSON(defaultSettings))
    }
    
    c.JSON(200, utils.SuccessResponse("Success", user.Settings))
}

func (sc *SettingsController) UpdateSettings(c *gin.Context) {
    userID := c.GetUint("user_id")
    
    var req map[string]interface{}
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, utils.ErrorResponse("Data tidak valid", err))
        return
    }
    
    if err := config.DB.Model(&models.User{}).
        Where("id = ?", userID).
        Update("settings", req).Error; err != nil {
        c.JSON(500, utils.ErrorResponse("Gagal menyimpan", err))
        return
    }
    
    c.JSON(200, utils.SuccessResponse("Settings berhasil disimpan", nil))
}
```

#### 3. Add Routes
```go
// backend/routes/routes.go

settingsCtrl := &controllers.SettingsController{}
api.GET("/settings", utils.AuthMiddleware(), settingsCtrl.GetSettings)
api.PUT("/settings", utils.AuthMiddleware(), settingsCtrl.UpdateSettings)
```

#### 4. Frontend Integration
```javascript
// frontend/src/utils/api.js
export const settingsAPI = {
    get: () => axios.get('/api/settings'),
    update: (data) => axios.put('/api/settings', data)
};

// frontend/src/pages/SettingsPage.jsx
const fetchSettings = async () => {
    const response = await settingsAPI.get();
    setSettings(response.data.data);
};

const handleSave = async (section) => {
    await settingsAPI.update(settings);
    toast.success(`Pengaturan ${section} berhasil disimpan`);
};
```

**Estimasi:** 2-3 jam

---

## 🖨️ FASE 4: RECEIPT PRINTING (Day 1-2, Week 2)

### **Objective:**
Struk profesional dengan data dari Settings (TIDAK HARDCODED!)

### **Alur Integrasi:**
```
1. Kasir klik "Bayar" → Transaksi berhasil
2. React fetch GET /api/settings
3. React fetch GET /api/transactions/:id
4. React render struk dengan data settings
5. User klik "Print" → window.print()
```

### **Implementation:**

#### 1. Create Receipt Modal Component
```javascript
// frontend/src/components/ReceiptModal.jsx

import React, { useState, useEffect } from 'react';
import { settingsAPI } from '../utils/api';
import { formatCurrency } from '../utils/helpers';
import { X, Printer } from 'lucide-react';

const ReceiptModal = ({ isOpen, onClose, transaction }) => {
  const [settings, setSettings] = useState(null);
  
  useEffect(() => {
    if (isOpen) {
      fetchSettings();
    }
  }, [isOpen]);
  
  const fetchSettings = async () => {
    const response = await settingsAPI.get();
    setSettings(response.data.data);
  };
  
  const handlePrint = () => {
    window.print();
  };
  
  if (!isOpen || !settings) return null;
  
  // Calculate tax if enabled
  const subtotal = transaction.total_amount;
  const taxAmount = settings.tax_enabled 
    ? (subtotal * settings.tax_percentage / 100) 
    : 0;
  const total = subtotal + taxAmount;
  
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 max-w-md w-full">
        {/* Header - Hide on print */}
        <div className="flex justify-between items-center mb-4 no-print">
          <h2 className="text-xl font-bold">Struk Pembayaran</h2>
          <button onClick={onClose} className="text-gray-500">
            <X className="w-6 h-6" />
          </button>
        </div>
        
        {/* Receipt Content - Printable */}
        <div className="receipt-content border-2 border-dashed border-gray-300 p-6">
          {/* Store Info dari Settings */}
          <div className="text-center mb-4">
            <h3 className="text-lg font-bold">{settings.store_name}</h3>
            <p className="text-sm">{settings.store_address}</p>
            <p className="text-sm">{settings.store_phone}</p>
          </div>
          
          <div className="border-t border-dashed border-gray-400 my-3"></div>
          
          {/* Transaction Info */}
          <div className="text-sm mb-3">
            <p>No: #{transaction.id}</p>
            <p>Tanggal: {new Date(transaction.created_at).toLocaleString('id-ID')}</p>
            {settings.receipt_show_cashier && (
              <p>Kasir: {transaction.cashier_name}</p>
            )}
          </div>
          
          <div className="border-t border-dashed border-gray-400 my-3"></div>
          
          {/* Items */}
          <div className="space-y-2 mb-3">
            {transaction.details.map(item => (
              <div key={item.id} className="flex justify-between text-sm">
                <span>{item.product_name} x{item.qty}</span>
                <span>{formatCurrency(item.total_price)}</span>
              </div>
            ))}
          </div>
          
          <div className="border-t border-dashed border-gray-400 my-3"></div>
          
          {/* Total */}
          <div className="space-y-1">
            <div className="flex justify-between">
              <span>Subtotal</span>
              <span>{formatCurrency(subtotal)}</span>
            </div>
            
            {settings.tax_enabled && (
              <div className="flex justify-between text-sm">
                <span>Pajak ({settings.tax_percentage}%)</span>
                <span>{formatCurrency(taxAmount)}</span>
              </div>
            )}
            
            <div className="flex justify-between font-bold text-lg">
              <span>TOTAL</span>
              <span>{formatCurrency(total)}</span>
            </div>
            
            <div className="flex justify-between">
              <span>Bayar</span>
              <span>{formatCurrency(transaction.cash_received)}</span>
            </div>
            
            <div className="flex justify-between">
              <span>Kembali</span>
              <span>{formatCurrency(transaction.change_amount)}</span>
            </div>
          </div>
          
          <div className="border-t border-dashed border-gray-400 my-3"></div>
          
          {/* Footer dari Settings */}
          <div className="text-center text-sm">
            <p>{settings.receipt_footer_text}</p>
          </div>
        </div>
        
        {/* Actions - Hide on print */}
        <div className="flex gap-3 mt-4 no-print">
          <button 
            onClick={handlePrint}
            className="btn btn-primary flex-1 flex items-center justify-center gap-2"
          >
            <Printer className="w-4 h-4" />
            Print
          </button>
          <button 
            onClick={onClose}
            className="btn bg-gray-200 flex-1"
          >
            Tutup
          </button>
        </div>
      </div>
    </div>
  );
};

export default ReceiptModal;
```

#### 2. Add Print CSS
```css
/* frontend/src/index.css */

@media print {
  /* Hide everything except receipt */
  body * {
    visibility: hidden;
  }
  
  .receipt-content, .receipt-content * {
    visibility: visible;
  }
  
  .receipt-content {
    position: absolute;
    left: 0;
    top: 0;
    width: 80mm; /* Thermal printer width */
  }
  
  /* Hide non-printable elements */
  .no-print {
    display: none !important;
  }
  
  /* Receipt styling */
  .receipt-content {
    font-family: 'Courier New', monospace;
    font-size: 12px;
    line-height: 1.4;
  }
}
```

#### 3. Use Receipt Modal
```javascript
// frontend/src/components/PaymentModal.jsx

import ReceiptModal from './ReceiptModal';

const PaymentModal = ({ ... }) => {
  const [showReceipt, setShowReceipt] = useState(false);
  const [transactionData, setTransactionData] = useState(null);
  
  const handlePayment = async () => {
    const response = await transactionsAPI.create(transactionData);
    setTransactionData(response.data.data.transaction);
    setShowReceipt(true);
    onSuccess();
  };
  
  return (
    <>
      {/* Payment Modal */}
      {/* ... */}
      
      {/* Receipt Modal */}
      <ReceiptModal 
        isOpen={showReceipt}
        onClose={() => setShowReceipt(false)}
        transaction={transactionData}
      />
    </>
  );
};
```

**Estimasi:** 1-2 hari

---

## 📊 FASE 5: EXPORT REPORTS (Day 3-4, Week 2)

### **Objective:**
Export laporan ke CSV/Excel

### **Implementation:**

#### 1. Backend Export Controller
```go
// backend/controllers/report_controller.go

func ExportDailyReportCSV(c *gin.Context) {
    date := c.Query("date")
    
    var transactions []models.Transaction
    config.DB.Where("DATE(created_at) = ?", date).
        Preload("Details").
        Find(&transactions)
    
    // Generate CSV
    csv := "No,Tanggal,Kasir,Total,Profit\n"
    for _, t := range transactions {
        csv += fmt.Sprintf("%d,%s,%s,%.0f,%.0f\n",
            t.ID, t.CreatedAt.Format("2006-01-02 15:04"), 
            t.CashierName, t.TotalAmount, t.TotalProfit)
    }
    
    c.Header("Content-Type", "text/csv")
    c.Header("Content-Disposition", "attachment; filename=report-"+date+".csv")
    c.String(200, csv)
}
```

#### 2. Frontend Export Button
```javascript
// frontend/src/pages/ReportsPage.jsx

const handleExport = async () => {
    const response = await reportsAPI.exportDaily(selectedDate);
    const blob = new Blob([response.data], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `report-${selectedDate}.csv`;
    a.click();
    toast.success('Laporan berhasil diexport!');
};
```

**Estimasi:** 1-2 hari

---

## ✨ FASE 6: POLISH & TESTING (Day 5, Week 2)

### **Checklist:**
- [ ] Test all flows end-to-end
- [ ] Fix bugs
- [ ] Add loading states
- [ ] Improve error messages
- [ ] Add "Reset to Default" di Settings (OPTIONAL)
- [ ] Documentation update
- [ ] Prepare demo data

**Estimasi:** 1 hari

---

## 📝 SETTINGS PRIORITY (CONFIRMED)

### ✅ **WAJIB (Must Have):**
1. **Store Info** - Nama, Alamat, Telepon (untuk struk)
2. **Low Stock Alert Threshold** - Persentase alert (50% default)
3. **Receipt Footer Text** - Branding message
4. **Tax/Service Charge** - Toggle + Persentase (NEW!)

### ⚠️ **NICE TO HAVE:**
5. Currency format
6. Theme (Light/Dark) - sudah ada

### ❌ **SKIP (Untuk MVP):**
7. Email notifications
8. Two-Factor Auth
9. Multi-language
10. Session timeout

---

## 🎯 SUCCESS CRITERIA

### **Week 1 Done:**
- ✅ Produk dengan recipe menampilkan available_stock dari bahan baku
- ✅ Transaksi validasi stok dari bahan baku
- ✅ Low stock alert muncul di dashboard
- ✅ Settings backend berfungsi

### **Week 2 Done:**
- ✅ Struk menggunakan data dari settings (tidak hardcoded)
- ✅ Tax/service charge bisa diaktifkan dari settings
- ✅ Export reports to CSV
- ✅ All features tested

---

## 💡 KEY POINTS

### **1. Dynamic Stock:**
```
Cappuccino butuh 10g Gula Pasir
Gula Pasir tersisa 1970g
→ Available Stock: 197 Cappuccino
```

### **2. Low Stock Alert:**
```
Threshold: 50%
Gula Pasir: 1000g (min: 2000g)
→ 50% → Alert: "Gula Pasir perlu restock!"
```

### **3. Settings Integration:**
```
Settings → API → Receipt
TIDAK BOLEH HARDCODED!
```

### **4. Tax Calculation:**
```
Subtotal: Rp 48,000
Tax (10%): Rp 4,800
Total: Rp 52,800
```

---

## 📅 TIMELINE SUMMARY

```
WEEK 1 (Core Features):
Mon-Wed: Dynamic Stock Logic
Thu-Fri: Low Stock Alert
Fri PM:  Settings Backend (2-3 jam)

WEEK 2 (Polish):
Mon-Tue: Receipt Printing (pakai settings)
Wed-Thu: Export Reports
Fri:     Testing & Polish

Total: 8-10 hari kerja
```

---

## ✅ NEXT ACTION

**Mulai Fase 1: Dynamic Stock Logic**

**First Task:**
1. Add `GetAvailableStock()` method di Product model
2. Update Product Controller untuk return available_stock
3. Test dengan curl

**Ready to code?** 🚀

---

**Prepared by:** Kiro AI Assistant  
**Approved by:** Lin (Owner)  
**Status:** READY TO IMPLEMENT  
**Last Updated:** 10 Feb 2026, 07:28
