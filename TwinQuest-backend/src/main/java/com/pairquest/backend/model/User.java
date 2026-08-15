package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private String id;
    private String email;
    private String name;
    private String avatar;
    private String authType; // GOOGLE, GUEST, STAFF
    private long createdAt;
    private long bestTimeMs;
    private String formattedBestTime;
    private int totalMatches;
}
