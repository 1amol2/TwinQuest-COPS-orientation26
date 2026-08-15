package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PairMatch {
    private String id;
    private String eventCode;
    private String player1Id;
    private String player2Id;
    private String player1Name;
    private String player2Name;
    private String avatar1;
    private String avatar2;
    private String leftHalfImage;
    private String rightHalfImage;
    private long startTime;
    private long endTime;
    private long durationMs;
    private String formattedTime;
    private String pinP1;
    private String pinP2;
    private boolean completed;
}
