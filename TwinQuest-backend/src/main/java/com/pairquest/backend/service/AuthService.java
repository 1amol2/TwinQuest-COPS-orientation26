package com.pairquest.backend.service;

import com.pairquest.backend.model.AuthRequest;
import com.pairquest.backend.model.AuthResponse;
import com.pairquest.backend.model.PairMatch;
import com.pairquest.backend.model.User;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    private final Map<String, User> usersByEmail = new ConcurrentHashMap<>();
    private final Map<String, List<PairMatch>> userMatches = new ConcurrentHashMap<>();
    private final DataPersistenceService persistenceService;
    private final String secretKey;

    public AuthService(DataPersistenceService persistenceService) {
        this.persistenceService = persistenceService;
        String envKey = System.getenv("JWT_SECRET");
        this.secretKey = (envKey != null && !envKey.trim().isEmpty())
                ? envKey
                : "PairQuest_COPS_IITBHU_Secure_Key_2026";
    }

    @PostConstruct
    public void init() {
        persistenceService.loadUsers(usersByEmail);
    }

    public AuthResponse authenticateGoogle(AuthRequest request) {
        String email = request.getEmail() != null && !request.getEmail().isEmpty()
                ? request.getEmail().toLowerCase()
                : "user" + System.currentTimeMillis() + "@itbhu.ac.in";
        String name = request.getName() != null && !request.getName().isEmpty()
                ? request.getName()
                : "Fresher Student";
        String avatar = request.getAvatar() != null ? request.getAvatar() : "⚡";

        User user = usersByEmail.computeIfAbsent(email, e -> User.builder()
                .id("USR_" + UUID.randomUUID().toString().substring(0, 8))
                .email(e)
                .name(name)
                .avatar(avatar)
                .authType("GOOGLE")
                .createdAt(System.currentTimeMillis())
                .bestTimeMs(0)
                .formattedBestTime("N/A")
                .totalMatches(0)
                .build());

        user.setName(name);
        user.setAvatar(avatar);

        String token = generateSecureToken(user.getEmail(), user.getAuthType());

        return AuthResponse.builder()
                .token(token)
                .user(user)
                .message("Google authentication successful")
                .build();
    }

    public AuthResponse authenticateGuest(AuthRequest request) {
        String guestId = "GUEST_" + UUID.randomUUID().toString().substring(0, 6);
        User guestUser = User.builder()
                .id(guestId)
                .email("guest@pairquest.app")
                .name(request.getName() != null ? request.getName() : "Guest Freshers")
                .avatar(request.getAvatar() != null ? request.getAvatar() : "🦊")
                .authType("GUEST")
                .createdAt(System.currentTimeMillis())
                .bestTimeMs(0)
                .formattedBestTime("N/A")
                .totalMatches(0)
                .build();

        String token = generateSecureToken(guestUser.getEmail(), "GUEST");

        return AuthResponse.builder()
                .token(token)
                .user(guestUser)
                .message("Guest session created")
                .build();
    }

    public boolean validateToken(String token, String expectedEmail) {
        if (token == null || !token.startsWith("PQ_TOKEN_")) return false;
        try {
            String[] parts = token.substring(9).split(":");
            if (parts.length < 3) return false;
            String email = parts[0];
            long timestamp = Long.parseLong(parts[1]);
            String signature = parts[2];

            // 7-day token expiration check
            if (System.currentTimeMillis() - timestamp > 7L * 24 * 3600 * 1000) {
                return false;
            }

            String expectedSignature = hash(email + ":" + timestamp + ":" + secretKey);
            return signature.equals(expectedSignature) && (expectedEmail == null || expectedEmail.equalsIgnoreCase(email));
        } catch (Exception e) {
            return false;
        }
    }

    public User getUserByEmail(String email) {
        if (email == null) return null;
        return usersByEmail.get(email.toLowerCase());
    }

    public Map<String, User> getUsersByEmailMap() {
        return usersByEmail;
    }

    public void recordMatchForUser(String email, PairMatch match) {
        if (email == null || email.equalsIgnoreCase("guest@pairquest.app")) {
            return;
        }

        String key = email.toLowerCase();
        User user = usersByEmail.get(key);
        if (user != null) {
            user.setTotalMatches(user.getTotalMatches() + 1);
            if (user.getBestTimeMs() == 0 || match.getDurationMs() < user.getBestTimeMs()) {
                user.setBestTimeMs(match.getDurationMs());
                user.setFormattedBestTime(match.getFormattedTime());
            }
        }

        userMatches.computeIfAbsent(key, k -> new ArrayList<>()).add(0, match);
    }

    public List<PairMatch> getUserMatches(String email) {
        if (email == null) return new ArrayList<>();
        return userMatches.getOrDefault(email.toLowerCase(), new ArrayList<>());
    }

    private String generateSecureToken(String email, String role) {
        long timestamp = System.currentTimeMillis();
        String payload = email + ":" + timestamp + ":" + secretKey;
        String signature = hash(payload);
        return "PQ_TOKEN_" + email + ":" + timestamp + ":" + signature;
    }

    private String hash(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString().substring(0, 16);
        } catch (NoSuchAlgorithmException e) {
            return Integer.toHexString(input.hashCode());
        }
    }
}
