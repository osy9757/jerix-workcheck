package com.workcheck.backend.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

// 회사 엔티티
@Entity
@Table(name = "companies")
class Company(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, length = 100)
    val name: String,

    @Column(nullable = false, unique = true, length = 20)
    val code: String,

    // [D4] 기기 등록 방식 (AUTO=첫 기기 자동등록 / APPROVAL=항상 관리자 승인). 갱신 위해 var
    @Enumerated(EnumType.STRING)
    @Column(name = "device_binding_mode", nullable = false, length = 16)
    var deviceBindingMode: DeviceBindingMode = DeviceBindingMode.AUTO,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
