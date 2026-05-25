package com.workcheck.backend.controller

import com.workcheck.backend.dto.response.AdminHistoryResponse
import com.workcheck.backend.service.AttendanceService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 관리자 전용 데이터 조회 API (로그인은 AuthController 로 분리됨)
@RestController
@RequestMapping("/api/v1/admin")
class AdminController(
    private val attendanceService: AttendanceService
) {
    // 관리자용 전체 출퇴근 기록 조회 (모든 직원)
    @GetMapping("/attendance/records")
    fun getAttendanceRecords(
        @RequestParam from: String,
        @RequestParam to: String
    ): ResponseEntity<AdminHistoryResponse> {
        return ResponseEntity.ok(attendanceService.getAllHistory(from, to))
    }
}
