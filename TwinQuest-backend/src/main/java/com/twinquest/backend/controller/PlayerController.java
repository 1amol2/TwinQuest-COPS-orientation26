package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.JoinPlayerRequest;
import com.twinquest.backend.dto.response.PlayerResponse;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.service.PlayerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/players")
@RequiredArgsConstructor
public class PlayerController {

    private final PlayerService playerService;

    @PostMapping("/join")
    public ResponseEntity<PlayerResponse> joinEvent(
            @Valid @RequestBody JoinPlayerRequest request
    ) {

        Player player = playerService.createPlayer(
                request.getName(),
                request.getEventCode(),
                request.getAvatar()
        );

        return ResponseEntity.ok(
                PlayerResponse.from(player)
        );
    }

    @GetMapping("/{playerId}")
    public ResponseEntity<PlayerResponse> getPlayer(
            @PathVariable String playerId
    ) {

        Player player =
                playerService.getPlayerById(playerId);

        return ResponseEntity.ok(
                PlayerResponse.from(player)
        );
    }
}