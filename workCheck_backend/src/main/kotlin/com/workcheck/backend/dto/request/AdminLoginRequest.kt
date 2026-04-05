package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 관리자 로그인 요청 DTO
data class AdminLoginRequest(
    @field:NotBlank
    val username: String,

    @field:NotBlank
    val password: String
)
