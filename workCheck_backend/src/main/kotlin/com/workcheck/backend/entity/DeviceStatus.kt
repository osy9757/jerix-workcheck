package com.workcheck.backend.entity

// 기기 바인딩 상태 (대리 출퇴근 방지)
// PENDING(승인 대기) / APPROVED(승인됨, 유저당 1대) / REJECTED(거부됨)
enum class DeviceStatus {
    PENDING, APPROVED, REJECTED
}
