package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 앱 회원가입 전용 DTO (POST /api/v1/auth/register)
// '관리자가 사전 등록한 미가입 직원 row 에 비밀번호 설정 + 활성화' 흐름.
// name 은 받지 않음 (인사정보에 등재된 기존 name 사용).
// 와이어 포맷 SNAKE_CASE: company_code / employee_id / password
data class RegisterRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val password: String
)
