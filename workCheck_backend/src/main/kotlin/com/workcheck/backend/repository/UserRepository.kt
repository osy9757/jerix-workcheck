package com.workcheck.backend.repository

import com.workcheck.backend.entity.User
import org.springframework.data.jpa.repository.JpaRepository

// 직원(사용자) 레포지토리
interface UserRepository : JpaRepository<User, Long> {
    // 회사 ID + 사번으로 직원 조회 (로그인 시 사용)
    fun findByCompanyIdAndEmployeeId(companyId: Long, employeeId: String): User?
    // 특정 회사의 전체 직원 목록 조회
    fun findAllByCompanyId(companyId: Long): List<User>
    // 특정 근무지에 소속된 직원이 있는지 확인 (근무지 삭제 전 검증용)
    fun existsByWorkplaceId(workplaceId: Long): Boolean
}
