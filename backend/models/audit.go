package models

import (
	"time"
	"gorm.io/datatypes"
)

type AuditLog struct {
	ID        uint           `gorm:"primaryKey" json:"id"`
	UserID    uint           `gorm:"index" json:"user_id"`
	Username  string         `gorm:"size:50" json:"username"`
	Action    string         `gorm:"size:20;index" json:"action"` // CREATE, UPDATE, DELETE
	TableName string         `gorm:"size:50;index;column:table_name" json:"table_name"`
	RecordID  uint           `json:"record_id"`
	OldValue  datatypes.JSON `gorm:"type:json" json:"old_value,omitempty"`
	NewValue  datatypes.JSON `gorm:"type:json" json:"new_value,omitempty"`
	IPAddress string         `gorm:"size:45" json:"ip_address"`
	CreatedAt time.Time      `gorm:"index" json:"created_at"`
}

