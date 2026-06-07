package com.workcheck.backend.service

import com.workcheck.backend.dto.response.AdminDeviceResponse
import com.workcheck.backend.entity.DeviceStatus
import com.workcheck.backend.entity.UserDevice
import com.workcheck.backend.repository.UserDeviceRepository
import jakarta.persistence.EntityManager
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime

// 관리자 기기 승인/거부 서비스 (대리 출퇴근 방지의 핵심 게이트)
// @Transactional: LAZY user 접근 + 승인 시 강등→flush→전환을 한 트랜잭션으로 처리
@Service
@Transactional
class DeviceAdminService(
    private val userDeviceRepository: UserDeviceRepository,
    private val entityManager: EntityManager
) {
    // 기기 목록 조회 (status 필터 옵션). MVP: 관리자 비인증.
    @Transactional(readOnly = true)
    fun listDevices(status: DeviceStatus?): List<AdminDeviceResponse> {
        val devices = if (status != null) {
            userDeviceRepository.findAllByStatusOrderByRequestedAtAsc(status)
        } else {
            userDeviceRepository.findAllByOrderByRequestedAtAsc()
        }
        return devices.map { toResponse(it) }
    }

    // 기기 승인: 기존 APPROVED 강등(REJECTED) → flush → 대상 APPROVED 전환
    //   순서가 중요 — 부분 유니크 인덱스(uq_user_devices_one_approved) 충돌 회피 (유저당 APPROVED 1대)
    fun approve(id: Long): AdminDeviceResponse {
        val target = userDeviceRepository.findById(id)
            .orElseThrow { IllegalArgumentException("기기를 찾을 수 없습니다: $id") }

        // 1. 같은 유저의 기존 APPROVED 가 있으면 REJECTED 로 강등 (교체, 이력 보존)
        val current = userDeviceRepository.findFirstByUserIdAndStatus(target.user.id, DeviceStatus.APPROVED)
        if (current != null && current.id != target.id) {
            current.status = DeviceStatus.REJECTED
            current.approvedAt = null
            userDeviceRepository.save(current)
            // 2. flush — DELETE/UPDATE 를 DB 에 먼저 반영하여 다음 단계 인덱스 충돌 방지
            entityManager.flush()
        }

        // 3. 대상 기기를 APPROVED 로 전환
        target.status = DeviceStatus.APPROVED
        target.approvedAt = OffsetDateTime.now()
        userDeviceRepository.save(target)

        return toResponse(target)
    }

    // 기기 거부: REJECTED 전환 (접속 불가)
    fun reject(id: Long): AdminDeviceResponse {
        val target = userDeviceRepository.findById(id)
            .orElseThrow { IllegalArgumentException("기기를 찾을 수 없습니다: $id") }

        target.status = DeviceStatus.REJECTED
        target.approvedAt = null
        userDeviceRepository.save(target)

        return toResponse(target)
    }

    // 엔티티 → 관리자 응답 DTO 변환 (LAZY user 접근 — @Transactional 내에서만 안전)
    private fun toResponse(device: UserDevice): AdminDeviceResponse {
        val user = device.user
        return AdminDeviceResponse(
            id = device.id,
            userId = user.id,
            employeeId = user.employeeId,
            employeeName = user.name,
            department = user.department,
            deviceId = device.deviceId,
            status = device.status.name,
            platform = device.platform,
            model = device.model,
            requestedAt = device.requestedAt,
            approvedAt = device.approvedAt,
            createdAt = device.createdAt,
            updatedAt = device.updatedAt
        )
    }
}
