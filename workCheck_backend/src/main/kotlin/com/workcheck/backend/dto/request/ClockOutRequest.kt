package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotNull

// 퇴근 submit 요청 DTO (v2: 2회 호출 구조)
data class ClockOutRequest(
    @field:NotNull
    val verificationData: Map<String, Map<String, Any>>
)
