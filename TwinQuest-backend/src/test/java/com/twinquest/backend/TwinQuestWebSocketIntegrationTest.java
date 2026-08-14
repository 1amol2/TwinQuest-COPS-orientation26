package com.twinquest.backend;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.service.EventService;
import com.twinquest.backend.service.MatchService;
import com.twinquest.backend.service.PlayerService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.simp.stomp.StompFrameHandler;
import org.springframework.messaging.simp.stomp.StompHeaders;
import org.springframework.messaging.simp.stomp.StompSession;
import org.springframework.messaging.simp.stomp.StompSessionHandlerAdapter;
import org.springframework.web.socket.client.standard.StandardWebSocketClient;
import org.springframework.web.socket.messaging.WebSocketStompClient;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class TwinQuestWebSocketIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private MatchService matchService;

    @Test
    void websocketReceivesPairLifecycleEvents() throws Exception {

        String eventId =
                "WS-TEST-" + UUID.randomUUID();

        String playerAId =
                "WS-PLAYER-A-" + UUID.randomUUID();

        String playerBId =
                "WS-PLAYER-B-" + UUID.randomUUID();

        System.out.println();
        System.out.println("==========================================");
        System.out.println("      WEBSOCKET INTEGRATION TEST");
        System.out.println("==========================================");

        /*
         * ---------------------------------------------------------
         * 1. CREATE PLAYERS
         * ---------------------------------------------------------
         */

        Player playerA = playerService.createPlayer(
                "WebSocket Player A",
                eventId,
                playerAId
        );

        Player playerB = playerService.createPlayer(
                "WebSocket Player B",
                eventId,
                playerBId
        );

        System.out.println(
                "PLAYER A: " + playerA.getId()
        );

        System.out.println(
                "PLAYER B: " + playerB.getId()
        );

        /*
         * ---------------------------------------------------------
         * 2. CONNECT TO WEBSOCKET
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
                "Connecting to: " + websocketUrl
        );

        TestStompHandler sessionHandler =
                new TestStompHandler();

        CompletableFuture<StompSession> future =
                stompClient.connectAsync(
                        websocketUrl,
                        sessionHandler
                );

        StompSession session =
                future.get(10, TimeUnit.SECONDS);

        assertTrue(session.isConnected());

        System.out.println("WEBSOCKET CONNECTED");

        /*
         * ---------------------------------------------------------
         * 3. SUBSCRIBE TO PLAYER A
         * ---------------------------------------------------------
         */

        String destination =
                "/topic/player/" + playerA.getId();

        System.out.println(
                "SUBSCRIBING TO: " + destination
        );

        session.subscribe(
                destination,
                new StompFrameHandler() {

                    @Override
                    public Type getPayloadType(
                            StompHeaders headers
                    ) {
                        return Map.class;
                    }

                    @Override
                    public void handleFrame(
                            StompHeaders headers,
                            Object payload
                    ) {

                        System.out.println(
                                "WEBSOCKET EVENT RECEIVED: "
                                        + payload
                        );

                        sessionHandler.addEvent(
                                (Map<?, ?>) payload
                        );
                    }
                }
        );

        /*
         * IMPORTANT:
         *
         * Give the subscription a moment to become active
         * before triggering the pair creation.
         */
        Thread.sleep(300);

        /*
         * ---------------------------------------------------------
         * 4. CREATE PAIR
         * ---------------------------------------------------------
         */

        Pair pair =
                matchService.findAndCreateMatch(eventId);

        assertNotNull(pair);

        System.out.println(
                "PAIR CREATED: " + pair.getId()
        );

        /*
         * ---------------------------------------------------------
         * 5. WAIT FOR CREATED + SEARCHING
         * ---------------------------------------------------------
         */

        waitForEvent(
                sessionHandler,
                "PAIR_CREATED"
        );

        waitForEvent(
                sessionHandler,
                "PAIR_SEARCHING"
        );

        /*
         * ---------------------------------------------------------
         * 6. SEARCHING → FOUND
         * ---------------------------------------------------------
         */

        matchService.updatePairStatus(
                pair.getId(),
                com.twinquest.backend.model.PairStatus.FOUND
        );

        waitForEvent(
                sessionHandler,
                "PAIR_FOUND"
        );

        /*
         * ---------------------------------------------------------
         * 7. FOUND → CONFIRMED
         * ---------------------------------------------------------
         */

        matchService.confirmMatch(
                pair.getId()
        );

        waitForEvent(
                sessionHandler,
                "PAIR_CONFIRMED"
        );

        /*
         * ---------------------------------------------------------
         * 8. CONFIRMED → COMPLETED
         * ---------------------------------------------------------
         */

        matchService.completeMatch(
                pair.getId(),
                12500L
        );

        waitForEvent(
                sessionHandler,
                "PAIR_COMPLETED"
        );

        /*
         * ---------------------------------------------------------
         * 9. VERIFY COMPLETE EVENT DATA
         * ---------------------------------------------------------
         */

        Map<?, ?> completedEvent =
                sessionHandler.findEvent(
                        "PAIR_COMPLETED"
                );

        assertNotNull(completedEvent);

        assertEquals(
                pair.getId(),
                completedEvent.get("pairId")
        );

        assertEquals(
                playerA.getId(),
                completedEvent.get("playerId")
        );

        assertEquals(
                playerB.getId(),
                completedEvent.get("opponentId")
        );

        assertEquals(
                "COMPLETED",
                completedEvent.get("status")
        );

        /*
         * Jackson may deserialize Long as Integer
         * depending on converter configuration, so compare
         * numerically.
         */
        assertEquals(
                12500L,
                ((Number) completedEvent.get(
                        "completionTimeMs"
                )).longValue()
        );

        /*
         * ---------------------------------------------------------
         * 10. PRINT RESULTS
         * ---------------------------------------------------------
         */

        System.out.println();
        System.out.println(
                "EVENTS RECEIVED: "
                        + sessionHandler.events.size()
        );

        for (Map<?, ?> event :
                sessionHandler.events) {

            System.out.println(
                    "  → " + event.get("type")
                            + " | "
                            + event.get("status")
            );
        }

        System.out.println();
        System.out.println(
                "=========================================="
        );
        System.out.println(
                "    WEBSOCKET FLOW PASSED"
        );
        System.out.println(
                "=========================================="
        );

        session.disconnect();
        stompClient.stop();
    }

    private void waitForEvent(
            TestStompHandler handler,
            String eventType
    ) throws Exception {

        long timeout =
                System.currentTimeMillis()
                        + 5000;

        while (
                System.currentTimeMillis()
                        < timeout
        ) {

            if (handler.hasEvent(eventType)) {
                return;
            }

            Thread.sleep(100);
        }

        fail(
                "Did not receive WebSocket event: "
                        + eventType
        );
    }

    private static class TestStompHandler
            extends StompSessionHandlerAdapter {

        private final List<Map<?, ?>> events =
                new ArrayList<>();

        @Override
        public void afterConnected(
                StompSession session,
                StompHeaders connectedHeaders
        ) {
            System.out.println(
                    "STOMP SESSION CONNECTED"
            );
        }

        public synchronized void addEvent(
                Map<?, ?> event
        ) {
            events.add(event);
        }

        public synchronized boolean hasEvent(
                String type
        ) {
            return events.stream()
                    .anyMatch(
                            event ->
                                    type.equals(
                                            event.get("type")
                                    )
                    );
        }

        public synchronized Map<?, ?> findEvent(
                String type
        ) {
            return events.stream()
                    .filter(
                            event ->
                                    type.equals(
                                            event.get("type")
                                    )
                    )
                    .findFirst()
                    .orElse(null);
        }
    }
}