package com.workcheck.backend.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

// 직원(사용자) 엔티티 - 회사 내 사번으로 고유 식별 (v2: workplace 관계 제거)
@Entity
@Table(
    name = "users",
    uniqueConstraints = [UniqueConstraint(columnNames = ["company_id", "employee_id"])]
)
class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    val company: Company,

    @Column(name = "employee_id", nullable = false, length = 50)
    val employeeId: String,

    @Column(nullable = false, length = 100)
    var name: String,

    @Column(length = 255)
    var email: String? = null,

    @Column(length = 100)
    var department: String? = null,

    // NULL = 관리자 등록만 됨(미가입), 값 존재 = 앱 회원가입 완료
    @Column(name = "password_hash", length = 255)
    var passwordHash: String? = null,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
