package com.workcheck.backend.dto.response

// 관리자 로그인 응답 DTO
data class AdminLoginResponse(
    val token: String,
    val admin: AdminInfo
)

// 관리자 기본 정보
data class AdminInfo(
    val id: Long,
    val username: String
)
