package com.twinquest.backend.service;

import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.PlayerStatus;
import com.twinquest.backend.repository.PlayerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PlayerService {

    private final PlayerRepository playerRepository;
    private final MongoTemplate mongoTemplate;

    public Player createPlayer(
            String name,
            String eventId,
            String deviceId
    ) {

        Player player = Player.builder()
                .name(name)
                .eventId(eventId)
                .deviceId(deviceId)
                .status(PlayerStatus.WAITING)
                .joinedAt(Instant.now())
                .build();

        return playerRepository.save(player);
    }

    public Player getPlayerById(String playerId) {

        return playerRepository.findById(playerId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Player not found: " + playerId
                        )
                );
    }

    public List<Player> getPlayersByEvent(String eventId) {

        return playerRepository.findByEventId(eventId);
    }

    public List<Player> getWaitingPlayers(String eventId) {

        return playerRepository.findByEventIdAndStatus(
                eventId,
                PlayerStatus.WAITING
        );
    }

    public Player updatePlayer(Player player) {

        return playerRepository.save(player);
    }

    public void deletePlayer(String playerId) {

        playerRepository.deleteById(playerId);
    }

    public Optional<Player> claimWaitingPlayer(String eventId) {

        Query query = new Query();

        query.addCriteria(
                Criteria.where("eventId").is(eventId)
                        .and("status").is(PlayerStatus.WAITING)
        );

        query.with(
                Sort.by(
                        Sort.Direction.ASC,
                        "joinedAt"
                )
        );

        Update update = new Update()
                .set("status", PlayerStatus.SEARCHING);

        FindAndModifyOptions options =
                FindAndModifyOptions.options()
                        .returnNew(true);

        Player player = mongoTemplate.findAndModify(
                query,
                update,
                options,
                Player.class
        );

        return Optional.ofNullable(player);
    }
}