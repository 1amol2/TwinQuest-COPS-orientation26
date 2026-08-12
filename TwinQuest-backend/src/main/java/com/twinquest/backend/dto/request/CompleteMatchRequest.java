package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class CompleteMatchRequest {

    @NotNull(message = "Completion time is required")
    @Positive(message = "Completion time must be greater than zero")
    private Long completionTimeMs;
}