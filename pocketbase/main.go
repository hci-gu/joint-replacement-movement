package main

import (
	"compress/gzip"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"path/filepath"

	_ "app/migrations"

	"github.com/google/uuid"
	"github.com/labstack/echo/v5"
	"github.com/labstack/echo/v5/middleware"
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/models"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
	"github.com/pocketbase/pocketbase/tools/cron"
	"github.com/pocketbase/pocketbase/tools/types"
	"github.com/sideshow/apns2"
	"github.com/sideshow/apns2/payload"
	"github.com/sideshow/apns2/token"
)

// const STORAGE_PATH = "./storage"
const STORAGE_PATH = "/pb/pb_data/raw"
const CERT_PATH = "/pb/cert"

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

// Function to parse date strings and return the earliest and latest dates
func getEarliestAndLatestDates(data []DataItem) (earliest string, latest string, err error) {
	if len(data) == 0 {
		return "", "", fmt.Errorf("no data points provided")
	}

	// Initialize earliest and latest dates with the first item's dates
	earliest = data[0].DateFrom
	latest = data[0].DateTo

	// Iterate through the data to find the actual earliest and latest dates
	for _, item := range data {
		if strings.Compare(item.DateFrom, earliest) < 0 {
			earliest = item.DateFrom
		}
		if strings.Compare(item.DateTo, latest) > 0 {
			latest = item.DateTo
		}
	}

	return earliest, latest, nil
}

// Write compressed data to a file
func writeCompressedFile(filePath string, data []DataItem) error {
	// Convert the []DataItem array to JSON
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	// Create the file for writing compressed data
	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	// Create a gzip writer
	gzipWriter := gzip.NewWriter(file)
	defer gzipWriter.Close()

	// Write compressed data
	_, err = gzipWriter.Write(jsonData)
	if err != nil {
		return err
	}

	return nil
}

// Read and decompress the file
func readCompressedFile(filePath string) ([]DataItem, error) {
	// Open the compressed file
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	// Create a gzip reader
	gzipReader, err := gzip.NewReader(file)
	if err != nil {
		return nil, err
	}
	defer gzipReader.Close()

	// Read and decompress the data
	decompressedData, err := io.ReadAll(gzipReader)
	if err != nil {
		return nil, err
	}

	// Unmarshal the decompressed data into []DataItem
	var dataItems []DataItem
	if err := json.Unmarshal(decompressedData, &dataItems); err != nil {
		return nil, err
	}

	return dataItems, nil
}

func getNotificationToken() *token.Token {
	authKey, err := token.AuthKeyFromFile("/pb/cert/key.p8")

	if err != nil {
		log.Fatal("Cert Error:", err)
	}

	token := &token.Token{
		AuthKey: authKey,
		KeyID:   "AUR4NK22L7",
		TeamID:  "5KQ3D3FG5H",
	}
	return token
}

func sendNotification(token *token.Token, notification *apns2.Notification) {
	client := apns2.NewTokenClient(token).Production()
	res, err := client.Push(notification)

	if err != nil {
		log.Fatal("Error:", err)
	}

	fmt.Printf("%v %v %v\n", res.StatusCode, res.ApnsID, res.Reason)
}

// functions that checks if we have already answered the questionnaire
func answeredQuestionnaire(answeredDate time.Time, occurance string) bool {
	var nextDueDate time.Time

	switch occurance {
	case "daily":
		// Add one day to the answered date, but ignore the time
		nextDueDate = answeredDate.AddDate(0, 0, 1) // Add one day
	case "weekly":
		weekday := answeredDate.Weekday()
		var daysUntilMonday int
		if weekday == time.Sunday {
			daysUntilMonday = 1
		} else {
			daysUntilMonday = (8 - int(weekday)) % 7
		}
		nextDueDate = answeredDate.AddDate(0, 0, daysUntilMonday)
	default:
		// Optionally handle unexpected occurrence value
		return false
	}
	nextDueDate = time.Date(nextDueDate.Year(), nextDueDate.Month(), nextDueDate.Day(), 0, 0, 0, 0, nextDueDate.Location())

	// Get the current date
	currentDate := time.Now()

	log.Println("Answered date: " + answeredDate.String())
	log.Println("Next due date: " + nextDueDate.String())
	// Check if the current date is past the next due date
	return nextDueDate.After(currentDate)
}

func notificationToSend(app *pocketbase.PocketBase, user *models.Record, questionnaires []*models.Record) *apns2.Notification {
	questionnairesToAnswer := make([]*models.Record, 0)
	for _, questionnaire := range questionnaires {
		answers, _ := app.Dao().FindRecordsByFilter("answers", "user = {:user} && questionnaire = {:questionnaire}", "-date", 1, 0, dbx.Params{
			"user":          user.Id,
			"questionnaire": questionnaire.Id,
		})
		if len(answers) == 0 {
			questionnairesToAnswer = append(questionnairesToAnswer, questionnaire)
			continue
		}
		answered := answers[0]

		if answered == nil || !answeredQuestionnaire(answered.Get("date").(types.DateTime).Time(), questionnaire.Get("occurance").(string)) {
			questionnairesToAnswer = append(questionnairesToAnswer, questionnaire)
		}
	}

	log.Println("Questionnaires to answer: " + strconv.Itoa(len(questionnairesToAnswer)))
	if len(questionnairesToAnswer) > 0 {
		notification := &apns2.Notification{}
		notification.DeviceToken = user.Get("device_token").(string)
		notification.Topic = "com.example.fractureMovement"
		payload := payload.NewPayload().Badge(1)
		if len(questionnairesToAnswer) == 1 {
			if questionnairesToAnswer[0].Get("occurance").(string) == "daily" {
				payload.Alert("Dags att fylla i dagboken")
			}
			if questionnairesToAnswer[0].Get("occurance").(string) == "weekly" {
				payload.Alert("Dags att fylla i veckans formulär")
			}
			payload.Custom("action", "questionnaire?id="+questionnairesToAnswer[0].Id)
		} else {
			payload.Alert("Dags att fylla i dagboken och veckans formulär")
		}
		notification.Payload = payload

		log.Println("Sending out a notification")

		return notification
	}

	return nil
}

func main() {
	app := pocketbase.New()

	isGoRun := strings.HasPrefix(os.Args[0], os.TempDir())

	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: isGoRun,
	})

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		scheduler := cron.New()

		e.Router.Use(middleware.Decompress())
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
			println("POST /data")
			reqBody := struct {
				PersonalId string     `json:"personalId"`
				Data       []DataItem `json:"data"`
			}{}

			if err := c.Bind(&reqBody); err != nil {
				log.Println("Error: ", err)
				return echo.NewHTTPError(http.StatusBadRequest, "Invalid request body")
			}

			// Create a folder path for the user based on the PersonalId
			userFolder := filepath.Join(STORAGE_PATH, reqBody.PersonalId)
			err := os.MkdirAll(userFolder, os.ModePerm) // MkdirAll creates the directory if it doesn't exist
			if err != nil {
				log.Println("Error: ", err)
				return err
			}

			// Use the current timestamp for the file name
			timestamp := time.Now()
			fileName := fmt.Sprintf("%s.json.gz", timestamp.Format("2006-01-02_15:04:05.000"))

			// Full file path within the user's folder
			filePath := filepath.Join(userFolder, fileName)
			err = writeCompressedFile(filePath, reqBody.Data)
			if err != nil {
				log.Println("Error: ", err)
				return err
			}

			// Extract the earliest and latest dates from the data
			datafrom, dataTo, err := getEarliestAndLatestDates(reqBody.Data)
			if err != nil {
				log.Println("Error: ", err)
				return err
			}

			collection, err := app.Dao().FindCollectionByNameOrId("dataUploads")
			if err != nil {
				log.Println("Error: ", err)
				return err
			}

			user, err := getUserForPersonalId(app, reqBody.PersonalId)
			if err != nil {
				log.Println("Error: ", err)
				return err
			}

			record := models.NewRecord(collection)
			record.Set("user", user.Id)
			record.Set("filePath", filePath)
			record.Set("timestamp", timestamp)
			record.Set("dataFrom", datafrom)
			record.Set("dataTo", dataTo)

			if err := app.Dao().SaveRecord(record); err != nil {
				log.Println("Error: ", err)
				return err
			}

			// Return success with metadata
			return c.JSON(http.StatusOK, map[string]interface{}{
				"message":  "Data saved successfully",
				"filePath": filePath,
			})
		})

		e.Router.GET("/data/:personalId", func(c echo.Context) error {
			// Extract the personalId from query parameters
			personalId := c.PathParam("personalId")

			// Construct the directory path based on the personalId
			userFolder := filepath.Join(STORAGE_PATH, personalId)

			// Open the directory and list all files
			files, err := os.ReadDir(userFolder)
			if err != nil {
				return err
			}

			// Slice to hold all concatenated data
			var allData []DataItem

			// Loop through each file in the directory
			for _, file := range files {
				// Ensure we're only processing .gz files
				if filepath.Ext(file.Name()) == ".gz" {
					// Construct the full file path
					filePath := filepath.Join(userFolder, file.Name())

					// Read and decompress the file (which contains an array of DataItem)
					dataItems, err := readCompressedFile(filePath)
					if err != nil {
						return err
					}

					// Append the data items to the allData slice
					allData = append(allData, dataItems...)
				}
			}

			// Return the concatenated array of data items
			return c.JSON(http.StatusOK, allData)
		})

		// cron job that triggers at 19:00 every day
		scheduler.MustAdd("hello", "0 19 * * *", func() {
			log.Println("Run notification job: ")
			token := getNotificationToken()

			users, _ := app.Dao().FindRecordsByFilter("users", "device_token != ''", "", 0, 0)
			log.Println("Users to notify: " + strconv.Itoa(len(users)))
			questionnaires, _ := app.Dao().FindRecordsByFilter("questionnaires", "enabled = true && (occurance = 'daily' || occurance = 'weekly')", "", 0, 0)

			for _, user := range users {
				notification := notificationToSend(app, user, questionnaires)

				if notification != nil {
					sendNotification(token, notification)
				}
			}
		})

		scheduler.Start()

		return nil
	})

	app.OnRecordAfterCreateRequest("answers").Add(func(e *core.RecordCreateEvent) error {
		userId := e.Record.Get("user").(string)

		// Get the user record
		user, _ := app.Dao().FindRecordById("users", userId)
		questionnaires, _ := app.Dao().FindRecordsByFilter("questionnaires", "enabled = true && (occurance = 'daily' || occurance = 'weekly')", "", 0, 0)

		notification := notificationToSend(app, user, questionnaires)

		if notification == nil {
			token := getNotificationToken()
			// we have answered so that we are done!
			notification := &apns2.Notification{}
			notification.DeviceToken = user.Get("device_token").(string)
			notification.Topic = "com.example.fractureMovement"
			payload := payload.NewPayload().Badge(0)
			notification.Payload = payload

			sendNotification(token, notification)
		}

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
