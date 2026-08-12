package com.twinquest.backend.service;

import com.twinquest.backend.exception.BadRequestException;
import com.twinquest.backend.exception.ResourceNotFoundException;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.model.PlayerStatus;
import com.twinquest.backend.repository.PairRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final PairRepository pairRepository;
    private final PlayerService playerService;

    public Pair createPair(
            String eventId,
            String playerAId,
            String playerBId
    ) {

        Pair pair = Pair.builder()
                .eventId(eventId)
                .playerAId(playerAId)
                .playerBId(playerBId)
                .status(PairStatus.SEARCHING)
                .createdAt(Instant.now())
                .build();

        Pair savedPair = pairRepository.save(pair);

        updatePlayerStatus(playerAId, PlayerStatus.PAIRED);
        updatePlayerStatus(playerBId, PlayerStatus.PAIRED);

        return savedPair;
    }

    public Pair findPairByPlayerId(String playerId) {

        return pairRepository
                .findByPlayerAIdOrPlayerBId(playerId, playerId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Pair not found for player: " + playerId
                        )
                );
    }

    public List<Pair> getPairsByEvent(String eventId) {

        return pairRepository.findByEventId(eventId);
    }

    public List<Pair> getSearchingPairs(String eventId) {

        return pairRepository.findByEventIdAndStatus(
                eventId,
                PairStatus.SEARCHING
        );
    }

    public Pair updatePairStatus(
            String pairId,
            PairStatus status
    ) {

        Pair pair = getPairById(pairId);

        validateStatusTransition(
                pair.getStatus(),
                status
        );

        pair.setStatus(status);

        if (status == PairStatus.FOUND) {
            pair.setMatchedAt(Instant.now());
        }

        return pairRepository.save(pair);
    }

    public Pair confirmMatch(String pairId) {

        Pair pair = getPairById(pairId);

        validateStatusTransition(
                pair.getStatus(),
                PairStatus.CONFIRMED
        );

        pair.setStatus(PairStatus.CONFIRMED);

        return pairRepository.save(pair);
    }

    public Pair completeMatch(
            String pairId,
            Long completionTimeMs
    ) {

        Pair pair = getPairById(pairId);

        validateStatusTransition(
                pair.getStatus(),
                PairStatus.COMPLETED
        );

        pair.setStatus(PairStatus.COMPLETED);
        pair.setCompletionTimeMs(completionTimeMs);

        return pairRepository.save(pair);
    }
    private void updatePlayerStatus(
            String playerId,
            PlayerStatus status
    ) {

        Player player = playerService.getPlayerById(playerId);

        player.setStatus(status);

        playerService.updatePlayer(player);
    }
    public Pair findAndCreateMatch(String eventId) {

        Optional<Player> playerA =
                playerService.claimWaitingPlayer(eventId);

        if (playerA.isEmpty()) {
            return null;
        }


        Optional<Player> playerB =
                playerService.claimWaitingPlayer(eventId);


        if (playerB.isEmpty()) {

            // No second player yet
            // revert first player back

            Player firstPlayer = playerA.get();

            firstPlayer.setStatus(PlayerStatus.WAITING);

            playerService.updatePlayer(firstPlayer);

            return null;
        }


        Pair pair = createPair(
                eventId,
                playerA.get().getId(),
                playerB.get().getId()
        );


        // Now actual pair exists

        updatePlayerStatus(
                playerA.get().getId(),
                PlayerStatus.PAIRED
        );

        updatePlayerStatus(
                playerB.get().getId(),
                PlayerStatus.PAIRED
        );


        return pair;
    }
    public Pair getPairById(String pairId) {

        return pairRepository.findById(pairId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Pair not found: " + pairId
                        )
                );
    }
    private void validateStatusTransition(
            PairStatus current,
            PairStatus next
    ) {

        boolean valid = switch (current) {

            case CREATED ->
                    next == PairStatus.SEARCHING;

            case SEARCHING ->
                    next == PairStatus.FOUND;

            case FOUND ->
                    next == PairStatus.CONFIRMED;

            case CONFIRMED ->
                    next == PairStatus.COMPLETED;

            case COMPLETED ->
                    false;
        };

        if (!valid) {
            throw new BadRequestException(
                    "Invalid pair status transition: "
                            + current
                            + " -> "
                            + next
            );
        }
    }
}