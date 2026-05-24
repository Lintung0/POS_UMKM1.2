package models

import (
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type User struct {
	ID        uint            `gorm:"primaryKey" json:"id"`
	Username  string          `gorm:"size:50;unique;not null" json:"username"`
	Password  string          `gorm:"size:255;not null" json:"-"`
	FullName  string          `gorm:"size:100;not null" json:"full_name"`
	Role      string          `gorm:"size:20;default:'cashier'" json:"role"`
	IsActive  bool            `gorm:"default:true" json:"is_active"`
	Settings  datatypes.JSON  `gorm:"type:json" json:"settings,omitempty"`
	LastLogin *time.Time      `json:"last_login,omitempty"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
	DeletedAt gorm.DeletedAt  `gorm:"index" json:"-"`
}

func (u *User) BeforeSave(tx *gorm.DB) (err error) {
	// Only hash the password if it is a plain-text value.
	// bcrypt hashes always start with "$2a$", "$2b$" or "$2y$".
	// Skipping re-hashing prevents double-hashing on partial updates.
	if u.Password != "" && len(u.Password) < 60 {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(u.Password), bcrypt.DefaultCost)
		if err != nil {
			return err
		}
		u.Password = string(hashedPassword)
	}
	return nil
}

func (u *User) VerifyPassword(password string) error {
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
}

type LoginRequest struct {
	Username string `json:"username" form:"username" query:"username" binding:"required"`
	Password string `json:"password" form:"password" query:"password" binding:"required"`
}

type userResponse struct {
	ID       uint   `json:"id"`
	Username string `json:"username"`
	FullName string `json:"full_name"`
	Role     string `json:"role"`
	IsActive bool   `json:"is_active"`
}
