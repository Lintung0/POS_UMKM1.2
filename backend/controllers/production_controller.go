package controllers

import (
	"backend/config"
	"backend/models"
	"backend/utils"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type ProductionController struct{}

// GetAllProductions retrieves production history
func (pc *ProductionController) GetAllProductions(c *gin.Context) {
	var productions []models.Production

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset := (page - 1) * limit

	var total int64
	config.DB.Model(&models.Production{}).Count(&total)

	result := config.DB.
		Preload("Product").
		Preload("Materials.Material").
		Limit(limit).
		Offset(offset).
		Order("created_at desc").
		Find(&productions)

	if result.Error != nil {
		response := utils.ErrorResponse("Gagal mengambil data produksi", result.Error)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	responseData := gin.H{
		"productions": productions,
		"pagination": gin.H{
			"page":       page,
			"limit":      limit,
			"total":      total,
			"total_page": (int(total) + limit - 1) / limit,
		},
	}

	response := utils.SuccessResponse("Berhasil mengambil data produksi", responseData)
	c.JSON(http.StatusOK, response)
}

// Calculate cost price from materials
func (pc *ProductionController) CalculateProductCost(c *gin.Context) {
	productID := c.Param("id")
	id, err := strconv.Atoi(productID)
	if err != nil {
		response := utils.ErrorResponse("ID produk tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Get product
	var product models.Product
	if err := config.DB.First(&product, id).Error; err != nil {
		response := utils.ErrorResponse("Produk tidak ditemukan", err)
		c.JSON(http.StatusNotFound, response)
		return
	}

	// Get recipes with materials
	var recipes []models.Recipe
	if err := config.DB.Where("product_id = ?", id).Preload("Material").Find(&recipes).Error; err != nil {
		response := utils.ErrorResponse("Gagal mengambil resep", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	if len(recipes) == 0 {
		response := utils.ErrorResponse("Produk belum memiliki resep", nil)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Calculate total cost from materials
	var totalCost float64
	var costBreakdown []map[string]interface{}

	for _, recipe := range recipes {
		materialCost := recipe.QuantityUsed * recipe.Material.PricePerUnit
		totalCost += materialCost

		costBreakdown = append(costBreakdown, map[string]interface{}{
			"material_name":  recipe.Material.Name,
			"quantity_used":  recipe.QuantityUsed,
			"unit":           recipe.Material.Unit,
			"price_per_unit": recipe.Material.PricePerUnit,
			"total_cost":     materialCost,
		})
	}

	// Update product cost price
	if err := config.DB.Model(&product).Update("cost_price", totalCost).Error; err != nil {
		response := utils.ErrorResponse("Gagal update harga modal", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Harga modal berhasil dihitung", map[string]interface{}{
		"product_id":     product.ID,
		"product_name":   product.Name,
		"old_cost_price": product.CostPrice,
		"new_cost_price": totalCost,
		"cost_breakdown": costBreakdown,
		"profit_margin":  product.SellingPrice - totalCost,
	})
	c.JSON(http.StatusOK, response)
}

// Calculate max production based on material stock
func (pc *ProductionController) CalculateMaxProduction(c *gin.Context) {
	productID := c.Param("id")
	id, err := strconv.Atoi(productID)
	if err != nil {
		response := utils.ErrorResponse("ID produk tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	var product models.Product
	if err := config.DB.First(&product, id).Error; err != nil {
		response := utils.ErrorResponse("Produk tidak ditemukan", err)
		c.JSON(http.StatusNotFound, response)
		return
	}

	var recipes []models.Recipe
	if err := config.DB.Where("product_id = ?", id).Preload("Material").Find(&recipes).Error; err != nil {
		response := utils.ErrorResponse("Gagal mengambil resep", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	if len(recipes) == 0 {
		response := utils.ErrorResponse("Produk belum memiliki resep", nil)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	var breakdown []map[string]interface{}
	var maxProduction float64 = -1

	for _, recipe := range recipes {
		maxProd := recipe.Material.Stock / recipe.QuantityUsed

		breakdown = append(breakdown, map[string]interface{}{
			"material_name":   recipe.Material.Name,
			"available_stock": recipe.Material.Stock,
			"quantity_needed": recipe.QuantityUsed,
			"max_production":  maxProd,
		})

		if maxProduction == -1 || maxProd < maxProduction {
			maxProduction = maxProd
		}
	}

	response := utils.SuccessResponse("Berhasil menghitung stok maksimal", map[string]interface{}{
		"product_id":     product.ID,
		"product_name":   product.Name,
		"max_production": int(maxProduction),
		"breakdown":      breakdown,
	})
	c.JSON(http.StatusOK, response)
}

// Produce products from materials
func (pc *ProductionController) ProduceProduct(c *gin.Context) {
	var req models.ProductionRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		response := utils.ErrorResponse("Data tidak valid", err)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Start atomic transaction
	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
			log.Printf("Production transaction rolled back: %v", r)
		}
	}()

	// Get product with recipes and materials
	var product models.Product
	if err := tx.Preload("Recipes.Material").First(&product, req.ProductID).Error; err != nil {
		tx.Rollback()
		response := utils.ErrorResponse("Produk tidak ditemukan", err)
		c.JSON(http.StatusNotFound, response)
		return
	}

	// Check if product has recipes
	if len(product.Recipes) == 0 {
		tx.Rollback()
		response := utils.ErrorResponse("Produk belum memiliki resep bahan baku", nil)
		c.JSON(http.StatusBadRequest, response)
		return
	}

	// Calculate total materials needed and validate stock
	var materialUsage []map[string]interface{}
	var totalCost float64

	for _, recipe := range product.Recipes {
		totalNeeded := recipe.QuantityUsed * float64(req.Quantity)

		// Check material stock availability
		if recipe.Material.Stock < totalNeeded {
			tx.Rollback()
			msg := fmt.Sprintf("Bahan baku %s tidak cukup. Tersedia: %.2f %s, Dibutuhkan: %.2f %s",
				recipe.Material.Name, recipe.Material.Stock, recipe.Material.Unit,
				totalNeeded, recipe.Material.Unit)
			response := utils.ErrorResponse(msg, nil)
			c.JSON(http.StatusBadRequest, response)
			return
		}

		// Calculate cost
		materialCost := totalNeeded * recipe.Material.PricePerUnit
		totalCost += materialCost

		materialUsage = append(materialUsage, map[string]interface{}{
			"material_id":   recipe.MaterialID,
			"material_name": recipe.Material.Name,
			"quantity_used": totalNeeded,
			"unit":          recipe.Material.Unit,
			"cost":          materialCost,
		})
	}

	// Generate batch number
	batchNumber := fmt.Sprintf("PROD-%d-%d", req.ProductID, time.Now().Unix())

	// Create production record
	costPerUnit := totalCost / float64(req.Quantity)
	production := models.Production{
		ProductID:        req.ProductID,
		QuantityProduced: req.Quantity,
		TotalCost:        totalCost,
		CostPerUnit:      costPerUnit,
		BatchNumber:      batchNumber,
		ProducedBy:       req.ProducedBy,
		Notes:            req.Notes,
	}

	if err := tx.Create(&production).Error; err != nil {
		tx.Rollback()
		response := utils.ErrorResponse("Gagal membuat record produksi", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Reduce material stock atomically and save production materials
	for _, recipe := range product.Recipes {
		totalNeeded := recipe.QuantityUsed * float64(req.Quantity)
		materialCost := totalNeeded * recipe.Material.PricePerUnit

		result := tx.Model(&models.RawMaterial{}).
			Where("id = ? AND stock >= ?", recipe.MaterialID, totalNeeded).
			Update("stock", gorm.Expr("stock - ?", totalNeeded))

		if result.Error != nil {
			tx.Rollback()
			response := utils.ErrorResponse("Gagal mengurangi stok bahan baku", result.Error)
			c.JSON(http.StatusInternalServerError, response)
			return
		}

		if result.RowsAffected == 0 {
			tx.Rollback()
			response := utils.ErrorResponse("Stok bahan baku berubah saat produksi", nil)
			c.JSON(http.StatusConflict, response)
			return
		}

		// Save production material detail
		prodMaterial := models.ProductionMaterial{
			ProductionID: production.ID,
			MaterialID:   recipe.MaterialID,
			QuantityUsed: totalNeeded,
			Cost:         materialCost,
		}

		if err := tx.Create(&prodMaterial).Error; err != nil {
			tx.Rollback()
			response := utils.ErrorResponse("Gagal menyimpan detail bahan produksi", err)
			c.JSON(http.StatusInternalServerError, response)
			return
		}
	}

	// Add to product stock
	if err := tx.Model(&product).Update("stock", gorm.Expr("stock + ?", req.Quantity)).Error; err != nil {
		tx.Rollback()
		response := utils.ErrorResponse("Gagal menambah stok produk", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Update product cost price based on materials
	if err := tx.Model(&product).Update("cost_price", costPerUnit).Error; err != nil {
		tx.Rollback()
		response := utils.ErrorResponse("Gagal update harga modal", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	// Commit transaction
	if err := tx.Commit().Error; err != nil {
		response := utils.ErrorResponse("Gagal commit produksi", err)
		c.JSON(http.StatusInternalServerError, response)
		return
	}

	response := utils.SuccessResponse("Produksi berhasil", map[string]interface{}{
		"production_id":     production.ID,
		"batch_number":      batchNumber,
		"product_id":        product.ID,
		"product_name":      product.Name,
		"quantity_produced": req.Quantity,
		"new_stock":         product.Stock + req.Quantity,
		"cost_per_unit":     costPerUnit,
		"total_cost":        totalCost,
		"material_usage":    materialUsage,
		"profit_margin":     product.SellingPrice - costPerUnit,
	})
	c.JSON(http.StatusOK, response)
}
