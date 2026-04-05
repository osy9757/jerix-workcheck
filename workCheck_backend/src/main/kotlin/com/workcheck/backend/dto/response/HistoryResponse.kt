package com.workcheck.backend.dto.response

// 출퇴근 이력 응답 DTO
data class HistoryResponse(
    val records: List<DailyRecord>,
    val total: Int
)

// 일별 출퇴근 기록
data class DailyRecord(
    val date: String,
    val clockIn: AttendanceResponse?,
    val clockOut: AttendanceResponse?
)

// 관리자용 출퇴근 이력 응답 DTO (직원 정보 포함)
data class AdminHistoryResponse(
    val records: List<AdminDailyRecord>,
    val total: Int
)

// 관리자용 일별 출퇴근 기록 (직원 정보 포함)
data class AdminDailyRecord(
    val date: String,
    val employeeId: String,
    val employeeName: String,
    val clockIn: AttendanceResponse?,
    val clockOut: AttendanceResponse?
)
