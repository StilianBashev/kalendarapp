## Календар с Flutter и Firebase

Приложение за управление на събития с Flutter и Firebase. Потребителите могат да се регистрират, влизат в профила си, създават, редактират и изтриват събития, които се показват в календара.

---

## Функционалности

- Вход и регистрация с Firebase Authentication
- Преглед на събития по дати в календар
- Създаване на събития със заглавие, описание (по избор), начална и крайна дата/час
- Редакция на вече създадени събития
- Профил с показване на имейл и всички събития на потребителя
- Изтриване на събития с потвърждение
- Долна навигация между "Календар" и "Профил"
- Валидиране на формите (имейл, парола, празни полета)
- Събитията се съхраняват във Firebase Firestore

- ## Стъпки за стартиране

1. Клонирай проекта:
```
-git clone https://github.com/yourusername/kalendar_app.git
-cd kalendar_app
```

2.Инсталирай зависимостите:
```
-flutter pub get
```

3.Конфигурирай Firebase:
Добави google-services.json (Android) или GoogleService-Info.plist (за iOS)
Активирай Email/Password login във Firebase Authentication
Създай база данни във Firestore

4.Стартирай приложението
```
-flutter run
```

- ## Структура на данните

Потребител:
```
{
  "uid": "a1b2c3d4",
  "email": "pesho@example.com",
  "name": "Pesho Peshov",
  "createdAt": "2025-06-01T10:20:30Z"
}
```

Събитие:
```
{
  "id": "event_001",
  "title": "Среща с екипа",
  "description": "Обсъждане на проектните задачи",
  "startTime": "2025-06-05T14:00:00Z",
  "endTime": "2025-06-05T15:00:00Z",
  "createdBy": "a1b2c3d4",
  "color": "#2196F3",
  "createdAt": "2025-06-01T12:00:00Z"
}
