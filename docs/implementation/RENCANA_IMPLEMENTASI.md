# 🎯 RENCANA IMPLEMENTASI - Lin-POS Workflow

**Tanggal:** 10 Februari 2026  
**Status:** READY TO IMPLEMENT  
**Target:** Sistem POS UMKM dengan Dynamic Stock & Smart Alerts

---

## 📋 KEPUTUSAN FINAL

### ✅ Q1: Sistem Stok - **OPSI A (Dynamic Stock)**
**Keputusan:** Stok dihitung dari bahan baku secara real-time

**Alasan:**
- ✅ Unique Selling Point untuk UMKM (Coffee Shop, Kedai Makanan)
- ✅ Tidak perlu stok produk jadi di rak
- ✅ Owner langsung tahu sisa bahan baku di kulkas
- ✅ Meracik saat ada pesanan (made-to-order)

**Implementasi:**
```
Transaksi 1 Kopi Susu:
- Potong 20g Biji Kopi dari raw_materials ✅
- Potong 100ml Susu dari raw_materials ✅
- Tidak perlu field stock di products (atau diabaikan)
```

---

### ✅ Q2: Format Struk - **OPSI A (Print HTML Browser)**
**Keputusan:** Print via browser (mobile-friendly)

**Alasan:**
- ✅ Mudah dikoding & fleksibel
- ✅ Bisa print ke printer bluetooth via HP
- ✅ Bisa screenshot → kirim WhatsApp
- ✅ Cocok untuk UMKM yang baru mulai

**Future:** Tambah PDF export jika ada waktu

---

### ✅ Q3: Fitur Prioritas - **Low Stock Alert + Export Reports**
**Keputusan:** 
1. Low Stock Alert (WAJIB)
2. Export Reports Excel/CSV

**Alasan:**
- ✅ Low Stock Alert = nyawa inventory system
- ✅ Export Reports = terlihat "mahal" tapi mudah dibuat
- ✅ Skip Production Module (terlalu kompleks untuk MVP)

---

## 🚀 RENCANA IMPLEMENTASI

### **FASE 1: FIX DYNAMIC STOCK LOGIC** ⚠️ PRIORITAS TINGGI

#### Problem Saat Ini:
```
Produk dengan recipe:
- Field stock di products masih ada (500 unit)
- Saat transaksi, stok bahan baku berkurang ✅
- Tapi stock produk tidak berkurang ❌

Produk tanpa recipe:
- Stok produk berkurang ✅
- Tidak ada bahan baku
```

#### Solusi:
**Opsi 1: Hapus field stock untuk produk dengan recipe**
```go
// Di transaction_controller.go
if len(product.Recipes) > 0 {
    // Produk dengan recipe - cek stok bahan baku
    // TIDAK CEK product.Stock
} else {
    // Produk tanpa recipe - cek product.Stock
}
```

**Opsi 2: Hitung available stock dari bahan baku**
```go
// Tambah method di Product model
func (p *Product) GetAvailableStock() int {
    if len(p.Recipes) == 0 {
        return p.Stock // Produk jadi
    }
    
    // Hitung dari bahan baku
    minStock := 999999
    for _, recipe := range p.Recipes {
        canMake := int(recipe.Material.Stock / recipe.QuantityUsed)
        if canMake < minStock {
            minStock = canMake
        }
    }
    return minStock
}
```

**Rekomendasi:** Opsi 2 (lebih informatif untuk kasir)

#### Files to Modify:
1. `backend/models/product.go` - Tambah method GetAvailableStock()
2. `backend/controllers/product_controller.go` - Return available_stock di response
3. `backend/controllers/transaction_controller.go` - Update validasi stok
4. `frontend/src/pages/CashierPage.jsx` - Display available stock

---

### **FASE 2: LOW STOCK ALERT** 🔔 PRIORITAS TINGGI

#### Feature Requirements:
1. **Real-time Alert di Dashboard**
   - Badge merah jika ada bahan baku < min_stock
   - List bahan baku yang perlu restock

2. **Alert di Kasir Page**
   - Warning saat pilih produk yang bahan bakunya menipis
   - "⚠️ Bahan baku Susu tinggal 200ml (min: 300ml)"

3. **Notification Toast**
   - Muncul saat login jika ada low stock
   - "Ada 3 bahan baku yang perlu direstock!"

#### Files to Create/Modify:
1. `frontend/src/components/LowStockBadge.jsx` - NEW
2. `frontend/src/components/LowStockAlert.jsx` - NEW
3. `frontend/src/pages/DashboardPage.jsx` - Add alert section
4. `frontend/src/pages/CashierPage.jsx` - Add warning
5. `backend/controllers/material_controller.go` - Already has GetLowStockMaterials ✅

---

### **FASE 3: IMPROVE RECEIPT PRINTING** 🖨️ PRIORITAS MEDIUM

#### Feature Requirements:
1. **Modal Struk Setelah Transaksi**
   - Tampilkan struk di modal
   - Button "Print" → window.print()
   - Button "Close" → kembali ke kasir

2. **Print-Friendly CSS**
   - @media print untuk hide navbar, sidebar
   - Format struk thermal printer style (58mm/80mm)

3. **Struk Content:**
   ```
   ================================
        NAMA TOKO UMKM
     Jl. Alamat Toko No. 123
        Telp: 0812-xxxx-xxxx
   ================================
   
   Tanggal: 10/02/2026 14:30
   Kasir: Admin
   No. Transaksi: #00017
   
   --------------------------------
   Kopi Susu x2      Rp 30,000
   Cappuccino x1     Rp 18,000
   --------------------------------
   
   TOTAL             Rp 48,000
   BAYAR             Rp 50,000
   KEMBALI           Rp  2,000
   
   ================================
      Terima Kasih!
   Selamat Berbelanja Kembali
   ================================
   ```

#### Files to Create/Modify:
1. `frontend/src/components/ReceiptModal.jsx` - NEW
2. `frontend/src/components/PaymentModal.jsx` - Call ReceiptModal after success
3. `frontend/src/index.css` - Add @media print styles

---

### **FASE 4: EXPORT REPORTS** 📊 PRIORITAS MEDIUM

#### Feature Requirements:
1. **Export Daily Report to Excel**
   - Button "Export Excel" di ReportsPage
   - Format: Date, Transaction Count, Total Sales, Total Profit

2. **Export Monthly Report to Excel**
   - Breakdown per hari dalam sebulan
   - Summary di akhir

3. **Export Transaction List to CSV**
   - All transactions dengan filter date range
   - Columns: ID, Date, Cashier, Total, Profit, Payment Method

#### Backend Implementation:
```go
// backend/controllers/report_controller.go - NEW
func ExportDailyReportCSV(c *gin.Context) {
    // Query data
    // Generate CSV
    // Set headers
    c.Header("Content-Type", "text/csv")
    c.Header("Content-Disposition", "attachment; filename=daily-report.csv")
    c.String(200, csvContent)
}
```

#### Frontend Implementation:
```jsx
// frontend/src/pages/ReportsPage.jsx
const handleExport = async () => {
    const response = await reportsAPI.exportDaily(date);
    const blob = new Blob([response.data], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `daily-report-${date}.csv`;
    a.click();
};
```

#### Files to Create/Modify:
1. `backend/controllers/report_controller.go` - NEW
2. `backend/routes/routes.go` - Add export routes
3. `frontend/src/utils/api.js` - Add export API calls
4. `frontend/src/pages/ReportsPage.jsx` - Add export buttons

---

### **FASE 5: POLISH & OPTIMIZATION** ✨ PRIORITAS LOW

#### Improvements:
1. **Loading States**
   - Skeleton loading untuk tables
   - Spinner untuk buttons

2. **Error Boundaries**
   - Catch React errors
   - Fallback UI

3. **Optimistic Updates**
   - Update UI sebelum API response
   - Rollback jika error

4. **Caching**
   - Cache products, materials di frontend
   - Refresh setiap 5 menit atau manual

5. **Keyboard Shortcuts**
   - F2: Focus search
   - F9: Checkout
   - ESC: Close modal

---

## 📅 TIMELINE ESTIMASI

### Sprint 1 (2-3 hari):
- ✅ Fase 1: Fix Dynamic Stock Logic
- ✅ Fase 2: Low Stock Alert

### Sprint 2 (2-3 hari):
- ✅ Fase 3: Improve Receipt Printing
- ✅ Fase 4: Export Reports

### Sprint 3 (1-2 hari):
- ✅ Fase 5: Polish & Optimization
- ✅ Testing & Bug Fixes

**Total:** 5-8 hari kerja

---

## 🎯 SUCCESS CRITERIA

### Must Have (MVP):
- ✅ Dynamic stock calculation dari bahan baku
- ✅ Low stock alert di dashboard & kasir
- ✅ Print struk via browser (mobile-friendly)
- ✅ Export reports to CSV/Excel

### Nice to Have:
- ✅ Keyboard shortcuts
- ✅ Optimistic updates
- ✅ Better loading states

### Future Enhancements:
- 📱 PWA (Progressive Web App)
- 🌙 Dark mode
- 🌐 Multi-language
- 📧 Email notifications
- 📱 WhatsApp integration

---

## 🔧 TECHNICAL STACK

### Backend:
- Go 1.25+
- Gin Framework
- GORM (MySQL)
- JWT Authentication
- CSV/Excel generation

### Frontend:
- React 18
- Vite
- Tailwind CSS
- Axios
- React Hot Toast
- Lucide Icons

### Database:
- MySQL 8.4.7
- phpMyAdmin (http://localhost:8081)

---

## 📝 CATATAN IMPLEMENTASI

### 1. Dynamic Stock Calculation
**Penting:** Jangan hapus field `stock` di products table (untuk backward compatibility)
- Produk dengan recipe: Ignore field stock, hitung dari bahan baku
- Produk tanpa recipe: Gunakan field stock

### 2. Low Stock Alert
**Formula:**
```
is_low_stock = (current_stock < min_stock)
stock_percentage = (current_stock / min_stock) * 100

Alert Level:
- Red (Danger): < 50%
- Yellow (Warning): 50-80%
- Green (Safe): > 80%
```

### 3. Receipt Printing
**CSS Print:**
```css
@media print {
    .no-print { display: none; }
    body { width: 80mm; }
    * { font-size: 12px; }
}
```

### 4. Export Reports
**Library Options:**
- Backend: `encoding/csv` (built-in Go)
- Frontend: `file-saver` + `blob`

---

## 🚦 NEXT ACTIONS

### Immediate (Hari Ini):
1. ✅ Review rencana ini
2. ✅ Confirm approach untuk dynamic stock
3. ✅ Setup development branch

### Tomorrow:
1. 🔨 Start Fase 1: Implement GetAvailableStock()
2. 🔨 Update transaction validation
3. 🔨 Update frontend display

### This Week:
1. 🔨 Complete Fase 1 & 2
2. 🧪 Testing dynamic stock
3. 🧪 Testing low stock alerts

---

## 💡 TIPS IMPLEMENTASI

### 1. Test-Driven Development
```bash
# Test setiap perubahan dengan curl
curl -X POST http://localhost:8082/api/transactions \
  -H "Content-Type: application/json" \
  -d '{"items":[{"product_id":12,"quantity":1}],...}'
```

### 2. Git Workflow
```bash
git checkout -b feature/dynamic-stock
# Implement
git commit -m "feat: add dynamic stock calculation"
git push origin feature/dynamic-stock
```

### 3. Documentation
- Update README.md setiap ada fitur baru
- Tambah comments di kode untuk logic kompleks
- Screenshot untuk dokumentasi UI

---

## 🎓 LEARNING POINTS

### Untuk Presentasi:
1. **Unique Feature:** Dynamic stock dari bahan baku (bukan stok produk jadi)
2. **Real-world Problem:** UMKM sering kehabisan bahan tanpa sadar
3. **Solution:** Smart alert + real-time calculation
4. **Impact:** Owner bisa fokus jualan, sistem yang urus inventory

### Demo Flow:
1. Login sebagai kasir
2. Pilih Cappuccino (3 unit)
3. Show: "Bahan baku Gula Pasir cukup untuk 197 unit"
4. Checkout → Print struk
5. Show dashboard: Stok Gula Pasir berkurang otomatis
6. Show alert: "Gula Pasir perlu restock"
7. Export report to Excel

---

## ✅ CHECKLIST SEBELUM MULAI

- [ ] Backup database current
- [ ] Create development branch
- [ ] Setup testing environment
- [ ] Review current code structure
- [ ] Prepare test data (products + recipes)
- [ ] Setup monitoring/logging

---

**Ready to implement?** 🚀

Prioritas pertama: **FASE 1 - Dynamic Stock Logic**

Ini adalah fondasi untuk semua fitur lainnya. Setelah ini selesai dan tested, baru lanjut ke Low Stock Alert.

---

**Prepared by:** Kiro AI Assistant  
**Approved by:** Lin (Owner)  
**Status:** READY TO CODE  
**Estimated Completion:** 5-8 hari kerja

---

## 📞 CONTACT FOR QUESTIONS

Jika ada pertanyaan atau butuh diskusi teknis:
1. Review kode di `backend/controllers/transaction_controller.go` line 50-90
2. Check business logic di `backend/models/product.go`
3. Test dengan data real di database `pos_umkm`

**Let's build this! 💪**
