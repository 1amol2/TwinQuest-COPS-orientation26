package com.twinquest.backend.service;

import com.twinquest.backend.dto.response.LeaderboardEntryResponse;
import com.twinquest.backend.exception.BadRequestException;
import com.twinquest.backend.exception.ResourceNotFoundException;
import com.twinquest.backend.model.*;
import com.twinquest.backend.repository.EventRepository;
import com.twinquest.backend.repository.PairRepository;
import com.twinquest.backend.repository.PlayerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final PlayerRepository playerRepository;
    private final PairRepository pairRepository;
    public Event createEvent(String title) {

        String eventCode = generateEventCode();

        Event event = Event.builder()
                .eventCode(eventCode)
                .name(title)
                .status(EventStatus.WAITING)
                .createdAt(Instant.now())
                .build();

        return eventRepository.save(event);
    }
    private String generateEventCode() {

        String code;

        do {
            code = UUID.randomUUID()
                    .toString()
                    .substring(0, 6)
                    .toUpperCase();

        } while (
                eventRepository
                        .findByEventCode(code)
                        .isPresent()
        );

        return code;
    }
    public Event startEvent(String eventId) {

        Event event = getEventById(eventId);

        event.setStatus(EventStatus.ACTIVE);

        return eventRepository.save(event);
    }
    public void resetEvent(String eventId) {

        Event event = getEventById(eventId);

        List<Pair> pairs =
                pairRepository.findByEventId(eventId);

        pairRepository.deleteAll(pairs);

        List<Player> players =
                playerRepository.findByEventId(eventId);

        for (Player player : players) {

            player.setStatus(
                    PlayerStatus.WAITING
            );

            playerRepository.save(player);
        }

        event.setStatus(
                EventStatus.WAITING
        );

        eventRepository.save(event);
    }
    public Event getEventById(String eventId) {

        return eventRepository.findById(eventId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Event not found: " + eventId
                        )
                );
    }

    public Event getEventByCode(String eventCode) {

        return eventRepository.findByEventCode(eventCode)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
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
                        new ResourceNotFoundException(
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
    public Event createOrientationEvent(String title) {

        String eventCode = "ORIENT26";

        Event existing =
                eventRepository
                        .findByEventCode(eventCode)
                        .orElse(null);

        if (existing != null) {
            return existing;
        }

        Event event = Event.builder()
                .eventCode(eventCode)
                .name(title)
                .status(EventStatus.WAITING)
                .createdAt(Instant.now())
                .build();

        return eventRepository.save(event);
    }

}