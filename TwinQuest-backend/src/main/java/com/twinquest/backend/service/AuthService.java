package com.twinquest.backend.service;

import com.twinquest.backend.dto.request.GuestAuthRequest;
import com.twinquest.backend.dto.response.GuestAuthResponse;
import com.twinquest.backend.model.User;
import com.twinquest.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class AuthService {


    private static final String GUEST_AUTH_TYPE =
            "GUEST";

    private final UserRepository userRepository;

    public GuestAuthResponse authenticateGuest(
            GuestAuthRequest request
    ) {

        String guestId = request.getGuestId();

        if (guestId == null || guestId.isBlank()) {
            throw new IllegalArgumentException("Guest ID is required");
        }

        String name = request.getName();

        if (name == null || name.isBlank()) {
            name = "Guest";
        }

        String avatar = request.getAvatar();

        if (avatar == null || avatar.isBlank()) {
            avatar = "🦊";
        }

        final String finalGuestId = guestId.trim();
        final String finalName = name.trim();
        final String finalAvatar = avatar.trim();

        String guestEmail =
                "guest-" + finalGuestId + "@pairquest.app";

        User user = userRepository
                .findByEmail(guestEmail)
                .orElseGet(() -> {

                    User newUser = User.builder()
                            .email(guestEmail)
                            .name(finalName)
                            .avatar(finalAvatar)
                            .authType(GUEST_AUTH_TYPE)
                            .createdAt(Instant.now())
                            .lastLoginAt(Instant.now())
                            .build();

                    return userRepository.save(newUser);
                });

        user.setName(finalName);
        user.setAvatar(finalAvatar);
        user.setAuthType(GUEST_AUTH_TYPE);
        user.setLastLoginAt(Instant.now());

        user = userRepository.save(user);

        return GuestAuthResponse.builder()
                .token(null)
                .userId(user.getId())
                .name(user.getName())
                .email(user.getEmail())
                .avatar(user.getAvatar())
                .authType(user.getAuthType())
                .build();
    }
}