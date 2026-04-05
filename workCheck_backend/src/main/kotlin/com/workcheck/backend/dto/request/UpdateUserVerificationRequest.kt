package com.workcheck.backend.dto.request

// 유저 인증 오버라이드 설정 요청
data class UpdateUserVerificationRequest(
    val methodType: String,          // "GPS", "WIFI" 등
    val isEnabled: Boolean,
    val configData: Map<String, Any> = emptyMap()
)
