package com.workcheck.backend.dto.request

// 인증 방법 수정 요청 DTO
data class UpdateVerificationRequest(
    val enabled: Boolean?,
    val config: Map<String, Any>?
)
