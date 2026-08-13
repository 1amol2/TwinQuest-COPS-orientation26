package com.twinquest.backend.service;

import com.twinquest.backend.dto.response.LeaderboardEntryResponse;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LeaderboardService {

    private final MatchService matchService;
    private final PlayerService playerService;

    public List<LeaderboardEntryResponse> getLeaderboard(String eventId) {

        List<Pair> completedPairs = matchService
                .getPairsByEvent(eventId)
                .stream()
                .filter(pair -> pair.getStatus() == PairStatus.COMPLETED)
                .filter(pair -> pair.getCompletionTimeMs() != null)
                .sorted(
                        Comparator.comparing(
                                Pair::getCompletionTimeMs
                        )
                )
                .toList();

        return java.util.stream.IntStream
                .range(0, completedPairs.size())
                .mapToObj(index -> {

                    Pair pair = completedPairs.get(index);

                    String playerA = playerService
                            .getPlayerById(pair.getPlayerAId())
                            .getName();

                    String playerB = playerService
                            .getPlayerById(pair.getPlayerBId())
                            .getName();

                    return LeaderboardEntryResponse.builder()
                            .rank(index + 1)
                            .playerA(playerA)
                            .playerB(playerB)
                            .completionTimeMs(
                                    pair.getCompletionTimeMs()
                            )
                            .build();
                })
                .toList();
    }
}