package utils

// Error messages constants
const (
	// Authentication errors
	ErrInvalidCredentials = "Username atau password salah"
	ErrTokenExpired       = "Token sudah kadaluarsa, silakan login kembali"
	ErrTokenInvalid       = "Token tidak valid"
	ErrUnauthorized       = "Anda tidak memiliki akses"
	ErrForbidden          = "Akses ditolak"

	// Validation errors
	ErrInvalidInput       = "Data yang dimasukkan tidak valid"
	ErrRequiredField      = "Field wajib diisi"
	ErrInvalidEmail       = "Format email tidak valid"
	ErrInvalidPhone       = "Format nomor telepon tidak valid"
	ErrInvalidPrice       = "Harga harus lebih dari 0"
	ErrInvalidQuantity    = "Jumlah harus lebih dari 0"
	ErrStockInsufficient  = "Stok tidak mencukupi"

	// Resource errors
	ErrNotFound           = "Data tidak ditemukan"
	ErrAlreadyExists      = "Data sudah ada"
	ErrCannotDelete       = "Data tidak dapat dihapus karena masih digunakan"

	// Transaction errors
	ErrInsufficientCash   = "Uang tidak cukup"
	ErrTransactionFailed  = "Transaksi gagal"
	ErrMaterialInsufficient = "Bahan baku tidak mencukupi"

	// Server errors
	ErrInternalServer     = "Terjadi kesalahan pada server"
	ErrDatabaseError      = "Terjadi kesalahan pada database"
	ErrNetworkError       = "Terjadi kesalahan jaringan"
)

// Success messages constants
const (
	SuccessLogin          = "Login berhasil"
	SuccessLogout         = "Logout berhasil"
	SuccessCreate         = "Data berhasil ditambahkan"
	SuccessUpdate         = "Data berhasil diperbarui"
	SuccessDelete         = "Data berhasil dihapus"
	SuccessTransaction    = "Transaksi berhasil diproses"
	SuccessProduction     = "Produksi berhasil"
)
