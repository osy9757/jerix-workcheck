package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.response.AppLoginResponse
import com.workcheck.backend.service.AuthService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 앱 인증 API
@RestController
@RequestMapping("/api/v1/auth")
class AuthController(
    private val authService: AuthService
) {
    // 앱 로그인
    @PostMapping("/login")
    fun login(@Valid @RequestBody request: AppLoginRequest): ResponseEntity<AppLoginResponse> {
        return ResponseEntity.ok(authService.login(request))
    }
}
