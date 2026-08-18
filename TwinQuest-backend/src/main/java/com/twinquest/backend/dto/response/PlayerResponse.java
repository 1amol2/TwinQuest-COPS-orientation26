package com.twinquest.backend.dto.response;

import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.PlayerStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PlayerResponse {

    private String id;
    private String playerId;

    private String name;

    private String eventId;
    private String eventCode;

    private String avatar;

    private PlayerStatus status;

    private Instant joinedAt;

    public static PlayerResponse from(Player player) {

        return PlayerResponse.builder()
                .id(player.getId())
                .playerId(player.getId())
                .name(player.getName())
                .eventId(player.getEventId())
                .avatar(player.getAvatar())
                .status(player.getStatus())
                .joinedAt(player.getJoinedAt())
                .build();
    }
}