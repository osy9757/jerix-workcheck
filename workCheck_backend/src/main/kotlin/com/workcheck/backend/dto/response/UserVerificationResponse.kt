package com.workcheck.backend.dto.response

// 유저별 인증 방법 응답 (근무지 기본 + 오버라이드 머지 결과)
data class UserVerificationResponse(
    val methodType: String,
    val enabled: Boolean,
    val config: Map<String, Any>,
    val isOverridden: Boolean       // 오버라이드 여부
)

// 유저 인증 방법 목록 응답 DTO
data class UserVerificationListResponse(
    val methods: List<UserVerificationResponse>,
    val total: Int
)
