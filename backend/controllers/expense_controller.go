package controllers

import (
	"backend/config"
	"backend/models"
	"backend/utils"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ExpenseController struct{}

// GetAllExpenses - Get expenses with filters
func (ec *ExpenseController) GetAllExpenses(c *gin.Context) {
	var expenses []models.Expense

	period := c.DefaultQuery("period", "month")
	search := c.Query("search")
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	query := config.DB.Model(&models.Expense{})

	// Apply date filter
	now := time.Now()
	if startDate != "" && endDate != "" {
		query = query.Where("date BETWEEN ? AND ?", startDate, endDate)
	} else {
		switch period {
		case "today":
			query = query.Where("date = ?", now.Format("2006-01-02"))
		case "week":
			startOfWeek := now.AddDate(0, 0, -int(now.Weekday())+1)
			endOfWeek := startOfWeek.AddDate(0, 0, 6)
			query = query.Where("date BETWEEN ? AND ?", startOfWeek.Format("2006-01-02"), endOfWeek.Format("2006-01-02"))
		case "month":
			startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
			endOfMonth := startOfMonth.AddDate(0, 1, -1)
			query = query.Where("date BETWEEN ? AND ?", startOfMonth.Format("2006-01-02"), endOfMonth.Format("2006-01-02"))
		case "year":
			startOfYear := time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
			endOfYear := time.Date(now.Year(), 12, 31, 0, 0, 0, 0, now.Location())
			query = query.Where("date BETWEEN ? AND ?", startOfYear.Format("2006-01-02"), endOfYear.Format("2006-01-02"))
		}
	}

	// Apply search filter
	if search != "" {
		query = query.Where("description LIKE ? OR category LIKE ?", "%"+search+"%", "%"+search+"%")
	}

	result := query.Order("date DESC, created_at DESC").Find(&expenses)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengambil data pengeluaran", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Berhasil mengambil data pengeluaran", expenses)
	c.JSON(http.StatusOK, response)
}

// GetExpenseSummary - Get summary with total and breakdown
func (ec *ExpenseController) GetExpenseSummary(c *gin.Context) {
	period := c.DefaultQuery("period", "month")
	startDate := c.Query("start_date")
	endDate := c.Query("end_date")

	query := config.DB.Model(&models.Expense{})

	// Apply date filter (same as GetAllExpenses)
	now := time.Now()
	if startDate != "" && endDate != "" {
		query = query.Where("date BETWEEN ? AND ?", startDate, endDate)
	} else {
		switch period {
		case "today":
			query = query.Where("date = ?", now.Format("2006-01-02"))
		case "week":
			startOfWeek := now.AddDate(0, 0, -int(now.Weekday())+1)
			endOfWeek := startOfWeek.AddDate(0, 0, 6)
			query = query.Where("date BETWEEN ? AND ?", startOfWeek.Format("2006-01-02"), endOfWeek.Format("2006-01-02"))
		case "month":
			startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
			endOfMonth := startOfMonth.AddDate(0, 1, -1)
			query = query.Where("date BETWEEN ? AND ?", startOfMonth.Format("2006-01-02"), endOfMonth.Format("2006-01-02"))
		case "year":
			startOfYear := time.Date(now.Year(), 1, 1, 0, 0, 0, 0, now.Location())
			endOfYear := time.Date(now.Year(), 12, 31, 0, 0, 0, 0, now.Location())
			query = query.Where("date BETWEEN ? AND ?", startOfYear.Format("2006-01-02"), endOfYear.Format("2006-01-02"))
		}
	}

	// Get total
	var totalAmount float64
	var count int64
	query.Select("COALESCE(SUM(amount), 0)").Scan(&totalAmount)
	query.Count(&count)

	// Get breakdown by category
	var categoryBreakdown []struct {
		Category string  `json:"category"`
		Total    float64 `json:"total"`
	}
	query.Select("category, SUM(amount) as total").Group("category").Scan(&categoryBreakdown)

	byCategory := make(map[string]float64)
	for _, item := range categoryBreakdown {
		byCategory[item.Category] = item.Total
	}

	summary := models.ExpenseSummary{
		TotalAmount: totalAmount,
		ByCategory:  byCategory,
		Count:       count,
	}

	response := utils.SuccessResponse("Berhasil mengambil ringkasan pengeluaran", summary)
	c.JSON(http.StatusOK, response)
}

// CreateExpense - Create new expense
func (ec *ExpenseController) CreateExpense(c *gin.Context) {
	var request models.ExpenseRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		response := utils.ErrorResponse("Data tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Parse date
	date, err := time.Parse("2006-01-02", request.Date)
	if err != nil {
		response := utils.ErrorResponse("Format tanggal tidak valid (gunakan YYYY-MM-DD)", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	expense := models.Expense{
		Date:        date,
		Category:    request.Category,
		Description: request.Description,
		Amount:      request.Amount,
		CreatedBy:   c.GetString("username"),
	}

	result := config.DB.Create(&expense)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal menyimpan pengeluaran", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Pengeluaran berhasil ditambahkan", expense)
	c.JSON(http.StatusCreated, response)
}

// UpdateExpense - Update existing expense
func (ec *ExpenseController) UpdateExpense(c *gin.Context) {
	id := c.Param("id")

	var expense models.Expense
	result := config.DB.First(&expense, id)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			response := utils.ErrorResponse("Pengeluaran tidak ditemukan", nil)
			c.JSON(http.StatusNotFound, response)
			return
		}
		response := utils.ErrorResponse("Gagal mengambil data pengeluaran", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	var request models.ExpenseRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		response := utils.ErrorResponse("Data tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Parse date
	date, err := time.Parse("2006-01-02", request.Date)
	if err != nil {
		response := utils.ErrorResponse("Format tanggal tidak valid (gunakan YYYY-MM-DD)", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	expense.Date = date
	expense.Category = request.Category
	expense.Description = request.Description
	expense.Amount = request.Amount

	result = config.DB.Save(&expense)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengupdate pengeluaran", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Pengeluaran berhasil diupdate", expense)
	c.JSON(http.StatusOK, response)
}

// DeleteExpense - Delete expense
func (ec *ExpenseController) DeleteExpense(c *gin.Context) {
	id := c.Param("id")

	result := config.DB.Delete(&models.Expense{}, id)
	if result.Error != nil {
		response := utils.ErrorResponse("Gagal menghapus pengeluaran", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	if result.RowsAffected == 0 {
		response := utils.ErrorResponse("Pengeluaran tidak ditemukan", nil)
		c.JSON(http.StatusNotFound, response)
		return
	}

	response := utils.SuccessResponse("Pengeluaran berhasil dihapus", nil)
	c.JSON(http.StatusOK, response)
}
