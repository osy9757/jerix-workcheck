package com.workcheck.backend.entity

// 기기 등록 방식 (회사 단위 설정)
// AUTO     = 첫 기기 자동등록 (a안: 바인드 기기 없으면 현재 기기를 자동 APPROVED)
// APPROVAL = 항상 관리자 승인 (b안: 바인드 기기 없어도 관리자 승인 후 접속)
enum class DeviceBindingMode {
    AUTO, APPROVAL
}
