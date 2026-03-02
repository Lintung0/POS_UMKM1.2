package utils

import (
	"regexp"
	"strings"
)

// SanitizeString removes dangerous characters from input
func SanitizeString(input string) string {
	// Remove leading/trailing whitespace
	input = strings.TrimSpace(input)
	
	// Remove null bytes
	input = strings.ReplaceAll(input, "\x00", "")
	
	return input
}

// ValidateEmail checks if email format is valid
func ValidateEmail(email string) bool {
	if email == "" {
		return true // Email is optional
	}
	
	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	return emailRegex.MatchString(email)
}

// ValidatePhone checks if phone format is valid
func ValidatePhone(phone string) bool {
	if phone == "" {
		return true // Phone is optional
	}
	
	// Indonesian phone format: 08xx or +62xxx
	phoneRegex := regexp.MustCompile(`^(\+62|62|0)[0-9]{9,13}$`)
	return phoneRegex.MatchString(phone)
}

// ValidatePositiveNumber checks if number is positive
func ValidatePositiveNumber(num float64) bool {
	return num >= 0
}

// ValidatePositiveInt checks if integer is positive
func ValidatePositiveInt(num int) bool {
	return num >= 0
}

// SanitizeProductName sanitizes product name
func SanitizeProductName(name string) string {
	name = SanitizeString(name)
	// Remove special characters except spaces, hyphens, and parentheses
	reg := regexp.MustCompile(`[^a-zA-Z0-9\s\-\(\)]`)
	return reg.ReplaceAllString(name, "")
}

// ValidateStockQuantity validates stock quantity
func ValidateStockQuantity(qty int) bool {
	return qty >= 0 && qty <= 1000000 // Max 1 million
}

// ValidatePrice validates price
func ValidatePrice(price float64) bool {
	return price >= 0 && price <= 100000000 // Max 100 million
}
