package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Player {
    private String id;
    private String name;
    private String eventCode;
    private String avatar;
    private String pairId;
    private String role; // LEFT or RIGHT
    private String imageHalfData; // Base64 / URL of assigned half
    private long createdAt;
}
