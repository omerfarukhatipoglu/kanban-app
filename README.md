# Kanban Board – Full Stack Project

Proje iki ana parçadan oluşmaktadır:
- **Mobil Uygulama:** Flutter ile geliştirilmiş Kanban Board mobil client
- **Backend API:** Go (Golang) ile geliştirilmiş RESTful API

---

## 📌 Projede Ne Yapıldı?

### Kanban Yapısı
- Board (Proje)
- Sabit 4 liste:
  - Backlog
  - To Do
  - In Progress
  - Done
- Kart (Card) yapısı:
  - Kart ekleme
  - Kart silme
  - Kart düzenleme (başlık, açıklama, renk)
  - Kartları listeler arası sürükle-bırak
  - Aynı liste içinde sıralama değiştirme

### Genel Özellikler
- Board oluşturulduğunda **unique bir ID** üretilir
- Bu ID ile herkes ilgili board’a erişebilir
- Kart sıralamaları backend tarafında kalıcı olarak saklanır
- Ziyaret edilen board’lar **local storage (SharedPreferences)** üzerinde tutulur

---

## 🧱 Proje Yapısı

kanban-board/
├── kanban_api/ # Go Backend
├── kanban_board/ # Flutter Mobile App
├── docs/
│ └── kanban-board.postman_collection.json
└── README.md


---

## 📮 API Dokümantasyonu
Tüm backend endpoint’leri Postman collection olarak eklenmiştir.

📁 Konum:
docs/kanban-board.postman_collection.json

---

## ▶️ Çalıştırma

Detaylı çalıştırma adımları ilgili klasörlerin içindeki README dosyalarında anlatılmıştır:

- [`kanban_api/README.md`](./kanban_api/README.md)
- [`kanban_board/README.md`](./kanban_board/README.md)