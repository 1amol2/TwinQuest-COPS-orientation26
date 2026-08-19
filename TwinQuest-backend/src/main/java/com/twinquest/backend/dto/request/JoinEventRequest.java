package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinEventRequest {

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotBlank(message = "Player name is required")
    private String name;

    @NotBlank(message = "Event code is required")
    private String eventCode;

    @NotBlank(message = "Avatar is required")
    private String avatar;
}