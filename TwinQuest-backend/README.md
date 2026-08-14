# TwinQuest Backend — REST API

Backend REST API for the TwinQuest application.

The backend is built with Spring Boot and MongoDB. It manages events, players, matchmaking, pairs, and the pair lifecycle.

---

## Base URL

For the deployed production backend on Railway:

```text
https://twinquest-cops-orientation26-production-4aed.up.railway.app
```
### Production API Example

```http
GET https://twinquest-cops-orientation26-production-4aed.up.railway.app/api/events/code/{eventCode}
```

The Flutter application should use the Railway URL when connecting to the deployed backend.

---

# API Overview

| Feature            | Method | Endpoint                       |
| ------------------ | ------ | ------------------------------ |
| Create event       | POST   | `/api/events`                  |
| Get event by ID    | GET    | `/api/events/{eventId}`        |
| Get event by code  | GET    | `/api/events/code/{eventCode}` |
| Join event         | POST   | `/api/players/join`            |
| Get player         | GET    | `/api/players/{playerId}`      |
| Create match       | POST   | `/api/matches/{eventId}`       |
| Get pair           | GET    | `/api/pairs/{pairId}`          |
| Get pair by player | GET    | `/api/pairs/player/{playerId}` |
| Get pairs by event | GET    | `/api/pairs/event/{eventId}`   |
| Get leaderboard     | GET    | `/api/leaderboard/{eventId}`     |
| Update pair status | PATCH  | `/api/pairs/{pairId}/status`   |
| Confirm pair       | POST   | `/api/pairs/{pairId}/confirm`  |
| Complete pair      | POST   | `/api/pairs/{pairId}/complete` |

---

# 1. Event APIs

## Create Event

Creates a new TwinQuest event.

### Request

```http
POST /api/events
Content-Type: application/json
```

### Body

```json
{
  "eventCode": "COPS30",
  "name": "COPS Orientation"
}
```

### Successful Response

```text
201 Created
```

```json
{
  "id": "EVENT_ID",
  "eventCode": "COPS30",
  "name": "COPS Orientation",
  "status": "ACTIVE",
  "createdAt": "2026-08-12T10:00:00Z"
}
```

### Validation

`eventCode` and `name` must not be blank.

Example invalid request:

```json
{
  "eventCode": "",
  "name": ""
}
```

Response:

```text
400 Bad Request
```

---

## Get Event by ID

Returns an event using its MongoDB ID.

### Request

```http
GET /api/events/{eventId}
```

Example:

```http
GET /api/events/6a7b31fa8c8020bb16b90745
```

### Response

```text
200 OK
```

```json
{
  "id": "6a7b31fa8c8020bb16b90745",
  "eventCode": "COPS30",
  "name": "COPS Orientation",
  "status": "ACTIVE",
  "createdAt": "2026-08-12T10:00:00Z"
}
```

---

## Get Event by Event Code

Returns an event using its event code.

### Request

```http
GET /api/events/code/{eventCode}
```

Example:

```http
GET /api/events/code/COPS30
```

### Response

```text
200 OK
```

```json
{
  "id": "EVENT_ID",
  "eventCode": "COPS30",
  "name": "COPS Orientation",
  "status": "ACTIVE",
  "createdAt": "2026-08-12T10:00:00Z"
}
```

---

# 2. Player APIs

## Join Event

Creates a player and adds them to an event.

New players initially have the status:

```text
WAITING
```

### Request

```http
POST /api/players/join
Content-Type: application/json
```

### Body

```json
{
  "name": "Amol",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "deviceId": "phone001"
}
```

### Successful Response

```text
201 Created
```

```json
{
  "id": "PLAYER_ID",
  "name": "Amol",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "status": "WAITING",
  "joinedAt": "2026-08-12T10:05:00Z"
}
```

`deviceId` is used internally and is not exposed through the player response DTO.

### Validation

The following fields are required:

```text
name
eventId
deviceId
```

A blank field results in:

```text
400 Bad Request
```

---

## Get Player

Returns a player using their ID.

### Request

```http
GET /api/players/{playerId}
```

Example:

```http
GET /api/players/6a7b34698c8020bb16b90748
```

### Response

```text
200 OK
```

```json
{
  "id": "6a7b34698c8020bb16b90748",
  "name": "Amol",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "status": "WAITING",
  "joinedAt": "2026-08-12T10:05:00Z"
}
```

---

# 3. Matchmaking API

## Create Match

Attempts to find two waiting players in an event and creates a pair.

### Request

```http
POST /api/matches/{eventId}
```

Example:

```http
POST /api/matches/6a7b31fa8c8020bb16b90745
```

No request body is required.

### When Two Players Are Available

Response:

```text
201 Created
```

```json
{
  "id": "PAIR_ID",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "playerAId": "PLAYER_A_ID",
  "playerBId": "PLAYER_B_ID",
  "status": "SEARCHING",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": null,
  "completionTimeMs": null
}
```

Both matched players are moved from:

```text
WAITING
```

to:

```text
PAIRED
```

### When There Are Not Enough Players

Response:

```text
204 No Content
```

This means there are currently not enough waiting players to create a pair.

The frontend can continue waiting and try matchmaking again according to the application's pairing strategy.

---

# 4. Pair APIs

## Get Pair by ID

Returns a pair using its ID.

### Request

```http
GET /api/pairs/{pairId}
```

Example:

```http
GET /api/pairs/6a7b35418c8020bb16b9074a
```

### Response

```text
200 OK
```

```json
{
  "id": "6a7b35418c8020bb16b9074a",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "playerAId": "6a7b34698c8020bb16b90748",
  "playerBId": "6a7b35288c8020bb16b90749",
  "status": "SEARCHING",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": null,
  "completionTimeMs": null
}
```

---

## Get Pair by Player

Returns the pair associated with a player.

### Request

```http
GET /api/pairs/player/{playerId}
```

Example:

```http
GET /api/pairs/player/6a7b34698c8020bb16b90748
```

### Response

```text
200 OK
```

```json
{
  "id": "PAIR_ID",
  "eventId": "EVENT_ID",
  "playerAId": "PLAYER_A_ID",
  "playerBId": "PLAYER_B_ID",
  "status": "SEARCHING",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": null,
  "completionTimeMs": null
}
```

---

## Get Pairs by Event

Returns all pairs associated with an event.

### Request

```http
GET /api/pairs/event/{eventId}
```

Example:

```http
GET /api/pairs/event/6a7b31fa8c8020bb16b90745
```

### Response

```text
200 OK
```

```json
[
  {
    "id": "PAIR_ID",
    "eventId": "6a7b31fa8c8020bb16b90745",
    "playerAId": "PLAYER_A_ID",
    "playerBId": "PLAYER_B_ID",
    "status": "SEARCHING",
    "createdAt": "2026-08-12T10:10:00Z",
    "matchedAt": null,
    "completionTimeMs": null
  }
]
```

---

# 5. Pair State Machine

The pair follows a controlled lifecycle:

```text
SEARCHING
    ↓
FOUND
    ↓
CONFIRMED
    ↓
COMPLETED
```

The backend validates state transitions.

Valid transitions:

```text
SEARCHING → FOUND
FOUND → CONFIRMED
CONFIRMED → COMPLETED
```

Invalid transitions are rejected.

Examples:

```text
SEARCHING → COMPLETED    ❌
FOUND → COMPLETED        ❌
COMPLETED → SEARCHING    ❌
COMPLETED → FOUND        ❌
```

Invalid transitions return:

```text
400 Bad Request
```

---

# 6. Update Pair Status

Used to move a pair from `SEARCHING` to `FOUND`.

### Request

```http
PATCH /api/pairs/{pairId}/status
Content-Type: application/json
```

Example:

```http
PATCH /api/pairs/6a7b35418c8020bb16b9074a/status
```

### Body

```json
{
  "status": "FOUND"
}
```

### Response

```text
200 OK
```

```json
{
  "id": "6a7b35418c8020bb16b9074a",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "playerAId": "6a7b34698c8020bb16b90748",
  "playerBId": "6a7b35288c8020bb16b90749",
  "status": "FOUND",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": "2026-08-12T10:12:00Z",
  "completionTimeMs": null
}
```

When the pair becomes `FOUND`, `matchedAt` is recorded.

---

# 7. Confirm Pair

Moves the pair from:

```text
FOUND → CONFIRMED
```

### Request

```http
POST /api/pairs/{pairId}/confirm
```

Example:

```http
POST /api/pairs/6a7b35418c8020bb16b9074a/confirm
```

No request body is required.

### Response

```text
200 OK
```

```json
{
  "id": "6a7b35418c8020bb16b9074a",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "playerAId": "6a7b34698c8020bb16b90748",
  "playerBId": "6a7b35288c8020bb16b90749",
  "status": "CONFIRMED",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": "2026-08-12T10:12:00Z",
  "completionTimeMs": null
}
```

---

# 8. Complete Pair

Moves the pair from:

```text
CONFIRMED → COMPLETED
```

and stores the completion time.

### Request

```http
POST /api/pairs/{pairId}/complete
Content-Type: application/json
```

Example:

```http
POST /api/pairs/6a7b35418c8020bb16b9074a/complete
```

### Body

```json
{
  "completionTimeMs": 12450
}
```

`12450` means:

```text
12.45 seconds
```

### Response

```text
200 OK
```

```json
{
  "id": "6a7b35418c8020bb16b9074a",
  "eventId": "6a7b31fa8c8020bb16b90745",
  "playerAId": "6a7b34698c8020bb16b90748",
  "playerBId": "6a7b35288c8020bb16b90749",
  "status": "COMPLETED",
  "createdAt": "2026-08-12T10:10:00Z",
  "matchedAt": "2026-08-12T10:12:00Z",
  "completionTimeMs": 12450
}
```

---

# 9. Leaderboard API

## Get Leaderboard

Returns the completed pairs for an event, sorted by completion time in ascending order. The fastest completed pair appears first.

### Request

```http
GET /api/leaderboard/{eventId}
```

### Production Example

```http
GET https://twinquest-cops-orientation26-production-4aed.up.railway.app/api/leaderboard/{eventId}
```

### Response

```text
200 OK
```

```json
[
  {
    "rank": 1,
    "playerA": "Amol",
    "playerB": "Rahul",
    "completionTimeMs": 12450
  },
  {
    "rank": 2,
    "playerA": "Aman",
    "playerB": "Priya",
    "completionTimeMs": 13800
  }
]
```

### Response Fields

```text
rank              → leaderboard position
playerA           → name of Player A
playerB           → name of Player B
completionTimeMs  → time taken by the pair in milliseconds
```

Only pairs with status `COMPLETED` and a non-null `completionTimeMs` are included.

If no completed pairs exist for the event, the endpoint returns:

```json
[]
```

The Flutter leaderboard screen can call this endpoint using the event ID and display the returned entries directly.

---

# 10. Error Responses

The backend provides a consistent error structure.

## Resource Not Found

For example:

```http
GET /api/events/invalid-id
```

Response:

```text
404 Not Found
```

```json
{
  "status": 404,
  "message": "Event not found: invalid-id",
  "timestamp": "2026-08-12T10:20:00Z"
}
```

The same structure applies to missing players and pairs.

---

## Validation Error

Example:

```http
POST /api/players/join
```

with:

```json
{
  "name": "",
  "eventId": "",
  "deviceId": ""
}
```

Response:

```text
400 Bad Request
```

Example:

```json
{
  "status": 400,
  "message": "name: Player name is required",
  "timestamp": "2026-08-12T10:20:00Z"
}
```

---

## Invalid Pair State Transition

Example:

```text
FOUND → COMPLETED
```

Response:

```text
400 Bad Request
```

Example:

```json
{
  "status": 400,
  "message": "Invalid pair status transition: FOUND -> COMPLETED",
  "timestamp": "2026-08-12T10:20:00Z"
}
```

---

# 11. Complete Frontend Flow

The basic REST flow is:

```text
┌──────────────────────┐
│      Join Event      │
└──────────┬───────────┘
           │
           ▼
POST /api/players/join
           │
           ▼
       WAITING
           │
           ▼
POST /api/matches/{eventId}
           │
      ┌────┴────┐
      │         │
      ▼         ▼
    204       201
  Waiting   Pair created
                │
                ▼
             SEARCHING
                │
                ▼
PATCH /api/pairs/{pairId}/status
        { "status": "FOUND" }
                │
                ▼
              FOUND
                │
                ▼
POST /api/pairs/{pairId}/confirm
                │
                ▼
            CONFIRMED
                │
                ▼
POST /api/pairs/{pairId}/complete
        { "completionTimeMs": ... }
                │
                ▼
            COMPLETED
```

---

# 12. Frontend Integration Notes

The frontend should store the following IDs when they are returned by the backend:

```text
eventId
playerId
pairId
```

For example, after joining:

```text
playerId → save locally
eventId   → save locally
```

After successful matchmaking:

```text
pairId → save locally
```

The frontend should use the `pairId` for subsequent pair operations.

---

# 13. Local Android Development

When the backend is running on the developer's laptop, the correct base URL depends on where the Flutter application is running.

### Android Emulator

Do not use:

```text
http://localhost:8080
```

Use:

```text
http://10.0.2.2:8080
```

because `10.0.2.2` maps to the host machine from the Android emulator.

### Physical Android Device

The phone and laptop should be on the same network.

Find the laptop's local IP address and use:

```text
http://<LAPTOP_IP>:8080
```

Example:

```text
http://192.168.1.10:8080
```

The backend server and firewall must allow connections from the device.

---

# 14. Current Backend Responsibilities

The backend currently handles:

* Event creation and retrieval
* Player registration
* Player persistence
* Player status
* Matchmaking
* Pair creation
* Pair retrieval
* Pair status transitions
* Match confirmation
* Match completion
* Completion time storage
* DTO-based API responses
* Request validation
* REST exception handling
* MongoDB persistence

---

# 15. Current Pair Lifecycle

```text
Player joins
     │
     ▼
WAITING
     │
     │ matchmaking
     ▼
PAIRED
     │
     ▼
Pair created
     │
     ▼
SEARCHING
     │
     ▼
FOUND
     │
     ▼
CONFIRMED
     │
     ▼
COMPLETED
```

---

# 16. Example Complete Session

Assume the event is:

```text
eventId = 6a7b31fa8c8020bb16b90745
```

Player A:

```text
playerId = PLAYER_A_ID
```

Player B:

```text
playerId = PLAYER_B_ID
```

### Step 1 — Players join

```http
POST /api/players/join
```

Both players initially become:

```text
WAITING
```

### Step 2 — Matchmaking

```http
POST /api/matches/6a7b31fa8c8020bb16b90745
```

Pair is created:

```text
PAIR_ID
```

Pair status:

```text
SEARCHING
```

### Step 3 — Pair found

```http
PATCH /api/pairs/{pairId}/status
```

```json
{
  "status": "FOUND"
}
```

### Step 4 — Confirm

```http
POST /api/pairs/{pairId}/confirm
```

Pair becomes:

```text
CONFIRMED
```

### Step 5 — Complete

```http
POST /api/pairs/{pairId}/complete
```

```json
{
  "completionTimeMs": 12450
}
```

Final state:

```text
COMPLETED
```

---

# 17. Backend Scope

This REST API is responsible for the backend data and matchmaking flow.

Real-time communication, Bluetooth communication, Flutter UI, and client-side interaction are separate application layers and are not part of this REST API contract.

---

# 18. Testing

The REST endpoints have been manually tested using Postman.

The complete TwinQuest flow has also been covered by an automated Spring Boot integration test:

```text
Create Event
      ↓
Join Player A
      ↓
Join Player B
      ↓
Create Match
      ↓
Get Pair
      ↓
Get Pair by Player
      ↓
Get Pairs by Event
      ↓
SEARCHING → FOUND
      ↓
FOUND → CONFIRMED
      ↓
CONFIRMED → COMPLETED
      ↓
Get Leaderboard
```

The automated integration test can be run with Gradle:

```powershell
.\gradlew test --tests com.twinquest.backend.TwinQuestApiIntegrationTest
```

The test starts the backend locally on a random port and executes the complete API flow automatically. It does not use the Railway URL.

For testing the deployed production backend manually, use:

```text
https://twinquest-cops-orientation26-production-4aed.up.railway.app
```

All core REST operations in this flow have been verified during backend development.

---

# 19. Status Values

## Player Status

The player status values used by the backend are:

```text
WAITING
PAIRED
SEARCHING
MATCHED
COMPLETED
```

## Pair Status

The pair lifecycle uses:

```text
CREATED
SEARCHING
FOUND
CONFIRMED
COMPLETED
```

The valid pair progression is:

```text
SEARCHING
    ↓
FOUND
    ↓
CONFIRMED
    ↓
COMPLETED
```

---

# 20. Recommended Frontend API Layer

The Flutter application should keep API communication separate from UI code.

A typical structure can be:

```text
Flutter
│
├── API / Network Layer
│   ├── Event API
│   ├── Player API
│   └── Pair API
│
├── Models
│   ├── Event
│   ├── Player
│   └── Pair
│
├── Repository
│
├── State Management
│
└── Screens
```

The frontend should treat the backend responses documented above as the API contract.

---

# 21. Summary

TwinQuest's REST backend provides the complete server-side flow required to create events, register players, find pairs, track pair state, and record match completion.

The core lifecycle is:

```text
EVENT
  ↓
PLAYER JOIN
  ↓
WAITING
  ↓
MATCHMAKING
  ↓
PAIR
  ↓
SEARCHING
  ↓
FOUND
  ↓
CONFIRMED
  ↓
COMPLETED
```

The frontend can integrate with these endpoints independently of the internal Spring Boot service and repository implementation.

# 22. WebSocket Integration — Flutter Pairing

TwinQuest uses WebSocket with STOMP for real-time communication during the pairing flow.

The WebSocket connection is intended for the pairing screen so the Flutter application does not need to repeatedly poll the backend for pair-status changes.

## WebSocket Endpoint

### Production

```text
wss://twinquest-cops-orientation26-production-4aed.up.railway.app/ws
```

### Local Development

Android Emulator:

```text
ws://10.0.2.2:8080/ws
```

Physical Android Device:

```text
ws://<LAPTOP_IP>:8080/ws
```

Use `wss://` for the deployed Railway backend.

## STOMP Destinations

### Client → Server

Join pairing:

```text
/app/pairing/join
```

Leave pairing:

```text
/app/pairing/leave
```

### Server → Client

Subscribe to the player's private destination:

```text
/topic/player/{playerId}
```

Example:

```text
/topic/player/PLAYER_ID
```

## 1. Connect to WebSocket

When the user enters the pairing screen:

```text
Flutter Pairing Screen
        ↓
Connect WebSocket
        ↓
STOMP connection established
        ↓
Subscribe to /topic/player/{playerId}
        ↓
Send /app/pairing/join
```

The WebSocket connection should remain active while the player is on the pairing screen.

## 2. Join Pairing Session

Send:

```text
/app/pairing/join
```

Body:

```json
{
  "playerId": "PLAYER_ID"
}
```

Example:

```json
{
  "playerId": "6a7b34698c8020bb16b90748"
}
```

The backend associates the WebSocket session with the player.

## 3. Subscribe to Player Events

Subscribe to:

```text
/topic/player/{playerId}
```

The backend sends pairing lifecycle events to this destination.

## 4. WebSocket Event Format

```json
{
  "type": "PAIR_FOUND",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "FOUND",
  "completionTimeMs": null
}
```

Fields:

```text
type
→ WebSocket event type

eventId
→ TwinQuest event ID

pairId
→ Current pair ID

playerId
→ Player receiving the event

opponentId
→ The other player in the pair

status
→ Current pair status

completionTimeMs
→ Match completion time when available
```

## 5. Pairing Lifecycle Events

The backend sends:

```text
PAIR_CREATED
      ↓
PAIR_SEARCHING
      ↓
PAIR_FOUND
      ↓
PAIR_CONFIRMED
      ↓
PAIR_COMPLETED
```

### PAIR_CREATED

```json
{
  "type": "PAIR_CREATED",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "CREATED",
  "completionTimeMs": null
}
```

### PAIR_SEARCHING

```json
{
  "type": "PAIR_SEARCHING",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "SEARCHING",
  "completionTimeMs": null
}
```

### PAIR_FOUND

```json
{
  "type": "PAIR_FOUND",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "FOUND",
  "completionTimeMs": null
}
```

### PAIR_CONFIRMED

```json
{
  "type": "PAIR_CONFIRMED",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "CONFIRMED",
  "completionTimeMs": null
}
```

### PAIR_COMPLETED

```json
{
  "type": "PAIR_COMPLETED",
  "eventId": "EVENT_ID",
  "pairId": "PAIR_ID",
  "playerId": "PLAYER_A_ID",
  "opponentId": "PLAYER_B_ID",
  "status": "COMPLETED",
  "completionTimeMs": 12500
}
```

## 6. Flutter Pairing Screen Flow

```text
User enters Pairing Screen
          ↓
Create WebSocket connection
          ↓
STOMP CONNECT
          ↓
Subscribe to /topic/player/{playerId}
          ↓
SEND /app/pairing/join
          ↓
Wait for WebSocket events
          ↓
PAIR_CREATED
          ↓
PAIR_SEARCHING
          ↓
PAIR_FOUND
          ↓
PAIR_CONFIRMED
          ↓
PAIR_COMPLETED
          ↓
Update Flutter UI
```

## 7. Pairing Screen State Mapping

```text
PAIR_CREATED
    ↓
Initializing pairing

PAIR_SEARCHING
    ↓
Searching / waiting for match

PAIR_FOUND
    ↓
Opponent found

PAIR_CONFIRMED
    ↓
Match confirmed

PAIR_COMPLETED
    ↓
Show completion/result screen
```

## 8. Leaving the Pairing Screen

When the user intentionally leaves the pairing screen, send:

```text
/app/pairing/leave
```

Body:

```json
{
  "playerId": "PLAYER_ID"
}
```

Then close the STOMP/WebSocket connection.

## 9. Unexpected Disconnect

The backend handles unexpected WebSocket disconnections automatically:

```text
WebSocket connection lost
        ↓
SessionDisconnectEvent
        ↓
WebSocketSessionListener
        ↓
PairingSessionService.leave()
        ↓
Player session removed
```

The frontend does not need a special request when the connection unexpectedly disappears.

## 10. IDs Required by Frontend

Store:

```text
eventId
playerId
pairId
```

The `playerId` is required for the WebSocket subscription:

```text
/topic/player/{playerId}
```

The `pairId` is obtained from the pairing WebSocket event.

## 11. REST + WebSocket Responsibilities

Use REST for operations such as:

```text
Join event
Create matchmaking request
Get player
Get pair
Get leaderboard
Confirm pair
Complete pair
```

Use WebSocket for real-time pairing updates:

```text
PAIR_CREATED
PAIR_SEARCHING
PAIR_FOUND
PAIR_CONFIRMED
PAIR_COMPLETED
```

The pairing screen should listen to WebSocket events for real-time state changes instead of continuously polling the pair endpoint.

## 12. Frontend Architecture

```text
                    Flutter
                       │
             ┌─────────┴─────────┐
             │                   │
        REST API             WebSocket
             │                   │
             ▼                   ▼
      Spring Boot API      STOMP /ws
             │                   │
             │                   ▼
             │          /topic/player/{id}
             │                   │
             └─────────┬─────────┘
                       ▼
                  Pairing Screen
                       │
                       ▼
                Update UI State
```

The backend WebSocket implementation has been integration-tested with two simultaneous clients. Both players successfully receive the complete pair lifecycle:

```text
PAIR_CREATED
PAIR_SEARCHING
PAIR_FOUND
PAIR_CONFIRMED
PAIR_COMPLETED
```
