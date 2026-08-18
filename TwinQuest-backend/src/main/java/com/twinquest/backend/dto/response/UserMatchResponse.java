package com.twinquest.backend.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserMatchResponse {

    private String partnerName;

    private String avatar;

    private Long durationMs;

    private String timeFormatted;

    private String date;
}