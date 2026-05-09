package entry

import (
	"backend/api/v1/utils"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/url"
	"os"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/lib/pq"
	"github.com/lithammer/fuzzysearch/fuzzy"

	data "backend/api/v1/data"
	messages "backend/api/v1/messages"
)

func AutocompleteAddress(c *gin.Context, db *sql.DB) {
	query := c.DefaultQuery("query", "")

	if query == "" {
		slog.Info("Empty autocomplete address query")
		messages.StatusBadRequest(c, errors.New("No query provided"))
		return
	}

	tomTomApiKey := os.Getenv("TOM_TOM_API_KEY")

	url := os.Getenv("TOM_TOM_BASE_URL") + "/search/2/search/" + url.QueryEscape(query) + ".json?key=" + tomTomApiKey + "&typeahead=true" + "&limit=3" + "&countrySet=US"

	resp, err := http.Get(url)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		slog.Error("Error from Tom Tom", "error", bodyBytes)
		messages.InternalServerError(c, errors.New(string(bodyBytes)))
		return
	}

	defer resp.Body.Close()

	responseData, err := io.ReadAll(resp.Body)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	var tomTomResponse data.TomTomResponse

	err = json.Unmarshal(responseData, &tomTomResponse)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	var suggestions []data.AddressSuggestion

	for _, result := range tomTomResponse.Results {
		var suggestion data.AddressSuggestion

		suggestion.Address = result.Address.FreeformAddress
		suggestion.Lat = result.Position.Lat
		suggestion.Lon = result.Position.Lon

		suggestions = append(suggestions, suggestion)
	}

	c.JSON(http.StatusOK, suggestions)
}

func CreateEntry(c *gin.Context, db *sql.DB) {
	var payload data.CreateEntryRequest

	if err := c.ShouldBindJSON(&payload); err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	query := `
		SELECT EXISTS (
			SELECT 1
			FROM entry
			WHERE ST_DWithin(location, geography(ST_MakePoint($1, $2)), 50)
		);
	`

	var entryAlreadyExists bool
	err := db.QueryRow(query, payload.Longitude, payload.Latitude).Scan(&entryAlreadyExists)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	if entryAlreadyExists {
		slog.Info("Entry already exists",
			"address", payload.Location,
			"longitude", payload.Longitude,
			"latitude", payload.Latitude,
		)
		messages.StatusConflict(c, errors.New(fmt.Sprintf("Entry at %s already exists", payload.Location)))
		return
	}

	var username string

	cookie, err := c.Cookie("access_token")
	if err != nil {
		slog.Info(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("User is unauthorized, please log in again."))
	}

	username, err = utils.ParseTokenAndReturnUsername(cookie)
	if err != nil {
		slog.Info(err.Error(), "error", err)
		messages.StatusUnauthorized(c, errors.New("User is unauthorized, please log in again."))
		return
	}

	tx, err := db.Begin()
	if err != nil {
		messages.InternalServerError(c, err)
	}
	defer func() {
		if err != nil {
			tx.Rollback()
		} else {
			err = tx.Commit()
		}
	}()

	var entryRevisionId int

	err = tx.QueryRow(`
		WITH user_cte AS (
				SELECT id FROM users WHERE username = $3
		),
		entry_insert AS (
				INSERT INTO entry (address, creator_id, location)
				VALUES ($2, (SELECT id FROM user_cte), ST_SetSRID(ST_MakePoint($4, $5), 4326))
				RETURNING id
		),
		revision_number AS (
				SELECT COUNT(*) + 1 AS revision_number
				FROM entry_revision
				WHERE entry_id = (SELECT id FROM entry_insert)
		)
		INSERT INTO entry_revision (entry_id, title, content, revision_number, creator_id)
		SELECT
				(SELECT id FROM entry_insert),
				$1,
				$6,
				(SELECT revision_number FROM revision_number),
				(SELECT id FROM user_cte)
		RETURNING id
		`, payload.Title, payload.Location, username, payload.Longitude, payload.Latitude, payload.Description).Scan(&entryRevisionId)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	utils.InsertTagAndEntryRevisionAssociation(tx, entryRevisionId, payload.Tags)

	fields := []data.Field{
		{
			Name:  "Title",
			Value: payload.Title,
		},
		{
			Name:  "Location",
			Value: payload.Location,
		},
		{
			Name:  "Description",
			Value: payload.Description,
		},
		{
			Name:  "Submitted By:",
			Value: username,
		},
	}

	for _, value := range payload.Tags {
		fields = append(fields, data.Field{
			Name:  value.Classification,
			Value: value.Name,
		})
	}

	go func() {
		utils.SendWebhook(
			"Entry",
			9033364,
			fields,
		)
	}()

	messages.StatusCreated(c, "Entry created successfully!")
}

func RetrieveEntriesWithinVisibleBounds(c *gin.Context, db *sql.DB) {
	var bounds data.Bounds
	if err := c.ShouldBindJSON(&bounds); err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("something went wrong"))
		return
	}

	rows, err := db.Query(`
		SELECT entry.id,
		       address,
		       er.content,
		       views,
		       date_created,
		       username,
		       first_name,
		       last_name,
		       er.id AS revision_id,
		       er.title,
		       ST_X(location::geometry) AS longitude,
		       ST_Y(location::geometry) AS latitude
		FROM entry
		JOIN users ON entry.creator_id = users.id
		JOIN (
			SELECT DISTINCT ON (entry_id) id, entry_id, title, content, revision_number
			FROM entry_revision
			ORDER BY entry_id, revision_number DESC
		) er ON entry.id = er.entry_id
		WHERE location::geometry && ST_MakeEnvelope($1, $2, $3, $4, 4326)
	`, bounds.West, bounds.South, bounds.East, bounds.North)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}
	defer rows.Close()

	var entries []data.Entry
	revisionIDs := []int{}
	revisionToEntry := map[int]int{}

	for rows.Next() {
		var entry data.Entry
		var revisionID int
		if err := rows.Scan(
			&entry.ID, &entry.Address, &entry.Content, &entry.Views,
			&entry.DateCreated, &entry.Username, &entry.FirstName, &entry.LastName,
			&revisionID, &entry.Title, &entry.Longitude, &entry.Latitude,
		); err != nil {
			slog.Error(err.Error(), "error", err)
			messages.InternalServerError(c, errors.New("Something went wrong"))
			return
		}
		entry.Tags = []data.Tag{}
		revisionToEntry[revisionID] = len(entries)
		revisionIDs = append(revisionIDs, revisionID)
		entries = append(entries, entry)
	}

	if len(entries) == 0 {
		messages.StatusNoContent(c, errors.New("no entries goat </3"))
		return
	}

	tagRows, err := db.Query(`
		SELECT ter.entry_revision_id, t.name, t.classification
		FROM tags t
		JOIN tags_entry_revision ter ON t.id = ter.tag_id
		WHERE ter.entry_revision_id = ANY($1)
	`, pq.Array(revisionIDs))
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}
	defer tagRows.Close()

	for tagRows.Next() {
		var revisionID int
		var tag data.Tag
		if err := tagRows.Scan(&revisionID, &tag.Name, &tag.Classification); err != nil {
			slog.Error(err.Error(), "error", err)
			messages.InternalServerError(c, errors.New("Something went wrong"))
			return
		}
		idx := revisionToEntry[revisionID]
		entries[idx].Tags = append(entries[idx].Tags, tag)
	}

	fmt.Println(entries)

	c.JSON(http.StatusOK, entries)
}

func RetrieveCity(c *gin.Context, db *sql.DB) {
	query := strings.ToLower(c.DefaultQuery("city", ""))

	if query == "" {
		messages.StatusBadRequest(c, errors.New("City not found"))
		return
	}

	var cities []data.City

	jsonFile, err := os.Open(os.Getenv("CITIES_FILE"))
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	defer jsonFile.Close()

	byteValue, _ := io.ReadAll(jsonFile)

	err = json.Unmarshal(byteValue, &cities)
	if err != nil {
		slog.Error(err.Error(), "error", err)
		messages.InternalServerError(c, errors.New("Something went wrong"))
		return
	}

	var cityNames []string

	for _, city := range cities {
		cityNames = append(cityNames, city.SearchTerm)
	}

	matches := fuzzy.RankFind(query, cityNames)

	if len(matches) > 3 {
		matches = matches[:3]
	}

	var results []data.City

	cityByName := make(map[string]data.City)
	for _, city := range cities {
		cityByName[city.SearchTerm] = city
	}

	for _, match := range matches {
		if city, ok := cityByName[match.Target]; ok {
			results = append(results, city)
		}
	}

	if len(results) == 0 {
		messages.StatusNoContent(c, errors.New("No results found"))
		return
	}

	c.JSON(http.StatusOK, results)
}
