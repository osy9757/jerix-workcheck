package com.workcheck.backend.repository

import com.workcheck.backend.entity.VerificationConfig
import org.springframework.data.jpa.repository.JpaRepository

// 인증 방법 설정 레포지토리
interface VerificationConfigRepository : JpaRepository<VerificationConfig, Long> {
    // 인증 방법 ID로 해당 설정 조회
    fun findByVerificationMethodId(verificationMethodId: Long): VerificationConfig?
}
