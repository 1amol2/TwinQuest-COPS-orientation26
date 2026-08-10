  # TwinQuest — Flutter App

TwinQuest is a Flutter-based real-world Bluetooth proximity matching application.

Participants are randomly paired with another participant and each player receives half of the same image. Players then use Bluetooth Low Energy (BLE) to find their assigned partner. As the two participants get closer, the app provides visual proximity feedback. Once the partners meet and confirm the match, the two image halves combine into a complete image with an animation.

The project is being developed as a Flutter frontend with a separate Spring Boot backend.

---

## 📱 Core Concept

```text
Participant A                         Participant B
     │                                      │
     │        Half of the image             │
     │                                      │
     └──────────── Bluetooth BLE ───────────┘
                         │
                         ▼
                  Proximity Detection
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
           BLUE         RED        GREEN
            Far        Close      Matched
                         │
                         ▼
                 Match Confirmation
                         │
                         ▼
                Image halves combine
                         │
                         ▼
                    Leaderboard
```

---

# ✨ Features

## Current UI

The Flutter application currently contains the complete visual flow and reusable UI components for the main TwinQuest experience.

### Included Screens

1. Home / Landing
2. Waiting for Pairing
3. Getting Closer
4. Touch to Match
5. Match Result
6. Leaderboard
7. My Pair
8. Profile
9. How It Works
10. Join Event
11. Nearby Pairs
12. Settings

---

# 🎨 Design System

TwinQuest follows a consistent warm, friendly visual language.

### Visual Style

- Warm beige backgrounds
- Dark brown primary color
- Soft peach accents
- Rounded cards
- Rounded buttons
- Soft shadows
- Minimal typography
- Clean spacing
- Bluetooth proximity indicators
- Signal rings
- Reusable bottom navigation
- Consistent component styling

The design is based on the supplied TwinQuest UI reference.

---

# 🧩 Technology Stack

## Mobile Application

- Flutter
- Dart
- Material Design
- Bluetooth Low Energy (BLE)
- REST API
- WebSockets

## Backend

- Spring Boot
- Java
- Spring Web
- Spring WebSocket
- Spring Data MongoDB
- MongoDB

## Backend Architecture

```text
Flutter App
    │
    ├──────── REST API ────────┐
    │                          │
    ├──────── WebSocket ───────┤
    │                          ▼
    │                    Spring Boot
    │                          │
    │                          ▼
    │                       MongoDB
    │
    └────── Bluetooth BLE
                │
                ▼
          Nearby Phones
```

Bluetooth proximity is handled directly between nearby devices. The backend is responsible for matchmaking, event management, player state, match results, and leaderboard data.

---

# 📁 Project Structure

```text
TwinQuest/
│
├── TwinQuest-app/
│   │
│   ├── android/
│   ├── ios/
│   ├── assets/
│   │   └── images/
│   │       ├── hero_pair.png
│   │       └── puzzle_landscape.png
│   │
│   ├── lib/
│   │   ├── core/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   └── routes.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── pairing_screen.dart
│   │   │   ├── closer_screen.dart
│   │   │   ├── touch_match_screen.dart
│   │   │   ├── match_result_screen.dart
│   │   │   ├── leaderboard_screen.dart
│   │   │   ├── my_pair_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── how_it_works_screen.dart
│   │   │   ├── join_event_screen.dart
│   │   │   ├── nearby_pairs_screen.dart
│   │   │   └── settings_screen.dart
│   │   │
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_card.dart
│   │   │   ├── app_header.dart
│   │   │   ├── avatar.dart
│   │   │   ├── bottom_nav.dart
│   │   │   ├── half_card.dart
│   │   │   ├── progress_row.dart
│   │   │   └── signal_rings.dart
│   │   │
│   │   └── main.dart
│   │
│   ├── reference/
│   │   └── ui_reference.jpg
│   │
│   ├── test/
│   │   └── widget_test.dart
│   │
│   ├── analysis_options.yaml
│   ├── pubspec.yaml
│   └── README.md
│
└── TwinQuest-backend/
    │
    ├── src/
    │   ├── main/
    │   │   ├── java/
    │   │   │   └── com/
    │   │   │       └── twinquest/
    │   │   │           └── backend/
    │   │   │
    │   │   └── resources/
    │   │       └── application.properties
    │   │
    │   └── test/
    │
    ├── build.gradle
    ├── settings.gradle
    └── gradlew.bat
```

---

# 🔄 Application Flow

```text
                         HOME
                           │
                           ▼
                      JOIN EVENT
                           │
                           ▼
                  WAITING FOR PAIR
                           │
                           ▼
                  PARTNER ASSIGNED
                           │
                           ▼
                   RECEIVE IMAGE HALF
                           │
                           ▼
                  SEARCH FOR PARTNER
                           │
                           ▼
                    GETTING CLOSER
                           │
                  ┌────────┴────────┐
                  │                 │
                 FAR              CLOSE
                  │                 │
                BLUE               RED
                                    │
                                    ▼
                              TOUCH PHONES
                                    │
                                    ▼
                              MATCH CONFIRMED
                                    │
                                    ▼
                         IMAGE MERGE ANIMATION
                                    │
                                    ▼
                              MATCH RESULT
                                    │
                                    ▼
                              LEADERBOARD
```

---

# 🔵 Bluetooth Proximity

The core gameplay mechanic uses Bluetooth Low Energy.

The phones communicate directly with nearby devices.

```text
Phone A
   │
   │ Bluetooth Low Energy
   │
   ▼
Phone B
```

The Flutter application will use BLE scanning and device information such as RSSI to estimate relative proximity.

Conceptually:

```text
Partner far away
       ↓
     🔵 BLUE

Partner getting closer
       ↓
     🔴 RED

Partner very close
       ↓
     🟢 GREEN

Match confirmed
       ↓
  Image combines
```

### Important

RSSI is an estimate of signal strength rather than a precise physical distance measurement. Thresholds will therefore need to be calibrated and tested across different Android devices and environments.

---

# 🌐 Backend Responsibilities

The Spring Boot backend does not determine physical Bluetooth proximity.

Instead, it handles the shared game state.

### Backend responsibilities

- Event creation
- Event joining
- Player registration
- Random matchmaking
- Partner assignment
- Image-half assignment
- Match state
- Match completion
- Match timing
- Leaderboard
- Live game updates
- WebSocket communication

### Bluetooth responsibilities

- Nearby device scanning
- BLE connection/discovery
- Device identification
- RSSI monitoring
- Proximity feedback
- Physical match confirmation

---

# 🔌 Communication Architecture

## REST

REST APIs are used for normal request/response operations.

```text
Flutter
   │
   │ HTTP
   ▼
Spring Boot
   │
   ▼
MongoDB
```

Potential endpoints:

```text
POST /api/events/join
GET  /api/events/{eventId}
GET  /api/matches/{playerId}
POST /api/matches/complete
GET  /api/leaderboard
```

---

## WebSocket

WebSockets are used for real-time updates.

```text
Flutter
   ⇅
WebSocket
   ⇅
Spring Boot
```

Potential events:

```text
PLAYER_JOINED
PAIR_ASSIGNED
GAME_STARTED
IMAGE_ASSIGNED
MATCH_STARTED
MATCH_CONFIRMED
LEADERBOARD_UPDATED
GAME_FINISHED
```

Example:

```json
{
  "type": "PAIR_ASSIGNED",
  "playerId": "123",
  "partnerId": "456",
  "half": "LEFT"
}
```

---

# 🗄️ Database

MongoDB will store persistent application data.

Potential collections:

```text
users
events
pairs
images
match_results
leaderboards
```

Example player document:

```json
{
  "id": "123",
  "name": "Amol",
  "eventId": "COPS2026",
  "status": "PAIRED"
}
```

Example pair document:

```json
{
  "pairId": "P001",
  "playerOneId": "123",
  "playerTwoId": "456",
  "imageId": "IMG001",
  "status": "SEARCHING"
}
```

---

# 🖼️ Image Matching

Each pair receives two halves of the same image.

```text
Original Image

┌─────────────────────────┐
│                         │
│         IMAGE           │
│                         │
└─────────────────────────┘

             ↓

┌─────────────┬───────────┐
│             │           │
│ LEFT HALF   │ RIGHT     │
│             │ HALF      │
└─────────────┴───────────┘
```

Player A receives:

```text
LEFT HALF
```

Player B receives:

```text
RIGHT HALF
```

After the match:

```text
LEFT HALF + RIGHT HALF
           ↓
     COMPLETE IMAGE
```

A merge animation will be shown after successful confirmation.

---

# 📱 UI Components

The application uses reusable Flutter widgets rather than duplicating UI code.

### Core widgets

- `AppButton`
- `AppCard`
- `AppHeader`
- `Avatar`
- `BottomNav`
- `HalfCard`
- `ProgressRow`
- `SignalRings`

This allows the same visual language to be maintained across the entire application.

---

# 📊 Game States

The application can be modeled using states such as:

```text
IDLE
  ↓
JOINING_EVENT
  ↓
WAITING_FOR_PAIR
  ↓
PAIR_ASSIGNED
  ↓
SEARCHING
  ↓
GETTING_CLOSER
  ↓
MATCH_READY
  ↓
CONFIRMING
  ↓
MATCHED
  ↓
COMPLETED
```

---

# 🚧 Implementation Status

## Flutter UI

- [x] Flutter project setup
- [x] Application theme
- [x] Color system
- [x] Home screen
- [x] Pairing screen
- [x] Getting closer screen
- [x] Touch to match screen
- [x] Match result screen
- [x] Leaderboard screen
- [x] My Pair screen
- [x] Profile screen
- [x] How It Works screen
- [x] Join Event screen
- [x] Nearby Pairs screen
- [x] Settings screen
- [x] Navigation
- [x] Reusable widgets
- [x] Reference illustrations
- [x] TwinQuest visual theme

## Backend

- [x] Spring Boot project setup
- [x] Spring Web dependency
- [x] Spring WebSocket dependency
- [x] Spring Data MongoDB dependency
- [ ] MongoDB configuration
- [ ] Data models
- [ ] Repositories
- [ ] Services
- [ ] REST controllers
- [ ] WebSocket configuration
- [ ] Matchmaking
- [ ] Event management
- [ ] Image assignment
- [ ] Match completion
- [ ] Leaderboard
- [ ] WebSocket events

## Bluetooth

- [ ] BLE permissions
- [ ] Bluetooth state detection
- [ ] BLE scanning
- [ ] Device identification
- [ ] RSSI monitoring
- [ ] Proximity thresholds
- [ ] Partner detection
- [ ] Match confirmation
- [ ] Multi-device testing

## Integration

- [ ] Flutter REST integration
- [ ] Flutter WebSocket integration
- [ ] Backend matchmaking integration
- [ ] Real image assignment
- [ ] Match completion synchronization
- [ ] Live leaderboard
- [ ] End-to-end testing

---

# 🛠️ Setup

## Prerequisites

Install:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Java 21
- Git
- MongoDB or MongoDB Atlas

Verify Flutter:

```bash
flutter doctor
```

Verify Java:

```bash
java -version
```

---

# 🚀 Run Flutter App

Navigate to the Flutter project:

```bash
cd TwinQuest-app
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

For a release Android APK:

```bash
flutter build apk --release
```

The generated APK can be found under:

```text
build/app/outputs/flutter-apk/
```

---

# 🚀 Run Spring Boot Backend

Navigate to the backend:

```bash
cd TwinQuest-backend
```

On Windows:

```bash
gradlew.bat bootRun
```

On macOS/Linux:

```bash
./gradlew bootRun
```

The backend will run on the configured Spring Boot port.

---

# ⚙️ Configuration

MongoDB configuration should be stored in the Spring Boot configuration.

Example:

```properties
spring.application.name=twinquest-backend

spring.data.mongodb.uri=${MONGODB_URI}

server.port=8080
```

For local development, environment variables can be configured through the IDE or system environment.

Do not commit database credentials, API keys, or other secrets to Git.

---

# 🧪 Testing

Testing will cover three major areas.

## Flutter

```text
UI
Navigation
State management
Bluetooth
REST
WebSocket
```

Run Flutter tests:

```bash
flutter test
```

## Backend

Test:

```text
REST APIs
Matchmaking
WebSocket events
MongoDB operations
Leaderboard
```

## Device Testing

Bluetooth functionality should be tested on real Android devices because emulator Bluetooth behavior does not accurately represent the real-world proximity experience.

Test with:

```text
2 phones
5 phones
10+ phones
```

and under different physical conditions.

---

# 🔐 Security Considerations

The backend should not blindly trust the Flutter client.

Important considerations:

- Validate all API requests.
- Validate event codes.
- Validate player IDs.
- Prevent duplicate participation.
- Prevent duplicate match completion.
- Validate match state transitions.
- Avoid exposing sensitive user information.
- Never commit MongoDB credentials.
- Add authentication if the production version requires accounts.

---

# 📈 Future Improvements

Potential future features include:

- Admin dashboard
- Event creation
- QR-based event joining
- QR-based pairing
- Player avatars
- Custom event themes
- Multiple image packs
- Tournament mode
- Team mode
- Match history
- Global leaderboard
- Persistent user profiles
- Push notifications
- Better proximity calibration
- Offline fallback
- Reconnection handling
- Anti-cheat mechanisms
- Analytics
- Event statistics

---

# 🧠 Architecture Overview

```text
                         TWINQUEST
                            │
              ┌─────────────┴─────────────┐
              │                           │
          Flutter App                Spring Boot
              │                           │
       ┌──────┼───────┐             ┌─────┼─────┐
       │      │       │             │     │     │
       UI   BLE    Networking      REST  WS   MongoDB
       │      │       │
       │      │       ├───────────────┐
       │      │                       │
       │      └── Phone-to-Phone      │
       │          Bluetooth           │
       │                              │
       └──────────────────────────────┘
```

The separation of responsibilities is intentional:

```text
Flutter
→ UI + Bluetooth + local game interaction

Spring Boot
→ Matchmaking + shared game state + APIs + WebSocket

MongoDB
→ Persistent application data
```

---

# 📌 Development Roadmap

### Phase 1 — UI

- [x] Design system
- [x] Main screens
- [x] Navigation
- [x] Reusable components

### Phase 2 — Backend

- [x] Spring Boot setup
- [ ] MongoDB
- [ ] Models
- [ ] APIs
- [ ] WebSockets
- [ ] Matchmaking

### Phase 3 — Bluetooth

- [ ] Permissions
- [ ] BLE scanning
- [ ] Device identification
- [ ] RSSI
- [ ] Proximity states

### Phase 4 — Integration

- [ ] Connect Flutter to REST APIs
- [ ] Connect Flutter to WebSocket
- [ ] Connect matchmaking to Bluetooth identity
- [ ] Synchronize match completion
- [ ] Live leaderboard

### Phase 5 — Polish

- [ ] Match animation
- [ ] Haptic feedback
- [ ] Sound effects
- [ ] Error states
- [ ] Reconnection
- [ ] Performance optimization
- [ ] Multi-device testing

---

# 👥 Project Goal

TwinQuest is designed as an interactive event experience where participants physically move around, use their phones to locate their assigned partners, and complete a shared visual puzzle.

The combination of:

```text
Flutter
+
Bluetooth Low Energy
+
Spring Boot
+
WebSockets
+
MongoDB
```

creates a real-time mobile experience that combines software with physical interaction.

---

## 📄 License

This project is developed for educational and event-oriented purposes.
