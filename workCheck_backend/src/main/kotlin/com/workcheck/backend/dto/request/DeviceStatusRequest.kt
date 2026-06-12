package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 기기 상태 폴링 조회 DTO (POST /api/v1/auth/device/status)
// 읽기전용 조회 → 비밀번호 미포함 (5초 폴링마다 BCrypt 연산 회피)
// 와이어 포맷은 SNAKE_CASE: company_code / employee_id / device_id
data class DeviceStatusRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val deviceId: String
)
