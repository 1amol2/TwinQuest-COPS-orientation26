package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.CompleteMatchRequest;
import com.twinquest.backend.dto.request.UpdatePairStatusRequest;
import com.twinquest.backend.dto.response.PairResponse;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.service.MatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pairs")
@RequiredArgsConstructor
public class PairController {

    private final MatchService matchService;


    @GetMapping("/{pairId}")
    public ResponseEntity<PairResponse> getPair(
            @PathVariable String pairId
    ) {

        Pair pair = matchService.getPairById(pairId);

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }


    @GetMapping("/player/{playerId}")
    public ResponseEntity<PairResponse> getPairByPlayer(
            @PathVariable String playerId
    ) {

        Pair pair = matchService.findPairByPlayerId(playerId);

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }


    @GetMapping("/event/{eventId}")
    public ResponseEntity<List<PairResponse>> getPairsByEvent(
            @PathVariable String eventId
    ) {

        List<PairResponse> pairs = matchService
                .getPairsByEvent(eventId)
                .stream()
                .map(PairResponse::from)
                .toList();

        return ResponseEntity.ok(pairs);
    }


    @PatchMapping("/{pairId}/status")
    public ResponseEntity<PairResponse> updateStatus(
            @PathVariable String pairId,
            @Valid @RequestBody UpdatePairStatusRequest request
    ) {

        Pair pair = matchService.updatePairStatus(
                pairId,
                request.getStatus()
        );

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }


    @PostMapping("/{pairId}/confirm")
    public ResponseEntity<PairResponse> confirmMatch(
            @PathVariable String pairId
    ) {

        Pair pair = matchService.confirmMatch(pairId);

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }


    @PostMapping("/{pairId}/complete")
    public ResponseEntity<PairResponse> completeMatch(
            @PathVariable String pairId,
            @Valid @RequestBody CompleteMatchRequest request
    ) {

        Pair pair = matchService.completeMatch(
                pairId,
                request.getCompletionTimeMs()
        );

        return ResponseEntity.ok(
                PairResponse.from(pair)
        );
    }
}