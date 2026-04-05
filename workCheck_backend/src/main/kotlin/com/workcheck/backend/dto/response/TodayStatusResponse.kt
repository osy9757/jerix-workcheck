package com.workcheck.backend.dto.response

// 오늘의 출퇴근 현황 응답 DTO
data class TodayStatusResponse(
    val clockIn: AttendanceResponse?,
    val clockOut: AttendanceResponse?
)
