package com.twinquest.backend.repository;

import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.PlayerStatus;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface PlayerRepository extends MongoRepository<Player, String> {

    List<Player> findByEventId(String eventId);

    List<Player> findByEventIdAndStatus(
            String eventId,
            PlayerStatus status
    );
    Optional<Player> findFirstByEventIdAndStatusOrderByJoinedAtAsc(
            String eventId,
            PlayerStatus status
    );
}