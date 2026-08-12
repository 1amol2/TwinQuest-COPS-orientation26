package com.twinquest.backend.repository;

import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface PairRepository extends MongoRepository<Pair, String> {

    List<Pair> findByEventId(String eventId);

    Optional<Pair> findByPlayerAIdOrPlayerBId(
            String playerAId,
            String playerBId
    );

    List<Pair> findByEventIdAndStatus(
            String eventId,
            PairStatus status
    );
}