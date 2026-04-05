package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.AdminLoginRequest
import com.workcheck.backend.dto.response.AdminHistoryResponse
import com.workcheck.backend.dto.response.AdminLoginResponse
import com.workcheck.backend.service.AdminService
import com.workcheck.backend.service.AttendanceService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 관리자 전용 API 컨트롤러
@RestController
@RequestMapping("/api/v1/admin")
class AdminController(
    private val adminService: AdminService,
    private val attendanceService: AttendanceService
) {
    // 관리자 로그인
    @PostMapping("/login")
    fun login(@Valid @RequestBody request: AdminLoginRequest): ResponseEntity<AdminLoginResponse> {
        return ResponseEntity.ok(adminService.login(request))
    }

    // 관리자용 전체 출퇴근 기록 조회 (모든 직원)
    @GetMapping("/attendance/records")
    fun getAttendanceRecords(
        @RequestParam from: String,
        @RequestParam to: String
    ): ResponseEntity<AdminHistoryResponse> {
        return ResponseEntity.ok(attendanceService.getAllHistory(from, to))
    }
}
