package com.workcheck.backend.entity

// 인증 방법 유형 (GPS, QR, WiFi, NFC, Beacon 및 복합 방식)
// QR 은 verification_presets 카탈로그 전용 (verification_methods / user_verification_overrides 에서는 사용 금지)
enum class MethodType {
    GPS, GPS_QR, WIFI, WIFI_QR, NFC, NFC_GPS, BEACON, BEACON_GPS, QR
}
