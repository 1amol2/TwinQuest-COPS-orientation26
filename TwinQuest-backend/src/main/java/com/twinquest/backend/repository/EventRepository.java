package com.twinquest.backend.repository;

import com.twinquest.backend.model.Event;
import com.twinquest.backend.model.EventStatus;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface EventRepository extends MongoRepository<Event, String> {

    Optional<Event> findByEventCode(String eventCode);

    boolean existsByEventCode(String eventCode);

    Optional<Event> findByEventCodeAndStatus(
            String eventCode,
            EventStatus status
    );
}