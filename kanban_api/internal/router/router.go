package router

import (
	"database/sql"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/cors"

	"kanban-api/internal/handler"
	"kanban-api/internal/repo"
)

func New(db *sql.DB) http.Handler {
	r := chi.NewRouter()

	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "POST", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		AllowCredentials: false,
		MaxAge:           300,
	}))

	boardRepo := repo.BoardRepo{DB: db}
	cardRepo := repo.CardRepo{DB: db}

	bh := handler.BoardHandler{Boards: boardRepo, Cards: cardRepo}
	ch := handler.CardHandler{Boards: boardRepo, Cards: cardRepo}

	r.Get("/health", handler.Health)

 	r.Post("/boards", bh.CreateBoard)
	r.Get("/boards/{id}", bh.GetBoard)
	r.Patch("/boards/{id}", bh.PatchBoard)      
	r.Delete("/boards/{id}", bh.DeleteBoard)    

 	r.Post("/boards/{id}/cards", ch.CreateCard)
	r.Patch("/boards/{id}/cards/{cardId}", ch.PatchCard)
	r.Delete("/boards/{id}/cards/{cardId}", ch.DeleteCard)

	return r
}
