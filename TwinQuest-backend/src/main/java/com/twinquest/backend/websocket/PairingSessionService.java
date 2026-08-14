package com.twinquest.backend.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class PairingSessionService {

    private final ConcurrentHashMap<String, Set<String>>
            playerSessions =
            new ConcurrentHashMap<>();

    public void join(
            String playerId,
            String sessionId
    ) {

        playerSessions
                .computeIfAbsent(
                        playerId,
                        key -> ConcurrentHashMap.newKeySet()
                )
                .add(sessionId);
    }

    public void leave(
            String playerId,
            String sessionId
    ) {

        Set<String> sessions =
                playerSessions.get(playerId);

        if (sessions == null) {
            return;
        }

        sessions.remove(sessionId);

        if (sessions.isEmpty()) {
            playerSessions.remove(playerId);
        }
    }

    public boolean isActive(
            String playerId
    ) {

        Set<String> sessions =
                playerSessions.get(playerId);

        return sessions != null
                && !sessions.isEmpty();
    }

    public int activePlayers() {

        return playerSessions.size();
    }
}