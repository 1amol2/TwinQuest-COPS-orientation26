package com.twinquest.backend.dto.response;

import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PairResponse {

    private String id;

    private String eventId;

    private String playerAId;

    private String playerBId;

    private PairStatus status;

    private Instant createdAt;

    private Instant matchedAt;

    private Long completionTimeMs;


    public static PairResponse from(Pair pair) {

        return PairResponse.builder()
                .id(pair.getId())
                .eventId(pair.getEventId())
                .playerAId(pair.getPlayerAId())
                .playerBId(pair.getPlayerBId())
                .status(pair.getStatus())
                .createdAt(pair.getCreatedAt())
                .matchedAt(pair.getMatchedAt())
                .completionTimeMs(pair.getCompletionTimeMs())
                .build();
    }
}