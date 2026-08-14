package com.twinquest.backend.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@RequiredArgsConstructor
public class WebSocketSessionListener {

    private final PairingSessionService pairingSessionService;

    private final Map<String, String> sessionPlayers =
            new ConcurrentHashMap<>();

    public void registerSession(
            String sessionId,
            String playerId
    ) {

        sessionPlayers.put(
                sessionId,
                playerId
        );
    }

    @EventListener
    public void handleDisconnect(
            SessionDisconnectEvent event
    ) {

        StompHeaderAccessor accessor =
                StompHeaderAccessor.wrap(
                        event.getMessage()
                );

        String sessionId =
                accessor.getSessionId();

        if (sessionId == null) {
            return;
        }

        String playerId =
                sessionPlayers.remove(sessionId);

        if (playerId != null) {

            pairingSessionService.leave(
                    playerId,
                    sessionId
            );
        }
    }
    public void unregisterSession(String sessionId) {
        sessionPlayers.remove(sessionId);
    }
}