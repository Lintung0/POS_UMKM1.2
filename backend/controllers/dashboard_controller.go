package controllers

import (
    "net/http"
    "time"
    "backend/config"
    "backend/utils"

    "github.com/gin-gonic/gin"
)

type DashboardController struct{}

// GetDashboardSummary - Get dashboard summary data
func (dc *DashboardController) GetDashboardSummary(c *gin.Context) {
    today := time.Now().Format("2006-01-02")
    currentMonth := time.Now().Format("2006-01")
    
    var summary gin.H = gin.H{
        "total_products":      0,
        "total_materials":     0,
        "total_transactions":  0,
        "today_sales":         0.0,
        "today_profit":        0.0,
        "monthly_sales":       0.0,
        "monthly_profit":      0.0,
        "low_stock_count":     0,
    }
    
    // Count products
    var totalProducts int64
    config.DB.Model(&struct{}{}).Table("products").Where("deleted_at IS NULL").Count(&totalProducts)
    summary["total_products"] = totalProducts
    
    // Count materials
    var totalMaterials int64
    config.DB.Model(&struct{}{}).Table("raw_materials").Where("deleted_at IS NULL").Count(&totalMaterials)
    summary["total_materials"] = totalMaterials
    
    // Count transactions
    var totalTransactions int64
    config.DB.Model(&struct{}{}).Table("transactions").Count(&totalTransactions)
    summary["total_transactions"] = totalTransactions
    
    // Today's sales and profit
    var todayResult struct {
        TotalSales  float64
        TotalProfit float64
    }
    config.DB.Raw("SELECT COALESCE(SUM(total_amount), 0) as total_sales, COALESCE(SUM(total_profit), 0) as total_profit FROM transactions WHERE DATE(created_at) = ?", today).Scan(&todayResult)
    summary["today_sales"] = todayResult.TotalSales
    summary["today_profit"] = todayResult.TotalProfit
    
    // Monthly sales and profit
    var monthlyResult struct {
        TotalSales  float64
        TotalProfit float64
    }
    config.DB.Raw("SELECT COALESCE(SUM(total_amount), 0) as total_sales, COALESCE(SUM(total_profit), 0) as total_profit FROM transactions WHERE DATE_FORMAT(created_at, '%Y-%m') = ?", currentMonth).Scan(&monthlyResult)
    summary["monthly_sales"] = monthlyResult.TotalSales
    summary["monthly_profit"] = monthlyResult.TotalProfit
    
    // Low stock count
    var lowStockCount int64
    config.DB.Model(&struct{}{}).Table("raw_materials").Where("stock <= min_stock * 2 AND deleted_at IS NULL").Count(&lowStockCount)
    summary["low_stock_count"] = lowStockCount
    
    response := utils.SuccessResponse("Berhasil mengambil data dashboard", summary)
    c.JSON(http.StatusOK, response)
}

// GetTopProducts - Get top selling products
func (dc *DashboardController) GetTopProducts(c *gin.Context) {
    limit := c.DefaultQuery("limit", "5")
    
    var topProducts []struct {
        ProductID   uint    `json:"product_id"`
        ProductName string  `json:"product_name"`
        TotalSold   int     `json:"total_sold"`
        TotalAmount float64 `json:"total_amount"`
        TotalProfit float64 `json:"total_profit"`
    }
    
    query := `
        SELECT 
            p.id as product_id,
            p.name as product_name,
            SUM(td.qty) as total_sold,
            SUM(td.total_price) as total_amount,
            SUM(td.profit_per_unit * td.qty) as total_profit
        FROM transaction_details td
        JOIN products p ON td.product_id = p.id
        GROUP BY p.id, p.name
        ORDER BY total_sold DESC
        LIMIT ?
    `
    
    result := config.DB.Raw(query, limit).Scan(&topProducts)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil data produk terlaris", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data produk terlaris", topProducts)
    c.JSON(http.StatusOK, response)
}

// GetSalesTrend - Get sales trend for last N days
func (dc *DashboardController) GetSalesTrend(c *gin.Context) {
    days := c.DefaultQuery("days", "30")
    
    var salesTrend []struct {
        Date        string  `json:"date"`
        TotalSales  float64 `json:"total_sales"`
        TotalProfit float64 `json:"total_profit"`
        TransactionCount int `json:"transaction_count"`
    }
    
    query := `
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as transaction_count,
            COALESCE(SUM(total_amount), 0) as total_sales,
            COALESCE(SUM(total_profit), 0) as total_profit
        FROM transactions
        WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
        GROUP BY DATE(created_at)
        ORDER BY date ASC
    `
    
    result := config.DB.Raw(query, days).Scan(&salesTrend)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil tren penjualan", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Berhasil mengambil tren penjualan", salesTrend)
    c.JSON(http.StatusOK, response)
}