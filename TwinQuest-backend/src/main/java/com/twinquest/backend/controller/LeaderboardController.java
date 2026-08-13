package com.twinquest.backend.controller;

import com.twinquest.backend.dto.response.LeaderboardEntryResponse;
import com.twinquest.backend.service.LeaderboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leaderboard")
@RequiredArgsConstructor
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    @GetMapping("/{eventId}")
    public ResponseEntity<List<LeaderboardEntryResponse>> getLeaderboard(
            @PathVariable String eventId
    ) {

        return ResponseEntity.ok(
                leaderboardService.getLeaderboard(eventId)
        );
    }
}