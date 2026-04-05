package com.workcheck.backend.dto.response

import java.time.OffsetDateTime

// 직원 정보 응답 DTO
data class UserResponse(
    val id: Long,
    val companyCode: String,
    val employeeId: String,
    val name: String,
    val workplaceId: Long? = null,       // 소속 근무지 ID
    val workplaceName: String? = null,   // 소속 근무지 이름
    val createdAt: OffsetDateTime
)

// 사용자 목록 응답 DTO
data class UserListResponse(
    val users: List<UserResponse>,
    val total: Int
)
