package com.twinquest.backend.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserProfileResponse {

    private String email;

    private String name;

    private String avatar;

    private String authType;

    private int totalMatches;

    private Long bestTimeMs;

    private String formattedBestTime;

    private int rank;
}