package utils

import (
	"errors"
	"regexp"
	"strings"
	"unicode"
)

// ValidatePassword checks password strength
func ValidatePassword(password string) error {
	if len(password) < 8 {
		return errors.New("password minimal 8 karakter")
	}
	
	var hasUpper, hasLower, hasNumber bool
	for _, char := range password {
		switch {
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsNumber(char):
			hasNumber = true
		}
	}
	
	if !hasUpper || !hasLower || !hasNumber {
		return errors.New("password harus mengandung huruf besar, kecil, dan angka")
	}
	
	return nil
}

// SanitizeString removes dangerous characters
func SanitizeString(input string) string {
	// Remove HTML tags
	re := regexp.MustCompile(`<[^>]*>`)
	input = re.ReplaceAllString(input, "")
	
	// Remove script tags
	re = regexp.MustCompile(`(?i)<script[^>]*>.*?</script>`)
	input = re.ReplaceAllString(input, "")
	
	// Trim spaces
	return strings.TrimSpace(input)
}

// ValidatePagination validates pagination parameters
func ValidatePagination(page, limit int) (int, int) {
	if page < 1 {
		page = 1
	}
	if limit < 1 || limit > 100 {
		limit = 20
	}
	return page, limit
}
