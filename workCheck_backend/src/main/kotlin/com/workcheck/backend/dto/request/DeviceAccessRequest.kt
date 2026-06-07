package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 기기 접근 요청 DTO (POST /api/v1/auth/device/request)
// 인사정보 + 비번 재검증으로 무단 PENDING 생성 방지 → 4필드 모두 필수
data class DeviceAccessRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val password: String,

    @field:NotBlank
    val deviceId: String
)
