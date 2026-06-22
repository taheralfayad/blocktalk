package users

import (
	"database/sql"
	"errors"
	"log/slog"
	"net/http"

	data "backend/api/v1/data"
	messages "backend/api/v1/messages"
	utils "backend/api/v1/utils"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/golang-jwt/jwt/v5"
	"github.com/lib/pq"
)

func CreateUser(c *gin.Context, db *sql.DB) {
	var payload data.CreateUserRequest

	if err := c.ShouldBindJSON(&payload); err != nil {
		slog.Error(err.Error(), "error", err)
		var validationErrors validator.ValidationErrors
		errorString := "Something went wrong"

		if errors.As(err, &validationErrors) {
			e := validationErrors[0]
			validationMessages := map[string]string{
				"Username:username_requirements": "Username is in incorrect format. Must be lowercase, alphanumeric, can contain . or _",
				"Username:max":                   "Username too long. Must be under 15 characters",
				"Username:min":                   "Username too short. Must be over 3 characters",
				"Password:min":                   "Password too short. Must be over 8 characters",
				"Password:max":                   "Password too long. Must be under 255 characters",
				"Password:password_requirements": "Password does not match requirements. Must include 1 lowercase, 1 uppercase, 1 digit, special character (@$!%*?&)",
				"PhoneNumber:e164":               "Phone number must be in E.164 format (e.g. +1234567910)",
				"FirstName:min":                  "First name is too short. Must be over 2 characters",
				"FirstName:max":                  "First name is too long. Must be under 50 characters",
				"LastName:min":                   "Last name is too short. Must be over 2 characters",
				"LastName:max":                   "Last name is too long. Must be under 50 characters",
			}

			key := e.Field() + ":" + e.Tag()

			if msg, ok := validationMessages[key]; ok {
				errorString = msg
			}
		}

		messages.InternalServerError(c, errors.New(errorString))
		return
	}

	hashedPassword, err := utils.HashPassword(payload.Password)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	_, err = db.Exec(`
		INSERT INTO users (username, first_name, last_name, password, email, phone_number)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, payload.Username, payload.FirstName, payload.LastName, hashedPassword, payload.Email, payload.PhoneNumber)
	if err != nil {
		if err, ok := err.(*pq.Error); ok && err.Code == "23505" {
			slog.Error(err.Error(), "error", err)
			messages.StatusConflict(c, errors.New("User already exists in the database"))
			return
		}

		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	accessToken, accessTokenExpDate, err := utils.GenerateAccessToken(payload.Username)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	refreshToken, refreshTokenExpDate, err := utils.GenerateRefreshToken(payload.Username)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	utils.SetCookies(
		c,
		accessToken,
		refreshToken,
		int(accessTokenExpDate),
		int(refreshTokenExpDate),
	)

	messages.StatusOk(c, "User has been successfully created.")

	go func() {
		fields := []data.Field{
			{
				Name:  "Username",
				Value: payload.Username,
			},
			{
				Name:  "First Name",
				Value: payload.FirstName,
			},
			{
				Name:  "Last Name",
				Value: payload.LastName,
			},
		}
		utils.SendWebhook("User", 9224158, fields)
	}()
}

func LoginUser(c *gin.Context, db *sql.DB) {
	var payload data.LoginRequest

	if err := c.ShouldBindJSON(&payload); err != nil {
		slog.Error(err.Error(), "error", err)
		var validationErrors validator.ValidationErrors
		errorString := "Cannot log user in"

		if errors.As(err, &validationErrors) {
			e := validationErrors[0]
			validationMessages := map[string]string{
				"Username:max": "Username is too long. Must be less than 15 characters",
				"Username:min": "Username is too short. Must be greater than 3 characters",
				"Password:max": "Password is too long. Must be less than 255 characters",
				"Password:min": "Password is too short. Must be greater than 8 characters",
			}

			key := e.Field() + ":" + e.Tag()

			if msg, ok := validationMessages[key]; ok {
				errorString = msg
			}
		}

		messages.InternalServerError(c, errors.New(errorString))
		return
	}

	var hashedPassword string

	err := db.QueryRow(`
		SELECT password FROM users WHERE username = $1
	`, payload.Username).Scan(&hashedPassword)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		if err == sql.ErrNoRows {
			messages.StatusUnauthorized(c, errors.New("User/password not found"))
			return
		}

		messages.InternalServerError(c, errors.New("User/password not found"))
		return
	}

	if !utils.VerifyPassword(hashedPassword, payload.Password) {
		slog.Info("Password did not match", "username", payload.Username)
		messages.StatusUnauthorized(c, errors.New("User/password not found"))
		return
	}

	accessToken, accessTokenExpDate, err := utils.GenerateAccessToken(payload.Username)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("An error has occured"))
		return
	}

	refreshToken, refreshTokenExpDate, err := utils.GenerateRefreshToken(payload.Username)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, err)
		return
	}

	utils.SetCookies(
		c,
		accessToken,
		refreshToken,
		int(accessTokenExpDate),
		int(refreshTokenExpDate),
	)

	messages.StatusOk(c, "User successfully logged in")
}

func RefreshToken(c *gin.Context) {
	refreshToken, err := c.Cookie("refresh_token")
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("Something went wrong"))
		return
	}

	token, err := jwt.Parse(refreshToken, func(token *jwt.Token) (interface{}, error) {
		return utils.JwtSecret, nil
	})
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("Something went wrong"))
		return
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("invalid token"))
		return
	}

	username, ok := claims["username"].(string)
	if !ok {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("invalid token"))
		return
	}

	newAccessToken, expirationDate, err := utils.GenerateAccessToken(username)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	utils.SetAuthCookie(
		c,
		"access_token",
		newAccessToken,
		int(expirationDate),
	)

	messages.StatusOk(c, "Access token has been refreshed!")
}

func Me(c *gin.Context, db *sql.DB) {
	refreshToken, err := c.Cookie("refresh_token")
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("User not authorized"))
		return
	}

	username, err := utils.ParseTokenAndReturnUsername(refreshToken)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("User not authorized"))
		return
	}

	var me data.Me

	verified, err := utils.UserIsVerified(username, db)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("User not authorized"))
		return
	}

	me.IsVerified = verified
	me.Username = username

	c.JSON(http.StatusOK, me)
}
