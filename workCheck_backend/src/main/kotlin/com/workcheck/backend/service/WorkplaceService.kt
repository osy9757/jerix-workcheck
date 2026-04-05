package com.workcheck.backend.service

import com.workcheck.backend.dto.request.CreateWorkplaceRequest
import com.workcheck.backend.dto.request.UpdateWorkplaceRequest
import com.workcheck.backend.dto.response.QrCodeResponse
import com.workcheck.backend.dto.response.WorkplaceConfigResponse
import com.workcheck.backend.dto.response.WorkplaceListResponse
import com.workcheck.backend.dto.response.WorkplaceResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.VerificationConfig
import com.workcheck.backend.entity.VerificationMethod
import com.workcheck.backend.entity.Workplace
import com.workcheck.backend.repository.AttendanceRecordRepository
import com.workcheck.backend.repository.CompanyRepository
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.repository.VerificationConfigRepository
import com.workcheck.backend.repository.VerificationMethodRepository
import com.workcheck.backend.repository.WorkplaceRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

// 근무지 생성·수정·삭제 및 QR 코드, 앱용 인증 설정 조회 서비스
@Service
class WorkplaceService(
    private val workplaceRepository: WorkplaceRepository,
    private val companyRepository: CompanyRepository,
    private val verificationMethodRepository: VerificationMethodRepository,
    private val verificationConfigRepository: VerificationConfigRepository,
    private val userRepository: UserRepository,
    private val attendanceRecordRepository: AttendanceRecordRepository
) {
    // 근무지 목록 조회
    fun getWorkplaces(companyId: Long): WorkplaceListResponse {
        val workplaces = workplaceRepository.findAllByCompanyId(companyId)
        return WorkplaceListResponse(
            workplaces = workplaces.map { toResponse(it) },
            total = workplaces.size
        )
    }

    // 근무지 생성 + 8가지 인증 방법 자동 생성
    @Transactional
    fun createWorkplace(companyId: Long, request: CreateWorkplaceRequest): WorkplaceResponse {
        val company = companyRepository.findById(companyId)
            .orElseThrow { IllegalArgumentException("회사를 찾을 수 없습니다") }

        val workplace = workplaceRepository.save(
            Workplace(
                company = company,
                name = request.name,
                address = request.address,
                latitude = request.latitude,
                longitude = request.longitude
            )
        )

        // 8가지 인증 방법 자동 생성 (모두 비활성)
        // QR 관련 방법은 qr_code 자동 생성
        val qrCode = UUID.randomUUID().toString()
        for (methodType in MethodType.entries) {
            val method = verificationMethodRepository.save(
                VerificationMethod(workplace = workplace, methodType = methodType, isEnabled = false)
            )
            val configData = if (methodType in qrMethodTypes) {
                mapOf("qr_code" to qrCode)
            } else {
                emptyMap()
            }
            verificationConfigRepository.save(
                VerificationConfig(verificationMethod = method, configData = configData)
            )
        }

        return toResponse(workplace)
    }

    // 근무지 수정
    @Transactional
    fun updateWorkplace(workplaceId: Long, request: UpdateWorkplaceRequest): WorkplaceResponse {
        val workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow { IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId") }

        request.name?.let { workplace.name = it }
        request.address?.let { workplace.address = it }
        request.latitude?.let { workplace.latitude = it }
        request.longitude?.let { workplace.longitude = it }
        workplace.updatedAt = java.time.OffsetDateTime.now()

        return toResponse(workplaceRepository.save(workplace))
    }

    // 근무지 삭제 (FK 참조 순서대로 삭제)
    @Transactional
    fun deleteWorkplace(workplaceId: Long) {
        if (!workplaceRepository.existsById(workplaceId)) {
            throw IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId")
        }

        // 1. 배정된 유저가 있으면 삭제 거부
        if (userRepository.existsByWorkplaceId(workplaceId)) {
            throw IllegalArgumentException("해당 근무지에 배정된 직원이 있어 삭제할 수 없습니다")
        }

        // 2. 출퇴근 기록이 참조하는 인증 방법이 있으면 삭제 거부
        val methods = verificationMethodRepository.findAllByWorkplaceId(workplaceId)
        val methodIds = methods.map { it.id }
        if (methodIds.isNotEmpty() && attendanceRecordRepository.existsByVerificationMethodIdIn(methodIds)) {
            throw IllegalArgumentException("해당 근무지의 출퇴근 기록이 존재하여 삭제할 수 없습니다")
        }

        // 3. verification_configs → verification_methods → workplace 순서로 삭제
        for (method in methods) {
            verificationConfigRepository.findByVerificationMethodId(method.id)?.let {
                verificationConfigRepository.delete(it)
            }
        }
        verificationMethodRepository.deleteAll(methods)
        workplaceRepository.deleteById(workplaceId)
    }

    // QR 코드가 포함된 인증 방법 타입
    private val qrMethodTypes = setOf(MethodType.GPS_QR, MethodType.WIFI_QR)

    // 근무지 QR 코드 조회
    fun getQrCode(workplaceId: Long): QrCodeResponse {
        if (!workplaceRepository.existsById(workplaceId)) {
            throw IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId")
        }

        val qrCode = findQrCodeByWorkplace(workplaceId)
        return QrCodeResponse(workplaceId = workplaceId, qrCode = qrCode)
    }

    // 근무지 QR 코드 재생성
    @Transactional
    fun regenerateQrCode(workplaceId: Long): QrCodeResponse {
        if (!workplaceRepository.existsById(workplaceId)) {
            throw IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId")
        }

        val newQrCode = UUID.randomUUID().toString()

        // GPS_QR, WIFI_QR config의 qr_code 필드 업데이트
        for (methodType in qrMethodTypes) {
            val method = verificationMethodRepository.findByWorkplaceIdAndMethodType(workplaceId, methodType)
                ?: continue
            val config = verificationConfigRepository.findByVerificationMethodId(method.id) ?: continue
            val updatedData = config.configData.toMutableMap()
            updatedData["qr_code"] = newQrCode
            config.configData = updatedData
            config.updatedAt = java.time.OffsetDateTime.now()
            verificationConfigRepository.save(config)
        }

        return QrCodeResponse(workplaceId = workplaceId, qrCode = newQrCode)
    }

    // 근무지의 QR 코드 값 조회 (GPS_QR 또는 WIFI_QR에서)
    private fun findQrCodeByWorkplace(workplaceId: Long): String {
        for (methodType in qrMethodTypes) {
            val method = verificationMethodRepository.findByWorkplaceIdAndMethodType(workplaceId, methodType)
                ?: continue
            val config = verificationConfigRepository.findByVerificationMethodId(method.id) ?: continue
            val qrCode = config.configData["qr_code"] as? String
            if (!qrCode.isNullOrBlank()) return qrCode
        }
        return ""
    }

    // GPS가 포함된 인증 방법 타입
    private val gpsMethodTypes = setOf(
        MethodType.GPS, MethodType.GPS_QR, MethodType.NFC_GPS, MethodType.BEACON_GPS
    )

    // 앱용 활성 인증 방법 + 설정값 일괄 조회 (근무지 기준)
    // GPS 관련 config에 근무지 좌표를 합쳐서 반환 (앱 호환)
    fun getWorkplaceConfig(workplaceId: Long): WorkplaceConfigResponse {
        val workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow { IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId") }

        val enabledMethods = verificationMethodRepository.findByWorkplaceIdAndIsEnabledTrue(workplaceId)

        val enabledNames = enabledMethods.map { it.methodType.name.lowercase() }
        val configs = mutableMapOf<String, Map<String, Any>>()

        for (method in enabledMethods) {
            val config = verificationConfigRepository.findByVerificationMethodId(method.id)
            if (config != null) {
                val configData = config.configData.toMutableMap()
                // GPS 포함 방법이면 근무지 좌표를 config에 합침
                if (method.methodType in gpsMethodTypes) {
                    workplace.latitude?.let { configData["latitude"] = it }
                    workplace.longitude?.let { configData["longitude"] = it }
                }
                configs[method.methodType.name.lowercase()] = configData
            }
        }

        return WorkplaceConfigResponse(
            enabledMethods = enabledNames,
            configs = configs
        )
    }

    // Workplace 엔티티를 API 응답 DTO로 변환
    private fun toResponse(workplace: Workplace): WorkplaceResponse {
        return WorkplaceResponse(
            id = workplace.id,
            name = workplace.name,
            address = workplace.address,
            latitude = workplace.latitude,
            longitude = workplace.longitude
        )
    }
}
