package com.workcheck.backend.dto.request

import com.workcheck.backend.entity.MethodType

// 인증 프리셋 생성/수정 요청 DTO
data class VerificationPresetRequest(
    val name: String,
    val methodType: MethodType,
    val configData: Map<String, Any> = emptyMap(),
    val memo: String? = null
)
