package com.twinquest.backend.controller;

import com.twinquest.backend.dto.response.PairResponse;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
public class MatchController {

    private final MatchService matchService;

    @PostMapping("/{eventId}")
    public ResponseEntity<PairResponse> createMatch(
            @PathVariable String eventId
    ) {

        Pair pair = matchService.findAndCreateMatch(eventId);

        if (pair == null) {
            return ResponseEntity.noContent().build();
        }

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }
}