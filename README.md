# TwinQuest — COPS Orientation 2026 App

TwinQuest is a real-world multiplayer Bluetooth & PIN verification proximity matching application designed for COPS orientation. 

Participants sign in via Google or Guest mode and are automatically paired by the Spring Boot backend. Each player receives half of a puzzle image and uses Bluetooth Low Energy (BLE) signal indicators plus a secret 4-Digit Verification PIN to locate their mystery partner in the orientation hall.

---

## 📱 Core Architecture & Flow

```text
Participant A                                     Participant B
     │                                                 │
     │         Google Sign-In / Guest Mode             │
     ├───────────────────────┬─────────────────────────┤
     │                       │                         │
     ▼                       ▼                         ▼
            Spring Boot Matchmaking Engine
     │                       │                         │
     ├─────────────── Assigned Pair ──────────────────┤
     │ (LEFT Half 🔒)                 (RIGHT Half 🔒) │
     │ (Screen PIN: 7842)            (Screen PIN: 9104)│
     │                       │                         │
     └─────────────── Bluetooth BLE ───────────────────┘
                             │
                             ▼
                    Proximity Detection
                             │
             ┌───────────────┼───────────────┐
             ▼               ▼               ▼
           BLUE            RED            GREEN
            Far           Close          Matched
                             │
                             ▼
                Asymmetric Cross-PIN Handshake
             (Player 1 inputs 9104, Player 2 inputs 7842)
                             │
                             ▼
              Server Timer & Anti-Cheat Validation
                             │
                             ▼
              Unique Puzzle Image Merge Animation
                             │
                             ▼
                     Live Leaderboard
```

---

## ✨ Key Features & Security Architecture

### 🔒 1. Asymmetric Cross-PIN Verification (Anti-Cheat)
- **Partner-Enforced Matching**: Each paired player receives a distinct 4-digit PIN code (`pinP1` & `pinP2`).
- **In-Person Requirement**: Player 1 must physically stand in front of Player 2 and enter the PIN displayed on Player 2's screen (and vice-versa).
- **Server Verification**: `GameService.completeMatch()` rejects mismatched or missing PINs with **`HTTP 400 Bad Request`**. Solo players cannot complete matches alone.

### ⏱️ 2. Server-Calculated Stopwatch Timers
- The Spring Boot backend measures match duration server-side (`now - match.getStartTime()`), ignoring client-fabricated timers and preventing duration spoofing.

### 🎁 3. Mystery Locked Cards & Picture Reveal
- **Pre-Match Privacy**: During the search phase, puzzle halves are hidden behind a **Mystery Locked Card 🔒** with the label `"🔒 Secret Puzzle Piece (LEFT/RIGHT Half)"`.
- **Dynamic Image Merging**: Once the PIN match is verified, the backend returns unique base64 PNG image halves (`leftHalfImage` and `rightHalfImage`), triggering a merged puzzle animation on `MatchResultScreen.dart`.

### 🔐 4. Admin Security & Data Persistence
- **Protected Reset**: `@PostMapping("/events/{code}/reset")` requires a valid Bearer token, returning **`HTTP 401 Unauthorized`** for unauthenticated requests.
- **Dynamic Environment Configuration**: Loads JWT secret dynamically from `JWT_SECRET`.
- **Persistent Data**: Game events, user stats, and match records persist automatically across server restarts.

---

## 🎨 Design System

- **Warm Linen Beige & Deep Espresso Brown**: Warm, minimal light theme.
- **Dark Obsidian Charcoal & Soft Sand**: High-contrast dark theme.
- **Locked Bottom Logout**: Clean `LOGOUT / SWITCH ACCOUNT` container pinned to the bottom of the profile screen.
- **Dynamic Profile Metrics**: Real database stats for **Best Speed**, **Matches Played**, and **Orientation Rank**.

---

## 🧩 Technology Stack

### Mobile Application (`TwinQuest-app`)
- **Framework**: Flutter 3.x / Dart 3.x
- **State Management**: Provider (`GameProvider`, `ThemeProvider`)
- **Storage**: Hive / SharedPreferences (`StorageService`)
- **Proximity**: `flutter_blue_plus` / `permission_handler`
- **Networking**: `http` / WebSockets

### Backend (`TwinQuest-backend`)
- **Framework**: Spring Boot 3.x (Java 21)
- **Web & Messaging**: Spring Web / Spring WebSocket (STOMP)
- **Security**: JWT Authentication (`AuthService`)
- **Persistence**: File & MongoDB Data Models (`GameService`)

---

## 📁 Project Structure

```text
TwinQuest/
│
├── TwinQuest-app/
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
│   │   ├── providers/
│   │   │   ├── game_provider.dart
│   │   │   └── theme_provider.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── pairing_screen.dart
│   │   │   ├── closer_screen.dart
│   │   │   ├── touch_match_screen.dart
│   │   │   ├── match_result_screen.dart
│   │   │   ├── leaderboard_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   └── settings_screen.dart
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   ├── ble_service.dart
│   │   │   └── storage_service.dart
│   │   │
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_header.dart
│   │       ├── half_card.dart
│   │       ├── image_combine_animation.dart
│   │       └── signal_rings.dart
│   │
│   └── pubspec.yaml
│
└── TwinQuest-backend/
    ├── src/main/java/com/pairquest/backend/
    │   ├── controller/
    │   │   ├── AuthController.java
    │   │   └── GameController.java
    │   ├── model/
    │   │   ├── PairMatch.java
    │   │   ├── Player.java
    │   │   └── User.java
    │   └── service/
    │       ├── AuthService.java
    │       ├── GameService.java
    │       └── ImageService.java
    │
    └── build.gradle
```

---

## 🚧 Implementation Status

- [x] **Google Sign-In & Guest Authentication**
- [x] **Spring Boot Automatic Matchmaking**
- [x] **Asymmetric 4-Digit PIN Cross-Verification**
- [x] **Server-Side Anti-Cheat Timing**
- [x] **Mystery Locked Cards 🔒 & Unique Picture Unveiling**
- [x] **BLE Proximity Monitoring & Permission Handshake**
- [x] **Live Leaderboard & Dynamic DB Profile Stats**
- [x] **Protected Admin Reset Endpoint (`HTTP 401`)**
- [x] **Light / Dark Mode Design System**

---

## 🚀 Running Locally

### 1. Spring Boot Backend
```bash
cd TwinQuest-backend
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
./gradlew bootRun
```
*Backend runs on port `8080`.*

### 2. Flutter Mobile Application
```bash
cd TwinQuest-app
flutter pub get
flutter run
```
*Run `flutter analyze` to verify zero lints.*

---

## 📄 License

Developed for COPS Orientation 2026.
