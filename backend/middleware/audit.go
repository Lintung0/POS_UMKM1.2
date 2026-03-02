package middleware

import (
	"backend/config"
	"backend/models"
	"encoding/json"
	"time"

	"github.com/gin-gonic/gin"
)

// AuditMiddleware logs all data changes
func AuditMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Skip for GET requests
		if c.Request.Method == "GET" || c.Request.Method == "OPTIONS" {
			c.Next()
			return
		}

		// Get user info from context
		userID, _ := c.Get("user_id")
		username, _ := c.Get("username")

		// Store request body for logging
		var requestBody map[string]interface{}
		if c.Request.Body != nil {
			c.ShouldBindJSON(&requestBody)
		}

		c.Next()

		// Log after request is processed
		if c.Writer.Status() >= 200 && c.Writer.Status() < 300 {
			action := ""
			switch c.Request.Method {
			case "POST":
				action = "CREATE"
			case "PUT", "PATCH":
				action = "UPDATE"
			case "DELETE":
				action = "DELETE"
			}

			if action != "" {
				newValueJSON, _ := json.Marshal(requestBody)
				
				audit := models.AuditLog{
					UserID:    userID.(uint),
					Username:  username.(string),
					Action:    action,
					TableName: c.FullPath(),
					IPAddress: c.ClientIP(),
					NewValue:  newValueJSON,
					CreatedAt: time.Now(),
				}

				go func() {
					config.DB.Create(&audit)
				}()
			}
		}
	}
}
