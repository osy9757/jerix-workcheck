package com.workcheck.backend.dto.request

// 유저 method 토글/설정 변경 요청 (Admin Web → PUT /api/v1/users/{userId}/methods/{methodType})
data class UpdateUserMethodRequest(
    val isEnabled: Boolean,
    val configData: Map<String, Any> = emptyMap()
)
