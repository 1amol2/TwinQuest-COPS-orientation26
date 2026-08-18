package com.twinquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "match_results")
public class MatchResult {

    @Id
    private String id;

    private String eventId;

    private String pairId;

    private String playerId;

    private String userEmail;

    private Long completionTimeMs;

    private Instant completedAt;
}