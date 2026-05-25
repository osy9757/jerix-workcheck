package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.ClockInRequest
import com.workcheck.backend.dto.request.ClockOutRequest
import com.workcheck.backend.dto.response.AttendanceInitResponse
import com.workcheck.backend.dto.response.AttendanceResponse
import com.workcheck.backend.dto.response.HistoryResponse
import com.workcheck.backend.dto.response.TodayStatusResponse
import com.workcheck.backend.service.AttendanceService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 출퇴근 API (v2: init/submit 2회 호출 구조)
@RestController
@RequestMapping("/api/v1/attendance")
class AttendanceController(
    private val attendanceService: AttendanceService
) {
    // 출근 1차: init - 어떤 method 데이터를 모아야 하는지 안내
    @PostMapping("/clock-in/init")
    fun clockInInit(@RequestAttribute userId: Long): ResponseEntity<AttendanceInitResponse> =
        ResponseEntity.ok(attendanceService.clockInInit(userId))

    // 출근 2차: submit - 수집한 데이터 일괄 제출 (AND 결합 검증)
    @PostMapping("/clock-in/submit")
    fun clockInSubmit(
        @RequestAttribute userId: Long,
        @Valid @RequestBody request: ClockInRequest
    ): ResponseEntity<AttendanceResponse> =
        ResponseEntity.ok(attendanceService.clockIn(userId, request))

    // 퇴근 1차: init
    @PostMapping("/clock-out/init")
    fun clockOutInit(@RequestAttribute userId: Long): ResponseEntity<AttendanceInitResponse> =
        ResponseEntity.ok(attendanceService.clockOutInit(userId))

    // 퇴근 2차: submit
    @PostMapping("/clock-out/submit")
    fun clockOutSubmit(
        @RequestAttribute userId: Long,
        @Valid @RequestBody request: ClockOutRequest
    ): ResponseEntity<AttendanceResponse> =
        ResponseEntity.ok(attendanceService.clockOut(userId, request))

    // 오늘 출퇴근 상태
    @GetMapping("/today")
    fun getTodayStatus(@RequestAttribute userId: Long): ResponseEntity<TodayStatusResponse> =
        ResponseEntity.ok(attendanceService.getTodayStatus(userId))

    // 출퇴근 기록 조회
    @GetMapping("/history")
    fun getHistory(
        @RequestAttribute userId: Long,
        @RequestParam from: String,
        @RequestParam to: String
    ): ResponseEntity<HistoryResponse> =
        ResponseEntity.ok(attendanceService.getHistory(userId, from, to))
}
