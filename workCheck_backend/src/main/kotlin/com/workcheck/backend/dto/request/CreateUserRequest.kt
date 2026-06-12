package com.workcheck.backend.dto.request

import jakarta.validation.constraints.NotBlank

// 사용자 생성 요청 DTO (관리자 사전 등록 — 미가입 상태)
// [D3] 비밀번호는 직원이 앱 회원가입에서 직접 설정 → password 필드 제거
data class CreateUserRequest(
    @field:NotBlank
    val companyCode: String,

    @field:NotBlank
    val employeeId: String,

    @field:NotBlank
    val name: String
)
