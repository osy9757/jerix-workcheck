package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 관리자 기기 승인 화면용 응답 DTO
// data class → Jackson SNAKE_CASE 적용 (wire: user_id, employee_id, employee_name, requested_at, approved_at ...)
data class AdminDeviceResponse(
    val id: Long,
    val userId: Long,
    val employeeId: String,
    val employeeName: String,
    val department: String?,
    val deviceId: String,
    val status: String,          // PENDING | APPROVED | REJECTED
    val platform: String?,
    val model: String?,
    val requestedAt: OffsetDateTime,
    val approvedAt: OffsetDateTime?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime
)
