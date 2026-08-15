package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LeaderboardEntry {
    private int rank;
    private String pairId;
    private String partner1;
    private String partner2;
    private String avatar1;
    private String avatar2;
    private String timeFormatted;
    private long durationMs;
    private boolean isUserPair;
}
