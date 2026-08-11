package com.twinquest.backend.dto.response;

import com.twinquest.backend.model.Event;
import com.twinquest.backend.model.EventStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EventResponse {

    private String id;

    private String eventCode;

    private String name;

    private EventStatus status;

    private Instant createdAt;

    public static EventResponse from(Event event) {

        return EventResponse.builder()
                .id(event.getId())
                .eventCode(event.getEventCode())
                .name(event.getName())
                .status(event.getStatus())
                .createdAt(event.getCreatedAt())
                .build();
    }
}