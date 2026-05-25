package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 출퇴근 기록 응답 DTO (v2: 다중 method AND 결합 결과 표현용 verifiedMethods 추가)
data class AttendanceResponse(
    val id: Long,
    val type: String,
    val timestamp: OffsetDateTime,
    val verificationMethod: String,                       // 대표 method (활성 method 중 첫 번째, 소문자)
    val verifiedMethods: List<String> = emptyList(),      // AND 결합 통과한 모든 method 키 (소문자)
    val verificationData: Map<String, Any>
)
