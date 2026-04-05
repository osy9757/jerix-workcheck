package com.workcheck.backend.repository

import com.workcheck.backend.entity.AdminUser
import org.springframework.data.jpa.repository.JpaRepository

// 관리자 계정 레포지토리
interface AdminUserRepository : JpaRepository<AdminUser, Long> {
    // 사용자명으로 관리자 조회 (로그인 시 사용)
    fun findByUsername(username: String): AdminUser?
}
