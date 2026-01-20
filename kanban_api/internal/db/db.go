package db

import (
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
)

func MustOpen(path string) *sql.DB {
	d, err := sql.Open("sqlite3", path)
	if err != nil {
		log.Fatal(err)
	}
	return d
}
