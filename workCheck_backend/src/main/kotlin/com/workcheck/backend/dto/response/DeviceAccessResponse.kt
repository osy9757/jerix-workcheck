package com.workcheck.backend.dto.response

// 기기 접근 요청 응답 DTO (POST /api/v1/auth/device/request)
// data class → Jackson SNAKE_CASE 적용 (wire: {status, message})
data class DeviceAccessResponse(
    val status: String,   // 등록된 기기 상태 (보통 "PENDING")
    val message: String
)
