package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

// 퇴근 요청 DTO
data class ClockOutRequest(
    @field:NotBlank
    val type: String = "CLOCK_OUT",

    @field:NotBlank
    val verificationMethod: String,

    @field:NotNull
    val verificationData: Map<String, Any>
)
