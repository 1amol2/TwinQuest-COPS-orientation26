package com.twinquest.backend.service;

import com.twinquest.backend.dto.response.LeaderboardEntryResponse;
import com.twinquest.backend.exception.ResourceNotFoundException;
import com.twinquest.backend.model.Event;
import com.twinquest.backend.model.Pair;
import com.twinquest.backend.model.PairStatus;
import com.twinquest.backend.model.Player;
import com.twinquest.backend.repository.EventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LeaderboardService {

    private final MatchService matchService;
    private final PlayerService playerService;
    private final EventRepository eventRepository;
    public List<LeaderboardEntryResponse> getLeaderboard(String eventId) {

        System.out.println("========== LEADERBOARD DEBUG ==========");
        System.out.println("Event ID: " + eventId);

        List<Pair> allPairs = matchService.getPairsByEvent(eventId);

        System.out.println("Total pairs for event: " + allPairs.size());

        for (Pair pair : allPairs) {

            System.out.println("--------------------------------------");
            System.out.println("Pair ID: " + pair.getId());
            System.out.println("Status: " + pair.getStatus());
            System.out.println("Player A ID: " + pair.getPlayerAId());
            System.out.println("Player B ID: " + pair.getPlayerBId());
            System.out.println("Completion Time: " + pair.getCompletionTimeMs());
        }

        List<Pair> completedPairs = allPairs
                .stream()
                .filter(pair -> pair.getStatus() == PairStatus.COMPLETED)
                .filter(pair -> pair.getCompletionTimeMs() != null)
                .sorted(
                        Comparator.comparing(Pair::getCompletionTimeMs)
                )
                .toList();

        System.out.println("Completed pairs: " + completedPairs.size());

        return java.util.stream.IntStream
                .range(0, completedPairs.size())
                .mapToObj(index -> {

                    Pair pair = completedPairs.get(index);

                    System.out.println("Processing pair: " + pair.getId());

                    System.out.println(
                            "Looking for Player A: " + pair.getPlayerAId()
                    );

                    Player playerAObject =
                            playerService.getPlayerById(pair.getPlayerAId());

                    System.out.println(
                            "Player A found: " + playerAObject.getName()
                    );

                    System.out.println(
                            "Looking for Player B: " + pair.getPlayerBId()
                    );

                    Player playerBObject =
                            playerService.getPlayerById(pair.getPlayerBId());

                    System.out.println(
                            "Player B found: " + playerBObject.getName()
                    );

                    return LeaderboardEntryResponse.builder()
                            .rank(index + 1)
                            .playerA(playerAObject.getName())
                            .playerB(playerBObject.getName())
                            .completionTimeMs(pair.getCompletionTimeMs())
                            .build();

                })
                .toList();
    }
    public List<LeaderboardEntryResponse>
    getLeaderboardByEventCode(
            String eventCode
    ) {

        Event event =
                eventRepository
                        .findByEventCode(eventCode)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Event not found: " + eventCode
                                )
                        );

        return getLeaderboard(event.getId());
    }
}