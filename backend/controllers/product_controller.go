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

type ProductController struct{}

// GetAllProducts - Get all products with pagination
func (pc *ProductController) GetAllProducts(c *gin.Context) {
    var products []models.Product
    
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    offset := (page - 1) * limit
    
    var total int64
    config.DB.Model(&models.Product{}).Count(&total)
    
    result := config.DB.
        Preload("Recipes.Material").
        Limit(limit).
        Offset(offset).
        Order("created_at desc").
        Find(&products)
    
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil data produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Convert to response format
    var productResponses []models.ProductResponse
    for _, product := range products {
        availableStock := calculateAvailableStock(product)
        hasRecipe := len(product.Recipes) > 0
        productResponses = append(productResponses, models.ProductResponse{
            ID:             product.ID,
            Name:           product.Name,
            CostPrice:      product.CostPrice,
            SellingPrice:   product.SellingPrice,
            Stock:          product.Stock,
            AvailableStock: availableStock,
            Category:       product.Category,
            Image:          product.Image,
            HasRecipe:      hasRecipe,
            Profit:         product.SellingPrice - product.CostPrice,
            CreatedAt:      product.CreatedAt,
        })
    }
    
    responseData := gin.H{
        "products": productResponses,
        "pagination": gin.H{
            "page":       page,
            "limit":      limit,
            "total":      total,
            "total_page": (int(total) + limit - 1) / limit,
        },
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data produk", responseData)
    c.JSON(http.StatusOK, response)
}

func calculateAvailableStock(product models.Product) int {
    if len(product.Recipes) == 0 {
        return product.Stock
    }

    minStock := int(^uint(0) >> 1)
    for _, recipe := range product.Recipes {
        if recipe.Material.ID > 0 && recipe.QuantityUsed > 0 {
            possibleUnits := int(recipe.Material.Stock / recipe.QuantityUsed)
            if possibleUnits < minStock {
                minStock = possibleUnits
            }
        }
    }

    if minStock == int(^uint(0)>>1) {
        return 0
    }
    return minStock
}

// GetProductByID - Get single product by ID
func (pc *ProductController) GetProductByID(c *gin.Context) {
    id := c.Param("id")
    
    var product models.Product
    result := config.DB.
        Preload("Recipes.Material").
        First(&product, id)
    
    if result.Error != nil {
        if result.Error == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Produk tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal mengambil data produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Calculate profit and available stock
    profit := product.SellingPrice - product.CostPrice
    availableStock := calculateAvailableStock(product)
    
    responseData := gin.H{
        "product": product,
        "profit":  profit,
        "available_stock": availableStock,
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data produk", responseData)
    c.JSON(http.StatusOK, response)
}

// CreateProduct - Create new product
func (pc *ProductController) CreateProduct(c *gin.Context) {
    var request models.ProductRequest
    
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    product := models.Product{
        Name:         request.Name,
        CostPrice:    request.CostPrice,
        SellingPrice: request.SellingPrice,
        Stock:        request.Stock,
        Category:     request.Category,
        Image:        request.Image,
    }
    
    result := config.DB.Create(&product)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal membuat produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Produk berhasil dibuat", product)
    c.JSON(http.StatusCreated, response)
}

// UpdateProduct - Update existing product
func (pc *ProductController) UpdateProduct(c *gin.Context) {
    id := c.Param("id")
    
    var product models.Product
    result := config.DB.First(&product, id)
    if result.Error != nil {
        if result.Error == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Produk tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal mengambil data produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    var request models.ProductRequest
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    // Update product (exclude has_recipe to prevent overwrite)
    updates := map[string]interface{}{
        "name":          request.Name,
        "cost_price":    request.CostPrice,
        "selling_price": request.SellingPrice,
        "stock":         request.Stock,
        "category":      request.Category,
    }
    if request.Image != "" {
        updates["image"] = request.Image
    }

    result = config.DB.Model(&product).Updates(updates)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengupdate produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Produk berhasil diupdate", product)
    c.JSON(http.StatusOK, response)
}

// DeleteProduct - Delete product
func (pc *ProductController) DeleteProduct(c *gin.Context) {
    id := c.Param("id")
    
    // Check if product is used in transactions
    var transactionCount int64
    config.DB.Table("transaction_details").Where("product_id = ?", id).Count(&transactionCount)
    if transactionCount > 0 {
        response := utils.ErrorResponse("Produk tidak dapat dihapus karena sudah digunakan dalam transaksi", nil)
        c.JSON(http.StatusBadRequest, response)
        return
    }

    tx := config.DB.Begin()
    defer func() {
        if r := recover(); r != nil {
            tx.Rollback()
        }
    }()

    // Delete related recipes first
    if err := tx.Where("product_id = ?", id).Delete(&models.Recipe{}).Error; err != nil {
        tx.Rollback()
        response := utils.ErrorResponse("Gagal menghapus resep terkait", err)
        c.JSON(http.StatusInternalServerError, response)
        return
    }

    result := tx.Delete(&models.Product{}, id)
    if result.Error != nil {
        tx.Rollback()
        response := utils.ErrorResponse("Gagal menghapus produk", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    if result.RowsAffected == 0 {
        tx.Rollback()
        response := utils.ErrorResponse("Produk tidak ditemukan", nil)
        c.JSON(http.StatusNotFound, response)
        return
    }

    if err := tx.Commit().Error; err != nil {
        response := utils.ErrorResponse("Gagal menghapus produk", err)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Produk berhasil dihapus", nil)
    c.JSON(http.StatusOK, response)
}

// GetProductRecipes - Get recipes for a product
func (pc *ProductController) GetProductRecipes(c *gin.Context) {
    productID := c.Param("id")
    
    var recipes []models.Recipe
    result := config.DB.
        Where("product_id = ?", productID).
        Preload("Material").
        Find(&recipes)
    
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal mengambil data resep", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Berhasil mengambil data resep", recipes)
    c.JSON(http.StatusOK, response)
}