package com.workcheck.backend.dto.response

// 유저 단일 method 응답 (Admin Web 토글/설정 표시용)
data class UserMethodResponse(
    val methodType: String,            // "GPS","WIFI","NFC","BEACON","QR"
    val isEnabled: Boolean,
    val configData: Map<String, Any> = emptyMap()
)

// 유저의 5개 method 전체 응답 (GET /api/v1/users/{userId}/methods)
data class UserMethodsResponse(
    val userId: Long,
    val methods: List<UserMethodResponse>
)
