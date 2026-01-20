package model

type Board struct {
	ID    string `json:"id"`
	Title string `json:"title"`
}

type BoardResponse struct {
	ID      string            `json:"id"`
	Title   string            `json:"title"`
	Columns map[string][]Card `json:"columns"`
}
