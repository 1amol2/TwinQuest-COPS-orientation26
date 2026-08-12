# TwinQuest Backend — REST API

Backend REST API for the TwinQuest application.

The backend is built with Spring Boot and MongoDB. It manages events, players, matchmaking, pairs, and the pair lifecycle.

---

## Base URL

For local development:

```text
http://localhost:8080
```

For a physical Android device connected to the same Wi-Fi network as the backend laptop:

```text
http://<YOUR-LAPTOP-IP>:8080
```

Example:

```text
http://192.168.1.10:8080
```

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

# 9. Error Responses

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

# 10. Complete Frontend Flow

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

# 11. Frontend Integration Notes

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

# 12. Local Android Development

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

# 13. Current Backend Responsibilities

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

# 14. Current Pair Lifecycle

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

# 15. Example Complete Session

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

# 16. Backend Scope

This REST API is responsible for the backend data and matchmaking flow.

Real-time communication, Bluetooth communication, Flutter UI, and client-side interaction are separate application layers and are not part of this REST API contract.

---

# 17. Testing

The REST endpoints have been manually tested using Postman.

The complete tested flow is:

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
```

All core REST operations in this flow have been verified during backend development.

---

# 18. Status Values

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

# 19. Recommended Frontend API Layer

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

# 20. Summary

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
