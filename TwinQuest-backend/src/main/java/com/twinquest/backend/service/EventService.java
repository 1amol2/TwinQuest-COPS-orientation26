package com.twinquest.backend.service;

import com.twinquest.backend.model.Event;
import com.twinquest.backend.model.EventStatus;
import com.twinquest.backend.repository.EventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;

    public Event createEvent(String eventCode, String name) {

        if (eventRepository.existsByEventCode(eventCode)) {
            throw new RuntimeException(
                    "Event code already exists: " + eventCode
            );
        }

        Event event = Event.builder()
                .eventCode(eventCode)
                .name(name)
                .status(EventStatus.ACTIVE)
                .createdAt(Instant.now())
                .build();

        return eventRepository.save(event);
    }

    public Event getEventById(String eventId) {

        return eventRepository.findById(eventId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Event not found: " + eventId
                        )
                );
    }

    public Event getEventByCode(String eventCode) {

        return eventRepository.findByEventCode(eventCode)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Event not found: " + eventCode
                        )
                );
    }

    public Event getActiveEvent(String eventCode) {

        return eventRepository
                .findByEventCodeAndStatus(
                        eventCode,
                        EventStatus.ACTIVE
                )
                .orElseThrow(() ->
                        new RuntimeException(
                                "Active event not found: " + eventCode
                        )
                );
    }

    public Event updateEvent(Event event) {

        return eventRepository.save(event);
    }

    public void deleteEvent(String eventId) {

        eventRepository.deleteById(eventId);
    }

}