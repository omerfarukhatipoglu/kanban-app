package model

type Card struct {
	ID          string  `json:"id"`
	BoardID     string  `json:"boardId"`
	List        string  `json:"list"`
	Title       string  `json:"title"`
	Description *string `json:"description,omitempty"`  
	ColorHex    string  `json:"colorHex,omitempty"`
	Order       int     `json:"order"`
	CreatedAt   string  `json:"createdAt"`
}
