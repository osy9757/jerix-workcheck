package com.workcheck.backend.entity

import io.hypersistence.utils.hibernate.type.json.JsonBinaryType
import jakarta.persistence.*
import org.hibernate.annotations.JdbcTypeCode
import org.hibernate.annotations.Type
import org.hibernate.type.SqlTypes
import java.time.OffsetDateTime

// 인증 프리셋 엔티티 - 자주 쓰이는 NFC/WiFi/GPS/Beacon 설정값을 이름 붙여 저장하는 글로벌 카탈로그
@Entity
@Table(name = "verification_presets")
class VerificationPreset(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    // 프리셋 이름 (예: "사무실 정문 NFC")
    @Column(name = "name", nullable = false, length = 100)
    var name: String,

    // 인증 방법 유형 (method_type_enum 재사용)
    @Enumerated(EnumType.STRING)
    @Column(name = "method_type", nullable = false, columnDefinition = "method_type_enum")
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    var methodType: MethodType,

    // 방법별 설정값 (JSONB) - verification_configs와 동일 스키마 사용
    @Type(JsonBinaryType::class)
    @Column(name = "config_data", nullable = false, columnDefinition = "jsonb")
    var configData: Map<String, Any> = emptyMap(),

    // 메모 (선택) - 프리셋 설명/사용 위치 등
    @Column(name = "memo", columnDefinition = "text")
    var memo: String? = null,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    var updatedAt: OffsetDateTime = OffsetDateTime.now()
) {
    // 엔티티 업데이트 시 updated_at 자동 갱신
    @PreUpdate
    fun preUpdate() {
        updatedAt = OffsetDateTime.now()
    }
}
