package com.workcheck.backend.dto.request

// 근무지 수정 요청
data class UpdateWorkplaceRequest(
    val name: String?,
    val address: String?,
    val latitude: Double? = null,
    val longitude: Double? = null
)
