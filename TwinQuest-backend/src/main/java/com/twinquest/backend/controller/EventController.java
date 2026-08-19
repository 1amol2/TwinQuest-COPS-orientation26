package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.CreateEventRequest;
import com.twinquest.backend.dto.request.CreateOrientationEventRequest;
import com.twinquest.backend.dto.request.JoinEventRequest;
import com.twinquest.backend.dto.request.JoinPlayerRequest;
import com.twinquest.backend.dto.response.EventResponse;
import com.twinquest.backend.dto.response.PlayerResponse;
import com.twinquest.backend.model.Event;
import com.twinquest.backend.model.EventStatus;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.service.EventService;
import com.twinquest.backend.service.MatchService;
import com.twinquest.backend.service.PlayerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;
    private final PlayerService playerService;
    private final MatchService matchService;

    @GetMapping("/{eventCode}/players")
    public ResponseEntity<List<PlayerResponse>> getPlayers(
            @PathVariable String eventCode
    ) {

        Event event =
                eventService.getEventByCode(eventCode);

        List<PlayerResponse> players =
                playerService
                        .getPlayersByEvent(event.getId())
                        .stream()
                        .map(player -> PlayerResponse.builder()
                                .id(player.getId())
                                .playerId(player.getId())
                                .name(player.getName())
                                .eventId(event.getId())
                                .eventCode(eventCode)
                                .avatar(player.getAvatar())
                                .status(player.getStatus())
                                .joinedAt(player.getJoinedAt())
                                .build())
                        .toList();

        return ResponseEntity.ok(players);
    }


    @PostMapping("/{eventCode}/reset")
    public ResponseEntity<Void> resetEvent(
            @PathVariable String eventCode
    ) {

        Event event =
                eventService.getEventByCode(eventCode);

        eventService.resetEvent(event.getId());

        return ResponseEntity.ok().build();
    }
    @PostMapping("/join")
    public ResponseEntity<PlayerResponse> joinEvent(
            @Valid @RequestBody JoinEventRequest request
    ) {

        Event event =
                eventService.getEventByCode(request.getEventCode());

        Player player =
                playerService.createPlayer(
                        request.getUserId(),
                        request.getName(),
                        event.getId(),
                        request.getAvatar()
                );

        return ResponseEntity.ok(
                PlayerResponse.builder()
                        .id(player.getId())
                        .playerId(player.getId())
                        .name(player.getName())
                        .eventId(event.getId())
                        .eventCode(event.getEventCode())
                        .avatar(player.getAvatar())
                        .status(player.getStatus())
                        .joinedAt(player.getJoinedAt())
                        .build()
        );
    }
    @PostMapping("/create")
    public ResponseEntity<EventResponse> createEvent(
            @Valid @RequestBody CreateEventRequest request
    ) {

        Event event =
                eventService.createEvent(
                        request.getTitle()
                );

        return ResponseEntity.ok(
                EventResponse.from(event)
        );
    }

    @PostMapping("/{eventCode}/start")
    public ResponseEntity<Map<String, Object>> startMatchmaking(
            @PathVariable String eventCode
    ) {

        Event event =
                eventService.getEventByCode(eventCode);

        event.setStatus(EventStatus.ACTIVE);

        int pairsCreated =
                matchService.startMatchmaking(
                        event.getId()
                );

        return ResponseEntity.ok(
                Map.of(
                        "status", "SUCCESS",
                        "pairsCreated", pairsCreated
                )
        );
    }
}