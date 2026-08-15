package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Event {
    private String id;
    private String code;
    private String title;
    private String status; // WAITING, MATCHMAKING, IN_PROGRESS, FINISHED
    private long createdAt;
}
