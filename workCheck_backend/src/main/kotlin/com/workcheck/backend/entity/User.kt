package com.workcheck.backend.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

// 직원(사용자) 엔티티 - 회사 내 사번으로 고유 식별
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

    // 소속 근무지 (nullable)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id")
    var workplace: Workplace? = null,

    @Column(name = "employee_id", nullable = false, length = 50)
    val employeeId: String,

    @Column(nullable = false, length = 100)
    var name: String,

    @Column(length = 255)
    var email: String? = null,

    @Column(length = 100)
    var department: String? = null,

    @Column(name = "password_hash", nullable = false, length = 255)
    var passwordHash: String,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
