package com.workcheck.backend.repository

import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.UserVerificationMethod
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

// 유저별 인증 방법 저장소 (v2)
@Repository
interface UserVerificationMethodRepository : JpaRepository<UserVerificationMethod, Long> {
    // 한 유저의 5개 method 전체 조회
    fun findAllByUserId(userId: Long): List<UserVerificationMethod>

    // 한 유저의 활성 method 목록 조회 (AND 결합용)
    fun findAllByUserIdAndIsEnabledTrue(userId: Long): List<UserVerificationMethod>

    // 한 유저의 특정 method (PUT 시 upsert 키)
    fun findByUserIdAndMethodType(userId: Long, methodType: MethodType): UserVerificationMethod?
}
