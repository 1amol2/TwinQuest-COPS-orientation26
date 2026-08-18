package com.twinquest.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchCompletionResponse {

    private String status;

    private String pairId;

    private Long durationMs;

    private String leftHalfImage;

    private String rightHalfImage;

    private String error;

    public static MatchCompletionResponse failure(
            String message
    ) {

        return MatchCompletionResponse.builder()
                .status("FAILURE")
                .error(message)
                .build();
    }
}