package com.pairquest.backend.controller;

import com.pairquest.backend.model.Event;
import com.pairquest.backend.model.LeaderboardEntry;
import com.pairquest.backend.model.PairMatch;
import com.pairquest.backend.model.Player;
import com.pairquest.backend.service.AuthService;
import com.pairquest.backend.service.GameService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class GameController {

    private final GameService gameService;
    private final AuthService authService;

    public GameController(GameService gameService, AuthService authService) {
        this.gameService = gameService;
        this.authService = authService;
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleException(Exception e) {
        Map<String, String> err = new HashMap<>();
        err.put("error", "An error occurred while processing request");
        err.put("status", "FAILURE");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(err);
    }

    @PostMapping("/events/create")
    public ResponseEntity<Event> createEvent(@RequestBody Map<String, String> request) {
        String title = request.getOrDefault("title", "Orientation 2026");
        return ResponseEntity.ok(gameService.createEvent(title));
    }

    @PostMapping("/events/join")
    public ResponseEntity<Player> joinEvent(@RequestBody Map<String, String> request) {
        String name = request.getOrDefault("name", "Volunteer");
        String eventCode = request.getOrDefault("eventCode", "ORIENT26");
        String avatar = request.getOrDefault("avatar", "⚡");
        return ResponseEntity.ok(gameService.joinEvent(name, eventCode, avatar));
    }

    @GetMapping("/events/{eventCode}/players")
    public ResponseEntity<List<Player>> getPlayers(@PathVariable String eventCode) {
        return ResponseEntity.ok(gameService.getPlayers(eventCode));
    }

    @PostMapping("/events/{eventCode}/start")
    public ResponseEntity<List<PairMatch>> startMatchmaking(@PathVariable String eventCode) {
        return ResponseEntity.ok(gameService.startMatchmaking(eventCode));
    }

    @GetMapping("/matches/player/{playerId}")
    public ResponseEntity<Map<String, Object>> getPlayerMatch(@PathVariable String playerId) {
        Map<String, Object> match = gameService.getPlayerMatch(playerId);
        if (match != null) {
            return ResponseEntity.ok(match);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/events/{eventCode}/reset")
    public ResponseEntity<?> resetEvent(
            @PathVariable String eventCode,
            @RequestHeader(value = "Authorization", required = false) String authHeader
    ) {
        String token = authHeader;
        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        if (token == null || !authService.validateToken(token, null)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Unauthorized: Valid admin token required to reset event", "status", "UNAUTHORIZED"));
        }

        gameService.resetEvent(eventCode);
        return ResponseEntity.ok(Map.of("status", "RESET_SUCCESSFUL"));
    }

    @PostMapping("/matches/complete")
    public ResponseEntity<?> completeMatch(@RequestBody Map<String, Object> request) {
        String pairId = (String) request.get("pairId");
        String playerId = (String) request.get("playerId");
        String pin = (String) request.get("pin");
        String userEmail = (String) request.getOrDefault("userEmail", "");
        long durationMs = ((Number) request.getOrDefault("durationMs", 0)).longValue();

        if (pairId == null || pairId.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "pairId is required", "status", "FAILURE"));
        }

        PairMatch match = gameService.completeMatch(pairId, playerId, pin, durationMs, userEmail);
        if (match == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Invalid or non-existent pairId / PIN code", "status", "FAILURE"));
        }

        return ResponseEntity.ok(match);
    }

    @GetMapping("/leaderboard/{eventCode}")
    public ResponseEntity<List<LeaderboardEntry>> getLeaderboard(@PathVariable String eventCode) {
        return ResponseEntity.ok(gameService.getLeaderboard(eventCode));
    }
}
