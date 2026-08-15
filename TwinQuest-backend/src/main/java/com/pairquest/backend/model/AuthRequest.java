package com.pairquest.backend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthRequest {
    private String email;
    private String name;
    private String avatar;
    private String authType; // GOOGLE, GUEST, STAFF
    private String idToken;
}
