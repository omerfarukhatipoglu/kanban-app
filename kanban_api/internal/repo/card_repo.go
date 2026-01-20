package repo

import (
	"database/sql"
	"time"

	"kanban-api/internal/model"
)

type CardRepo struct{ DB *sql.DB }

func (r CardRepo) ListByBoard(boardID string) ([]model.Card, error) {
	rows, err := r.DB.Query(`
		SELECT id, board_id, list, title, description, color_hex, ord, created_at
		FROM cards
		WHERE board_id = ?
		ORDER BY list ASC, ord ASC
	`, boardID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var out []model.Card
	for rows.Next() {
		var c model.Card
		var desc, color sql.NullString
		if err := rows.Scan(&c.ID, &c.BoardID, &c.List, &c.Title, &desc, &color, &c.Order, &c.CreatedAt); err != nil {
			return nil, err
		}

		if desc.Valid {
			s := desc.String
			c.Description = &s 
		} else {
			c.Description = nil
		}

		if color.Valid {
			c.ColorHex = color.String
		}
		out = append(out, c)
	}
	return out, nil
}

func (r CardRepo) NextOrder(boardID, list string) (int, error) {
	var ord int
	err := r.DB.QueryRow(
		`SELECT COALESCE(MAX(ord), -1) + 1 FROM cards WHERE board_id = ? AND list = ?`,
		boardID, list,
	).Scan(&ord)
	return ord, err
}

func (r CardRepo) Create(c model.Card) error {
	if c.CreatedAt == "" {
		c.CreatedAt = time.Now().UTC().Format(time.RFC3339)
	}

	var desc any = nil
	if c.Description != nil && len(*c.Description) > 0 {
		desc = *c.Description  
	}

	_, err := r.DB.Exec(`
		INSERT INTO cards(id, board_id, list, title, description, color_hex, ord, created_at)
		VALUES(?, ?, ?, ?, ?, ?, ?, ?)
	`, c.ID, c.BoardID, c.List, c.Title, desc, nullIfEmpty(c.ColorHex), c.Order, c.CreatedAt)
	return err
}

 func (r CardRepo) UpdateFields(
	boardID, cardID string,
	title *string,
	list *string,
	description *string,  
	ord *int,
	colorHex *string,
) error {
	if title != nil {
		if _, err := r.DB.Exec(`UPDATE cards SET title = ? WHERE id = ? AND board_id = ?`, *title, cardID, boardID); err != nil {
			return err
		}
	}

 	if description != nil {
		var v any = nil
		if len(*description) > 0 {
			v = *description
		}
		if _, err := r.DB.Exec(`UPDATE cards SET description = ? WHERE id = ? AND board_id = ?`, v, cardID, boardID); err != nil {
			return err
		}
	}

	if colorHex != nil {
		if _, err := r.DB.Exec(`UPDATE cards SET color_hex = ? WHERE id = ? AND board_id = ?`, nullIfEmpty(*colorHex), cardID, boardID); err != nil {
			return err
		}
	}
	if list != nil {
		if _, err := r.DB.Exec(`UPDATE cards SET list = ? WHERE id = ? AND board_id = ?`, *list, cardID, boardID); err != nil {
			return err
		}
	}
	if ord != nil {
		if _, err := r.DB.Exec(`UPDATE cards SET ord = ? WHERE id = ? AND board_id = ?`, *ord, cardID, boardID); err != nil {
			return err
		}
	}
	return nil
}

func (r CardRepo) Delete(boardID, cardID string) (bool, error) {
	res, err := r.DB.Exec(`DELETE FROM cards WHERE id = ? AND board_id = ?`, cardID, boardID)
	if err != nil {
		return false, err
	}
	n, _ := res.RowsAffected()
	return n > 0, nil
}

 func (r CardRepo) DeleteByBoard(boardID string) error {
	_, err := r.DB.Exec(`DELETE FROM cards WHERE board_id = ?`, boardID)
	return err
}

func (r CardRepo) NormalizeOrders(boardID, list string) error {
	rows, err := r.DB.Query(`SELECT id FROM cards WHERE board_id = ? AND list = ? ORDER BY ord ASC, created_at ASC`, boardID, list)
	if err != nil {
		return err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return err
		}
		ids = append(ids, id)
	}

	tx, err := r.DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	for i, id := range ids {
		if _, err := tx.Exec(`UPDATE cards SET ord = ? WHERE id = ? AND board_id = ?`, i, id, boardID); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func nullIfEmpty(s string) any {
	if len(s) == 0 {
		return nil
	}
	return s
}
