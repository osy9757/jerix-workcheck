package com.workcheck.backend.service

// 기기 바인딩 차단 예외 (403 DEVICE_NOT_ALLOWED 매핑용)
// deviceStatus: "NONE_MATCH"(불일치 APPROVED 존재) | "PENDING"(승인 대기) | "REJECTED"(거부됨)
// → 앱이 deviceStatus 로 "관리자 요청"/"대기"/"거부 안내" UI 분기
class DeviceNotAllowedException(
    val deviceStatus: String,
    message: String
) : RuntimeException(message)
