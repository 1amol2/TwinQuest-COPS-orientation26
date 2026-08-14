package com.twinquest.backend;

import com.twinquest.backend.model.Player;
import com.twinquest.backend.service.PlayerService;
import com.twinquest.backend.websocket.PairingSessionService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.util.UUID;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class TwinQuestWebSocketSessionIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private PairingSessionService pairingSessionService;

    @Test
    void websocketSessionLifecycle() throws Exception {

        String eventId =
                "SESSION-TEST-" + UUID.randomUUID();

        String playerId =
                "SESSION-PLAYER-" + UUID.randomUUID();

        System.out.println();
        System.out.println("==========================================");
        System.out.println("     WEBSOCKET SESSION LIFECYCLE TEST");
        System.out.println("==========================================");

        /*
         * ---------------------------------------------------------
         * 1. CREATE PLAYER
         * ---------------------------------------------------------
         */

        Player player =
                playerService.createPlayer(
                        "Session Test Player",
                        eventId,
                        playerId
                );

        System.out.println(
                "PLAYER: " + player.getId()
        );

        /*
         * Player should initially have no active
         * WebSocket session.
         */

        assertFalse(
                pairingSessionService.isActive(
                        player.getId()
                )
        );

        System.out.println(
                "INITIAL ACTIVE: false"
        );

        /*
         * ---------------------------------------------------------
         * 2. CONNECT WEBSOCKET
         * ---------------------------------------------------------
         */

        WebSocketStompClient stompClient =
                new WebSocketStompClient(
                        new StandardWebSocketClient()
                );

        stompClient.setMessageConverter(
                new MappingJackson2MessageConverter()
        );

        String websocketUrl =
                "ws://localhost:" + port + "/ws";

        System.out.println(
                "CONNECTING TO: " + websocketUrl
        );

        StompSession session =
                stompClient
                        .connectAsync(
                                websocketUrl,
                                new StompSessionHandlerAdapter() {

                                    @Override
                                    public void afterConnected(
                                            StompSession session,
                                            StompHeaders headers
                                    ) {

                                        System.out.println(
                                                "STOMP CONNECTED"
                                        );
                                    }
                                }
                        )
                        .get(
                                10,
                                TimeUnit.SECONDS
                        );

        assertTrue(session.isConnected());

        /*
         * ---------------------------------------------------------
         * 3. JOIN PAIRING SESSION
         * ---------------------------------------------------------
         */

        System.out.println(
                "SENDING PAIRING JOIN"
        );

        session.send(
                "/app/pairing/join",
                new com.twinquest.backend.websocket.PairingSessionRequest(
                        player.getId()
                )
        );

        /*
         * Give the STOMP message time to reach
         * the Spring WebSocket controller.
         */

        Thread.sleep(500);

        /*
         * Player should now be active.
         */

        assertTrue(
                pairingSessionService.isActive(
                        player.getId()
                )
        );

        System.out.println(
                "AFTER JOIN ACTIVE: true"
        );

        /*
         * ---------------------------------------------------------
         * 4. LEAVE PAIRING SESSION
         * ---------------------------------------------------------
         */

        System.out.println(
                "SENDING PAIRING LEAVE"
        );

        session.send(
                "/app/pairing/leave",
                new com.twinquest.backend.websocket.PairingSessionRequest(
                        player.getId()
                )
        );

        Thread.sleep(500);

        /*
         * Player should no longer be active.
         */

        assertFalse(
                pairingSessionService.isActive(
                        player.getId()
                )
        );

        System.out.println(
                "AFTER LEAVE ACTIVE: false"
        );

        /*
         * ---------------------------------------------------------
         * 5. REJOIN
         * ---------------------------------------------------------
         */

        System.out.println(
                "SENDING PAIRING JOIN AGAIN"
        );

        session.send(
                "/app/pairing/join",
                new com.twinquest.backend.websocket.PairingSessionRequest(
                        player.getId()
                )
        );

        Thread.sleep(500);

        assertTrue(
                pairingSessionService.isActive(
                        player.getId()
                )
        );

        System.out.println(
                "AFTER REJOIN ACTIVE: true"
        );

        /*
         * ---------------------------------------------------------
         * 6. DISCONNECT
         * ---------------------------------------------------------
         *
         * This time we DON'T explicitly send /leave.
         *
         * WebSocketSessionListener should detect the
         * SessionDisconnectEvent and automatically remove
         * the player session.
         */

        System.out.println(
                "DISCONNECTING WEBSOCKET"
        );

        session.disconnect();

        /*
         * Wait for SessionDisconnectEvent.
         */

        waitUntilInactive(
                player.getId()
        );

        /*
         * Player must now be inactive.
         */

        assertFalse(
                pairingSessionService.isActive(
                        player.getId()
                )
        );

        System.out.println(
                "AFTER DISCONNECT ACTIVE: false"
        );

        /*
         * ---------------------------------------------------------
         * 7. FINAL RESULT
         * ---------------------------------------------------------
         */

        System.out.println();
        System.out.println(
                "=========================================="
        );
        System.out.println(
                "     SESSION LIFECYCLE TEST PASSED"
        );
        System.out.println(
                "=========================================="
        );

        stompClient.stop();
    }

    private void waitUntilInactive(
            String playerId
    ) throws Exception {

        long timeout =
                System.currentTimeMillis()
                        + 5000;

        while (
                System.currentTimeMillis()
                        < timeout
        ) {

            if (!pairingSessionService.isActive(
                    playerId
            )) {

                return;
            }

            Thread.sleep(100);
        }

        fail(
                "Player session did not become inactive"
        );
    }
}