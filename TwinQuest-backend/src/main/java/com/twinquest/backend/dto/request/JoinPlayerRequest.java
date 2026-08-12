package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinPlayerRequest {

    @NotBlank(message = "Player name is required")
    private String name;

    @NotBlank(message = "Event ID is required")
    private String eventId;

    @NotBlank(message = "Device ID is required")
    private String deviceId;
}