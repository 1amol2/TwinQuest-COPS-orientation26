package com.pairquest.backend.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pairquest.backend.model.Event;
import com.pairquest.backend.model.PairMatch;
import com.pairquest.backend.model.Player;
import com.pairquest.backend.model.User;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class DataPersistenceService {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final String dataDir = "data";

    @PostConstruct
    public void init() {
        File dir = new File(dataDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
    }

    public synchronized void saveState(
            Map<String, Event> events,
            Map<String, Player> players,
            Map<String, PairMatch> pairMatches,
            Map<String, User> usersByEmail
    ) {
        try {
            objectMapper.writeValue(new File(dataDir, "events.json"), events);
            objectMapper.writeValue(new File(dataDir, "players.json"), players);
            objectMapper.writeValue(new File(dataDir, "pair_matches.json"), pairMatches);
            objectMapper.writeValue(new File(dataDir, "users.json"), usersByEmail);
        } catch (IOException e) {
            System.err.println("Failed to persist data to disk: " + e.getMessage());
        }
    }

    public synchronized void loadEvents(Map<String, Event> events) {
        File file = new File(dataDir, "events.json");
        if (file.exists()) {
            try {
                Map<String, Event> loaded = objectMapper.readValue(file, new TypeReference<ConcurrentHashMap<String, Event>>() {});
                events.putAll(loaded);
            } catch (IOException e) {
                System.err.println("Failed to load events from disk: " + e.getMessage());
            }
        }
    }

    public synchronized void loadPlayers(Map<String, Player> players) {
        File file = new File(dataDir, "players.json");
        if (file.exists()) {
            try {
                Map<String, Player> loaded = objectMapper.readValue(file, new TypeReference<ConcurrentHashMap<String, Player>>() {});
                players.putAll(loaded);
            } catch (IOException e) {
                System.err.println("Failed to load players from disk: " + e.getMessage());
            }
        }
    }

    public synchronized void loadPairMatches(Map<String, PairMatch> pairMatches) {
        File file = new File(dataDir, "pair_matches.json");
        if (file.exists()) {
            try {
                Map<String, PairMatch> loaded = objectMapper.readValue(file, new TypeReference<ConcurrentHashMap<String, PairMatch>>() {});
                pairMatches.putAll(loaded);
            } catch (IOException e) {
                System.err.println("Failed to load pair matches from disk: " + e.getMessage());
            }
        }
    }

    public synchronized void loadUsers(Map<String, User> users) {
        File file = new File(dataDir, "users.json");
        if (file.exists()) {
            try {
                Map<String, User> loaded = objectMapper.readValue(file, new TypeReference<ConcurrentHashMap<String, User>>() {});
                users.putAll(loaded);
            } catch (IOException e) {
                System.err.println("Failed to load users from disk: " + e.getMessage());
            }
        }
    }
}
