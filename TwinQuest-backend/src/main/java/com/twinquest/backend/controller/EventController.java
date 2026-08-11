package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.CreateEventRequest;
import com.twinquest.backend.dto.response.EventResponse;
import com.twinquest.backend.model.Event;
import com.twinquest.backend.service.EventService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @PostMapping
    public ResponseEntity<Event> createEvent(
            @RequestBody CreateEventRequest request
            ) {

        Event event = eventService.createEvent(request.getEventCode(), request.getName());

        return ResponseEntity.ok(event);
    }
    @GetMapping("/code/{eventCode}")
    public ResponseEntity<EventResponse> getEventByCode(
            @PathVariable String eventCode
    ) {
        Event event = eventService.getEventByCode(eventCode);

        return ResponseEntity.ok(
                EventResponse.from(event)
        );
    }
    @GetMapping("/{eventId}")
    public ResponseEntity<EventResponse> getEventById(
            @PathVariable String eventId
    ) {
        Event event = eventService.getEventById(eventId);

        return ResponseEntity.ok(
                EventResponse.from(event)
        );
    }
}