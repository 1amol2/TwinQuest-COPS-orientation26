package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateOrientationEventRequest {

    @NotBlank(message = "Event title is required")
    private String title;
}