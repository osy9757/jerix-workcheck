package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.ClockInRequest
import com.workcheck.backend.dto.request.ClockOutRequest
import com.workcheck.backend.dto.response.AttendanceResponse
import com.workcheck.backend.dto.response.HistoryResponse
import com.workcheck.backend.dto.response.TodayStatusResponse
import com.workcheck.backend.service.AttendanceService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 출퇴근 기록 관리 API 컨트롤러
@RestController
@RequestMapping("/api/v1/attendance")
class AttendanceController(
    private val attendanceService: AttendanceService
) {
    // 출근 등록 (JWT 토큰에서 userId 추출)
    @PostMapping("/clock-in")
    fun clockIn(
        @RequestAttribute userId: Long,
        @Valid @RequestBody request: ClockInRequest
    ): ResponseEntity<AttendanceResponse> {
        return ResponseEntity.ok(attendanceService.clockIn(userId, request))
    }

    // 퇴근 등록
    @PostMapping("/clock-out")
    fun clockOut(
        @RequestAttribute userId: Long,
        @Valid @RequestBody request: ClockOutRequest
    ): ResponseEntity<AttendanceResponse> {
        return ResponseEntity.ok(attendanceService.clockOut(userId, request))
    }

    // 오늘 출퇴근 상태
    @GetMapping("/today")
    fun getTodayStatus(
        @RequestAttribute userId: Long
    ): ResponseEntity<TodayStatusResponse> {
        return ResponseEntity.ok(attendanceService.getTodayStatus(userId))
    }

    // 출퇴근 기록 조회
    @GetMapping("/history")
    fun getHistory(
        @RequestAttribute userId: Long,
        @RequestParam from: String,
        @RequestParam to: String
    ): ResponseEntity<HistoryResponse> {
        return ResponseEntity.ok(attendanceService.getHistory(userId, from, to))
    }
}
