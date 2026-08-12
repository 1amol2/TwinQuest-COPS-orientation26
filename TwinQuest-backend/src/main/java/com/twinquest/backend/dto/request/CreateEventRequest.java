package com.twinquest.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateEventRequest {

    @NotBlank(message = "Event code is required")
    private String eventCode;

    @NotBlank(message = "Event name is required")
    private String name;
}