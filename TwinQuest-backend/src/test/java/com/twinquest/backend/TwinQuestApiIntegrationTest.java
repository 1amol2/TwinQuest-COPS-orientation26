package com.twinquest.backend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.jupiter.api.Test;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.DefaultResponseErrorHandler;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpMethod;

import java.net.http.HttpClient;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT
)
class TwinQuestApiIntegrationTest {
    @LocalServerPort
    private int port;

    private String baseUrl() {
        return "http://localhost:" + port;
    }
    private final RestTemplate restTemplate =
            new RestTemplate(
                    new JdkClientHttpRequestFactory(
                            HttpClient.newHttpClient()
                    )
            );
    private final ObjectMapper objectMapper =
            new ObjectMapper();


    @Test
    void completeTwinQuestFlow() throws Exception {

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);


        // =========================================================
        // 1. CREATE EVENT
        // =========================================================

        String eventCode =
                "TEST-" + System.currentTimeMillis();

        Map<String, String> eventRequest = Map.of(
                "eventCode", eventCode,
                "name", "Automated Test Event"
        );

        HttpEntity<Map<String, String>> eventEntity =
                new HttpEntity<>(eventRequest, headers);

        ResponseEntity<String> eventResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/events",
                        eventEntity,
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

        assertNotNull(eventId);




        // =========================================================
        // 2. JOIN PLAYER A
        // =========================================================

        Map<String, String> playerARequest = Map.of(
                "name", "Test Player A",
                "eventId", eventId,
                "deviceId", "automation-device-A-" + System.currentTimeMillis()
        );

        HttpEntity<Map<String, String>> playerAEntity =
                new HttpEntity<>(playerARequest, headers);

        ResponseEntity<String> playerAResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/players/join",
                        playerAEntity,
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

        assertNotNull(playerAId);



        // =========================================================
        // 3. JOIN PLAYER B
        // =========================================================

        Map<String, String> playerBRequest = Map.of(
                "name", "Test Player B",
                "eventId", eventId,
                "deviceId", "automation-device-B-" + System.currentTimeMillis()
        );

        HttpEntity<Map<String, String>> playerBEntity =
                new HttpEntity<>(playerBRequest, headers);

        ResponseEntity<String> playerBResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/players/join",
                        playerBEntity,
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

        assertNotNull(playerBId);




        // =========================================================
        // 4. CREATE MATCH
        // =========================================================

        ResponseEntity<String> matchResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/matches/" + eventId,
                        null,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                matchResponse.getStatusCode()
        );

        JsonNode pair =
                objectMapper.readTree(matchResponse.getBody());

        String pairId =
                pair.get("id").asText();

        assertNotNull(pairId);

        assertEquals(
                eventId,
                pair.get("eventId").asText()
        );

        assertEquals(
                playerAId,
                pair.get("playerAId").asText()
        );

        assertEquals(
                playerBId,
                pair.get("playerBId").asText()
        );

        // MatchService creates the pair directly as SEARCHING
        assertEquals(
                "SEARCHING",
                pair.get("status").asText()
        );



        // =========================================================
        // 5. SEARCHING → FOUND
        // =========================================================

        Map<String, String> foundRequest = Map.of(
                "status", "FOUND"
        );

        HttpEntity<Map<String, String>> foundEntity =
                new HttpEntity<>(foundRequest, headers);

        ResponseEntity<String> foundResponse =
                restTemplate.exchange(
                        baseUrl() + "/api/pairs/" + pairId + "/status",
                        HttpMethod.PATCH,
                        foundEntity,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                foundResponse.getStatusCode()
        );

        JsonNode foundPair =
                objectMapper.readTree(foundResponse.getBody());

        assertEquals(
                "FOUND",
                foundPair.get("status").asText()
        );

        assertNotNull(
                foundPair.get("matchedAt")
        );




        // =========================================================
        // 6. FOUND → CONFIRMED
        // =========================================================

        ResponseEntity<String> confirmResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/" + pairId + "/confirm",
                        null,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                confirmResponse.getStatusCode()
        );

        JsonNode confirmedPair =
                objectMapper.readTree(confirmResponse.getBody());

        assertEquals(
                "CONFIRMED",
                confirmedPair.get("status").asText()
        );




        // =========================================================
        // 7. CONFIRMED → COMPLETED
        // =========================================================

        Map<String, Long> completeRequest = Map.of(
                "completionTimeMs", 12500L
        );

        HttpEntity<Map<String, Long>> completeEntity =
                new HttpEntity<>(completeRequest, headers);

        ResponseEntity<String> completeResponse =
                restTemplate.postForEntity(
                        baseUrl() + "/api/pairs/" + pairId + "/complete",
                        completeEntity,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                completeResponse.getStatusCode()
        );

        JsonNode completedPair =
                objectMapper.readTree(completeResponse.getBody());

        assertEquals(
                "COMPLETED",
                completedPair.get("status").asText()
        );

        assertEquals(
                12500L,
                completedPair.get("completionTimeMs").asLong()
        );




        // =========================================================
        // 8. GET FINAL PAIR
        // =========================================================

        ResponseEntity<String> finalPairResponse =
                restTemplate.getForEntity(
                        baseUrl() + "/api/pairs/" + pairId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                finalPairResponse.getStatusCode()
        );

        JsonNode finalPair =
                objectMapper.readTree(finalPairResponse.getBody());

        assertEquals(
                pairId,
                finalPair.get("id").asText()
        );

        assertEquals(
                "COMPLETED",
                finalPair.get("status").asText()
        );

        assertEquals(
                12500L,
                finalPair.get("completionTimeMs").asLong()
        );


        // =========================================================
        // 9. VERIFY PLAYER A
        // =========================================================

        ResponseEntity<String> finalPlayerA =
                restTemplate.getForEntity(
                        baseUrl() + "/api/players/" + playerAId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                finalPlayerA.getStatusCode()
        );

        JsonNode finalPlayerAJson =
                objectMapper.readTree(finalPlayerA.getBody());

        assertEquals(
                "PAIRED",
                finalPlayerAJson.get("status").asText()
        );


        // =========================================================
        // 10. VERIFY PLAYER B
        // =========================================================

        ResponseEntity<String> finalPlayerB =
                restTemplate.getForEntity(
                        baseUrl() + "/api/players/" + playerBId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                finalPlayerB.getStatusCode()
        );

        JsonNode finalPlayerBJson =
                objectMapper.readTree(finalPlayerB.getBody());

        assertEquals(
                "PAIRED",
                finalPlayerBJson.get("status").asText()
        );
        // =========================================================
// 11. GET LEADERBOARD
// =========================================================

        ResponseEntity<String> leaderboardResponse =
                restTemplate.getForEntity(
                        baseUrl() + "/api/leaderboard/" + eventId,
                        String.class
                );

        assertEquals(
                HttpStatus.OK,
                leaderboardResponse.getStatusCode()
        );

        JsonNode leaderboard =
                objectMapper.readTree(
                        leaderboardResponse.getBody()
                );

        assertTrue(leaderboard.isArray());

        assertFalse(leaderboard.isEmpty());

        assertEquals(
                1,
                leaderboard.size()
        );

        JsonNode firstEntry = leaderboard.get(0);

        assertEquals(
                1,
                firstEntry.get("rank").asInt()
        );

        assertEquals(
                "Test Player A",
                firstEntry.get("playerA").asText()
        );

        assertEquals(
                "Test Player B",
                firstEntry.get("playerB").asText()
        );

        assertEquals(
                12500L,
                firstEntry.get("completionTimeMs").asLong()
        );

    }
}