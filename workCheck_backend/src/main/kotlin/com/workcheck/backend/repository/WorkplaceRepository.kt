package com.workcheck.backend.repository

import com.workcheck.backend.entity.Workplace
import org.springframework.data.jpa.repository.JpaRepository

// 근무지 레포지토리
interface WorkplaceRepository : JpaRepository<Workplace, Long> {
    // 특정 회사의 전체 근무지 목록 조회
    fun findAllByCompanyId(companyId: Long): List<Workplace>
}
