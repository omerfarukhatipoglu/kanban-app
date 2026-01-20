package handler

import (
	"net/http"

	"kanban-api/internal/httpx"
)

func Health(w http.ResponseWriter, r *http.Request) {
	httpx.JSON(w, http.StatusOK, map[string]string{"ok": "true"})
}
