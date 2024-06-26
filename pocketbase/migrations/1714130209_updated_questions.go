package migrations

import (
	"encoding/json"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models/schema"
)

func init() {
	m.Register(func(db dbx.Builder) error {
		dao := daos.New(db);

		collection, err := dao.FindCollectionByNameOrId("revsudry2wqi0dp")
		if err != nil {
			return err
		}

		// add
		new_valueFromQuestion := &schema.SchemaField{}
		if err := json.Unmarshal([]byte(`{
			"system": false,
			"id": "yqp6lqi4",
			"name": "valueFromQuestion",
			"type": "relation",
			"required": false,
			"presentable": false,
			"unique": false,
			"options": {
				"collectionId": "revsudry2wqi0dp",
				"cascadeDelete": false,
				"minSelect": null,
				"maxSelect": 1,
				"displayFields": null
			}
		}`), new_valueFromQuestion); err != nil {
			return err
		}
		collection.Schema.AddField(new_valueFromQuestion)

		return dao.SaveCollection(collection)
	}, func(db dbx.Builder) error {
		dao := daos.New(db);

		collection, err := dao.FindCollectionByNameOrId("revsudry2wqi0dp")
		if err != nil {
			return err
		}

		// remove
		collection.Schema.RemoveField("yqp6lqi4")

		return dao.SaveCollection(collection)
	})
}
