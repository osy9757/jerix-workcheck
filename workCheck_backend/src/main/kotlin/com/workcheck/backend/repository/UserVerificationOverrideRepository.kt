package com.workcheck.backend.repository

import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.UserVerificationOverride
import org.springframework.data.jpa.repository.JpaRepository

// 유저별 인증 오버라이드 레포지토리
interface UserVerificationOverrideRepository : JpaRepository<UserVerificationOverride, Long> {
    // 특정 유저의 전체 인증 오버라이드 목록 조회
    fun findAllByUserId(userId: Long): List<UserVerificationOverride>
    // 특정 유저 + 인증 방법 유형으로 오버라이드 단건 조회
    fun findByUserIdAndMethodType(userId: Long, methodType: MethodType): UserVerificationOverride?
    // 특정 유저 + 인증 방법 유형의 오버라이드 삭제
    fun deleteByUserIdAndMethodType(userId: Long, methodType: MethodType)
}
