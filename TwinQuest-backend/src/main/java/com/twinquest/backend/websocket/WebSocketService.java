package com.twinquest.backend.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WebSocketService {

    private final SimpMessagingTemplate messagingTemplate;

    public void sendToPlayer(
            String playerId,
            WebSocketEvent event
    ) {

        messagingTemplate.convertAndSend(
                "/topic/player/" + playerId,
                event
        );
    }

    public void sendToPair(
            String pairId,
            WebSocketEvent event
    ) {

        messagingTemplate.convertAndSend(
                "/topic/pair/" + pairId,
                event
        );
    }

    public void sendToEvent(
            String eventId,
            WebSocketEvent event
    ) {

        messagingTemplate.convertAndSend(
                "/topic/event/" + eventId,
                event
        );
    }
}