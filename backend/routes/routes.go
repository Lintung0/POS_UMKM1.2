package routes

import (
	"backend/config"
	"backend/controllers"
	"backend/models"
	"backend/utils"
	"fmt"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func generateReceiptHTML(transaction models.Transaction, details []models.TransactionDetail) string {
	html := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Struk #%d</title>
    <style>
        @media print {
            body { margin: 0; }
            .no-print { display: none; }
        }
        body { font-family: monospace; width: 300px; margin: 20px auto; }
        .header { text-align: center; border-bottom: 2px dashed #000; padding-bottom: 10px; margin-bottom: 10px; }
        .item { display: flex; justify-content: space-between; margin: 5px 0; }
        .total { border-top: 2px dashed #000; padding-top: 10px; margin-top: 10px; font-weight: bold; }
        .footer { text-align: center; border-top: 2px dashed #000; padding-top: 10px; margin-top: 10px; font-size: 12px; }
        button { margin: 20px auto; display: block; padding: 10px 20px; }
    </style>
</head>
<body>
    <div class="header">
        <h2>POS UMKM</h2>
        <p>Jl. Contoh No. 123<br>Telp: 0812-3456-7890</p>
        <p>Struk #%d<br>%s</p>
        <p>Kasir: %s</p>
    </div>
    <div class="items">`, transaction.ID, transaction.ID, transaction.CreatedAt.Format("02/01/2006 15:04"), transaction.CashierName)

	for _, detail := range details {
		html += fmt.Sprintf(`
        <div class="item">
            <span>%s x%d</span>
            <span>Rp %.0f</span>
        </div>`, detail.ProductName, detail.Qty, detail.TotalPrice)
	}

	html += fmt.Sprintf(`
    </div>
    <div class="total">
        <div class="item"><span>TOTAL</span><span>Rp %.0f</span></div>
        <div class="item"><span>BAYAR</span><span>Rp %.0f</span></div>
        <div class="item"><span>KEMBALI</span><span>Rp %.0f</span></div>
    </div>
    <div class="footer">
        <p>Terima Kasih<br>Selamat Berbelanja Kembali</p>
    </div>
    <button class="no-print" onclick="window.print()">🖨️ Print</button>
</body>
</html>`, transaction.TotalAmount, transaction.CashReceived, transaction.ChangeAmount)

	return html
}

func SetupRouter() *gin.Engine {
	r := gin.Default()

	// CORS configuration
	r.Use(cors.New(cors.Config{
		AllowOrigins: []string{
			"http://localhost:3000", "http://localhost:3001", "http://localhost:3002", "http://localhost:3003", "http://localhost:3004", "http://localhost:3005", "http://localhost:3006", "http://localhost:3007",
			"http://127.0.0.1:3000", "http://127.0.0.1:3001", "http://127.0.0.1:3002", "http://127.0.0.1:3003", "http://127.0.0.1:3004", "http://127.0.0.1:3005", "http://127.0.0.1:3006", "http://127.0.0.1:3007",
			"https://posumkm.busines.biz.id", "http://posumkm.busines.biz.id",
		},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "X-Requested-With"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Request logging middleware
	r.Use(func(c *gin.Context) {
		start := time.Now()
		c.Next()
		latency := time.Since(start)
		status := c.Writer.Status()

		if status >= 400 {
			gin.DefaultWriter.Write([]byte(
				fmt.Sprintf("[%s] %s %s %d %s\n",
					time.Now().Format("2006-01-02 15:04:05"),
					c.Request.Method,
					c.Request.URL.Path,
					status,
					latency,
				)))
		}
	})

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":    "healthy",
			"service":   "POS UMKM API",
			"version":   "1.0.0",
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	// Auth routes (no prefix)
	r.POST("/login", func(c *gin.Context) {
		var req models.LoginRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(400, utils.ErrorResponse("Invalid request", err))
			return
		}

		var user models.User
		if err := config.DB.Where("username = ?", req.Username).First(&user).Error; err != nil {
			c.JSON(401, utils.ErrorResponse("Username atau password salah", nil))
			return
		}

		// Check password with bcrypt
		if !utils.CheckPasswordHash(req.Password, user.Password) {
			c.JSON(401, utils.ErrorResponse("Username atau password salah", nil))
			return
		}

		// Generate JWT token
		token, err := utils.GenerateToken(user.ID, user.Username, user.Role)
		if err != nil {
			c.JSON(500, utils.ErrorResponse("Gagal generate token", err))
			return
		}

		// Update last login
		config.DB.Model(&user).Update("last_login", time.Now())

		response := utils.SuccessResponse("Login berhasil", gin.H{
			"id":       user.ID,
			"username": user.Username,
			"name":     user.FullName,
			"role":     user.Role,
			"token":    token,
		})
		c.JSON(200, response)
	})

	// KASIR Routes - untuk transaksi penjualan
	kasir := r.Group("/kasir")
	{
		transactionCtrl := &controllers.TransactionController{}
		kasir.POST("/transaksi", transactionCtrl.CreateTransaction)
		kasir.GET("/transaksi", transactionCtrl.GetAllTransactions)
		kasir.GET("/transaksi/:id", transactionCtrl.GetTransactionByID)
		kasir.GET("/transaksi/:id/struk", func(c *gin.Context) {
			id := c.Param("id")

			var transaction models.Transaction
			if err := config.DB.First(&transaction, id).Error; err != nil {
				c.JSON(404, utils.ErrorResponse("Transaksi tidak ditemukan", err))
				return
			}

			var details []models.TransactionDetail
			config.DB.Where("transaction_id = ?", id).Find(&details)

			receipt := gin.H{
				"transaction":   transaction,
				"details":       details,
				"store_name":    "UMKM Store",
				"store_address": "Jl. Contoh No. 123",
				"print_time":    time.Now().Format("2006-01-02 15:04:05"),
			}

			response := utils.SuccessResponse("Receipt generated", receipt)
			c.JSON(200, response)
		})

		kasir.GET("/transaksi/:id/struk/print", func(c *gin.Context) {
			id := c.Param("id")

			var transaction models.Transaction
			if err := config.DB.First(&transaction, id).Error; err != nil {
				c.String(404, "Transaksi tidak ditemukan")
				return
			}

			var details []models.TransactionDetail
			config.DB.Where("transaction_id = ?", id).Find(&details)

			html := generateReceiptHTML(transaction, details)
			c.Header("Content-Type", "text/html; charset=utf-8")
			c.String(200, html)
		})

		// Product list untuk kasir
		productCtrl := &controllers.ProductController{}
		kasir.GET("/produk", productCtrl.GetAllProducts)
		kasir.GET("/produk/:id", productCtrl.GetProductByID)
	}

	// LAPORAN Routes - untuk reporting
	laporan := r.Group("/laporan")
	{
		transactionCtrl := &controllers.TransactionController{}
		laporan.GET("/harian", transactionCtrl.GetDailyReport)
		laporan.GET("/bulanan", transactionCtrl.GetMonthlyReport)
		laporan.GET("/perbandingan-periode", transactionCtrl.GetPeriodComparison)
		laporan.GET("/jam-sibuk", transactionCtrl.GetPeakHours)

		dashboardCtrl := &controllers.DashboardController{}
		laporan.GET("/ringkasan", dashboardCtrl.GetDashboardSummary)
		laporan.GET("/produk-terlaris", dashboardCtrl.GetTopProducts)
		laporan.GET("/tren-penjualan", dashboardCtrl.GetSalesTrend)

		profitCtrl := &controllers.ProfitController{}
		laporan.GET("/laba-rugi", profitCtrl.GetProfitSummary)
		laporan.GET("/analisis-produk", profitCtrl.GetProductProfitAnalysis)
		laporan.GET("/tren-laba", profitCtrl.GetDailyProfitTrend)
		laporan.GET("/analisis-lengkap", profitCtrl.GetProfitAnalysis)

		expenseCtrl := &controllers.ExpenseController{}
		laporan.GET("/pengeluaran", expenseCtrl.GetAllExpenses)
		laporan.GET("/pengeluaran/ringkasan", expenseCtrl.GetExpenseSummary)

		reportCtrl := &controllers.ReportController{}
		laporan.GET("/export/harian", reportCtrl.ExportDailyReportCSV)
		laporan.GET("/export/bulanan", reportCtrl.ExportMonthlyReportCSV)
		laporan.GET("/export/semua", reportCtrl.ExportAllTransactionsCSV)
	}

	// PRODUKSI Routes - untuk production management
	produksi := r.Group("/produksi", utils.AuthMiddleware(), utils.AdminOnly())
	{
		productionCtrl := &controllers.ProductionController{}
		produksi.GET("", productionCtrl.GetAllProductions)
		produksi.POST("", productionCtrl.ProduceProduct)
		produksi.POST("/hitung-biaya/:id", productionCtrl.CalculateProductCost)
		produksi.GET("/stok-maksimal/:id", productionCtrl.CalculateMaxProduction)

		// Recipe management
		recipeCtrl := &controllers.RecipeController{}
		produksi.GET("/resep/:product_id", recipeCtrl.GetRecipesByProduct)
		produksi.POST("/resep", recipeCtrl.SaveRecipes)
		produksi.DELETE("/resep/:id", recipeCtrl.DeleteRecipe)
	}

	// PRODUK Routes - untuk product management
	produk := r.Group("/produk")
	{
		productCtrl := &controllers.ProductController{}
		produk.GET("", productCtrl.GetAllProducts)
		produk.GET("/:id", productCtrl.GetProductByID)
		produk.GET("/:id/resep", productCtrl.GetProductRecipes)

		// Admin only
		adminProduk := produk.Group("", utils.AuthMiddleware(), utils.AdminOnly())
		{
			adminProduk.POST("", productCtrl.CreateProduct)
			adminProduk.PUT("/:id", productCtrl.UpdateProduct)
			adminProduk.DELETE("/:id", productCtrl.DeleteProduct)
		}
	}

	// BAHAN-BAKU Routes - untuk material management
	bahanBaku := r.Group("/bahan-baku")
	{
		materialCtrl := &controllers.MaterialController{}
		bahanBaku.GET("", materialCtrl.GetAllMaterials)
		bahanBaku.GET("/stok-menipis", materialCtrl.GetLowStockMaterials)

		// Admin only
		adminBahan := bahanBaku.Group("", utils.AuthMiddleware(), utils.AdminOnly())
		{
			adminBahan.POST("", materialCtrl.CreateMaterial)
			adminBahan.PUT("/:id", materialCtrl.UpdateMaterial)
			adminBahan.DELETE("/:id", materialCtrl.DeleteMaterial)
			adminBahan.POST("/:id/restock", materialCtrl.RestockMaterial)
		}
	}

	// PENGELUARAN Routes - untuk expense management
	pengeluaran := r.Group("/pengeluaran", utils.AuthMiddleware())
	{
		expenseCtrl := &controllers.ExpenseController{}
		pengeluaran.GET("", expenseCtrl.GetAllExpenses)
		pengeluaran.GET("/ringkasan", expenseCtrl.GetExpenseSummary)
		pengeluaran.POST("", expenseCtrl.CreateExpense)
		pengeluaran.PUT("/:id", expenseCtrl.UpdateExpense)
		pengeluaran.DELETE("/:id", expenseCtrl.DeleteExpense)
	}

	// PENGATURAN Routes - untuk settings
	pengaturan := r.Group("/pengaturan", utils.AuthMiddleware(), utils.AdminOnly())
	{
		settingsCtrl := &controllers.SettingsController{}
		pengaturan.GET("", settingsCtrl.GetSettings)
		pengaturan.PUT("", settingsCtrl.UpdateSettings)
	}

	// Keep old API routes for backward compatibility
	api := r.Group("/api")
	{
		productCtrl := &controllers.ProductController{}
		productRoutes := api.Group("/products")
		{
			productRoutes.GET("", productCtrl.GetAllProducts)
			productRoutes.GET("/:id", productCtrl.GetProductByID)
			productRoutes.GET("/:id/recipes", productCtrl.GetProductRecipes)

			// Admin only
			productRoutes.POST("", utils.AuthMiddleware(), utils.AdminOnly(), productCtrl.CreateProduct)
			productRoutes.PUT("/:id", utils.AuthMiddleware(), utils.AdminOnly(), productCtrl.UpdateProduct)
			productRoutes.DELETE("/:id", utils.AuthMiddleware(), utils.AdminOnly(), productCtrl.DeleteProduct)
		}

		// Material routes (Admin only untuk create/update)
		materialCtrl := &controllers.MaterialController{}
		materialRoutes := api.Group("/materials")
		{
			materialRoutes.GET("", materialCtrl.GetAllMaterials)
			materialRoutes.GET("/low-stock", materialCtrl.GetLowStockMaterials)

			// Admin only
			materialRoutes.POST("", utils.AuthMiddleware(), utils.AdminOnly(), materialCtrl.CreateMaterial)
			materialRoutes.PUT("/:id", utils.AuthMiddleware(), utils.AdminOnly(), materialCtrl.UpdateMaterial)
			materialRoutes.DELETE("/:id", utils.AuthMiddleware(), utils.AdminOnly(), materialCtrl.DeleteMaterial)
			materialRoutes.POST("/:id/restock", utils.AuthMiddleware(), utils.AdminOnly(), materialCtrl.RestockMaterial)
		}

		// Recipe routes (Admin only)
		recipeCtrl := &controllers.RecipeController{}
		recipeRoutes := api.Group("/recipes")
		{
			recipeRoutes.GET("/product/:product_id", recipeCtrl.GetRecipesByProduct)

			// Admin only
			recipeRoutes.POST("", utils.AuthMiddleware(), utils.AdminOnly(), recipeCtrl.SaveRecipes)
			recipeRoutes.DELETE("/:id", utils.AuthMiddleware(), utils.AdminOnly(), recipeCtrl.DeleteRecipe)
		}

		// Transaction routes (KASIR)
		transactionCtrl := &controllers.TransactionController{}
		api.POST("/transactions", transactionCtrl.CreateTransaction)
		api.GET("/transactions", transactionCtrl.GetAllTransactions)
		api.GET("/transactions/:id", transactionCtrl.GetTransactionByID)
		api.GET("/transactions/report/daily", transactionCtrl.GetDailyReport)
		api.GET("/transactions/report/monthly", transactionCtrl.GetMonthlyReport)
		api.GET("/transactions/:id/receipt", func(c *gin.Context) {
			id := c.Param("id")

			var transaction models.Transaction
			if err := config.DB.First(&transaction, id).Error; err != nil {
				c.JSON(404, utils.ErrorResponse("Transaksi tidak ditemukan", err))
				return
			}

			var details []models.TransactionDetail
			config.DB.Where("transaction_id = ?", id).Find(&details)

			receipt := gin.H{
				"transaction":   transaction,
				"details":       details,
				"store_name":    "UMKM Store",
				"store_address": "Jl. Contoh No. 123",
				"print_time":    time.Now().Format("2006-01-02 15:04:05"),
			}

			response := utils.SuccessResponse("Receipt generated", receipt)
			c.JSON(200, response)
		})

		api.GET("/transactions/:id/receipt/print", func(c *gin.Context) {
			id := c.Param("id")

			var transaction models.Transaction
			if err := config.DB.First(&transaction, id).Error; err != nil {
				c.String(404, "Transaksi tidak ditemukan")
				return
			}

			var details []models.TransactionDetail
			config.DB.Where("transaction_id = ?", id).Find(&details)

			html := generateReceiptHTML(transaction, details)
			c.Header("Content-Type", "text/html; charset=utf-8")
			c.String(200, html)
		})

		// Dashboard routes
		dashboardCtrl := &controllers.DashboardController{}
		api.GET("/dashboard/summary", dashboardCtrl.GetDashboardSummary)
		api.GET("/dashboard/top-products", dashboardCtrl.GetTopProducts)
		api.GET("/dashboard/sales-trend", dashboardCtrl.GetSalesTrend)

		// Production routes (Admin only)
		productionCtrl := &controllers.ProductionController{}
		adminProduction := api.Group("/production", utils.AuthMiddleware(), utils.AdminOnly())
		{
			adminProduction.POST("/calculate-cost/:id", productionCtrl.CalculateProductCost)
			adminProduction.POST("/max-production/:id", productionCtrl.CalculateMaxProduction)
			adminProduction.POST("/produce", productionCtrl.ProduceProduct)
		}

		// Expense routes
		expenseCtrl := &controllers.ExpenseController{}
		api.GET("/expenses", expenseCtrl.GetAllExpenses)
		api.GET("/expenses/summary", expenseCtrl.GetExpenseSummary)

		adminExpenses := api.Group("/expenses", utils.AuthMiddleware())
		{
			adminExpenses.POST("", expenseCtrl.CreateExpense)
			adminExpenses.PUT("/:id", expenseCtrl.UpdateExpense)
			adminExpenses.DELETE("/:id", expenseCtrl.DeleteExpense)
		}

		// Profit Analysis routes
		profitCtrl := &controllers.ProfitController{}
		api.GET("/profit/summary", profitCtrl.GetProfitSummary)
		api.GET("/profit/products", profitCtrl.GetProductProfitAnalysis)
		api.GET("/profit/trend", profitCtrl.GetDailyProfitTrend)
		api.GET("/profit/analysis", profitCtrl.GetProfitAnalysis)

		// Settings routes (Admin only)
		settingsCtrl := &controllers.SettingsController{}
		adminSettings := api.Group("/settings", utils.AuthMiddleware(), utils.AdminOnly())
		{
			adminSettings.GET("", settingsCtrl.GetSettings)
			adminSettings.PUT("", settingsCtrl.UpdateSettings)
		}

		// Productions routes (Admin only)
		api.GET("/productions", utils.AuthMiddleware(), productionCtrl.GetAllProductions)
		api.POST("/productions", utils.AuthMiddleware(), utils.AdminOnly(), productionCtrl.ProduceProduct)
	}

	// 404 handler
	r.NoRoute(func(c *gin.Context) {
		c.JSON(404, gin.H{
			"error":  "Endpoint not found",
			"path":   c.Request.URL.Path,
			"method": c.Request.Method,
		})
	})

	return r
}
