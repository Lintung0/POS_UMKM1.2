package controllers

import (
	"backend/config"
	"backend/models"
	"backend/utils"
	"encoding/json"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
)

type SettingsController struct{}

// GetSettings - Get user settings
func (sc *SettingsController) GetSettings(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, utils.ErrorResponse("Unauthorized", nil))
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, utils.ErrorResponse("User tidak ditemukan", err))
		return
	}

	// Default settings jika belum ada
	if user.Settings == nil || len(user.Settings) == 0 {
		defaultSettings := map[string]interface{}{
			"store_name":              "UMKM Store",
			"store_address":           "Jl. Contoh No. 123",
			"store_phone":             "081234567890",
			"store_email":             "",
			"stock_alert_enabled":     true,
			"stock_alert_threshold":   50,
			"receipt_footer_text":     "Terima kasih!",
			"receipt_show_cashier":    true,
			"receipt_show_tax":        false,
			"tax_enabled":             false,
			"tax_percentage":          10,
			"service_charge_enabled":  false,
			"service_charge_percentage": 5,
		}
		
		jsonData, _ := json.Marshal(defaultSettings)
		user.Settings = datatypes.JSON(jsonData)
		config.DB.Model(&user).Update("settings", user.Settings)
	}

	var settings map[string]interface{}
	json.Unmarshal(user.Settings, &settings)

	c.JSON(http.StatusOK, utils.SuccessResponse("Berhasil mengambil settings", settings))
}

// UpdateSettings - Update user settings
func (sc *SettingsController) UpdateSettings(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, utils.ErrorResponse("Unauthorized", nil))
		return
	}

	var req map[string]interface{}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, utils.ErrorResponse("Data tidak valid", err))
		return
	}

	jsonData, err := json.Marshal(req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("Gagal menyimpan settings", err))
		return
	}

	if err := config.DB.Model(&models.User{}).
		Where("id = ?", userID).
		Update("settings", datatypes.JSON(jsonData)).Error; err != nil {
		c.JSON(http.StatusInternalServerError, utils.ErrorResponse("Gagal menyimpan settings", err))
		return
	}

	c.JSON(http.StatusOK, utils.SuccessResponse("Settings berhasil disimpan", nil))
}
