package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CompleteGameMatchRequest {

    @NotBlank
    private String pairId;

    @NotBlank
    private String playerId;

    @NotBlank
    private String pin;

    @NotNull
    @Positive
    private Long durationMs;

    private String userEmail;
}