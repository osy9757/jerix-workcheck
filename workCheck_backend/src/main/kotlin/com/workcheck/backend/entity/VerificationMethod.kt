package com.workcheck.backend.entity

import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.type.SqlTypes
import java.time.OffsetDateTime

@Entity
@Table(
    name = "verification_methods",
    uniqueConstraints = [UniqueConstraint(columnNames = ["workplace_id", "method_type"])]
)
class VerificationMethod(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    // 근무지 FK (company → workplace로 변경)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id", nullable = false)
    val workplace: Workplace,

    @Enumerated(EnumType.STRING)
    @Column(name = "method_type", nullable = false, columnDefinition = "method_type_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    val methodType: MethodType,

    @Column(name = "is_enabled", nullable = false)
    var isEnabled: Boolean = true,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now(),

    @OneToOne(mappedBy = "verificationMethod", cascade = [CascadeType.ALL], fetch = FetchType.LAZY)
    var config: VerificationConfig? = null
)
