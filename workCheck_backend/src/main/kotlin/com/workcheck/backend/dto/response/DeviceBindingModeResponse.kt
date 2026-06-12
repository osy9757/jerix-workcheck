package com.workcheck.backend.dto.response

// [D4] 기기 등록 방식 응답 DTO
// Jackson SNAKE_CASE 전역 설정으로 company_code / mode 직렬화
data class DeviceBindingModeResponse(
    val companyCode: String,
    val mode: String   // "AUTO" | "APPROVAL"
)
