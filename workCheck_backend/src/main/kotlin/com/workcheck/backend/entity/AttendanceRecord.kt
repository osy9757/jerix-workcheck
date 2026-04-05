package com.workcheck.backend.entity

import io.hypersistence.utils.hibernate.type.json.JsonBinaryType
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.annotations.Type
import org.hibernate.type.SqlTypes
import java.time.OffsetDateTime

// 출퇴근 기록 엔티티
@Entity
@Table(name = "attendance_records")
class AttendanceRecord(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, columnDefinition = "attendance_type_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    val type: AttendanceType,

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, columnDefinition = "attendance_status_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    var status: AttendanceStatus = AttendanceStatus.PENDING,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "verification_method_id", nullable = false)
    val verificationMethod: VerificationMethod,

    @Type(JsonBinaryType::class)
    @Column(name = "verification_data", nullable = false, columnDefinition = "jsonb")
    val verificationData: Map<String, Any> = emptyMap(),

    @Column(name = "recorded_at", nullable = false)
    val recordedAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now()
)
