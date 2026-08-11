package com.twinquest.backend.dto.request;

import lombok.Data;

@Data
public class CreateEventRequest {
    private String eventCode;
    private String name;
}
