package com.twinquest.backend.dto.request;

import lombok.Data;

@Data
public class GuestAuthRequest {

    private String guestId;
    private String name;
    private String avatar;
}