package com.twinquest.backend.websocket;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

@Slf4j
@Component
@RequiredArgsConstructor
public class WebSocketDisconnectListener {

    private final PairingSessionService pairingSessionService;

    @EventListener
    public void handleWebSocketDisconnect(
            SessionDisconnectEvent event
    ) {
        String sessionId = event.getSessionId();

        log.info(
                "WebSocket disconnected: sessionId={}",
                sessionId
        );

        pairingSessionService.leaveBySessionId(sessionId);
    }
}