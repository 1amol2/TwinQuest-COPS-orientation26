package com.twinquest.backend.websocket;

import com.twinquest.backend.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class PairingSessionService {

    private final PlayerService playerService;

    private final ConcurrentHashMap<String, Set<String>> playerSessions =
            new ConcurrentHashMap<>();

    // Maps WebSocket session ID -> player ID
    private final ConcurrentHashMap<String, String> sessionPlayers =
            new ConcurrentHashMap<>();
    public void join(
            String playerId,
            String sessionId
    ) {
        playerSessions
                .computeIfAbsent(
                        playerId,
                        k -> ConcurrentHashMap.newKeySet()
                )
                .add(sessionId);

        sessionPlayers.put(sessionId, playerId);
    }

    public void leave(
            String playerId,
            String sessionId
    ) {
        Set<String> sessions = playerSessions.get(playerId);

        if (sessions == null) {
            sessionPlayers.remove(sessionId);
            return;
        }

        sessions.remove(sessionId);
        sessionPlayers.remove(sessionId);

        if (sessions.isEmpty()) {
            playerSessions.remove(playerId);

            // Player is no longer connected to the application.
            playerService.deletePlayer(playerId);
        }
    }
    public void leaveBySessionId(String sessionId) {
        String playerId = sessionPlayers.get(sessionId);

        if (playerId == null) {
            return;
        }

        leave(playerId, sessionId);
    }
    public boolean isActive(String playerId) {
        Set<String> sessions =
                playerSessions.get(playerId);

        return sessions != null
                && !sessions.isEmpty();
    }

    public int activePlayers() {
        return playerSessions.size();
    }
}