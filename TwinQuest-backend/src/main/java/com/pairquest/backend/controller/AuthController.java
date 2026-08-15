package com.pairquest.backend.controller;

import com.pairquest.backend.model.AuthRequest;
import com.pairquest.backend.model.AuthResponse;
import com.pairquest.backend.model.PairMatch;
import com.pairquest.backend.model.User;
import com.pairquest.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/auth/google")
    public ResponseEntity<AuthResponse> authenticateGoogle(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.authenticateGoogle(request));
    }

    @PostMapping("/auth/guest")
    public ResponseEntity<AuthResponse> authenticateGuest(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.authenticateGuest(request));
    }

    @GetMapping("/users/{email}/profile")
    public ResponseEntity<User> getUserProfile(@PathVariable String email) {
        User user = authService.getUserByEmail(email);
        if (user != null) {
            return ResponseEntity.ok(user);
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/users/{email}/matches")
    public ResponseEntity<List<PairMatch>> getUserMatches(@PathVariable String email) {
        return ResponseEntity.ok(authService.getUserMatches(email));
    }
}
