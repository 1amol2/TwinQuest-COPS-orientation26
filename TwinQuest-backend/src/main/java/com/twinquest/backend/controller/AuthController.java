package com.twinquest.backend.controller;

import com.twinquest.backend.model.Player;
import com.twinquest.backend.service.PlayerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final PlayerService playerService;

    @PostMapping("/guest")
    public ResponseEntity<GuestLoginResponse> guestLogin(
            @RequestBody GuestLoginRequest request
    ) {

        if (request.name() == null ||
                request.name().isBlank()) {

            return ResponseEntity.badRequest().build();
        }

        if (request.eventId() == null ||
                request.eventId().isBlank()) {

            return ResponseEntity.badRequest().build();
        }

        Player player =
                playerService.createPlayer(
                        request.name().trim(),
                        request.eventId().trim(),
                        request.avatar()
                );

        GuestLoginResponse response =
                new GuestLoginResponse(
                        player.getId(),
                        player.getName(),
                        player.getAvatar(),
                        player.getEventId(),
                        player.getStatus().name()
                );

        return ResponseEntity.ok(response);
    }

    public record GuestLoginRequest(
            String name,
            String avatar,
            String eventId
    ) {}

    public record GuestLoginResponse(
            String playerId,
            String name,
            String avatar,
            String eventId,
            String status
    ) {}
}