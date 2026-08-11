package com.twinquest.backend.dto.request;

import com.twinquest.backend.model.PairStatus;
import lombok.Data;

@Data
public class UpdatePairStatusRequest {

    private PairStatus status;
}