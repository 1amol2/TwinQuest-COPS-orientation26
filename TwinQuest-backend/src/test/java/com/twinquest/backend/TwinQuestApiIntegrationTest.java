package com.twinquest.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class TwinQuestApiIntegrationTest {

    @LocalServerPort
    private int port;

    private final RestTemplate restTemplate;

    private final ObjectMapper objectMapper =
            new ObjectMapper();

    {
        restTemplate = new RestTemplate();

        /*
         * Allow us to inspect 4xx/5xx response bodies
         * instead of RestTemplate throwing immediately.
         */
        restTemplate.setErrorHandler(
                new DefaultResponseErrorHandler() {
                    @Override
                    public boolean hasError(
                            ClientHttpResponse response
                    ) {
                        return false;
                    }
                }
        );
    }

    private String baseUrl() {
        return "http://localhost:" + port;
    }

    @Test
    void createEventAndJoinTwoPlayers() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        /*
         * =========================================================
         * 1. CREATE EVENT
         * =========================================================
         *
         * We create a fresh event for every test run.
         * This prevents the test from depending on ORIENT26
         * already existing in MongoDB.
         */

        Map<String, String> eventRequest = Map.of(
                "title",
                "TwinQuest Integration Test"
        );

        HttpEntity<Map<String, String>> eventEntity =
                new HttpEntity<>(
                        eventRequest,
                        headers
                );

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        eventEntity,
                        String.class
                );

        System.out.println(
                "CREATE EVENT STATUS: "
                        + eventResponse.getStatusCode()
        );

        System.out.println(
                "CREATE EVENT BODY: "
                        + eventResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                eventResponse.getStatusCode()
        );

        JsonNode event =
                objectMapper.readTree(
                        eventResponse.getBody()
                );

        String eventId =
                event.get("id").asText();

        String eventCode =
                event.get("eventCode").asText();

        assertNotNull(eventId);
        assertNotNull(eventCode);

        assertFalse(eventId.isBlank());
        assertFalse(eventCode.isBlank());

        /*
         * =========================================================
         * 2. PLAYER A JOINS
         * =========================================================
         */

        Map<String, String> playerARequest = Map.of(
                "name",
                "Test Player A",

                "eventCode",
                eventCode,

                "avatar",
                "avatar_a"
        );

        HttpEntity<Map<String, String>> playerAEntity =
                new HttpEntity<>(
                        playerARequest,
                        headers
                );

        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        playerAEntity,
                        String.class
                );

        System.out.println(
                "PLAYER A JOIN STATUS: "
                        + playerAResponse.getStatusCode()
        );

        System.out.println(
                "PLAYER A JOIN BODY: "
                        + playerAResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                playerAResponse.getStatusCode()
        );

        JsonNode playerA =
                objectMapper.readTree(
                        playerAResponse.getBody()
                );

        String playerAId =
                playerA.get("id").asText();

        assertNotNull(playerAId);
        assertFalse(playerAId.isBlank());

        assertEquals(
                "Test Player A",
                playerA.get("name").asText()
        );

        assertEquals(
                eventCode,
                playerA.get("eventCode").asText()
        );

        assertEquals(
                eventId,
                playerA.get("eventId").asText()
        );

        /*
         * =========================================================
         * 3. PLAYER B JOINS
         * =========================================================
         */

        Map<String, String> playerBRequest = Map.of(
                "name",
                "Test Player B",

                "eventCode",
                eventCode,

                "avatar",
                "avatar_b"
        );

        HttpEntity<Map<String, String>> playerBEntity =
                new HttpEntity<>(
                        playerBRequest,
                        headers
                );

        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        playerBEntity,
                        String.class
                );

        System.out.println(
                "PLAYER B JOIN STATUS: "
                        + playerBResponse.getStatusCode()
        );

        System.out.println(
                "PLAYER B JOIN BODY: "
                        + playerBResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                playerBResponse.getStatusCode()
        );

        JsonNode playerB =
                objectMapper.readTree(
                        playerBResponse.getBody()
                );

        String playerBId =
                playerB.get("id").asText();

        assertNotNull(playerBId);
        assertFalse(playerBId.isBlank());

        assertNotEquals(
                playerAId,
                playerBId
        );

        assertEquals(
                "Test Player B",
                playerB.get("name").asText()
        );

        assertEquals(
                eventCode,
                playerB.get("eventCode").asText()
        );

        assertEquals(
                eventId,
                playerB.get("eventId").asText()
        );

        /*
         * =========================================================
         * 4. CHECK LOBBY
         * =========================================================
         *
         * Both players should now appear in the event lobby.
         */

        ResponseEntity<String> lobbyResponse =
                restTemplate.getForEntity(
                        baseUrl()
                                + "/api/events/"
                                + eventCode
                                + "/players",
                        String.class
                );

        System.out.println(
                "LOBBY STATUS: "
                        + lobbyResponse.getStatusCode()
        );

        System.out.println(
                "LOBBY BODY: "
                        + lobbyResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                lobbyResponse.getStatusCode()
        );

        JsonNode players =
                objectMapper.readTree(
                        lobbyResponse.getBody()
                );

        assertTrue(players.isArray());

        assertEquals(
                2,
                players.size()
        );

        /*
         * Verify both players are present.
         */

        assertTrue(
                players.toString()
                        .contains("Test Player A")
        );

        assertTrue(
                players.toString()
                        .contains("Test Player B")
        );
    }
    @Test
    void createPairAfterTwoPlayersJoin() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 1. Create event
        Map<String, String> eventRequest = Map.of(
                "title",
                "Pair Integration Test"
        );

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        new HttpEntity<>(eventRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                eventResponse.getStatusCode()
        );

        JsonNode event =
                objectMapper.readTree(eventResponse.getBody());

        String eventId =
                event.get("id").asText();

        String eventCode =
                event.get("eventCode").asText();


        // 2. Player A joins
        Map<String, String> playerARequest = Map.of(
                "name",
                "Pair Test A",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_a"
        );

        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerARequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerAResponse.getStatusCode()
        );

        JsonNode playerA =
                objectMapper.readTree(playerAResponse.getBody());

        String playerAId =
                playerA.get("id").asText();


        // 3. Player B joins
        Map<String, String> playerBRequest = Map.of(
                "name",
                "Pair Test B",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_b"
        );

        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerBRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerBResponse.getStatusCode()
        );

        JsonNode playerB =
                objectMapper.readTree(playerBResponse.getBody());

        String playerBId =
                playerB.get("id").asText();


        // 4. Create pair
        Map<String, String> pairRequest = Map.of(
                "eventId",
                eventId,

                "playerAId",
                playerAId,

                "playerBId",
                playerBId
        );

        ResponseEntity<String> pairResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/create",
                        new HttpEntity<>(pairRequest, headers),
                        String.class
                );

        System.out.println(
                "PAIR CREATE STATUS: "
                        + pairResponse.getStatusCode()
        );

        System.out.println(
                "PAIR CREATE BODY: "
                        + pairResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                pairResponse.getStatusCode()
        );


        // 5. Verify pair response
        JsonNode pair =
                objectMapper.readTree(pairResponse.getBody());

        assertNotNull(pair.get("id"));

        assertEquals(
                eventId,
                pair.get("eventId").asText()
        );
        String pairId =
                pair.get("id").asText();

        assertFalse(pairId.isBlank());

        assertEquals(
                "CREATED",
                pair.get("status").asText()
        );
        assertEquals(
                playerAId,
                pair.get("playerAId").asText()
        );

        assertEquals(
                playerBId,
                pair.get("playerBId").asText()
        );
        // 6. Mark pair as SEARCHING

        ResponseEntity<String> searchingResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/searching",
                        new HttpEntity<>(headers),
                        String.class
                );

        System.out.println(
                "PAIR SEARCHING STATUS: "
                        + searchingResponse.getStatusCode()
        );

        System.out.println(
                "PAIR SEARCHING BODY: "
                        + searchingResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                searchingResponse.getStatusCode()
        );

        JsonNode searchingPair =
                objectMapper.readTree(
                        searchingResponse.getBody()
                );

        assertEquals(
                pairId,
                searchingPair.get("id").asText()
        );

        assertEquals(
                "SEARCHING",
                searchingPair.get("status").asText()
        );

        ResponseEntity<String> foundResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/found",
                        new HttpEntity<>(headers),
                        String.class
                );

        System.out.println(
                "PAIR FOUND STATUS: "
                        + foundResponse.getStatusCode()
        );

        System.out.println(
                "PAIR FOUND BODY: "
                        + foundResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                foundResponse.getStatusCode()
        );

        JsonNode foundPair =
                objectMapper.readTree(
                        foundResponse.getBody()
                );

        assertEquals(
                pairId,
                foundPair.get("id").asText()
        );

        assertEquals(
                "FOUND",
                foundPair.get("status").asText()
        );

        // 7. Confirm pair

        ResponseEntity<String> confirmResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/confirm",
                        new HttpEntity<>(headers),
                        String.class
                );

        System.out.println(
                "PAIR CONFIRM STATUS: "
                        + confirmResponse.getStatusCode()
        );

        System.out.println(
                "PAIR CONFIRM BODY: "
                        + confirmResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                confirmResponse.getStatusCode()
        );

        JsonNode confirmedPair =
                objectMapper.readTree(
                        confirmResponse.getBody()
                );

        assertEquals(
                pairId,
                confirmedPair.get("id").asText()
        );

        assertEquals(
                "CONFIRMED",
                confirmedPair.get("status").asText()
        );
    }
    @Test
    void completeGameMatchAfterPairConfirmation() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 1. Create event
        Map<String, String> eventRequest = Map.of(
                "title",
                "Complete Match Integration Test"
        );

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        new HttpEntity<>(eventRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                eventResponse.getStatusCode()
        );

        JsonNode event =
                objectMapper.readTree(
                        eventResponse.getBody()
                );

        String eventId =
                event.get("id").asText();

        String eventCode =
                event.get("eventCode").asText();


        // 2. Player A joins
        Map<String, String> playerARequest = Map.of(
                "name",
                "Complete Test A",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_a"
        );

        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerARequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerAResponse.getStatusCode()
        );

        JsonNode playerA =
                objectMapper.readTree(
                        playerAResponse.getBody()
                );

        String playerAId =
                playerA.get("id").asText();


        // 3. Player B joins
        Map<String, String> playerBRequest = Map.of(
                "name",
                "Complete Test B",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_b"
        );

        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerBRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerBResponse.getStatusCode()
        );

        JsonNode playerB =
                objectMapper.readTree(
                        playerBResponse.getBody()
                );

        String playerBId =
                playerB.get("id").asText();


        // 4. Create pair
        Map<String, String> pairRequest = Map.of(
                "eventId",
                eventId,
                "playerAId",
                playerAId,
                "playerBId",
                playerBId
        );

        ResponseEntity<String> pairResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/create",
                        new HttpEntity<>(pairRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                pairResponse.getStatusCode()
        );

        JsonNode pair =
                objectMapper.readTree(
                        pairResponse.getBody()
                );

        String pairId =
                pair.get("id").asText();

        assertEquals(
                "CREATED",
                pair.get("status").asText()
        );


        // 5. Move pair to SEARCHING
        ResponseEntity<String> searchingResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/searching",
                        new HttpEntity<>(headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                searchingResponse.getStatusCode()
        );


        // 6. Move pair to FOUND
        ResponseEntity<String> foundResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/found",
                        new HttpEntity<>(headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                foundResponse.getStatusCode()
        );


        // 7. Move pair to CONFIRMED
        ResponseEntity<String> confirmResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/confirm",
                        new HttpEntity<>(headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                confirmResponse.getStatusCode()
        );

        JsonNode confirmedPair =
                objectMapper.readTree(
                        confirmResponse.getBody()
                );

        assertEquals(
                "CONFIRMED",
                confirmedPair.get("status").asText()
        );


        // 8. Complete the game
        Map<String, Object> completionRequest = Map.of(
                "pairId",
                pairId,

                "playerId",
                playerAId,

                "pin",
                "1234",

                "durationMs",
                15000L
        );

        ResponseEntity<String> completionResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/matches/complete",
                        new HttpEntity<>(
                                completionRequest,
                                headers
                        ),
                        String.class
                );

        System.out.println(
                "MATCH COMPLETE STATUS: "
                        + completionResponse.getStatusCode()
        );

        System.out.println(
                "MATCH COMPLETE BODY: "
                        + completionResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                completionResponse.getStatusCode()
        );


        // 9. Verify completion response
        JsonNode completion =
                objectMapper.readTree(
                        completionResponse.getBody()
                );

        assertNotNull(completion);

        System.out.println(
                "MATCH COMPLETION RESPONSE: "
                        + completion
        );
    }
    @Test
    void completeGameMatchWithBothPlayerPins() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 1. Create event
        Map<String, String> eventRequest = Map.of(
                "title",
                "PIN Verification Integration Test"
        );

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        new HttpEntity<>(eventRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                eventResponse.getStatusCode()
        );

        JsonNode event =
                objectMapper.readTree(eventResponse.getBody());

        String eventId =
                event.get("id").asText();

        String eventCode =
                event.get("eventCode").asText();


        // 2. Player A joins
        Map<String, String> playerARequest = Map.of(
                "name",
                "PIN Test A",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_a"
        );

        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerARequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerAResponse.getStatusCode()
        );

        JsonNode playerA =
                objectMapper.readTree(
                        playerAResponse.getBody()
                );

        String playerAId =
                playerA.get("id").asText();


        // 3. Player B joins
        Map<String, String> playerBRequest = Map.of(
                "name",
                "PIN Test B",
                "eventCode",
                eventCode,
                "avatar",
                "avatar_b"
        );

        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(playerBRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerBResponse.getStatusCode()
        );

        JsonNode playerB =
                objectMapper.readTree(
                        playerBResponse.getBody()
                );

        String playerBId =
                playerB.get("id").asText();


        // 4. Create pair
        Map<String, String> pairRequest = Map.of(
                "eventId",
                eventId,
                "playerAId",
                playerAId,
                "playerBId",
                playerBId
        );

        ResponseEntity<String> pairResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/create",
                        new HttpEntity<>(pairRequest, headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                pairResponse.getStatusCode()
        );

        JsonNode pair =
                objectMapper.readTree(
                        pairResponse.getBody()
                );

        String pairId =
                pair.get("id").asText();


        // 5. Get Player A's match information
        ResponseEntity<String> playerAMatchResponse =
                restTemplate.getForEntity(
                        baseUrl()
                                + "/api/matches/player/"
                                + playerAId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerAMatchResponse.getStatusCode()
        );

        JsonNode playerAMatch =
                objectMapper.readTree(
                        playerAMatchResponse.getBody()
                );

        String playerAPin =
                playerAMatch.get("pin").asText();


        // 6. Get Player B's match information
        ResponseEntity<String> playerBMatchResponse =
                restTemplate.getForEntity(
                        baseUrl()
                                + "/api/matches/player/"
                                + playerBId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                playerBMatchResponse.getStatusCode()
        );

        JsonNode playerBMatch =
                objectMapper.readTree(
                        playerBMatchResponse.getBody()
                );

        String playerBPin =
                playerBMatch.get("pin").asText();


        assertNotEquals(
                playerAPin,
                playerBPin
        );


        // 7. Move pair to FOUND
        ResponseEntity<String> searchingResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/searching",
                        new HttpEntity<>(headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                searchingResponse.getStatusCode()
        );

        ResponseEntity<String> foundResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/"
                                + pairId
                                + "/found",
                        new HttpEntity<>(headers),
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                foundResponse.getStatusCode()
        );


        // 8. Player A enters Player B's PIN
        Map<String, Object> playerACompletionRequest =
                Map.of(
                        "pairId",
                        pairId,
                        "playerId",
                        playerAId,
                        "pin",
                        playerBPin,
                        "durationMs",
                        12000L
                );

        ResponseEntity<String> playerACompletionResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/matches/complete",
                        new HttpEntity<>(
                                playerACompletionRequest,
                                headers
                        ),
                        String.class
                );

        System.out.println(
                "PLAYER A COMPLETION: "
                        + playerACompletionResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                playerACompletionResponse.getStatusCode()
        );

        JsonNode playerACompletion =
                objectMapper.readTree(
                        playerACompletionResponse.getBody()
                );

        assertEquals(
                "VERIFIED",
                playerACompletion.get("status").asText()
        );


        // 9. Player B enters Player A's PIN
        Map<String, Object> playerBCompletionRequest =
                Map.of(
                        "pairId",
                        pairId,
                        "playerId",
                        playerBId,
                        "pin",
                        playerAPin,
                        "durationMs",
                        12000L
                );

        ResponseEntity<String> playerBCompletionResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/matches/complete",
                        new HttpEntity<>(
                                playerBCompletionRequest,
                                headers
                        ),
                        String.class
                );

        System.out.println(
                "PLAYER B COMPLETION: "
                        + playerBCompletionResponse.getBody()
        );

        assertEquals(
                HttpStatus.OK,
                playerBCompletionResponse.getStatusCode()
        );

        JsonNode playerBCompletion =
                objectMapper.readTree(
                        playerBCompletionResponse.getBody()
                );

        assertEquals(
                "COMPLETED",
                playerBCompletion.get("status").asText()
        );

        assertEquals(
                pairId,
                playerBCompletion.get("pairId").asText()
        );
    }
    @Test
    void completeGameMatchWithWrongPinFails() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // Create event
        Map<String, String> eventRequest = Map.of(
                "title", "Wrong PIN Test"
        );

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        new HttpEntity<>(eventRequest, headers),
                        String.class
                );

        JsonNode event =
                objectMapper.readTree(eventResponse.getBody());

        String eventId = event.get("id").asText();
        String eventCode = event.get("eventCode").asText();

        // Player A
        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(
                                Map.of(
                                        "name", "Wrong PIN A",
                                        "eventCode", eventCode,
                                        "avatar", "avatar_a"
                                ),
                                headers
                        ),
                        String.class
                );

        String playerAId =
                objectMapper
                        .readTree(playerAResponse.getBody())
                        .get("id")
                        .asText();

        // Player B
        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(
                                Map.of(
                                        "name", "Wrong PIN B",
                                        "eventCode", eventCode,
                                        "avatar", "avatar_b"
                                ),
                                headers
                        ),
                        String.class
                );

        String playerBId =
                objectMapper
                        .readTree(playerBResponse.getBody())
                        .get("id")
                        .asText();

        // Create pair
        ResponseEntity<String> pairResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/create",
                        new HttpEntity<>(
                                Map.of(
                                        "eventId", eventId,
                                        "playerAId", playerAId,
                                        "playerBId", playerBId
                                ),
                                headers
                        ),
                        String.class
                );

        JsonNode pair =
                objectMapper.readTree(pairResponse.getBody());

        String pairId =
                pair.get("id").asText();

        // Move pair to FOUND
        restTemplate.postForEntity(
                baseUrl() + "/api/matches/"
                        + pairId
                        + "/searching",
                new HttpEntity<>(headers),
                String.class
        );

        restTemplate.postForEntity(
                baseUrl() + "/api/matches/"
                        + pairId
                        + "/found",
                new HttpEntity<>(headers),
                String.class
        );

        // A submits WRONG PIN
        Map<String, Object> completionRequest =
                Map.of(
                        "pairId", pairId,
                        "playerId", playerAId,
                        "pin", "9999",
                        "durationMs", 12000
                );

        ResponseEntity<String> completionResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/matches/complete",
                        new HttpEntity<>(
                                completionRequest,
                                headers
                        ),
                        String.class
                );

        System.out.println(
                "WRONG PIN RESPONSE: "
                        + completionResponse.getBody()
        );

        JsonNode result =
                objectMapper.readTree(
                        completionResponse.getBody()
                );

        assertEquals(
                "FAILURE",
                result.get("status").asText()
        );

        assertEquals(
                "Invalid partner PIN",
                result.get("error").asText()
        );
    }
    @Test
    void nonPairPlayerCannotCompleteMatch() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // 1. Create event
        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/create",
                        new HttpEntity<>(
                                Map.of(
                                        "title",
                                        "Unauthorized Player Test"
                                ),
                                headers
                        ),
                        String.class
                );

        JsonNode event =
                objectMapper.readTree(
                        eventResponse.getBody()
                );

        String eventId =
                event.get("id").asText();

        String eventCode =
                event.get("eventCode").asText();


        // 2. Player A joins
        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(
                                Map.of(
                                        "name",
                                        "Player A",

                                        "eventCode",
                                        eventCode,

                                        "avatar",
                                        "avatar_a"
                                ),
                                headers
                        ),
                        String.class
                );

        String playerAId =
                objectMapper
                        .readTree(
                                playerAResponse.getBody()
                        )
                        .get("id")
                        .asText();


        // 3. Player B joins
        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(
                                Map.of(
                                        "name",
                                        "Player B",

                                        "eventCode",
                                        eventCode,

                                        "avatar",
                                        "avatar_b"
                                ),
                                headers
                        ),
                        String.class
                );

        String playerBId =
                objectMapper
                        .readTree(
                                playerBResponse.getBody()
                        )
                        .get("id")
                        .asText();


        // 4. Player C joins
        ResponseEntity<String> playerCResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events/join",
                        new HttpEntity<>(
                                Map.of(
                                        "name",
                                        "Player C",

                                        "eventCode",
                                        eventCode,

                                        "avatar",
                                        "avatar_c"
                                ),
                                headers
                        ),
                        String.class
                );

        String playerCId =
                objectMapper
                        .readTree(
                                playerCResponse.getBody()
                        )
                        .get("id")
                        .asText();


        // 5. Create A + B pair
        ResponseEntity<String> pairResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/create",
                        new HttpEntity<>(
                                Map.of(
                                        "eventId",
                                        eventId,

                                        "playerAId",
                                        playerAId,

                                        "playerBId",
                                        playerBId
                                ),
                                headers
                        ),
                        String.class
                );

        JsonNode pair =
                objectMapper.readTree(
                        pairResponse.getBody()
                );

        String pairId =
                pair.get("id").asText();


        // 6. Move pair to FOUND
        restTemplate.postForEntity(
                baseUrl()
                        + "/api/matches/"
                        + pairId
                        + "/searching",
                new HttpEntity<>(headers),
                String.class
        );

        restTemplate.postForEntity(
                baseUrl()
                        + "/api/matches/"
                        + pairId
                        + "/found",
                new HttpEntity<>(headers),
                String.class
        );


        /*
         * 7. C attempts to complete A+B's pair.
         *
         * Even if C somehow knows B's PIN,
         * C is not part of the pair.
         */
        Map<String, Object> completionRequest =
                Map.of(
                        "pairId",
                        pairId,

                        "playerId",
                        playerCId,

                        "pin",
                        "0000",

                        "durationMs",
                        12000
                );

        ResponseEntity<String> completionResponse =
                restTemplate.postForEntity(
                        baseUrl()
                                + "/api/matches/complete",
                        new HttpEntity<>(
                                completionRequest,
                                headers
                        ),
                        String.class
                );

        System.out.println(
                "UNAUTHORIZED PLAYER RESPONSE: "
                        + completionResponse.getBody()
        );

        JsonNode result =
                objectMapper.readTree(
                        completionResponse.getBody()
                );

        assertEquals(
                "FAILURE",
                result.get("status").asText()
        );

        assertEquals(
                "Player does not belong to this pair",
                result.get("error").asText()
        );
    }
}