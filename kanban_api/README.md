# 🧠 Kanban Board – Backend API (Go)

Bu klasör, Rast Mobile tarafından iletilen teknik task kapsamında geliştirilen  
**Kanban Board uygulamasının backend (sunucu) tarafını** içermektedir.

Backend, **Go (Golang)** kullanılarak geliştirilmiş olup **RESTful API prensiplerine**
uygun şekilde tasarlanmıştır.

---

## 🚀 Kullanılan Teknolojiler

- Go (Golang)
- net/http
- Chi Router
- SQLite (kalıcı veri saklama)
- JSON tabanlı REST API

---

## 📌 Backend’de Yapılanlar

### Board Yönetimi
- Yeni board oluşturma
- Her board için **unique bir ID** üretme
- Board’lara **ID ile public erişim**
- Board silme (board silinince bağlı kartlar da silinir)

### Card Yönetimi
- Kart oluşturma
- Kart silme
- Kart güncelleme:
  - Başlık (title)
  - Açıklama (description – opsiyonel)
  - Renk (colorHex – opsiyonel)
  - Liste (backlog, todo, inprogress, done)
  - Sıra (order)
- Kartların:
  - Aynı liste içinde sıralanabilmesi
  - Listeler arası taşınabilmesi
- Kart sıralamalarının backend tarafında **normalize edilmesi**

---

## 🗃️ Veri Modeli

### Board
| Alan | Açıklama |
|-----|----------|
| id | Board’un unique ID’si |
| title | Board başlığı |

### Card
| Alan | Açıklama |
|------|----------|
| id | Kart ID |
| board_id | Bağlı olduğu board |
| list | Bulunduğu liste |
| title | Kart başlığı |
| description | Kart açıklaması (opsiyonel) |
| color_hex | Kart rengi (opsiyonel) |
| ord | Kart sırası |
| created_at | Oluşturulma zamanı |

---

## 🧱 Proje Yapısı

kanban_api/
├── cmd/
│ └── main.go
├── internal/
│ ├── db/ # DB bağlantısı ve migration
│ ├── handler/ # HTTP handlers
│ ├── model/ # Veri modelleri
│ ├── repo/ # Database işlemleri
│ ├── router/ # Router tanımları
│ └── util/ # Yardımcı fonksiyonlar
├── go.mod
└── go.sum

  
Katmanlı yapı sayesinde:
- **Handler** → HTTP request/response
- **Repo** → Veritabanı işlemleri
- **Model** → Veri yapıları  

net bir şekilde ayrılmıştır.

---

## 🌐 API Endpoint’leri

### Health Check
GET /health

shell
 
### Board
POST /boards
GET /boards/{id}
DELETE /boards/{id}

shell
 
### Card
POST /boards/{id}/cards
PATCH /boards/{id}/cards/{cardId}
DELETE /boards/{id}/cards/{cardId}

  
---

## 📮 Postman Collection

Tüm backend endpoint’leri Postman collection olarak hazırlanmıştır.

📁 Dosya yolu:
docs/kanban-board.postman_collection.json

  
Bu dosya Postman’e import edilerek API’ler test edilebilir.

---

## ▶️ Çalıştırma

```bash
go run main.go
Backend varsayılan olarak aşağıdaki adreste çalışır:

http://localhost:8080