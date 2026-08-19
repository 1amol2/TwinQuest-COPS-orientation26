package com.twinquest.backend;

import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.PairStatus;
import com.twinquest.backend.service.MatchService;
import com.twinquest.backend.service.PlayerService;
import com.twinquest.backend.websocket.PairingSessionRequest;
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
class TwinQuestTwoPlayerPairingWebSocketIntegrationTest {

    @LocalServerPort
    private int port;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private MatchService matchService;

    @Test
    void twoPlayersCompletePairingFlowOverWebSocket()
            throws Exception {

        String eventId =
                "TWO-PLAYER-WS-" + UUID.randomUUID();

        /*
         * ---------------------------------------------------------
         * 1. CREATE TWO PLAYERS
         * ---------------------------------------------------------
         */
        Player playerA =
                playerService.createPlayer(
                        "test-user-a",
                        "Player A",
                        eventId,
                        "DEVICE-A-" + UUID.randomUUID()
                );

        Player playerB =
                playerService.createPlayer(
                        "test-user-b",
                        "Player B",
                        eventId,
                        "DEVICE-B-" + UUID.randomUUID()
                );

        System.out.println();
        System.out.println("==========================================");
        System.out.println("   TWO PLAYER WEBSOCKET PAIRING TEST");
        System.out.println("==========================================");

        System.out.println(
                "PLAYER A: " + playerA.getId()
        );

        System.out.println(
                "PLAYER B: " + playerB.getId()
        );

        /*
         * ---------------------------------------------------------
         * 2. CREATE TWO WEBSOCKET CLIENTS
         * ---------------------------------------------------------
         */

        WebSocketStompClient clientA =
                createClient();

        WebSocketStompClient clientB =
                createClient();

        String websocketUrl =
                "ws://localhost:" + port + "/ws";

        TestEventHandler handlerA =
                new TestEventHandler("PLAYER A");

        TestEventHandler handlerB =
                new TestEventHandler("PLAYER B");

        /*
         * ---------------------------------------------------------
         * 3. CONNECT BOTH PLAYERS
         * ---------------------------------------------------------
         */

        StompSession sessionA =
                clientA.connectAsync(
                                websocketUrl,
                                handlerA
                        )
                        .get(
                                10,
                                TimeUnit.SECONDS
                        );

        StompSession sessionB =
                clientB.connectAsync(
                                websocketUrl,
                                handlerB
                        )
                        .get(
                                10,
                                TimeUnit.SECONDS
                        );

        assertTrue(sessionA.isConnected());
        assertTrue(sessionB.isConnected());

        System.out.println(
                "BOTH PLAYERS CONNECTED"
        );

        /*
         * ---------------------------------------------------------
         * 4. SUBSCRIBE BOTH PLAYERS
         * ---------------------------------------------------------
         */

        sessionA.subscribe(
                "/topic/player/" + playerA.getId(),
                handlerA
        );

        sessionB.subscribe(
                "/topic/player/" + playerB.getId(),
                handlerB
        );

        /*
         * Make sure subscriptions are registered before
         * triggering matchmaking.
         */

        Thread.sleep(300);

        /*
         * ---------------------------------------------------------
         * 5. BOTH PLAYERS JOIN PAIRING SESSION
         * ---------------------------------------------------------
         */

        sessionA.send(
                "/app/pairing/join",
                new PairingSessionRequest(
                        playerA.getId()
                )
        );

        sessionB.send(
                "/app/pairing/join",
                new PairingSessionRequest(
                        playerB.getId()
                )
        );

        /*
         * Give the controller time to process both joins.
         */

        Thread.sleep(500);

        System.out.println(
                "BOTH PLAYERS JOINED PAIRING"
        );

        /*
         * ---------------------------------------------------------
         * 6. CREATE MATCH
         * ---------------------------------------------------------
         */

        Pair pair =
                matchService.findAndCreateMatch(
                        eventId
                );

        assertNotNull(pair);

        assertEquals(
                eventId,
                pair.getEventId()
        );

        assertEquals(
                playerA.getId(),
                pair.getPlayerAId()
        );

        assertEquals(
                playerB.getId(),
                pair.getPlayerBId()
        );

        System.out.println(
                "PAIR CREATED: " + pair.getId()
        );

        /*
         * ---------------------------------------------------------
         * 7. VERIFY CREATED + SEARCHING
         * ---------------------------------------------------------
         */

        handlerA.waitForEvent(
                "PAIR_CREATED"
        );

        handlerB.waitForEvent(
                "PAIR_CREATED"
        );

        handlerA.waitForEvent(
                "PAIR_SEARCHING"
        );

        handlerB.waitForEvent(
                "PAIR_SEARCHING"
        );

        /*
         * ---------------------------------------------------------
         * 8. SEARCHING → FOUND
         * ---------------------------------------------------------
         */

        matchService.updatePairStatus(
                pair.getId(),
                PairStatus.FOUND
        );

        handlerA.waitForEvent(
                "PAIR_FOUND"
        );

        handlerB.waitForEvent(
                "PAIR_FOUND"
        );

        /*
         * ---------------------------------------------------------
         * 9. FOUND → CONFIRMED
         * ---------------------------------------------------------
         */

        matchService.confirmMatch(
                pair.getId()
        );

        handlerA.waitForEvent(
                "PAIR_CONFIRMED"
        );

        handlerB.waitForEvent(
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

        handlerA.waitForEvent(
                "PAIR_COMPLETED"
        );

        handlerB.waitForEvent(
                "PAIR_COMPLETED"
        );

        /*
         * ---------------------------------------------------------
         * 11. VERIFY PLAYER A EVENT
         * ---------------------------------------------------------
         */

        Map<?, ?> completedA =
                handlerA.findEvent(
                        "PAIR_COMPLETED"
                );

        assertNotNull(completedA);

        assertEquals(
                pair.getId(),
                completedA.get("pairId")
        );

        assertEquals(
                playerA.getId(),
                completedA.get("playerId")
        );

        assertEquals(
                playerB.getId(),
                completedA.get("opponentId")
        );

        assertEquals(
                "COMPLETED",
                completedA.get("status")
        );

        assertEquals(
                12500L,
                ((Number) completedA.get(
                        "completionTimeMs"
                )).longValue()
        );

        /*
         * ---------------------------------------------------------
         * 12. VERIFY PLAYER B EVENT
         * ---------------------------------------------------------
         */

        Map<?, ?> completedB =
                handlerB.findEvent(
                        "PAIR_COMPLETED"
                );

        assertNotNull(completedB);

        assertEquals(
                pair.getId(),
                completedB.get("pairId")
        );

        assertEquals(
                playerB.getId(),
                completedB.get("playerId")
        );

        assertEquals(
                playerA.getId(),
                completedB.get("opponentId")
        );

        assertEquals(
                "COMPLETED",
                completedB.get("status")
        );

        assertEquals(
                12500L,
                ((Number) completedB.get(
                        "completionTimeMs"
                )).longValue()
        );

        /*
         * ---------------------------------------------------------
         * 13. VERIFY EVENT COUNTS
         * ---------------------------------------------------------
         */

        assertEquals(
                5,
                handlerA.events.size()
        );

        assertEquals(
                5,
                handlerB.events.size()
        );

        System.out.println();
        System.out.println(
                "PLAYER A EVENTS: "
                        + handlerA.events.size()
        );

        handlerA.printEvents();

        System.out.println();
        System.out.println(
                "PLAYER B EVENTS: "
                        + handlerB.events.size()
        );

        handlerB.printEvents();

        /*
         * ---------------------------------------------------------
         * 14. FINAL RESULT
         * ---------------------------------------------------------
         */

        System.out.println();
        System.out.println(
                "=========================================="
        );

        System.out.println(
                " TWO PLAYER PAIRING FLOW PASSED"
        );

        System.out.println(
                "=========================================="
        );

        sessionA.disconnect();
        sessionB.disconnect();

        clientA.stop();
        clientB.stop();
    }

    private WebSocketStompClient createClient() {

        WebSocketStompClient client =
                new WebSocketStompClient(
                        new StandardWebSocketClient()
                );

        client.setMessageConverter(
                new MappingJackson2MessageConverter()
        );

        return client;
    }

    private static class TestEventHandler
            extends StompSessionHandlerAdapter
            implements StompFrameHandler {

        private final String playerName;

        private final List<Map<?, ?>> events =
                new ArrayList<>();

        TestEventHandler(String playerName) {
            this.playerName = playerName;
        }

        @Override
        public void afterConnected(
                StompSession session,
                StompHeaders connectedHeaders
        ) {

            System.out.println(
                    playerName + " STOMP CONNECTED"
            );
        }

        @Override
        public Type getPayloadType(
                StompHeaders headers
        ) {

            return Map.class;
        }

        @Override
        public synchronized void handleFrame(
                StompHeaders headers,
                Object payload
        ) {

            Map<?, ?> event =
                    (Map<?, ?>) payload;

            events.add(event);

            System.out.println(
                    playerName
                            + " RECEIVED → "
                            + event.get("type")
                            + " | "
                            + event.get("status")
            );
        }

        public void waitForEvent(
                String eventType
        ) throws Exception {

            long timeout =
                    System.currentTimeMillis()
                            + 5000;

            while (
                    System.currentTimeMillis()
                            < timeout
            ) {

                synchronized (this) {

                    boolean found =
                            events.stream()
                                    .anyMatch(
                                            event ->
                                                    eventType.equals(
                                                            event.get(
                                                                    "type"
                                                            )
                                                    )
                                    );

                    if (found) {
                        return;
                    }
                }

                Thread.sleep(100);
            }

            fail(
                    playerName
                            + " did not receive event: "
                            + eventType
            );
        }

        public synchronized Map<?, ?> findEvent(
                String eventType
        ) {

            return events.stream()
                    .filter(
                            event ->
                                    eventType.equals(
                                            event.get("type")
                                    )
                    )
                    .findFirst()
                    .orElse(null);
        }

        public synchronized void printEvents() {

            for (Map<?, ?> event : events) {

                System.out.println(
                        "  → "
                                + event.get("type")
                                + " | "
                                + event.get("status")
                );
            }
        }
    }
}