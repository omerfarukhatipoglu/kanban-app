# Kanban Board – Mobile (Flutter)

Bu klasör, Kanban Board uygulamasının **mobil tarafını** içermektedir.  
Uygulama Flutter framework’ü ile geliştirilmiştir ve state management için **GetX** kullanılmıştır.

---

## 🚀 Kullanılan Teknolojiler
- Flutter
- Dart
- GetX (State Management & Routing)
- HTTP package
- SharedPreferences (local storage)

---

## 📌 Mobil Tarafta Yapılanlar

### Ana Ekran
- Yeni board oluşturma
- Board ID ile mevcut board’a katılma
- Daha önce ziyaret edilen board’ların listelenmesi
- Son ziyaret edilen board’ların localde saklanması

### Board Ekranı
- Sabit 4 kolon (Backlog, To Do, In Progress, Done)
- Kart ekleme / silme / düzenleme
- Kartlara renk ve açıklama ekleme
- Drag & Drop ile:
  - Liste içi sıralama
  - Listeler arası taşıma

---

## 📱 UI & UX
- Responsive tasarım
- Mobil ekranlar için optimize edilmiş layout
- Kullanıcı etkileşimlerine uygun animasyonlar

---

## ▶️ Çalıştırma

```bash
flutter pub get
flutter run
Not: Backend çalışıyor olmalıdır.
Varsayılan backend adresi:
http://localhost:8080