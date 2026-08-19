package com.twinquest.backend.controller;

import com.twinquest.backend.dto.request.GuestAuthRequest;
import com.twinquest.backend.dto.response.GuestAuthResponse;
import com.twinquest.backend.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/guest")
    public ResponseEntity<GuestAuthResponse> guestLogin(
            @RequestBody GuestAuthRequest request) {

        GuestAuthResponse response =
                authService.authenticateGuest(request);

        return ResponseEntity.ok(response);
    }
}