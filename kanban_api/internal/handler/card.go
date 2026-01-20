package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"kanban-api/internal/httpx"
	"kanban-api/internal/model"
	"kanban-api/internal/repo"
	"kanban-api/internal/util"
)

var allowedLists = map[string]bool{
	"backlog": true, "todo": true, "inprogress": true, "done": true,
}

type CardHandler struct {
	Boards repo.BoardRepo
	Cards  repo.CardRepo
}

func (h CardHandler) CreateCard(w http.ResponseWriter, r *http.Request) {
	boardID := chi.URLParam(r, "id")

	exists, err := h.Boards.Exists(boardID)
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	if !exists {
		httpx.Error(w, http.StatusNotFound, "board not found")
		return
	}

	var body struct {
		List        string  `json:"list"`
		Title       string  `json:"title"`
		Description *string `json:"description,omitempty"`  
		ColorHex    string  `json:"colorHex"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpx.Error(w, http.StatusBadRequest, "invalid json")
		return
	}

	list := strings.ToLower(strings.TrimSpace(body.List))
	if !allowedLists[list] {
		httpx.Error(w, http.StatusBadRequest, "invalid list")
		return
	}
	title := strings.TrimSpace(body.Title)
	if title == "" {
		httpx.Error(w, http.StatusBadRequest, "title required")
		return
	}

	ord, _ := h.Cards.NextOrder(boardID, list)

	card := model.Card{
		ID:          util.NewID(),
		BoardID:     boardID,
		List:        list,
		Title:       title,
		Description: util.NormalizeOptionalString(body.Description),  
		ColorHex:    body.ColorHex,
		Order:       ord,
	}

	if err := h.Cards.Create(card); err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	httpx.JSON(w, http.StatusCreated, card)
}

func (h CardHandler) PatchCard(w http.ResponseWriter, r *http.Request) {
	boardID := chi.URLParam(r, "id")
	cardID := chi.URLParam(r, "cardId")

	var body struct {
		List        *string `json:"list,omitempty"`
		Title       *string `json:"title,omitempty"`
		Description *string `json:"description,omitempty"`  
		Order       *int    `json:"order,omitempty"`
		ColorHex    *string `json:"colorHex,omitempty"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		httpx.Error(w, http.StatusBadRequest, "invalid json")
		return
	}

	if body.List != nil {
		l := strings.ToLower(strings.TrimSpace(*body.List))
		if !allowedLists[l] {
			httpx.Error(w, http.StatusBadRequest, "invalid list")
			return
		}
		*body.List = l
	}
	if body.Title != nil {
		t := strings.TrimSpace(*body.Title)
		if t == "" {
			httpx.Error(w, http.StatusBadRequest, "title cannot be empty")
			return
		}
		*body.Title = t
	}
	if body.Order != nil && *body.Order < 0 {
		httpx.Error(w, http.StatusBadRequest, "order must be >= 0")
		return
	}

 	var desc *string
	if body.Description != nil {
		desc = util.NormalizeOptionalString(body.Description)  
	}

	if err := h.Cards.UpdateFields(
		boardID,
		cardID,
		body.Title,
		body.List,
		desc,  
		body.Order,
		body.ColorHex,
	); err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}

	if body.List != nil {
		_ = h.Cards.NormalizeOrders(boardID, *body.List)
	}

	httpx.JSON(w, http.StatusOK, map[string]string{"ok": "true"})
}

func (h CardHandler) DeleteCard(w http.ResponseWriter, r *http.Request) {
	boardID := chi.URLParam(r, "id")
	cardID := chi.URLParam(r, "cardId")

	ok, err := h.Cards.Delete(boardID, cardID)
	if err != nil {
		httpx.Error(w, http.StatusInternalServerError, err.Error())
		return
	}
	if !ok {
		httpx.Error(w, http.StatusNotFound, "card not found")
		return
	}
	httpx.JSON(w, http.StatusOK, map[string]string{"ok": "true"})
}
