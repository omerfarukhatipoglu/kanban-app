package handler

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"kanban-api/internal/httpx"
	"kanban-api/internal/model"
	"kanban-api/internal/repo"
	"kanban-api/internal/util"
)

type BoardHandler struct {
	Boards repo.BoardRepo
	Cards  repo.CardRepo
}

func (h BoardHandler) CreateBoard(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Title string `json:"title"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpx.Error(w, http.StatusBadRequest, "invalid json")
		return
	}

	title := strings.TrimSpace(body.Title)
	if title == "" {
		title = "Untitled Board"
	}

	id := util.NewPublicID()
	if err := h.Boards.Create(id, title); err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	httpx.JSON(w, http.StatusCreated, model.Board{ID: id, Title: title})
}

func (h BoardHandler) GetBoard(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	b, err := h.Boards.Get(id)
	if err == sql.ErrNoRows {
		httpx.Error(w, http.StatusNotFound, "board not found")
		return
	}
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	cards, err := h.Cards.ListByBoard(id)
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	cols := map[string][]model.Card{
		"backlog": {}, "todo": {}, "inprogress": {}, "done": {},
	}
	for _, c := range cards {
		cols[c.List] = append(cols[c.List], c)
	}

	httpx.JSON(w, http.StatusOK, model.BoardResponse{
		ID:      b.ID,
		Title:   b.Title,
		Columns: cols,
	})
}

func (h BoardHandler) PatchBoard(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	_, err := h.Boards.Get(id)
	if err == sql.ErrNoRows {
		httpx.Error(w, http.StatusNotFound, "board not found")
		return
	}
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	var body struct {
		Title *string `json:"title"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpx.Error(w, http.StatusBadRequest, "invalid json")
		return
	}
	if body.Title == nil {
		httpx.Error(w, http.StatusBadRequest, "no fields to update")
		return
	}

	title := strings.TrimSpace(*body.Title)
	if title == "" {
		httpx.Error(w, http.StatusBadRequest, "title cannot be empty")
		return
	}

	if err := h.Boards.UpdateTitle(id, title); err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	httpx.JSON(w, http.StatusOK, map[string]string{"ok": "true"})
}

 
func (h BoardHandler) DeleteBoard(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	_, err := h.Boards.Get(id)
	if err == sql.ErrNoRows {
		httpx.Error(w, http.StatusNotFound, "board not found")
		return
	}
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
 
	if err := h.Cards.DeleteByBoard(id); err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	 
	ok, err := h.Boards.Delete(id)
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	if !ok {
		httpx.Error(w, http.StatusNotFound, "board not found")
		return
	}

	httpx.JSON(w, http.StatusOK, map[string]string{"ok": "true"})
}
