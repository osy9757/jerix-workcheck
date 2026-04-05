package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 출퇴근 기록 응답 DTO
data class AttendanceResponse(
    val id: Long,
    val type: String,
    val timestamp: OffsetDateTime,
    val verificationMethod: String,
    val verificationData: Map<String, Any>
)
