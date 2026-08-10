package com.twinquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "players")
public class Player {

    @Id
    private String id;

    private String name;

    private String eventId;

    private String deviceId;

    private PlayerStatus status;

    private Instant joinedAt;
}