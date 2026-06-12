package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// [D4] 기기 등록 방식 변경 요청 DTO (PUT /api/v1/admin/settings/device-binding)
// 와이어 포맷 SNAKE_CASE: company_code / mode
data class UpdateDeviceBindingModeRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val mode: String   // "AUTO" | "APPROVAL" (대소문자 무관, 서버에서 valueOf 변환)
)
