package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JoinPlayerRequest {

    @NotBlank(message = "User ID is required")
    private String userId;

    @NotBlank(message = "Player name is required")
    private String name;

    @NotBlank(message = "Event id is required")
    private String eventId;

    @NotBlank(message = "Avatar is required")
    private String avatar;
}