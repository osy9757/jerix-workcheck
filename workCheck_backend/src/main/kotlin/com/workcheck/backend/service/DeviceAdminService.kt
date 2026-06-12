package com.workcheck.backend.service

import com.workcheck.backend.dto.response.AdminDeviceResponse
import com.workcheck.backend.dto.response.DeviceBindingModeResponse
import com.workcheck.backend.entity.DeviceBindingMode
import com.workcheck.backend.entity.DeviceStatus
import com.workcheck.backend.entity.UserDevice
import com.workcheck.backend.repository.CompanyRepository
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
    private val companyRepository: CompanyRepository,
    private val entityManager: EntityManager
) {
    // [D4] 회사의 기기 등록 방식 조회
    @Transactional(readOnly = true)
    fun getBindingMode(companyCode: String): DeviceBindingModeResponse {
        val company = companyRepository.findByCode(companyCode)
            ?: throw IllegalArgumentException("회사 코드를 찾을 수 없습니다: $companyCode")
        return DeviceBindingModeResponse(companyCode = company.code, mode = company.deviceBindingMode.name)
    }

    // [D4] 회사의 기기 등록 방식 변경 (AUTO/APPROVAL). 잘못된 값은 400.
    //   비소급: APPROVAL 전환해도 기존 APPROVED 바인딩은 유지 (이 메서드는 모드만 변경)
    fun updateBindingMode(companyCode: String, mode: String): DeviceBindingModeResponse {
        val company = companyRepository.findByCode(companyCode)
            ?: throw IllegalArgumentException("회사 코드를 찾을 수 없습니다: $companyCode")
        val parsed = runCatching { DeviceBindingMode.valueOf(mode.uppercase()) }
            .getOrElse { throw IllegalArgumentException("알 수 없는 기기 등록 방식: $mode (AUTO|APPROVAL)") }
        company.deviceBindingMode = parsed
        companyRepository.save(company)
        return DeviceBindingModeResponse(companyCode = company.code, mode = parsed.name)
    }

    // 기기 목록 조회 (status 필터 옵션). 관리자 JWT 필요(AdminJwtAuthInterceptor, /admin/** 보호).
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

    // 기기 삭제: row 완전 제거 (예: 삭제 후 첫기기 자동 재바인딩 테스트). 없으면 예외.
    fun delete(id: Long) {
        if (!userDeviceRepository.existsById(id)) {
            throw IllegalArgumentException("기기를 찾을 수 없습니다: $id")
        }
        userDeviceRepository.deleteById(id)
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
