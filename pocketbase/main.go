package main

import (
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"

	_ "app/migrations"

	"github.com/google/uuid"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/daos"
	"github.com/pocketbase/pocketbase/models"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
)

type Value struct {
	NumericValue string `json:"numericValue"`
}

type DataItem struct {
	Value        Value  `json:"value"`
	DataType     string `json:"data_type"`
	Unit         string `json:"unit"`
	DateFrom     string `json:"date_from"`
	DateTo       string `json:"date_to"`
	PlatformType string `json:"platform_type"`
	DeviceId     string `json:"device_id"`
	SourceId     string `json:"source_id"`
	SourceName   string `json:"source_name"`
}

// const (
// 	StepsCollection                = "steps"
// 	WalkingAsymmetryCollection     = "walking_asymmetry_percentage"
// 	WalkingDoubleSupportCollection = "walking_double_support_percentage"
// 	WalkingSpeedCollection         = "walking_speed"
// 	WalkingSteadinessCollection    = "walking_steadiness"
// 	WalkingStepLengthCollection    = "walking_step_length"
// )

//	var collections = []string{
//		StepsCollection,
//		WalkingAsymmetryCollection,
//		WalkingDoubleSupportCollection,
//		WalkingSpeedCollection,
//		WalkingSteadinessCollection,
//		WalkingStepLengthCollection,
//	}

func main() {
	app := pocketbase.New()

	isGoRun := strings.HasPrefix(os.Args[0], os.TempDir())

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: isGoRun,
	})

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.Use(middleware.BodyLimit(200 * 1024 * 1024))

		e.Router.GET("/test", func(c echo.Context) error {
			return c.String(http.StatusOK, "Test endpoint")
		})

		e.Router.POST("/users", func(c echo.Context) error {
			data := struct {
				PersonalId string `json:"personalId"`
				Consent    bool   `json:"consent"`
				EventDate  string `json:"eventDate"`
			}{}
			if err := c.Bind(&data); err != nil {
				return apis.NewBadRequestError("Failed to read request data", err)
			}
			log.Printf("Request body: %v", data)

			user, _, err := findOrCreateUser(app, data.PersonalId, data.EventDate)
			if err != nil {
				return echo.NewHTTPError(http.StatusInternalServerError, "Failed to handle user")
			}

			collection, err := app.Dao().FindCollectionByNameOrId("consent")
			if err != nil {
				return echo.NewHTTPError(http.StatusInternalServerError, "Failed to find collection")
			}

			record := models.NewRecord(collection)
			record.Set("user", user.Id)
			record.Set("consented", data.Consent)
			app.Dao().SaveRecord(record)

			return c.JSON(http.StatusOK, user)
		})

		e.Router.POST("/:id/form", func(c echo.Context) error {
			id := c.PathParam("id")
			data := struct {
				Name    string      `json:"name"`
				Answers interface{} `json:"answers"`
			}{}

			if err := c.Bind(&data); err != nil {
				return apis.NewBadRequestError("Failed to read request data", err)
			}

			user, err := getUserForPersonalId(app, id)
			if err != nil {
				return echo.NewHTTPError(http.StatusNotFound, "User not found")
			}

			collection, err := app.Dao().FindCollectionByNameOrId("questionnaires")
			if err != nil {
				return echo.NewHTTPError(http.StatusInternalServerError, "Failed to find collection")
			}

			record := models.NewRecord(collection)
			record.Set("user", user.Id)
			record.Set("name", data.Name)
			record.Set("answers", data.Answers)
			app.Dao().SaveRecord(record)

			return nil
		})

		e.Router.POST("/data", func(c echo.Context) error {
			reqBody := struct {
				PersonalId string     `json:"personalId"`
				EventDate  string     `json:"eventDate"`
				Data       []DataItem `json:"data"`
			}{}

			if err := c.Bind(&reqBody); err != nil {
				log.Println("Error: ", err)
				return echo.NewHTTPError(http.StatusBadRequest, "Invalid request body")
			}

			// Logic to find or create a user based on PersonalId
			user, _, err := findOrCreateUser(app, reqBody.PersonalId, reqBody.EventDate)
			if err != nil {
				return echo.NewHTTPError(http.StatusInternalServerError, "Failed to handle user")
			}

			// Group data by data_type
			dataGroups := groupDataByType(reqBody.Data)

			app.Dao().RunInTransaction(func(txDao *daos.Dao) error {
				// Process each data group in batches
				for dataType, items := range dataGroups {
					if err := processInBatches(txDao, dataType, user, items, 5000); err != nil {
						return echo.NewHTTPError(http.StatusInternalServerError, "Failed to save data")
					}
				}
				return nil
			})

			return c.NoContent(http.StatusOK)
		})

		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}

func getUserForPersonalId(app *pocketbase.PocketBase, personalId string) (*models.Record, error) {
	return app.Dao().FindFirstRecordByData("users", "username", personalId)
}

func findOrCreateUser(app *pocketbase.PocketBase, personalId, eventDate string) (*models.Record, string, error) {
	user, _ := getUserForPersonalId(app, personalId)

	if user != nil {
		return user, "", nil
	}

	collection, err := app.Dao().FindCollectionByNameOrId("users")
	if err != nil {
		return nil, "", err
	}

	record := models.NewRecord(collection)
	record.Set("username", personalId)
	record.Set("event_date", eventDate)
	uuid, _ := uuid.NewRandom()
	password := uuid.String()
	record.SetPassword(password)

	log.Println(record.TokenKey())

	if err := app.Dao().SaveRecord(record); err != nil {
		log.Println(err)
		return nil, "", err
	}

	return record, password, nil
}

func groupDataByType(data []DataItem) map[string][]DataItem {
	groups := make(map[string][]DataItem)
	for _, item := range data {
		groups[item.DataType] = append(groups[item.DataType], item)
	}
	return groups
}

func processInBatches(txDao *daos.Dao, table string, user *models.Record, data []DataItem, batchSize int) error {
	for i := 0; i < len(data); i += batchSize {
		end := i + batchSize
		if end > len(data) {
			end = len(data)
		}
		batch := data[i:end]
		if err := batchInsert(txDao, table, user, batch); err != nil {
			return err
		}
	}
	return nil
}

func batchInsert(txDao *daos.Dao, table string, user *models.Record, data []DataItem) error {
	collection, err := txDao.FindCollectionByNameOrId(table)
	if err != nil {
		return err
	}

	for _, item := range data {
		record := models.NewRecord(collection)
		// parse string value to float
		value, _ := strconv.ParseFloat(item.Value.NumericValue, 64)

		record.Set("user", user.Id)
		record.Set("value", value)
		record.Set("date_from", item.DateFrom)
		record.Set("date_to", item.DateTo)
		record.Set("device_id", item.DeviceId)
		record.Set("source_id", item.SourceId)
		record.Set("source_name", item.SourceName)
		if err := txDao.SaveRecord(record); err != nil {
			return err
		}
	}

	return nil
}
