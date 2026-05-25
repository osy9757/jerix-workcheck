package com.workcheck.backend.entity

import io.hypersistence.utils.hibernate.type.json.JsonBinaryType
import jakarta.persistence.*
import org.hibernate.annotations.Type
import java.time.OffsetDateTime

// 유저별 인증 방법 (v2 통합 테이블)
// 한 유저가 5개 단위 프리셋(GPS/WIFI/NFC/BEACON/QR) 각각에 대해 토글/설정값을 보유.
// is_enabled=TRUE 인 row 들은 AND 결합으로 검증된다.
@Entity
@Table(
    name = "user_verification_methods",
    uniqueConstraints = [UniqueConstraint(columnNames = ["user_id", "method_type"])]
)
class UserVerificationMethod(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,

    @Enumerated(EnumType.STRING)
    @Column(name = "method_type", nullable = false, length = 16)
    val methodType: MethodType,

    @Column(name = "is_enabled", nullable = false)
    var isEnabled: Boolean = false,

    @Type(JsonBinaryType::class)
    @Column(name = "config_data", nullable = false, columnDefinition = "jsonb")
    var configData: Map<String, Any> = emptyMap(),

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
)
