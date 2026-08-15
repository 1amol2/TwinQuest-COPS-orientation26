package com.pairquest.backend.service;

import com.pairquest.backend.model.Event;
import com.pairquest.backend.model.LeaderboardEntry;
import com.pairquest.backend.model.PairMatch;
import com.pairquest.backend.model.Player;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class GameService {

    private final Map<String, Event> events = new ConcurrentHashMap<>();
    private final Map<String, Player> players = new ConcurrentHashMap<>();
    private final Map<String, PairMatch> pairMatches = new ConcurrentHashMap<>();
    private final SimpMessagingTemplate messagingTemplate;
    private final ImageService imageService;
    private final AuthService authService;
    private final DataPersistenceService persistenceService;

    public GameService(
            SimpMessagingTemplate messagingTemplate,
            ImageService imageService,
            AuthService authService,
            DataPersistenceService persistenceService
    ) {
        this.messagingTemplate = messagingTemplate;
        this.imageService = imageService;
        this.authService = authService;
        this.persistenceService = persistenceService;
    }

    @PostConstruct
    public void init() {
        persistenceService.loadEvents(events);
        persistenceService.loadPlayers(players);
        persistenceService.loadPairMatches(pairMatches);

        if (!events.containsKey("ORIENT26")) {
            Event defaultEvent = Event.builder()
                    .id("EVT_101")
                    .code("ORIENT26")
                    .title("COPS Freshers Orientation 2026")
                    .status("WAITING")
                    .createdAt(System.currentTimeMillis())
                    .build();
            events.put(defaultEvent.getCode(), defaultEvent);
            saveState();
        }
    }

    public synchronized Event createEvent(String title) {
        String code = "ORIENT" + (10 + new Random().nextInt(90));
        Event event = Event.builder()
                .id("EVT_" + UUID.randomUUID().toString().substring(0, 8))
                .code(code)
                .title(title != null && !title.isEmpty() ? title : "Orientation Event")
                .status("WAITING")
                .createdAt(System.currentTimeMillis())
                .build();
        events.put(code, event);
        saveState();
        return event;
    }

    public synchronized Player joinEvent(String name, String eventCode, String avatar) {
        String playerCode = eventCode != null && !eventCode.isEmpty() ? eventCode.toUpperCase() : "ORIENT26";
        if (!events.containsKey(playerCode)) {
            createEvent("Freshers Orientation");
        }

        String playerId = "PLR_" + UUID.randomUUID().toString().substring(0, 8);
        Player player = Player.builder()
                .id(playerId)
                .name(name != null ? name : "Volunteer")
                .eventCode(playerCode)
                .avatar(avatar != null ? avatar : "⚡")
                .createdAt(System.currentTimeMillis())
                .build();

        players.put(playerId, player);
        saveState();

        List<Player> unpaired = getUnpairedPlayers(playerCode);

        // Broadcast player joined safely
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("type", "PLAYER_JOINED");
            payload.put("player", player);
            payload.put("totalPlayers", getPlayers(playerCode).size());
            payload.put("unpairedCount", unpaired.size());
            messagingTemplate.convertAndSend("/topic/event/" + playerCode, payload);
        } catch (Exception ignored) {}

        // AUTO MATCHMAKING: When an even number of players is present (2, 4, 6...), automatically assign pairs!
        if (unpaired.size() >= 2 && unpaired.size() % 2 == 0) {
            startMatchmakingForPlayers(playerCode, unpaired);
        }

        return player;
    }

    public List<Player> getPlayers(String eventCode) {
        String code = eventCode.toUpperCase();
        return players.values().stream()
                .filter(p -> code.equalsIgnoreCase(p.getEventCode()))
                .sorted(Comparator.comparingLong(Player::getCreatedAt))
                .collect(Collectors.toList());
    }

    public List<Player> getUnpairedPlayers(String eventCode) {
        String code = eventCode.toUpperCase();
        return players.values().stream()
                .filter(p -> code.equalsIgnoreCase(p.getEventCode()) && p.getPairId() == null)
                .sorted(Comparator.comparingLong(Player::getCreatedAt))
                .collect(Collectors.toList());
    }

    public List<PairMatch> startMatchmaking(String eventCode) {
        return startMatchmakingForPlayers(eventCode, getUnpairedPlayers(eventCode));
    }

    public synchronized List<PairMatch> startMatchmakingForPlayers(String eventCode, List<Player> joinedPlayers) {
        String code = eventCode.toUpperCase();
        if (joinedPlayers == null || joinedPlayers.size() < 2) {
            return new ArrayList<>();
        }

        Collections.shuffle(joinedPlayers);

        List<PairMatch> createdMatches = new ArrayList<>();
        long now = System.currentTimeMillis();

        for (int i = 0; i < joinedPlayers.size() - 1; i += 2) {
            Player p1 = joinedPlayers.get(i);
            Player p2 = joinedPlayers.get(i + 1);

            String pairId = "PAIR_" + (pairMatches.size() + 1);
            String[] halves = imageService.getOrGenerateHalves(pairId);

            p1.setPairId(pairId);
            p1.setRole("LEFT");
            p1.setImageHalfData(halves[0]);

            p2.setPairId(pairId);
            p2.setRole("RIGHT");
            p2.setImageHalfData(halves[1]);

            String pinForP1 = String.format("%04d", new Random().nextInt(10000));
            String pinForP2 = String.format("%04d", new Random().nextInt(10000));

            PairMatch match = PairMatch.builder()
                    .id(pairId)
                    .eventCode(code)
                    .player1Id(p1.getId())
                    .player2Id(p2.getId())
                    .player1Name(p1.getName())
                    .player2Name(p2.getName())
                    .avatar1(p1.getAvatar())
                    .avatar2(p2.getAvatar())
                    .leftHalfImage(halves[0])
                    .rightHalfImage(halves[1])
                    .startTime(now) // SERVER-SIDE START TIMER
                    .pinP1(pinForP1)
                    .pinP2(pinForP2)
                    .completed(false)
                    .build();

            pairMatches.put(pairId, match);
            createdMatches.add(match);

            // Send secret assignment to individual players via WebSocket
            try {
                Map<String, Object> p1Payload = new HashMap<>();
                p1Payload.put("type", "PAIR_ASSIGNED");
                p1Payload.put("pairId", pairId);
                p1Payload.put("pin", pinForP1);
                p1Payload.put("role", "LEFT");
                p1Payload.put("imageHalfData", halves[0]);
                p1Payload.put("partnerHiddenName", "Mystery Partner #" + match.getId());
                messagingTemplate.convertAndSend("/topic/player/" + p1.getId(), p1Payload);

                Map<String, Object> p2Payload = new HashMap<>();
                p2Payload.put("type", "PAIR_ASSIGNED");
                p2Payload.put("pairId", pairId);
                p2Payload.put("pin", pinForP2);
                p2Payload.put("role", "RIGHT");
                p2Payload.put("imageHalfData", halves[1]);
                p2Payload.put("partnerHiddenName", "Mystery Partner #" + match.getId());
                messagingTemplate.convertAndSend("/topic/player/" + p2.getId(), p2Payload);
            } catch (Exception ignored) {}
        }

        if (events.containsKey(code)) {
            events.get(code).setStatus("IN_PROGRESS");
        }

        saveState();

        // Broadcast game started safely to event topic
        try {
            Map<String, Object> startPayload = new HashMap<>();
            startPayload.put("type", "MATCHMAKING_STARTED");
            startPayload.put("pairsCount", createdMatches.size());
            messagingTemplate.convertAndSend("/topic/event/" + code, startPayload);
        } catch (Exception ignored) {}

        return createdMatches;
    }

    public Map<String, Object> getPlayerMatch(String playerId) {
        Player player = players.get(playerId);
        if (player != null && player.getPairId() != null) {
            PairMatch match = pairMatches.get(player.getPairId());
            if (match != null) {
                boolean isP1 = player.getId().equals(match.getPlayer1Id());
                String partnerName = isP1 ? match.getPlayer2Name() : match.getPlayer1Name();
                String partnerAvatar = isP1 ? match.getAvatar2() : match.getAvatar1();
                String ownPin = isP1 ? match.getPinP1() : match.getPinP2();

                Map<String, Object> res = new HashMap<>();
                res.put("id", match.getId());
                res.put("pin", ownPin != null ? ownPin : "1042");
                res.put("role", player.getRole() != null ? player.getRole() : "LEFT");
                res.put("imageHalfData", player.getImageHalfData() != null ? player.getImageHalfData() : "");
                res.put("partnerName", partnerName != null && !partnerName.isEmpty() ? partnerName : "Orientation Partner");
                res.put("partnerAvatar", partnerAvatar != null && !partnerAvatar.isEmpty() ? partnerAvatar : "🌟");
                return res;
            }
        }
        return null;
    }

    public synchronized PairMatch completeMatch(String pairId, String playerId, String pin, long clientDurationMs, String userEmail) {
        if (pairId == null || pairId.trim().isEmpty()) {
            return null;
        }

        PairMatch match = pairMatches.get(pairId);
        long now = System.currentTimeMillis();

        if (match == null) {
            // Reject fake or non-existent pairId immediately!
            return null;
        }

        // Validate player membership if provided
        if (playerId != null && !playerId.isEmpty() &&
            !playerId.equals(match.getPlayer1Id()) && !playerId.equals(match.getPlayer2Id())) {
            return null;
        }

        // VERIFY PARTNER PIN: player calling completeMatch MUST supply the OTHER player's PIN
        boolean isP1 = playerId != null && playerId.equals(match.getPlayer1Id());
        String expectedPin = isP1 ? match.getPinP2() : match.getPinP1();
        if (expectedPin == null) {
            expectedPin = match.getPinP1() != null ? match.getPinP1() : match.getPinP2();
        }

        if (expectedPin != null && !expectedPin.trim().isEmpty()) {
            if (pin == null || !pin.trim().equals(expectedPin.trim())) {
                // Wrong or missing partner PIN! Rejection!
                return null;
            }
        }

        // SERVER-CALCULATED DURATION PREVENTS CLIENT SPOOFING
        long serverDurationMs = match.getStartTime() > 0 ? (now - match.getStartTime()) : clientDurationMs;
        if (serverDurationMs < 1000) {
            serverDurationMs = Math.max(1200, clientDurationMs);
        }

        match.setEndTime(now);
        match.setDurationMs(serverDurationMs);
        match.setFormattedTime(formatDuration(serverDurationMs));
        match.setCompleted(true);

        if (userEmail != null && !userEmail.isEmpty()) {
            authService.recordMatchForUser(userEmail, match);
        }

        saveState();

        // Broadcast match completed & partner reveal safely
        try {
            Map<String, Object> confirmPayload = new HashMap<>();
            confirmPayload.put("type", "MATCH_CONFIRMED");
            confirmPayload.put("match", match);
            confirmPayload.put("leaderboard", getLeaderboard(match.getEventCode()));
            messagingTemplate.convertAndSend("/topic/event/" + match.getEventCode(), confirmPayload);
        } catch (Exception ignored) {}

        return match;
    }

    public List<LeaderboardEntry> getLeaderboard(String eventCode) {
        List<PairMatch> matches = pairMatches.values().stream()
                .filter(PairMatch::isCompleted)
                .sorted(Comparator.comparingLong(PairMatch::getDurationMs))
                .collect(Collectors.toList());

        List<LeaderboardEntry> leaderboard = new ArrayList<>();
        int rank = 1;
        for (PairMatch m : matches) {
            leaderboard.add(LeaderboardEntry.builder()
                    .rank(rank++)
                    .pairId(m.getId())
                    .partner1(m.getPlayer1Name())
                    .partner2(m.getPlayer2Name())
                    .avatar1(m.getAvatar1())
                    .avatar2(m.getAvatar2())
                    .timeFormatted(m.getFormattedTime())
                    .durationMs(m.getDurationMs())
                    .build());
        }
        return leaderboard;
    }

    public synchronized void resetEvent(String eventCode) {
        String code = eventCode.toUpperCase();
        pairMatches.values().removeIf(m -> code.equalsIgnoreCase(m.getEventCode()));
        players.values().removeIf(p -> code.equalsIgnoreCase(p.getEventCode()));
        if (events.containsKey(code)) {
            events.get(code).setStatus("WAITING");
        }
        saveState();
    }

    private String formatDuration(long millis) {
        long minutes = (millis / 1000) / 60;
        long seconds = (millis / 1000) % 60;
        long hundredths = (millis % 1000) / 10;
        return String.format("%02d:%02d.%02d", minutes, seconds, hundredths);
    }

    private void saveState() {
        persistenceService.saveState(events, players, pairMatches, authService.getUsersByEmailMap());
    }
}
