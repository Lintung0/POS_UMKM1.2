package controllers

import (
    "fmt"
    "net/http"
    "backend/config"
    "backend/models"
    "backend/utils"

    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type RecipeController struct{}

// GetRecipesByProduct - Get all recipes for a product
func (rc *RecipeController) GetRecipesByProduct(c *gin.Context) {
    productID := c.Param("product_id")
    
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

// SaveRecipes - Save or update recipes for a product
func (rc *RecipeController) SaveRecipes(c *gin.Context) {
    var request models.RecipeBatchRequest
    
    if err := c.ShouldBindJSON(&request); err != nil {
        response := utils.ErrorResponse("Data tidak valid", err)
        c.JSON(http.StatusBadRequest, response)
        return
    }
    
    // Validate product exists
    var product models.Product
    if err := config.DB.First(&product, request.ProductID).Error; err != nil {
        if err == gorm.ErrRecordNotFound {
            response := utils.ErrorResponse("Produk tidak ditemukan", nil)
            c.JSON(http.StatusNotFound, response)
            return
        }
        response := utils.ErrorResponse("Gagal validasi produk", err)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Validate all materials exist
    for _, recipeReq := range request.Recipes {
        var material models.RawMaterial
        if err := config.DB.First(&material, recipeReq.MaterialID).Error; err != nil {
            if err == gorm.ErrRecordNotFound {
                response := utils.ErrorResponse(fmt.Sprintf("Bahan baku dengan ID %d tidak ditemukan", recipeReq.MaterialID), nil)
                c.JSON(http.StatusNotFound, response)
                return
            }
            response := utils.ErrorResponse("Gagal validasi bahan baku", err)
            c.JSON(http.StatusInternalServerError, response)
            return
        }
    }
    
    // Start transaction
    tx := config.DB.Begin()
    defer func() {
        if r := recover(); r != nil {
            tx.Rollback()
        }
    }()
    
    // Delete existing recipes for this product
    if err := tx.Where("product_id = ?", request.ProductID).
        Delete(&models.Recipe{}).Error; err != nil {
        tx.Rollback()
        response := utils.ErrorResponse("Gagal menghapus resep lama", err)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    // Insert new recipes
    for _, recipeReq := range request.Recipes {
        recipe := models.Recipe{
            ProductID:    request.ProductID,
            MaterialID:   recipeReq.MaterialID,
            QuantityUsed: recipeReq.QuantityUsed,
            Notes:        recipeReq.Notes,
        }
        
        if err := tx.Create(&recipe).Error; err != nil {
            tx.Rollback()
            response := utils.ErrorResponse("Gagal menyimpan resep", err)
            c.JSON(http.StatusInternalServerError, response)
            return
        }
    }
    
    // Update product has_recipe flag
    if len(request.Recipes) > 0 {
        if err := tx.Model(&models.Product{}).
            Where("id = ?", request.ProductID).
            Update("has_recipe", true).Error; err != nil {
            tx.Rollback()
            response := utils.ErrorResponse("Gagal update flag resep", err)
            c.JSON(http.StatusInternalServerError, response)
            return
        }
    } else {
        if err := tx.Model(&models.Product{}).
            Where("id = ?", request.ProductID).
            Update("has_recipe", false).Error; err != nil {
            tx.Rollback()
            response := utils.ErrorResponse("Gagal update flag resep", err)
            c.JSON(http.StatusInternalServerError, response)
            return
        }
    }
    
    // Commit transaction
    if err := tx.Commit().Error; err != nil {
        response := utils.ErrorResponse("Gagal menyimpan resep", err)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    response := utils.SuccessResponse("Resep berhasil disimpan", nil)
    c.JSON(http.StatusOK, response)
}

// DeleteRecipe - Delete a recipe
func (rc *RecipeController) DeleteRecipe(c *gin.Context) {
    id := c.Param("id")
    
    result := config.DB.Delete(&models.Recipe{}, id)
    if result.Error != nil {
        response := utils.ErrorResponse("Gagal menghapus resep", result.Error)
        c.JSON(http.StatusInternalServerError, response)
        return
    }
    
    if result.RowsAffected == 0 {
        response := utils.ErrorResponse("Resep tidak ditemukan", nil)
        c.JSON(http.StatusNotFound, response)
        return
    }
    
    response := utils.SuccessResponse("Resep berhasil dihapus", nil)
    c.JSON(http.StatusOK, response)
}