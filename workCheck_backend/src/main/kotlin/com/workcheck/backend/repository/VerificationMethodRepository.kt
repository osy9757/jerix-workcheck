package com.workcheck.backend.repository

import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.VerificationMethod
import org.springframework.data.jpa.repository.JpaRepository

// 인증 방법 레포지토리 (company → workplace 기준으로 변경)
interface VerificationMethodRepository : JpaRepository<VerificationMethod, Long> {
    // 근무지의 전체 인증 방법 목록 조회
    fun findAllByWorkplaceId(workplaceId: Long): List<VerificationMethod>
    // 근무지의 활성화된 인증 방법 목록만 조회
    fun findByWorkplaceIdAndIsEnabledTrue(workplaceId: Long): List<VerificationMethod>
    // 근무지 + 인증 방법 유형으로 단건 조회
    fun findByWorkplaceIdAndMethodType(workplaceId: Long, methodType: MethodType): VerificationMethod?
}
