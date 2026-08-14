package com.twinquest.backend.websocket;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class WebSocketEvent {

    private String type;

    private String eventId;

    private String pairId;

    private String playerId;

    private String opponentId;

    private String status;

    private Long completionTimeMs;
}