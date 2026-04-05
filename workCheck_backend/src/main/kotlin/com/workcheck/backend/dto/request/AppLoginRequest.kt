package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 앱 로그인 요청 DTO
data class AppLoginRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val password: String
)
