package com.workcheck.backend.dto.response

// 출퇴근 init 응답 (앱이 호출 후 어떤 method 데이터를 모아 submit 해야 하는지 안내)
data class AttendanceInitResponse(
    val requiredMethods: List<String>,                       // ["gps","wifi","nfc"] 소문자
    val configs: Map<String, Map<String, Any>> = emptyMap()  // method 키별 config_data
)
