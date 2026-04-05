package com.workcheck.backend.repository

import com.workcheck.backend.entity.Company
import org.springframework.data.jpa.repository.JpaRepository

// 회사 레포지토리
interface CompanyRepository : JpaRepository<Company, Long> {
    // 회사 코드로 조회 (직원 등록/로그인 시 회사 식별에 사용)
    fun findByCode(code: String): Company?
}
