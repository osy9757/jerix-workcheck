package com.workcheck.backend.dto.response

// 근무지 인증 설정 응답 DTO
data class WorkplaceConfigResponse(
    val enabledMethods: List<String>,
    val configs: Map<String, Map<String, Any>>
)
