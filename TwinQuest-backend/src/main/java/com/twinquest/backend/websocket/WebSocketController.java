package com.twinquest.backend.websocket;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class WebSocketController {

    private final PairingSessionService pairingSessionService;
    private final WebSocketSessionListener sessionListener;

    @MessageMapping("/pairing/join")
    public void joinPairing(
            PairingSessionRequest request,
            @Header("simpSessionId") String sessionId
    ) {

        pairingSessionService.join(
                request.getPlayerId(),
                sessionId
        );

        sessionListener.registerSession(
                sessionId,
                request.getPlayerId()
        );
    }
    @MessageMapping("/pairing/leave")
    public void leavePairing(
            PairingSessionRequest request,
            @Header("simpSessionId") String sessionId
    ) {

        pairingSessionService.leave(
                request.getPlayerId(),
                sessionId
        );

        sessionListener.unregisterSession(sessionId);
    }
}