package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotNull

// 출근 요청 DTO
data class ClockInRequest(
    @field:NotBlank
    val type: String = "CLOCK_IN",

    @field:NotBlank
    val verificationMethod: String,

    @field:NotNull
    val verificationData: Map<String, Any>
)
