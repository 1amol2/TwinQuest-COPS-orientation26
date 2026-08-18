package com.twinquest.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GuestAuthResponse {

    private String token;

    private String userId;

    private String name;

    private String email;

    private String avatar;

    private String authType;
}