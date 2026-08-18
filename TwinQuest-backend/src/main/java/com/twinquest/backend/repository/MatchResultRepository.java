package com.twinquest.backend.repository;

import com.twinquest.backend.model.MatchResult;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface MatchResultRepository extends MongoRepository<MatchResult, String> {

    Optional<MatchResult> findByPairId(String pairId);

    List<MatchResult> findByEventIdOrderByCompletionTimeMsAsc(String eventId);

    List<MatchResult>
    findByUserEmailOrderByCompletedAtDesc(
            String userEmail
    );
    
}