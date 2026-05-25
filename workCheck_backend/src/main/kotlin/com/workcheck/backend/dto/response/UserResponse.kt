package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 직원 정보 응답 DTO (v2: workplace 필드 제거)
data class UserResponse(
    val id: Long,
    val companyCode: String,
    val employeeId: String,
    val name: String,
    val email: String? = null,
    val department: String? = null,
    val createdAt: OffsetDateTime
)

// 사용자 목록 응답 DTO
data class UserListResponse(
    val users: List<UserResponse>,
    val total: Int
)
