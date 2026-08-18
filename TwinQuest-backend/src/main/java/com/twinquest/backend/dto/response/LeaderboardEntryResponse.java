package com.twinquest.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
public class LeaderboardEntryResponse {

    private int rank;

    private String playerA;
    private String playerB;

    private String partner1;
    private String partner2;

    private String avatar1;
    private String avatar2;

    private Long completionTimeMs;

    private String timeFormatted;

    private boolean isUserPair;
}