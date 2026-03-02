package utils

import (
	"fmt"
	"log"
	"time"
)

// LogInfo logs informational messages
func LogInfo(message string, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("[INFO] %s - %s\n", timestamp, fmt.Sprintf(message, args...))
}

// LogError logs error messages
func LogError(message string, err error, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	if err != nil {
		log.Printf("[ERROR] %s - %s: %v\n", timestamp, fmt.Sprintf(message, args...), err)
	} else {
		log.Printf("[ERROR] %s - %s\n", timestamp, fmt.Sprintf(message, args...))
	}
}

// LogWarning logs warning messages
func LogWarning(message string, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("[WARNING] %s - %s\n", timestamp, fmt.Sprintf(message, args...))
}

// LogDebug logs debug messages (only in debug mode)
func LogDebug(message string, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("[DEBUG] %s - %s\n", timestamp, fmt.Sprintf(message, args...))
}

// LogTransaction logs transaction activities
func LogTransaction(userID uint, action string, details string) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	log.Printf("[TRANSACTION] %s - User:%d Action:%s Details:%s\n", timestamp, userID, action, details)
}
