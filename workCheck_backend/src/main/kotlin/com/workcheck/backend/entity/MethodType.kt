package com.workcheck.backend.entity

// 인증 방법 유형 (GPS, QR, WiFi, NFC, Beacon 및 복합 방식)
enum class MethodType {
    GPS, GPS_QR, WIFI, WIFI_QR, NFC, NFC_GPS, BEACON, BEACON_GPS
}
