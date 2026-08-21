package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.CompleteGameMatchRequest;
import com.twinquest.backend.dto.response.MatchCompletionResponse;
import com.twinquest.backend.dto.response.MatchResponse;
import com.twinquest.backend.dto.response.PairResponse;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import com.twinquest.backend.service.MatchService;
import jakarta.validation.Valid;
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
    @GetMapping("/player/{playerId}")
    public ResponseEntity<MatchResponse> getPlayerMatch(
            @PathVariable String playerId
    ) {

        return ResponseEntity.ok(
                matchService.getMatchForPlayer(playerId)
        );
    }
    @PostMapping("/complete")
    public ResponseEntity<MatchCompletionResponse> completeGameMatch(
            @Valid @RequestBody CompleteGameMatchRequest request
    ) {

        return ResponseEntity.ok(
                matchService.completeGameMatch(
                        request
                )
        );
    }


    @PostMapping("/{pairId}/confirm")
    public ResponseEntity<PairResponse> confirmPair(
            @PathVariable String pairId
    ) {

        Pair pair =
                matchService.confirmMatch(pairId);

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }
    @PostMapping("/{pairId}/searching")
    public ResponseEntity<PairResponse> pairSearching(
            @PathVariable String pairId
    ) {

        Pair pair =
                matchService.updatePairStatus(
                        pairId,
                        PairStatus.SEARCHING
                );

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }
    @PostMapping("/{pairId}/found")
    public ResponseEntity<Pair> markPairFound(
            @PathVariable String pairId
    ) {
        return ResponseEntity.ok(
                matchService.markPairFound(pairId)
        );
    }
}