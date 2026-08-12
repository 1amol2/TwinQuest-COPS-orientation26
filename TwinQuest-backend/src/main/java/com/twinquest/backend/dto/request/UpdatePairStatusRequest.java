package com.twinquest.backend.dto.request;

import com.twinquest.backend.model.PairStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpdatePairStatusRequest {

    @NotNull(message = "Pair status is required")
    private PairStatus status;
}