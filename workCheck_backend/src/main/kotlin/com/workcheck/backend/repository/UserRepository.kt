package com.workcheck.backend.repository

import com.workcheck.backend.entity.User
import org.springframework.data.jpa.repository.JpaRepository

// 직원(사용자) 레포지토리 (v2: workplace 관련 메서드 제거)
interface UserRepository : JpaRepository<User, Long> {
    // 회사 ID + 사번으로 직원 조회 (로그인 시 사용)
    fun findByCompanyIdAndEmployeeId(companyId: Long, employeeId: String): User?
    // 특정 회사의 전체 직원 목록 조회
    fun findAllByCompanyId(companyId: Long): List<User>
}
