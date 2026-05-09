package data

import (
	"regexp"
	"unicode"

	"github.com/go-playground/validator/v10"
)

var (
	usernameRegex        = regexp.MustCompile("^[a-z0-9_.]+$")
	passwordSpecialRegex = regexp.MustCompile(`[@$!%*?&]`)
)

func ValidateUsername(fl validator.FieldLevel) bool {
	return usernameRegex.MatchString(fl.Field().String())
}

func ValidatePassword(fl validator.FieldLevel) bool {
	password := fl.Field().String()

	if len([]byte(password)) > 72 {
		return false
	}

	var hasLower, hasUpper, hasDigit, hasSpecial bool

	for _, ch := range password {
		switch {
		case unicode.IsLower(ch):
			hasLower = true
		case unicode.IsUpper(ch):
			hasUpper = true
		case unicode.IsDigit(ch):
			hasDigit = true
		case passwordSpecialRegex.MatchString(string(ch)):
			hasSpecial = true
		}
	}

	return hasLower && hasUpper && hasDigit && hasSpecial
}

type CreateUserRequest struct {
	Username    string  `json:"username" binding:"required,min=3,max=15,username_requirements"`
	FirstName   string  `json:"first_name" binding:"required,min=2,max=50"`
	LastName    string  `json:"last_name" binding:"required,min=2,max=50"`
	Password    string  `json:"password" binding:"required,min=8,max=255,password_requirements"`
	Email       *string `json:"email" binding:"omitempty,email"`
	PhoneNumber *string `json:"phone_number" binding:"omitempty,e164"`
}

type LoginRequest struct {
	Username string `json:"username" binding:"required,min=3,max=15"`
	Password string `json:"password" binding:"required,min=8,max=255"`
}

type Me struct {
	IsVerified bool `json:"is_verified"`
}
