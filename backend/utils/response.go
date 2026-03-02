package utils

import (
	"time"
)

type Response struct {
    Success   bool        `json:"success"`
    Message   string      `json:"message"`
    Data      interface{} `json:"data,omitempty"`
    Error     string      `json:"error,omitempty"`
    Timestamp string      `json:"timestamp"`
}

func SuccessResponse(message string, data interface{}) Response {
	return Response {
		Success:   true,
        Message:   message,
        Data:      data,
        Timestamp: time.Now().Format(time.RFC3339),
	}
}

func ErrorResponse(message string, err error) Response {
	errorMsg := ""
	if err != nil {
		errorMsg = err.Error()
	}

	return Response{
		Success:   false,
        Message:   message,
        Error:     errorMsg,
        Timestamp: time.Now().Format(time.RFC3339),
	}
}

func ValidationError(message string, errors map[string]string) Response {
	return Response{
		Success:   false,
        Message:   message,
        Data:      errors,
        Timestamp: time.Now().Format(time.RFC3339),
	}
}