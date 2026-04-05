package com.workcheck.backend.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

// 근무지 엔티티
@Entity
@Table(name = "workplaces")
class Workplace(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "company_id", nullable = false)
    val company: Company,

    @Column(nullable = false, length = 100)
    var name: String,

    @Column(length = 255)
    var address: String? = null,

    // 근무지 위도
    @Column(name = "latitude")
    var latitude: Double? = null,

    // 근무지 경도
    @Column(name = "longitude")
    var longitude: Double? = null,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
)
