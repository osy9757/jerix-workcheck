package com.workcheck.backend.service

// 인증 검증 실패 에러 코드
enum class VerificationErrorCode {
    VERIFICATION_FAILED,         // 일반 검증 실패 (분류 불가 폴백)
    NFC_VERIFICATION_FAILED,     // NFC 태그 ID 불일치/누락
    GPS_VERIFICATION_FAILED,     // GPS 반경 밖 또는 좌표 누락
    WIFI_VERIFICATION_FAILED,    // WiFi SSID/BSSID 불일치 또는 누락
    QR_VERIFICATION_FAILED,      // QR 코드 불일치 또는 누락
    BEACON_NOT_DETECTED,         // 비콘이 아예 감지되지 않음
    BEACON_UUID_MISMATCH,        // 비콘은 감지됐지만 UUID 불일치
    BEACON_RSSI_TOO_WEAK         // UUID 일치하지만 RSSI 임계값 미달
}

// 검증 실패 예외 - errorCode로 앱에서 적절한 UI 분기 가능
class VerificationFailedException(
    val errorCode: VerificationErrorCode,
    message: String
) : RuntimeException(message)
