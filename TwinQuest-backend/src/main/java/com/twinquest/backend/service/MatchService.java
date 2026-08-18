package com.twinquest.backend.service;

import com.twinquest.backend.dto.request.CompleteGameMatchRequest;
import com.twinquest.backend.dto.response.MatchCompletionResponse;
import com.twinquest.backend.dto.response.MatchResponse;
import com.twinquest.backend.exception.BadRequestException;
import com.twinquest.backend.exception.ResourceNotFoundException;
import com.twinquest.backend.model.*;
import com.twinquest.backend.repository.GameImageRepository;
import com.twinquest.backend.repository.MatchResultRepository;
import com.twinquest.backend.repository.PairRepository;
import com.twinquest.backend.websocket.WebSocketEvent;
import com.twinquest.backend.websocket.WebSocketService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final PairRepository pairRepository;
    private final PlayerService playerService;
    private final WebSocketService webSocketService;
    private final ImageService imageService;
    private final GameImageRepository gameImageRepository;
    private final MatchResultRepository matchResultRepository;
    public Pair createPair(
            String eventId,
            String playerAId,
            String playerBId
    ) {

        Pair pair = Pair.builder()
                .eventId(eventId)
                .playerAId(playerAId)
                .playerBId(playerBId)
                .playerAPin(generatePin())
                .playerBPin(generatePin())
                .playerAVerified(false)
                .playerBVerified(false)
                .status(PairStatus.CREATED)
                .createdAt(Instant.now())
                .build();
        Pair savedPair =
                pairRepository.save(pair);

        GameImage gameImage =
                imageService.generatePuzzleImage(
                        savedPair.getId()
                );

        savedPair.setGameImageId(
                gameImage.getId()
        );

        savedPair.setMatchedAt(
                Instant.now()
        );

        savedPair.setGameStartedAt(
                Instant.now()
        );
        savedPair.setStatus(
                PairStatus.CREATED
        );
        savedPair =
                pairRepository.save(savedPair);

        updatePlayerStatus(playerAId, PlayerStatus.PAIRED);
        updatePlayerStatus(playerBId, PlayerStatus.PAIRED);

        notifyPlayers(
                savedPair,
                "PAIR_CREATED"
        );

        return savedPair;
    }
    private void notifyPlayers(
            Pair pair,
            String eventType
    ) {

        WebSocketEvent playerAEvent =
                WebSocketEvent.builder()
                        .type(eventType)
                        .eventId(pair.getEventId())
                        .pairId(pair.getId())
                        .playerId(pair.getPlayerAId())
                        .opponentId(pair.getPlayerBId())
                        .status(pair.getStatus().name())
                        .completionTimeMs(
                                pair.getCompletionTimeMs()
                        )
                        .build();

        WebSocketEvent playerBEvent =
                WebSocketEvent.builder()
                        .type(eventType)
                        .eventId(pair.getEventId())
                        .pairId(pair.getId())
                        .playerId(pair.getPlayerBId())
                        .opponentId(pair.getPlayerAId())
                        .status(pair.getStatus().name())
                        .completionTimeMs(
                                pair.getCompletionTimeMs()
                        )
                        .build();

        webSocketService.sendToPlayer(
                pair.getPlayerAId(),
                playerAEvent
        );

        webSocketService.sendToPlayer(
                pair.getPlayerBId(),
                playerBEvent
        );
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

        Pair savedPair = pairRepository.save(pair);

        String eventType = switch (status) {
            case CREATED -> "PAIR_CREATED";
            case SEARCHING -> "PAIR_SEARCHING";
            case FOUND -> "PAIR_FOUND";
            case CONFIRMED -> "PAIR_CONFIRMED";
            case COMPLETED -> "PAIR_COMPLETED";
        };

        notifyPlayers(
                savedPair,
                eventType
        );

        return savedPair;
    }
    public Pair confirmMatch(String pairId) {

        Pair pair = getPairById(pairId);

        validateStatusTransition(
                pair.getStatus(),
                PairStatus.CONFIRMED
        );

        pair.setStatus(PairStatus.CONFIRMED);

        Pair savedPair = pairRepository.save(pair);

        notifyPlayers(
                savedPair,
                "PAIR_CONFIRMED"
        );

        return savedPair;
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

        Pair savedPair = pairRepository.save(pair);

        notifyPlayers(
                savedPair,
                "PAIR_COMPLETED"
        );

        return savedPair;
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

        pair = updatePairStatus(
                pair.getId(),
                PairStatus.SEARCHING
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
    public int startMatchmaking(String eventId) {

        int pairsCreated = 0;

        while (true) {

            Pair pair = findAndCreateMatch(eventId);

            if (pair == null) {
                break;
            }

            pairsCreated++;
        }

        return pairsCreated;
    }
    private String generatePin() {

        SecureRandom random =
                new SecureRandom();

        return String.format(
                "%04d",
                random.nextInt(10000)
        );
    }
    public MatchResponse getMatchForPlayer(
            String playerId
    ) {

        Pair pair =
                pairRepository
                        .findByPlayerAIdOrPlayerBId(
                                playerId,
                                playerId
                        )
                        .orElse(null);

        if (pair == null) {
            throw new ResourceNotFoundException(
                    "Match not found for player: " + playerId
            );
        }

        boolean isPlayerA =
                playerId.equals(
                        pair.getPlayerAId()
                );

        String partnerId =
                isPlayerA
                        ? pair.getPlayerBId()
                        : pair.getPlayerAId();

        Player partner =
                playerService.getPlayerById(
                        partnerId
                );

        return MatchResponse.builder()
                .id(pair.getId())

                .role(
                        isPlayerA
                                ? "LEFT"
                                : "RIGHT"
                )

                .partnerName(
                        partner.getName()
                )

                .partnerAvatar(
                        partner.getAvatar()
                )

                // IMPORTANT:
                // This is the player's own PIN.
                // They show this to their partner.
                .pin(
                        isPlayerA
                                ? pair.getPlayerAPin()
                                : pair.getPlayerBPin()
                )

                .status(
                        pair.getStatus().name()
                )

                .build();
    }
    public MatchCompletionResponse completeGameMatch(
            CompleteGameMatchRequest request
    ) {

        Pair pair =
                pairRepository
                        .findById(request.getPairId())
                        .orElse(null);

        if (pair == null) {
            return MatchCompletionResponse.failure(
                    "Pair not found"
            );
        }

        boolean isPlayerA =
                request.getPlayerId()
                        .equals(pair.getPlayerAId());

        boolean isPlayerB =
                request.getPlayerId()
                        .equals(pair.getPlayerBId());

        /*
         * The player submitting the PIN must actually
         * belong to this pair.
         */
        if (!isPlayerA && !isPlayerB) {
            return MatchCompletionResponse.failure(
                    "Player does not belong to this pair"
            );
        }

        /*
         * PIN verification is allowed only after
         * the pair has been found.
         */
        if (pair.getStatus() != PairStatus.FOUND &&
                pair.getStatus() != PairStatus.CONFIRMED) {

            return MatchCompletionResponse.failure(
                    "Pair is not ready for completion"
            );
        }

        /*
         * Each player must enter the OTHER player's PIN.
         *
         * Player A -> must enter Player B's PIN
         * Player B -> must enter Player A's PIN
         */
        String expectedPin =
                isPlayerA
                        ? pair.getPlayerBPin()
                        : pair.getPlayerAPin();

        if (!expectedPin.equals(request.getPin())) {

            return MatchCompletionResponse.failure(
                    "Invalid partner PIN"
            );
        }

        /*
         * Mark the player who just entered the correct
         * partner PIN as verified.
         */
        if (isPlayerA) {
            pair.setPlayerAVerified(true);
        } else {
            pair.setPlayerBVerified(true);
        }

        Pair savedPair =
                pairRepository.save(pair);

        /*
         * Only one player has verified so far.
         *
         * The match must NOT end yet.
         */
        if (!savedPair.isPlayerAVerified()
                || !savedPair.isPlayerBVerified()) {

            return MatchCompletionResponse.builder()
                    .status("VERIFIED")
                    .pairId(savedPair.getId())
                    .build();
        }

        /*
         * BOTH players have now entered the correct
         * partner PIN.
         *
         * The match can finally be completed.
         */
        savedPair.setCompletionTimeMs(
                request.getDurationMs()
        );

        savedPair.setStatus(
                PairStatus.COMPLETED
        );

        savedPair =
                pairRepository.save(savedPair);

        /*
         * Save the completed match result.
         */
        saveMatchResult(
                savedPair,
                request
        );

        /*
         * Get the generated puzzle image.
         */
        GameImage image =
                gameImageRepository
                        .findById(
                                savedPair.getGameImageId()
                        )
                        .orElse(null);

        /*
         * Notify both players that the match
         * has actually completed.
         */
        notifyPlayers(
                savedPair,
                "PAIR_COMPLETED"
        );

        /*
         * If the image doesn't exist, the match is still
         * successfully completed.
         */
        if (image == null) {

            return MatchCompletionResponse.builder()
                    .status("COMPLETED")
                    .pairId(savedPair.getId())
                    .durationMs(
                            savedPair.getCompletionTimeMs()
                    )
                    .build();
        }

        return MatchCompletionResponse.builder()
                .status("COMPLETED")
                .pairId(savedPair.getId())
                .durationMs(
                        savedPair.getCompletionTimeMs()
                )
                .leftHalfImage(
                        image.getLeftHalfUrl()
                )
                .rightHalfImage(
                        image.getRightHalfUrl()
                )
                .build();
    }
    private void saveMatchResult(
            Pair pair,
            CompleteGameMatchRequest request
    ) {

        if (request.getPlayerId() == null ||
                request.getPlayerId().isBlank()) {

            return;
        }

        MatchResult result =
                MatchResult.builder()
                        .eventId(pair.getEventId())
                        .pairId(pair.getId())
                        .playerId(request.getPlayerId())
                        .userEmail(request.getUserEmail())
                        .completionTimeMs(
                                request.getDurationMs()
                        )
                        .completedAt(Instant.now())
                        .build();

        matchResultRepository.save(result);
    }
}