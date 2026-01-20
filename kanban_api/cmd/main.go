package main

import (
	"log"
	"net/http"

	"kanban-api/internal/db"
	"kanban-api/internal/router"
)

func main() {
	database := db.MustOpen("./kanban.db")
	db.MustMigrate(database)

	r := router.New(database)

	log.Println("API running on :8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
