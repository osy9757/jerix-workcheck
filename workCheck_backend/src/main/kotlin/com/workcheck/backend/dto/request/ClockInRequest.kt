package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotNull

// 출근 submit 요청 DTO (v2: 2회 호출 구조)
// init 응답의 requiredMethods 각각에 대해 클라이언트가 데이터 수집 후 한 번에 전송
// 예: { "verificationData": { "gps": {...}, "wifi": {...}, "nfc": {...} } }
data class ClockInRequest(
    @field:NotNull
    val verificationData: Map<String, Map<String, Any>>
)
