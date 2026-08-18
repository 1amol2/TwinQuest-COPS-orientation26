package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreatePairRequest {

    @NotBlank
    private String eventId;

    @NotBlank
    private String playerAId;

    @NotBlank
    private String playerBId;
}