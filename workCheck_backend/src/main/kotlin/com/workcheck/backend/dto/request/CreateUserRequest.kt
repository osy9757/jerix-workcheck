package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 사용자 생성 요청 DTO
data class CreateUserRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val name: String,

    @field:NotBlank
    val password: String
)
