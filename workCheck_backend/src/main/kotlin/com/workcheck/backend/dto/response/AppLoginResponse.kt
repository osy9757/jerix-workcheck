package com.workcheck.backend.dto.response

// 앱 로그인 응답 DTO (v2: workplaceId 제거)
data class AppLoginResponse(
    val token: String,
    val user: AppUserInfo,
    val enabledMethods: List<String> = emptyList()  // 활성화된 인증 방법 목록 (소문자 키: gps,wifi,nfc,beacon,qr)
)

// 앱 로그인 사용자 기본 정보 (v2: workplaceId 제거)
data class AppUserInfo(
    val id: Long,
    val name: String,
    val employeeId: String,
    val department: String?
)
