package com.workcheck.backend.dto.response

// 근무지 응답 DTO
data class WorkplaceResponse(
    val id: Long,
    val name: String,
    val address: String?,
    val latitude: Double? = null,
    val longitude: Double? = null
)

// 근무지 목록 응답 DTO
data class WorkplaceListResponse(
    val workplaces: List<WorkplaceResponse>,
    val total: Int
)
