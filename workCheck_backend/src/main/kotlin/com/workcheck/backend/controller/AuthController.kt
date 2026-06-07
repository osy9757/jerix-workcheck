package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.AdminLoginRequest
import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.request.DeviceAccessRequest
import com.workcheck.backend.dto.response.AdminLoginResponse
import com.workcheck.backend.dto.response.AppLoginResponse
import com.workcheck.backend.dto.response.DeviceAccessResponse
import com.workcheck.backend.service.AdminService
import com.workcheck.backend.service.AuthService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 인증 API (앱 + 관리자)
@RestController
@RequestMapping("/api/v1/auth")
class AuthController(
    private val authService: AuthService,
    private val adminService: AdminService
) {
    // 앱 로그인 (직원)
    @PostMapping("/login")
    fun login(@Valid @RequestBody request: AppLoginRequest): ResponseEntity<AppLoginResponse> {
        return ResponseEntity.ok(authService.login(request))
    }

    // 관리자 로그인 (Admin Web) — 도메인적으로 auth 그룹에 통합
    @PostMapping("/admin/login")
    fun adminLogin(@Valid @RequestBody request: AdminLoginRequest): ResponseEntity<AdminLoginResponse> {
        return ResponseEntity.ok(adminService.login(request))
    }

    // 기기 접근 요청 (기기 불일치 403 후 "관리자 요청" → 새 기기 PENDING 등록)
    @PostMapping("/device/request")
    fun requestDeviceAccess(@Valid @RequestBody request: DeviceAccessRequest): ResponseEntity<DeviceAccessResponse> {
        return ResponseEntity.ok(authService.requestDeviceAccess(request))
    }
}
