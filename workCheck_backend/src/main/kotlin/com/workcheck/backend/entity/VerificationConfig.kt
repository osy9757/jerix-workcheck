package com.workcheck.backend.entity

import io.hypersistence.utils.hibernate.type.json.JsonBinaryType
import jakarta.persistence.*
import org.hibernate.annotations.Type
import java.time.OffsetDateTime

// 인증 방법별 세부 설정 엔티티 (JSON 형태의 설정 데이터 저장)
@Entity
@Table(name = "verification_configs")
class VerificationConfig(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "verification_method_id", nullable = false, unique = true)
    val verificationMethod: VerificationMethod,

    @Type(JsonBinaryType::class)
    @Column(name = "config_data", nullable = false, columnDefinition = "jsonb")
    var configData: Map<String, Any> = emptyMap(),

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
)
