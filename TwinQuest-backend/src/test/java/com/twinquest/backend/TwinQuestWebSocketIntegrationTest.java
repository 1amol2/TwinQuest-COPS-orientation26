package com.twinquest.backend;

import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import com.twinquest.backend.model.Player;
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
         * 2. CONNECT BOTH PLAYERS TO WEBSOCKET
         * ---------------------------------------------------------
         */

        WebSocketStompClient stompClientA =
                new WebSocketStompClient(
                        new StandardWebSocketClient()
                );

        WebSocketStompClient stompClientB =
                new WebSocketStompClient(
                        new StandardWebSocketClient()
                );

        stompClientA.setMessageConverter(
                new MappingJackson2MessageConverter()
        );

        stompClientB.setMessageConverter(
                new MappingJackson2MessageConverter()
        );

        String websocketUrl =
                "ws://localhost:" + port + "/ws";

        System.out.println(
                "Connecting Player A to: "
                        + websocketUrl
        );

        System.out.println(
                "Connecting Player B to: "
                        + websocketUrl
        );

        TestStompHandler handlerA =
                new TestStompHandler();

        TestStompHandler handlerB =
                new TestStompHandler();

        StompSession sessionA =
                stompClientA.connectAsync(
                        websocketUrl,
                        handlerA
                ).get(10, TimeUnit.SECONDS);

        StompSession sessionB =
                stompClientB.connectAsync(
                        websocketUrl,
                        handlerB
                ).get(10, TimeUnit.SECONDS);

        assertTrue(sessionA.isConnected());
        assertTrue(sessionB.isConnected());

        System.out.println(
                "PLAYER A WEBSOCKET CONNECTED"
        );

        System.out.println(
                "PLAYER B WEBSOCKET CONNECTED"
        );

        /*
         * ---------------------------------------------------------
         * 3. SUBSCRIBE EACH PLAYER TO THEIR OWN TOPIC
         * ---------------------------------------------------------
         */

        System.out.println(
                "Subscribing Player A..."
        );

        sessionA.subscribe(
                "/topic/player/" + playerA.getId(),
                createFrameHandler(handlerA)
        );

        System.out.println(
                "Subscribing Player B..."
        );

        sessionB.subscribe(
                "/topic/player/" + playerB.getId(),
                createFrameHandler(handlerB)
        );

        /*
         * Give both subscriptions time to become active.
         */
        Thread.sleep(300);

        /*
         * ---------------------------------------------------------
         * 4. CREATE MATCH
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
         * 5. VERIFY PAIR CREATED
         * ---------------------------------------------------------
         */

        waitForEvent(
                handlerA,
                "PAIR_CREATED"
        );

        waitForEvent(
                handlerB,
                "PAIR_CREATED"
        );

        /*
         * ---------------------------------------------------------
         * 6. VERIFY SEARCHING
         * ---------------------------------------------------------
         *
         * findAndCreateMatch() already moves:
         *
         * CREATED → SEARCHING
         *
         * and sends PAIR_SEARCHING.
         */

        waitForEvent(
                handlerA,
                "PAIR_SEARCHING"
        );

        waitForEvent(
                handlerB,
                "PAIR_SEARCHING"
        );
        /*
         * ---------------------------------------------------------
         * 7. SEARCHING → FOUND
         * ---------------------------------------------------------
         */

        matchService.updatePairStatus(
                pair.getId(),
                PairStatus.FOUND
        );

        waitForEvent(
                handlerA,
                "PAIR_FOUND"
        );

        waitForEvent(
                handlerB,
                "PAIR_FOUND"
        );

        /*
         * ---------------------------------------------------------
         * 8. VERIFY FOUND EVENT DATA
         * ---------------------------------------------------------
         */

        Map<?, ?> foundEventA =
                handlerA.findEvent("PAIR_FOUND");

        Map<?, ?> foundEventB =
                handlerB.findEvent("PAIR_FOUND");

        assertNotNull(foundEventA);
        assertNotNull(foundEventB);

        System.out.println();
        System.out.println("========== FOUND EVENT DEBUG ==========");

        System.out.println(
                "Player A expected ID : "
                        + playerA.getId()
        );

        System.out.println(
                "Player A received    : "
                        + foundEventA
        );

        System.out.println();

        System.out.println(
                "Player B expected ID : "
                        + playerB.getId()
        );

        System.out.println(
                "Player B received    : "
                        + foundEventB
        );

        System.out.println("=======================================");

        /*
         * Player A should receive:
         *
         * playerId   = Player A
         * opponentId = Player B
         */

        assertEquals(
                playerA.getId(),
                String.valueOf(
                        foundEventA.get("playerId")
                )
        );

        assertEquals(
                playerB.getId(),
                String.valueOf(
                        foundEventA.get("opponentId")
                )
        );

        /*
         * Player B should receive:
         *
         * playerId   = Player B
         * opponentId = Player A
         */

        assertEquals(
                playerB.getId(),
                String.valueOf(
                        foundEventB.get("playerId")
                )
        );

        assertEquals(
                playerA.getId(),
                String.valueOf(
                        foundEventB.get("opponentId")
                )
        );

        assertEquals(
                pair.getId(),
                String.valueOf(
                        foundEventA.get("pairId")
                )
        );

        assertEquals(
                pair.getId(),
                String.valueOf(
                        foundEventB.get("pairId")
                )
        );

        assertEquals(
                "FOUND",
                String.valueOf(
                        foundEventA.get("status")
                )
        );

        assertEquals(
                "FOUND",
                String.valueOf(
                        foundEventB.get("status")
                )
        );
        /*
         * ---------------------------------------------------------
         * 9. FOUND → CONFIRMED
         * ---------------------------------------------------------
         */

        matchService.confirmMatch(
                pair.getId()
        );

        waitForEvent(
                handlerA,
                "PAIR_CONFIRMED"
        );

        waitForEvent(
                handlerB,
                "PAIR_CONFIRMED"
        );

        /*
         * ---------------------------------------------------------
         * 10. CONFIRMED → COMPLETED
         * ---------------------------------------------------------
         */

        matchService.completeMatch(
                pair.getId(),
                12500L
        );

        waitForEvent(
                handlerA,
                "PAIR_COMPLETED"
        );

        waitForEvent(
                handlerB,
                "PAIR_COMPLETED"
        );

        /*
         * ---------------------------------------------------------
         * 11. VERIFY COMPLETED EVENT DATA
         * ---------------------------------------------------------
         */

        Map<?, ?> completedEventA =
                handlerA.findEvent(
                        "PAIR_COMPLETED"
                );

        Map<?, ?> completedEventB =
                handlerB.findEvent(
                        "PAIR_COMPLETED"
                );

        assertNotNull(completedEventA);
        assertNotNull(completedEventB);

        /*
         * Player A completion event
         */

        assertEquals(
                pair.getId(),
                completedEventA.get("pairId")
        );

        assertEquals(
                playerA.getId(),
                completedEventA.get("playerId")
        );

        assertEquals(
                playerB.getId(),
                completedEventA.get("opponentId")
        );

        assertEquals(
                "COMPLETED",
                completedEventA.get("status")
        );

        /*
         * Player B completion event
         */

        assertEquals(
                pair.getId(),
                completedEventB.get("pairId")
        );

        assertEquals(
                playerB.getId(),
                completedEventB.get("playerId")
        );

        assertEquals(
                playerA.getId(),
                completedEventB.get("opponentId")
        );

        assertEquals(
                "COMPLETED",
                completedEventB.get("status")
        );

        /*
         * Jackson may deserialize Long as Integer
         * depending on converter configuration,
         * so compare numerically.
         */

        assertEquals(
                12500L,
                ((Number) completedEventA.get(
                        "completionTimeMs"
                )).longValue()
        );

        assertEquals(
                12500L,
                ((Number) completedEventB.get(
                        "completionTimeMs"
                )).longValue()
        );

        /*
         * ---------------------------------------------------------
         * 12. PRINT RESULTS
         * ---------------------------------------------------------
         */

        System.out.println();
        System.out.println(
                "PLAYER A EVENTS: "
                        + handlerA.events.size()
        );

        for (Map<?, ?> event :
                handlerA.events) {

            System.out.println(
                    "PLAYER A → "
                            + event.get("type")
                            + " | "
                            + event.get("status")
            );
        }

        System.out.println();

        System.out.println(
                "PLAYER B EVENTS: "
                        + handlerB.events.size()
        );

        for (Map<?, ?> event :
                handlerB.events) {

            System.out.println(
                    "PLAYER B → "
                            + event.get("type")
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
                "==========================================");

        /*
         * ---------------------------------------------------------
         * 13. DISCONNECT BOTH PLAYERS
         * ---------------------------------------------------------
         */

        sessionA.disconnect();
        sessionB.disconnect();

        stompClientA.stop();
        stompClientB.stop();
    }

    /*
     * -------------------------------------------------------------
     * CREATE STOMP FRAME HANDLER
     * -------------------------------------------------------------
     */

    private StompFrameHandler createFrameHandler(
            TestStompHandler handler
    ) {

        return new StompFrameHandler() {

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

                handler.addEvent(
                        (Map<?, ?>) payload
                );
            }
        };
    }

    /*
     * -------------------------------------------------------------
     * WAIT FOR EVENT
     * -------------------------------------------------------------
     */

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

    /*
     * -------------------------------------------------------------
     * WAIT FOR EVENT WITH SPECIFIC STATUS
     * -------------------------------------------------------------
     *
     * Needed because PAIR_STATUS_CHANGED is used for
     * both SEARCHING and FOUND.
     */

    private void waitForEventWithStatus(
            TestStompHandler handler,
            String eventType,
            String status
    ) throws Exception {

        long timeout =
                System.currentTimeMillis()
                        + 5000;

        while (
                System.currentTimeMillis()
                        < timeout
        ) {

            if (
                    handler.hasEventWithStatus(
                            eventType,
                            status
                    )
            ) {
                return;
            }

            Thread.sleep(100);
        }

        fail(
                "Did not receive WebSocket event: "
                        + eventType
                        + " with status: "
                        + status
        );
    }

    /*
     * -------------------------------------------------------------
     * TEST STOMP HANDLER
     * -------------------------------------------------------------
     */

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

        public synchronized boolean hasEventWithStatus(
                String type,
                String status
        ) {

            return events.stream()
                    .anyMatch(
                            event ->
                                    type.equals(
                                            event.get("type")
                                    )
                                            &&
                                            status.equals(
                                                    event.get("status")
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

        public synchronized Map<?, ?> findEventWithStatus(
                String type,
                String status
        ) {

            return events.stream()
                    .filter(
                            event ->
                                    type.equals(
                                            event.get("type")
                                    )
                                            &&
                                            status.equals(
                                                    event.get("status")
                                            )
                    )
                    .findFirst()
                    .orElse(null);
        }
    }
}