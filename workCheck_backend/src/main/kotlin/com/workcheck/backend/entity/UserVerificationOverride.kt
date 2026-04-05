package com.workcheck.backend.entity

import io.hypersistence.utils.hibernate.type.json.JsonBinaryType
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.annotations.Type
import org.hibernate.type.SqlTypes
import java.time.OffsetDateTime

// 유저별 인증 방법 오버라이드 엔티티
@Entity
@Table(
    name = "user_verification_overrides",
    uniqueConstraints = [UniqueConstraint(columnNames = ["user_id", "method_type"])]
)
class UserVerificationOverride(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,

    @Enumerated(EnumType.STRING)
    @Column(name = "method_type", nullable = false, columnDefinition = "method_type_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    val methodType: MethodType,

    @Column(name = "is_enabled", nullable = false)
    var isEnabled: Boolean = true,

    @Type(JsonBinaryType::class)
    @Column(name = "config_data", nullable = false, columnDefinition = "jsonb")
    var configData: Map<String, Any> = emptyMap(),

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
)
