package com.workcheck.backend.dto.request

// 근무지 생성 요청
data class CreateWorkplaceRequest(
    val name: String,
    val address: String? = null,
    val latitude: Double? = null,
    val longitude: Double? = null
)
