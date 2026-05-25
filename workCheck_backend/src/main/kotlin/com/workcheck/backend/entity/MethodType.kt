package com.workcheck.backend.entity

// 인증 방법 유형 (v2: 5개 단위 프리셋. 조합은 user_verification_methods 의 여러 row 가 동시에 enabled 상태로 표현)
// AND 결합: enabled=TRUE 인 모든 row 의 검증이 통과해야 인증 성공
enum class MethodType {
    GPS, WIFI, NFC, BEACON, QR
}
