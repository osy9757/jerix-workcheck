package com.workcheck.backend.entity

import jakarta.persistence.*
import java.time.OffsetDateTime

// 유저별 등록 기기 엔티티 (대리 출퇴근 방지)
// - 유저당 APPROVED 기기 정확히 1대 (DB 부분 유니크 인덱스 uq_user_devices_one_approved 로 강제)
// - status 는 ENUM 회피: @Enumerated(STRING) + length=16 (VARCHAR(16)+CHECK 와 validate 일치, NAMED_ENUM 금지)
@Entity
@Table(
    name = "user_devices",
    uniqueConstraints = [UniqueConstraint(columnNames = ["user_id", "device_id"])]
)
class UserDevice(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User,

    // flutter_udid 불투명 식별자
    @Column(name = "device_id", nullable = false, length = 255)
    val deviceId: String,

    // 승인 상태 (PENDING/APPROVED/REJECTED)
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 16)
    var status: DeviceStatus = DeviceStatus.PENDING,

    // 플랫폼 (IOS/ANDROID, 관리자 표시용 선택)
    @Column(name = "platform", length = 16)
    var platform: String? = null,

    // 기기 모델명 (관리자 표시용 선택)
    @Column(name = "model", length = 100)
    var model: String? = null,

    // 등록/요청 시각
    @Column(name = "requested_at", nullable = false)
    var requestedAt: OffsetDateTime = OffsetDateTime.now(),

    // 승인 시각 (APPROVED 일 때만 세팅)
    @Column(name = "approved_at")
    var approvedAt: OffsetDateTime? = null,

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
