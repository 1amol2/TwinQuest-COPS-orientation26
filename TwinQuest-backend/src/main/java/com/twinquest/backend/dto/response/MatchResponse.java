package com.twinquest.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchResponse {

    private String id;

    private String role;

    private String partnerName;

    private String partnerAvatar;

    private String pin;

    private String status;
}