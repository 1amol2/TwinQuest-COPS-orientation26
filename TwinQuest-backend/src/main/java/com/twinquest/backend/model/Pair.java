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
@Document(collection = "pairs")
public class Pair {

    @Id
    private String id;

    private String eventId;

    private String playerAId;

    private String playerBId;

    private PairStatus status;

    private Instant createdAt;

    private Instant matchedAt;

    private Long completionTimeMs;
}