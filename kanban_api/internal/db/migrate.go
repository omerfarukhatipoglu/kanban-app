package db

import (
	"database/sql"
	"log"
)

func MustMigrate(db *sql.DB) {
	stmts := []string{
		`CREATE TABLE IF NOT EXISTS boards(
			id TEXT PRIMARY KEY,
			title TEXT NOT NULL
		);`,

		`CREATE TABLE IF NOT EXISTS cards(
			id TEXT PRIMARY KEY,
			board_id TEXT NOT NULL,
			list TEXT NOT NULL,
			title TEXT NOT NULL,
			description TEXT,           
			color_hex TEXT,            
			ord INTEGER NOT NULL,
			created_at TEXT NOT NULL,
			FOREIGN KEY(board_id) REFERENCES boards(id)
		);`,

		`CREATE INDEX IF NOT EXISTS idx_cards_board_list_ord
			ON cards(board_id, list, ord);`,
	}

	for _, s := range stmts {
		if _, err := db.Exec(s); err != nil {
			log.Fatal(err)
		}
	}
}
