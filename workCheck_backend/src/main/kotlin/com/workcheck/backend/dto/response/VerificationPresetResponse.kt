package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 인증 프리셋 응답 DTO
data class VerificationPresetResponse(
    val id: Long,
    val name: String,
    val methodType: String,
    val configData: Map<String, Any>,
    val memo: String?,
    val createdAt: OffsetDateTime,
    val updatedAt: OffsetDateTime
)
