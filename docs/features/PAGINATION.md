# Pagination Implementation

## Overview
Pagination telah ditambahkan ke semua halaman yang menampilkan data dalam bentuk tabel untuk meningkatkan performa dan user experience.

## Limit Per Page
**15 data per halaman**

## Halaman yang Sudah Ditambahkan Pagination

### 1. **Pengeluaran (ExpensesPage)**
- Menampilkan 15 pengeluaran per halaman
- Filter tetap berfungsi (date range, search)
- Pagination otomatis menyesuaikan dengan hasil filter

### 2. **Produk (ProductsPage)**
- Menampilkan 15 produk per halaman
- Search dan filter kategori tetap berfungsi
- Pagination client-side untuk performa optimal

### 3. **Bahan Baku (MaterialsPage)**
- Menampilkan 15 bahan baku per halaman
- Filter low stock dan search tetap berfungsi
- Pagination menyesuaikan dengan filter aktif

### 4. **Laporan Transaksi (ReportsPage)**
- Menampilkan 15 transaksi per halaman
- Semua filter (date, cashier, payment method) tetap berfungsi
- Pagination pada tab "Transaksi"

## Komponen Pagination

### Lokasi
`/frontend/src/components/Pagination.jsx`

### Fitur
- Navigasi Previous/Next
- Jump ke halaman tertentu
- Tampilan halaman saat ini
- Ellipsis (...) untuk banyak halaman
- Responsive design
- Dark mode support

### Props
```jsx
<Pagination 
  currentPage={currentPage}      // Halaman saat ini
  totalPages={totalPages}        // Total halaman
  onPageChange={setCurrentPage}  // Callback saat ganti halaman
/>
```

## Implementasi

### Client-Side Pagination
Semua pagination menggunakan client-side untuk:
- Performa lebih cepat (no server request)
- Filter dan search lebih responsive
- Mengurangi beban server

### Logic
```javascript
// 1. State untuk pagination
const [currentPage, setCurrentPage] = useState(1);
const [totalPages, setTotalPages] = useState(1);
const itemsPerPage = 15;

// 2. Filter dan paginate data
useEffect(() => {
  const filtered = allData.filter(/* filter logic */);
  
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  setDisplayData(filtered.slice(startIndex, endIndex));
  setTotalPages(Math.ceil(filtered.length / itemsPerPage));
}, [allData, filters, currentPage]);
```

## Benefits

1. **Performa Lebih Baik**
   - Hanya render 15 data per halaman
   - Scroll lebih smooth
   - Loading lebih cepat

2. **User Experience**
   - Mudah navigasi data
   - Tidak overwhelm dengan banyak data
   - Clear indication halaman saat ini

3. **Scalable**
   - Bisa handle ribuan data
   - Tidak lag meskipun data banyak
   - Memory efficient

## Tanggal Implementasi
11 Maret 2026
