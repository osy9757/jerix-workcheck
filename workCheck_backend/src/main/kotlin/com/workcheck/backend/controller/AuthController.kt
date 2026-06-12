package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.AdminLoginRequest
import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.request.DeviceAccessRequest
import com.workcheck.backend.dto.request.DeviceStatusRequest
import com.workcheck.backend.dto.request.RegisterRequest
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

    // 앱 회원가입 (미가입 직원에 비밀번호 설정 + 활성화) — 토큰 미발급, 앱이 자동로그인 재사용
    @PostMapping("/register")
    fun register(@Valid @RequestBody request: RegisterRequest): ResponseEntity<Void> {
        authService.register(request)
        return ResponseEntity.ok().build()
    }

    // 기기 접근 요청 (기기 불일치 403 후 "관리자 요청" → 새 기기 PENDING 등록)
    @PostMapping("/device/request")
    fun requestDeviceAccess(@Valid @RequestBody request: DeviceAccessRequest): ResponseEntity<DeviceAccessResponse> {
        return ResponseEntity.ok(authService.requestDeviceAccess(request))
    }

    // 기기 상태 조회 (대기화면 5초 폴링 — 비번 미포함 읽기전용)
    @PostMapping("/device/status")
    fun getDeviceStatus(@Valid @RequestBody request: DeviceStatusRequest): ResponseEntity<DeviceAccessResponse> {
        return ResponseEntity.ok(authService.getDeviceStatus(request))
    }

    // 기기 접근 요청 취소 (대기화면 '요청취소' — 비번 재검증 후 PENDING row 삭제)
    @PostMapping("/device/cancel")
    fun cancelDeviceRequest(@Valid @RequestBody request: DeviceAccessRequest): ResponseEntity<DeviceAccessResponse> {
        return ResponseEntity.ok(authService.cancelDeviceRequest(request))
    }

    // [BACKLOG] 세션 체크 (앱 시작 시 영속 자동로그인) — JwtAuthInterceptor 가 userId attribute 셋업
    // 기기 바인딩 재검증 + 토큰 재발급 → AppLoginResponse (로그인과 동일 형태)
    @GetMapping("/session")
    fun checkSession(
        @RequestAttribute("userId") userId: Long,
        @RequestParam("device_id", required = false) deviceId: String?
    ): ResponseEntity<AppLoginResponse> {
        return ResponseEntity.ok(authService.checkSession(userId, deviceId))
    }
}
