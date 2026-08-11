package com.twinquest.backend.dto.request;

import lombok.Data;

@Data
public class JoinPlayerRequest {

    private String name;

    private String eventId;

    private String deviceId;
}