# 📋 ANALISIS & REKOMENDASI MENU SETTINGS

**Status Saat Ini:** ✅ UI Sudah Ada, ⚠️ Belum Connect Backend

---

## 🔍 YANG SUDAH ADA (Frontend Only)

### ✅ Tab Settings yang Sudah Dibuat:

1. **👤 Profil**
   - Nama Lengkap
   - Username
   - Email
   - Telepon

2. **🏪 Toko**
   - Nama Toko
   - Alamat Toko
   - Telepon Toko
   - Pajak (%)

3. **🔔 Notifikasi**
   - Notifikasi Email (toggle)
   - Peringatan Stok (toggle)
   - Laporan Harian (toggle)

4. **💾 Sistem**
   - Mata Uang (IDR/USD)
   - Zona Waktu
   - Bahasa (ID/EN)

5. **🔒 Keamanan**
   - Two-Factor Authentication (toggle)
   - Session Timeout
   - Password Expiry

6. **🎨 Tampilan**
   - Theme (Light/Dark)

---

## ⚠️ MASALAH SAAT INI

### 1. **Tidak Ada Backend API**
```javascript
// Saat ini hanya:
const handleSave = (section) => {
    toast.success(`Pengaturan ${section} berhasil disimpan`);
    // ❌ Tidak ada API call
    // ❌ Data tidak tersimpan ke database
};
```

### 2. **Tidak Ada Tabel Settings di Database**
```sql
-- Database saat ini:
✓ users
✓ products
✓ raw_materials
✓ recipes
✓ transactions
✓ transaction_details

❌ settings (TIDAK ADA)
```

### 3. **Data Hardcoded**
```javascript
storeName: 'UMKM Store',  // ❌ Hardcoded
storeAddress: 'Jl. Contoh No. 123',  // ❌ Hardcoded
```

---

## 🎯 REKOMENDASI IMPLEMENTASI

### **OPSI A: SIMPLE (Recommended untuk MVP)** ⭐

**Konsep:** Settings disimpan di tabel `users` (per user)

**Alasan:**
- ✅ Tidak perlu tabel baru
- ✅ Setiap user punya settings sendiri
- ✅ Cepat diimplementasi
- ✅ Cukup untuk UMKM kecil

**Implementasi:**

#### 1. Update Tabel Users
```sql
ALTER TABLE users ADD COLUMN settings JSON;

-- Contoh data:
{
  "store_name": "Kedai Kopi Lin",
  "store_address": "Jl. Sudirman No. 123",
  "store_phone": "081234567890",
  "store_tax": 10,
  "email_notifications": true,
  "stock_alerts": true,
  "daily_reports": false,
  "currency": "IDR",
  "timezone": "Asia/Jakarta",
  "language": "id"
}
```

#### 2. Backend API (Go)
```go
// backend/controllers/settings_controller.go
type SettingsController struct{}

// GET /api/settings
func (sc *SettingsController) GetSettings(c *gin.Context) {
    userID := c.GetUint("user_id") // dari JWT
    
    var user models.User
    config.DB.First(&user, userID)
    
    c.JSON(200, gin.H{
        "success": true,
        "data": user.Settings,
    })
}

// PUT /api/settings
func (sc *SettingsController) UpdateSettings(c *gin.Context) {
    userID := c.GetUint("user_id")
    
    var req map[string]interface{}
    c.BindJSON(&req)
    
    config.DB.Model(&models.User{}).
        Where("id = ?", userID).
        Update("settings", req)
    
    c.JSON(200, gin.H{
        "success": true,
        "message": "Settings berhasil disimpan",
    })
}
```

#### 3. Frontend API Call
```javascript
// frontend/src/utils/api.js
export const settingsAPI = {
    get: () => axios.get('/api/settings'),
    update: (data) => axios.put('/api/settings', data)
};

// frontend/src/pages/SettingsPage.jsx
const handleSave = async (section) => {
    try {
        await settingsAPI.update(settings);
        toast.success(`Pengaturan ${section} berhasil disimpan`);
    } catch (error) {
        toast.error('Gagal menyimpan pengaturan');
    }
};
```

**Estimasi:** 2-3 jam

---

### **OPSI B: ADVANCED (Untuk Scale Up)**

**Konsep:** Tabel `settings` terpisah (global untuk semua user)

**Alasan:**
- ✅ Settings global (semua user lihat data yang sama)
- ✅ Lebih terstruktur
- ✅ Bisa ada settings per-role
- ❌ Lebih kompleks

**Implementasi:**

#### 1. Buat Tabel Settings
```sql
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(20), -- 'string', 'number', 'boolean', 'json'
    category VARCHAR(50), -- 'store', 'system', 'notification'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Seed data:
INSERT INTO settings (setting_key, setting_value, setting_type, category) VALUES
('store_name', 'UMKM Store', 'string', 'store'),
('store_address', 'Jl. Contoh No. 123', 'string', 'store'),
('store_phone', '081234567890', 'string', 'store'),
('store_tax', '10', 'number', 'store'),
('stock_alert_enabled', 'true', 'boolean', 'notification'),
('currency', 'IDR', 'string', 'system'),
('timezone', 'Asia/Jakarta', 'string', 'system');
```

#### 2. Backend Model & Controller
```go
// backend/models/setting.go
type Setting struct {
    ID           uint   `gorm:"primaryKey" json:"id"`
    SettingKey   string `gorm:"unique;not null" json:"setting_key"`
    SettingValue string `json:"setting_value"`
    SettingType  string `json:"setting_type"`
    Category     string `json:"category"`
}

// backend/controllers/settings_controller.go
func GetAllSettings(c *gin.Context) {
    var settings []models.Setting
    config.DB.Find(&settings)
    
    // Convert to map
    result := make(map[string]interface{})
    for _, s := range settings {
        result[s.SettingKey] = s.SettingValue
    }
    
    c.JSON(200, gin.H{"success": true, "data": result})
}

func UpdateSetting(c *gin.Context) {
    key := c.Param("key")
    var req struct {
        Value string `json:"value"`
    }
    c.BindJSON(&req)
    
    config.DB.Model(&models.Setting{}).
        Where("setting_key = ?", key).
        Update("setting_value", req.Value)
    
    c.JSON(200, gin.H{"success": true})
}
```

**Estimasi:** 4-6 jam

---

## 💡 REKOMENDASI UNTUK LIN-POS

### **Pilih OPSI A (Simple)** ⭐

**Alasan:**
1. ✅ **Cepat diimplementasi** (2-3 jam vs 4-6 jam)
2. ✅ **Cukup untuk UMKM** (1-5 user)
3. ✅ **Tidak perlu migration kompleks**
4. ✅ **Fokus ke fitur utama** (Dynamic Stock, Low Stock Alert)

**Yang Perlu Ditambahkan:**

### 1. **Settings yang PENTING untuk UMKM:**

#### A. **Toko Settings** (WAJIB)
```javascript
{
  store_name: "Kedai Kopi Lin",
  store_address: "Jl. Sudirman No. 123, Jakarta",
  store_phone: "081234567890",
  store_tax: 10,  // Untuk perhitungan pajak (opsional)
}
```
**Digunakan di:** Struk, Dashboard, Reports

#### B. **Low Stock Alert Settings** (WAJIB)
```javascript
{
  stock_alert_enabled: true,
  stock_alert_threshold: 50,  // Alert jika < 50% dari min_stock
  stock_alert_email: "owner@kedaikopi.com",
}
```
**Digunakan di:** Dashboard, Material Management

#### C. **Receipt Settings** (PENTING)
```javascript
{
  receipt_footer_text: "Terima kasih! Selamat berbelanja kembali",
  receipt_show_tax: false,
  receipt_show_cashier: true,
}
```
**Digunakan di:** Print Struk

#### D. **System Settings** (NICE TO HAVE)
```javascript
{
  currency: "IDR",
  currency_symbol: "Rp",
  date_format: "DD/MM/YYYY",
  time_format: "24h",
}
```
**Digunakan di:** Seluruh aplikasi

---

### 2. **Settings yang BISA SKIP (Untuk MVP):**

❌ **Two-Factor Authentication** - Terlalu kompleks untuk MVP
❌ **Email Notifications** - Butuh email server
❌ **Session Timeout** - JWT sudah handle
❌ **Password Expiry** - Tidak urgent untuk UMKM kecil
❌ **Multi-language** - Fokus Bahasa Indonesia dulu

---

## 🚀 IMPLEMENTASI PLAN

### **FASE 1: Backend Settings API** (1-2 jam)

#### Step 1: Update User Model
```go
// backend/models/user.go
type User struct {
    // ... existing fields
    Settings datatypes.JSON `gorm:"type:json" json:"settings"`
}
```

#### Step 2: Create Settings Controller
```go
// backend/controllers/settings_controller.go
package controllers

import (
    "backend/config"
    "backend/models"
    "backend/utils"
    "github.com/gin-gonic/gin"
)

type SettingsController struct{}

func (sc *SettingsController) GetSettings(c *gin.Context) {
    userID := c.GetUint("user_id")
    
    var user models.User
    if err := config.DB.First(&user, userID).Error; err != nil {
        c.JSON(404, utils.ErrorResponse("User tidak ditemukan", err))
        return
    }
    
    // Default settings jika belum ada
    if user.Settings == nil {
        user.Settings = datatypes.JSON([]byte(`{
            "store_name": "UMKM Store",
            "store_address": "Jl. Contoh No. 123",
            "store_phone": "081234567890",
            "store_tax": 0,
            "stock_alert_enabled": true,
            "stock_alert_threshold": 50,
            "receipt_footer_text": "Terima kasih!",
            "currency": "IDR"
        }`))
    }
    
    c.JSON(200, utils.SuccessResponse("Berhasil mengambil settings", user.Settings))
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
        c.JSON(500, utils.ErrorResponse("Gagal menyimpan settings", err))
        return
    }
    
    c.JSON(200, utils.SuccessResponse("Settings berhasil disimpan", nil))
}
```

#### Step 3: Add Routes
```go
// backend/routes/routes.go
settingsCtrl := &controllers.SettingsController{}
api.GET("/settings", utils.AuthMiddleware(), settingsCtrl.GetSettings)
api.PUT("/settings", utils.AuthMiddleware(), settingsCtrl.UpdateSettings)
```

---

### **FASE 2: Frontend Integration** (1 jam)

#### Step 1: Add API Functions
```javascript
// frontend/src/utils/api.js
export const settingsAPI = {
    get: () => axios.get('/api/settings'),
    update: (data) => axios.put('/api/settings', data)
};
```

#### Step 2: Update SettingsPage
```javascript
// frontend/src/pages/SettingsPage.jsx
import { settingsAPI } from '../utils/api';

const SettingsPage = () => {
    const [settings, setSettings] = useState({});
    const [loading, setLoading] = useState(true);
    
    useEffect(() => {
        fetchSettings();
    }, []);
    
    const fetchSettings = async () => {
        try {
            const response = await settingsAPI.get();
            setSettings(response.data.data);
        } catch (error) {
            toast.error('Gagal memuat settings');
        } finally {
            setLoading(false);
        }
    };
    
    const handleSave = async (section) => {
        try {
            await settingsAPI.update(settings);
            toast.success(`Pengaturan ${section} berhasil disimpan`);
        } catch (error) {
            toast.error('Gagal menyimpan pengaturan');
        }
    };
    
    // ... rest of component
};
```

---

### **FASE 3: Use Settings di Aplikasi** (30 menit)

#### A. Di Receipt/Struk
```javascript
// frontend/src/components/ReceiptModal.jsx
const { settings } = useSettings(); // Custom hook

<div className="receipt">
    <h2>{settings.store_name}</h2>
    <p>{settings.store_address}</p>
    <p>{settings.store_phone}</p>
    {/* ... */}
    <p>{settings.receipt_footer_text}</p>
</div>
```

#### B. Di Dashboard
```javascript
// frontend/src/pages/DashboardPage.jsx
const { settings } = useSettings();

// Low stock alert threshold
const isLowStock = (material) => {
    const threshold = settings.stock_alert_threshold || 50;
    const percentage = (material.stock / material.min_stock) * 100;
    return percentage < threshold;
};
```

---

## 📋 PRIORITAS IMPLEMENTASI

### **PRIORITAS TINGGI** (Untuk MVP):
1. ✅ **Store Settings** (Nama, Alamat, Telepon) - Untuk struk
2. ✅ **Low Stock Alert Settings** - Untuk inventory management
3. ✅ **Receipt Settings** - Untuk customize struk

### **PRIORITAS MEDIUM** (Nice to have):
4. ⚠️ **Currency Settings** - Untuk format harga
5. ⚠️ **Theme Settings** - Sudah ada di frontend

### **PRIORITAS LOW** (Skip untuk MVP):
6. ❌ Email Notifications
7. ❌ Two-Factor Auth
8. ❌ Multi-language

---

## 🎯 KESIMPULAN

### **Rekomendasi Final:**

**1. Implementasi Settings dengan Opsi A (Simple)**
- Simpan di tabel `users` kolom `settings` (JSON)
- Fokus ke 3 kategori: Store, Low Stock Alert, Receipt
- Estimasi: 2-3 jam total

**2. Prioritas Fitur:**
```
Week 1:
├─ Dynamic Stock Logic (DONE)
├─ Low Stock Alert (DONE)
└─ Settings Backend + Frontend (NEW) ← 2-3 jam

Week 2:
├─ Receipt Printing (use settings)
├─ Export Reports
└─ Polish
```

**3. Settings yang Wajib:**
- ✅ Store Name, Address, Phone (untuk struk)
- ✅ Stock Alert Threshold (untuk alert)
- ✅ Receipt Footer Text (untuk struk)

**4. Settings yang Skip:**
- ❌ Email notifications (butuh email server)
- ❌ 2FA (terlalu kompleks)
- ❌ Multi-language (fokus ID dulu)

---

## 💬 PERTANYAAN UNTUK DISKUSI

**Q1:** Mau implementasi Settings sekarang atau setelah Dynamic Stock & Low Stock Alert selesai?

**Rekomendasi:** Setelah Fase 1 & 2 selesai, karena Settings akan digunakan di Receipt Printing (Fase 3)

**Q2:** Settings mana yang paling prioritas untuk UMKM?
- Store info (nama, alamat, telepon) ✅
- Low stock alert threshold ✅
- Receipt customization ✅
- Yang lain? 

**Q3:** Perlu fitur "Reset to Default" untuk settings?

---

**Status:** ⚠️ Settings UI sudah ada, tinggal connect ke backend (2-3 jam)

**Next Action:** Lanjut implementasi Dynamic Stock dulu, atau mau setup Settings backend dulu?
