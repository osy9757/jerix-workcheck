package com.workcheck.backend.repository

import com.workcheck.backend.entity.DeviceStatus
import com.workcheck.backend.entity.UserDevice
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

// 유저별 등록 기기 저장소 (기기 바인딩)
@Repository
interface UserDeviceRepository : JpaRepository<UserDevice, Long> {
    // 유저 + 기기ID 로 단건 조회 (이미 등록된 기기인지 확인 — 로그인 상태머신/요청 멱등)
    fun findByUserIdAndDeviceId(userId: Long, deviceId: String): UserDevice?

    // 유저의 특정 상태 기기 단건 조회 (APPROVED 단건 = findFirstByUserIdAndStatus(.., APPROVED))
    fun findFirstByUserIdAndStatus(userId: Long, status: DeviceStatus): UserDevice?

    // 유저의 특정 상태 기기 목록 조회
    fun findByUserIdAndStatus(userId: Long, status: DeviceStatus): List<UserDevice>

    // 유저의 특정 상태 기기 존재 여부
    fun existsByUserIdAndStatus(userId: Long, status: DeviceStatus): Boolean

    // 상태별 전체 기기 목록 (관리자 승인 대기열, 요청순 정렬)
    fun findAllByStatusOrderByRequestedAtAsc(status: DeviceStatus): List<UserDevice>

    // 전체 기기 목록 (관리자 status 필터 미지정 시, 요청순 정렬)
    fun findAllByOrderByRequestedAtAsc(): List<UserDevice>
}
