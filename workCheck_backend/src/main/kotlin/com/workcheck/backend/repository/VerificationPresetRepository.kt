package com.workcheck.backend.repository

import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.VerificationPreset
import org.springframework.data.jpa.repository.JpaRepository

// 인증 프리셋 레포지토리 - 글로벌 카탈로그 (회사/근무지 종속 아님)
interface VerificationPresetRepository : JpaRepository<VerificationPreset, Long> {
    // 전체 프리셋 조회 (방법유형 → 이름 순 정렬)
    fun findAllByOrderByMethodTypeAscNameAsc(): List<VerificationPreset>

    // 특정 방법유형의 프리셋만 조회 (이름 순 정렬)
    fun findAllByMethodTypeOrderByNameAsc(methodType: MethodType): List<VerificationPreset>
}
