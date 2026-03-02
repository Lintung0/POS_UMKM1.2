package controllers

import (
    "net/http"
    "strconv"
    "backend/config"
    "backend/models"
    "backend/utils"

    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type MaterialController struct{}

// GetAllMaterials - Get all raw materials
func (mc *MaterialController) GetAllMaterials(c *gin.Context) {
    var materials []models.RawMaterial
    
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    offset := (page - 1) * limit
    
    var total int64
    config.DB.Model(&models.RawMaterial{}).Count(&total)
    
    result := config.DB.
        Limit(limit).
        Offset(offset).
        Order("created_at desc").
        Find(&materials)
    
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil data bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    responseData := gin.H{
        "materials": materials,
        "pagination": gin.H{
            "page":       page,
            "limit":      limit,
            "total":      total,
            "total_page": (int(total) + limit - 1) / limit,
        },
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data bahan baku", responseData)
    c.JSON(http.StatusOK, response)
}

// GetLowStockMaterials - Get materials with low stock
func (mc *MaterialController) GetLowStockMaterials(c *gin.Context) {
    var materials []models.LowStockMaterial
    
    // Raw SQL query to get low stock materials (only CRITICAL)
    query := `
        SELECT 
            id,
            name,
            stock,
            unit,
            min_stock,
            'CRITICAL' as stock_status
        FROM raw_materials
        WHERE stock < min_stock
        ORDER BY stock ASC
    `
    
    result := config.DB.Raw(query).Scan(&materials)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil data stok rendah", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Ensure empty array instead of null
    if materials == nil {
        materials = []models.LowStockMaterial{}
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data stok rendah", materials)
    c.JSON(http.StatusOK, response)
}

// CreateMaterial - Create new raw material
func (mc *MaterialController) CreateMaterial(c *gin.Context) {
    var request models.RawMaterialRequest
    
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    material := models.RawMaterial{
        Name:         request.Name,
        Stock:        request.Stock,
        Unit:         request.Unit,
        PricePerUnit: request.CostPerUnit,
        MinStock:     request.MinStock,
        Supplier:     request.Supplier,
    }
    
    result := config.DB.Create(&material)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal membuat bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Bahan baku berhasil dibuat", material)
    c.JSON(http.StatusCreated, response)
}

// UpdateMaterial - Update existing raw material
func (mc *MaterialController) UpdateMaterial(c *gin.Context) {
    id := c.Param("id")
    
    var material models.RawMaterial
    result := config.DB.First(&material, id)
    if result.Error != nil {
        if result.Error == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Bahan baku tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal mengambil data bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    var request models.RawMaterialRequest
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    // Update material
    material.Name = request.Name
    material.Stock = request.Stock
    material.Unit = request.Unit
    material.PricePerUnit = request.CostPerUnit
    material.MinStock = request.MinStock
    material.Supplier = request.Supplier
    
    result = config.DB.Save(&material)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengupdate bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Bahan baku berhasil diupdate", material)
    c.JSON(http.StatusOK, response)
}

// DeleteMaterial - Delete raw material
func (mc *MaterialController) DeleteMaterial(c *gin.Context) {
    id := c.Param("id")
    
    // Check if material exists
    var material models.RawMaterial
    result := config.DB.First(&material, id)
    if result.Error != nil {
        if result.Error == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Bahan baku tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal mengambil data bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Check if material is used in recipes
    var recipeCount int64
    config.DB.Model(&models.Recipe{}).Where("material_id = ?", id).Count(&recipeCount)
    if recipeCount > 0 {
        response := utils.ErrorResponse("Bahan baku tidak dapat dihapus karena masih digunakan dalam resep", nil)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    // Delete material
    result = config.DB.Delete(&material)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal menghapus bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Bahan baku berhasil dihapus", nil)
    c.JSON(http.StatusOK, response)
}

// RestockMaterial - Add stock to existing material
func (mc *MaterialController) RestockMaterial(c *gin.Context) {
    id := c.Param("id")
    
    var request struct {
        Quantity float64 `json:"quantity" binding:"required,min=0.01"`
        Notes    string  `json:"notes"`
    }
    
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    var material models.RawMaterial
    result := config.DB.First(&material, id)
    if result.Error != nil {
        if result.Error == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Bahan baku tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal mengambil data bahan baku", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    oldStock := material.Stock
    newStock := oldStock + request.Quantity
    
    // Update stock
    result = config.DB.Model(&material).Update("stock", newStock)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal menambah stok", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    responseData := gin.H{
        "material":  material.Name,
        "old_stock": oldStock,
        "added":     request.Quantity,
        "new_stock": newStock,
        "unit":      material.Unit,
    }
    
    response := utils.SuccessResponse("Stok berhasil ditambahkan", responseData)
    c.JSON(http.StatusOK, response)
}