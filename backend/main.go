package main

import (
	"database/sql"
	"errors"
	"log"
	"os"
	"time"

	"github.com/go-playground/validator/v10"
	_ "github.com/lib/pq"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"

	entry "backend/api/v1/entry"
	messages "backend/api/v1/messages"
	users "backend/api/v1/users"
	utils "backend/api/v1/utils"

	data "backend/api/v1/data"
)

var db *sql.DB

func RequestLogger(db *sql.DB, controller string, action string) gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
		utils.LogRequest(c, db, controller, action)
	}
}

func AuthMiddleware(db *sql.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		cookie, err := c.Cookie("access_token")
		if err != nil {
			messages.StatusUnauthorized(c, err)
			return
		}

		username, err := utils.ParseTokenAndReturnUsername(cookie)
		if err != nil {
			messages.StatusUnauthorized(c, err)
			return
		}

		isVerified, err := utils.UserIsVerified(username, db)
		if err != nil {
			messages.StatusUnauthorized(c, err)
			return
		}
		if !isVerified {
			messages.StatusUnauthorized(c, errors.New("user is not verified"))
			return
		}

		c.Next()
	}
}

func handleRequests() {
	r := gin.Default()

	validate := validator.New()
	validate.RegisterValidation("username_requirements", data.ValidateUsername)
	validate.RegisterValidation("password_requirements", data.ValidatePassword)

	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		v.RegisterValidation("username_requirements", data.ValidateUsername)
	}

	if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
		v.RegisterValidation("password_requirements", data.ValidatePassword)
	}

	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"http://localhost:5173"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		AllowCredentials: true,
	}))

	userRoutes := r.Group("/users")
	userRoutesPrivileged := r.Group("/users")
	userRoutesPrivileged.Use(AuthMiddleware(db))
	entryRoutes := r.Group("/entries")
	entryPrivilegedRoutes := r.Group("/entries")
	entryPrivilegedRoutes.Use(AuthMiddleware(db))

	userRoutes.POST("/create-user", RequestLogger(db, "UserController", "CreateUser"), func(c *gin.Context) {
		users.CreateUser(c, db)
	})

	userRoutes.POST("/login", func(c *gin.Context) {
		users.LoginUser(c, db)
	})

	userRoutes.POST("/refresh-token", users.RefreshToken)

	userRoutes.POST("/me", func(c *gin.Context) {
		users.Me(c, db)
	})

	entryRoutes.POST("/retrieve-entries-within-visible-bounds", func(c *gin.Context) {
		entry.RetrieveEntriesWithinVisibleBounds(c, db)
	})

	entryRoutes.GET("/retrieve-city", func(c *gin.Context) {
		entry.RetrieveCity(c, db)
	})

	entryRoutes.GET("/feed", func(c *gin.Context) {
		entry.RetrieveFeed(c, db)
	})

	entryPrivilegedRoutes.POST("/create-entry", RequestLogger(db, "EntryController", "CreateEntry"), func(c *gin.Context) {
		entry.CreateEntry(c, db)
	})

	entryPrivilegedRoutes.GET("/autocomplete-address", func(c *gin.Context) {
		entry.AutocompleteAddress(c, db)
	})

	entryPrivilegedRoutes.POST("/vote-entry", func(c *gin.Context) {
		entry.VoteEntry(c, db)
	})

	entryPrivilegedRoutes.POST("/edit-entry", func(c *gin.Context) {
		entry.EditEntry(c, db)
	})

	if os.Getenv("GIN_ENV") == "production" {
		r.Static("/assets", "/app/assets")
		r.Static("/login", "/app/assets")
		r.Static("/create-entry", "/app/assets")
		r.Static("/verification-page", "/app/assets")
		gin.DefaultWriter = os.Stderr
		gin.DefaultErrorWriter = os.Stderr
		r.Use(gin.Logger())
		r.Use(gin.Recovery())
	}

	r.Run()
}

func main() {
	var err error
	db, err = initDB()

	for i := 0; i < 10 && err != nil; i++ {
		log.Printf("Failed to connect to DB, attempt %d: %v", i+1, err)
		time.Sleep(2 * time.Second)
		err = db.Ping()
	}

	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer db.Close()

	handleRequests()
}
