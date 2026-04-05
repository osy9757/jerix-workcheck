package com.workcheck.backend.dto.response

// 근무지 인증 방법 응답 DTO
data class VerificationMethodResponse(
    val id: Long,
    val methodType: String,
    val enabled: Boolean,
    val config: Map<String, Any>?
)

// 근무지 인증 방법 목록 응답 DTO
data class VerificationMethodListResponse(
    val methods: List<VerificationMethodResponse>
)
