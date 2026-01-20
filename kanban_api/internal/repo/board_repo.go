package repo

import (
	"database/sql"

	"kanban-api/internal/model"
)

type BoardRepo struct{ DB *sql.DB }

func (r BoardRepo) Create(id, title string) error {
	_, err := r.DB.Exec(`INSERT INTO boards(id, title) VALUES(?, ?)`, id, title)
	return err
}

func (r BoardRepo) Get(id string) (model.Board, error) {
	var b model.Board
	err := r.DB.QueryRow(`SELECT id, title FROM boards WHERE id = ?`, id).Scan(&b.ID, &b.Title)
	return b, err
}

func (r BoardRepo) Exists(id string) (bool, error) {
	var tmp string
	err := r.DB.QueryRow(`SELECT id FROM boards WHERE id = ?`, id).Scan(&tmp)
	if err == sql.ErrNoRows {
		return false, nil
	}
	return err == nil, err
}

 
func (r BoardRepo) UpdateTitle(id, title string) error {
	_, err := r.DB.Exec(`UPDATE boards SET title = ? WHERE id = ?`, title, id)
	return err
}
 
func (r BoardRepo) Delete(id string) (bool, error) {
	res, err := r.DB.Exec(`DELETE FROM boards WHERE id = ?`, id)
	if err != nil {
		return false, err
	}
	n, _ := res.RowsAffected()
	return n > 0, nil
}
