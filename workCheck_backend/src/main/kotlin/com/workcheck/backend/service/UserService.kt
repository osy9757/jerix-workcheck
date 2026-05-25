package com.workcheck.backend.service

import com.workcheck.backend.dto.request.CreateUserRequest
import com.workcheck.backend.dto.request.UpdateUserMethodRequest
import com.workcheck.backend.dto.response.UserListResponse
import com.workcheck.backend.dto.response.UserMethodResponse
import com.workcheck.backend.dto.response.UserMethodsResponse
import com.workcheck.backend.dto.response.UserResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.User
import com.workcheck.backend.entity.UserVerificationMethod
import com.workcheck.backend.repository.CompanyRepository
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.repository.UserVerificationMethodRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import kotlin.math.log10

// 직원 등록 + 인증 방법 관리 서비스 (v2: workplace 개념 제거, 5개 단위 프리셋 토글 + AND 결합)
@Service
class UserService(
    private val userRepository: UserRepository,
    private val companyRepository: CompanyRepository,
    private val uvmRepository: UserVerificationMethodRepository,
    private val passwordEncoder: PasswordEncoder
) {
    // 직원 목록
    fun getUsers(companyId: Long): UserListResponse {
        val company = companyRepository.findById(companyId)
            .orElseThrow { IllegalArgumentException("회사를 찾을 수 없습니다") }
        val users = userRepository.findAllByCompanyId(companyId)
        return UserListResponse(
            users = users.map { toResponse(it, company.code) },
            total = users.size
        )
    }

    // 직원 등록 (v2: 등록 시 5개 method row 자동 생성, 모두 disabled)
    @Transactional
    fun createUser(request: CreateUserRequest): UserResponse {
        val company = companyRepository.findByCode(request.companyCode)
            ?: throw IllegalArgumentException("회사 코드를 찾을 수 없습니다: ${request.companyCode}")

        val existing = userRepository.findByCompanyIdAndEmployeeId(company.id, request.employeeId)
        if (existing != null) {
            throw IllegalArgumentException("이미 등록된 사원번호입니다: ${request.employeeId}")
        }

        val user = User(
            company = company,
            employeeId = request.employeeId,
            name = request.name,
            passwordHash = passwordEncoder.encode(request.password)
        )
        val saved = userRepository.save(user)

        // 신규 직원에게 5개 method row 자동 생성 (모두 disabled + 빈 config)
        MethodType.values().forEach { type ->
            uvmRepository.save(
                UserVerificationMethod(
                    user = saved,
                    methodType = type,
                    isEnabled = false,
                    configData = emptyMap()
                )
            )
        }

        return toResponse(saved, company.code)
    }

    // 유저의 5개 method 전체 조회 (Admin Web 인증 페이지용)
    fun getUserMethods(userId: Long): UserMethodsResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }

        val existing = uvmRepository.findAllByUserId(userId).associateBy { it.methodType }
        // 누락된 method 가 있으면 disabled+빈 config 로 채워서 반환 (오래된 유저 대응)
        val methods = MethodType.values().map { type ->
            val uvm = existing[type]
            UserMethodResponse(
                methodType = type.name,
                isEnabled = uvm?.isEnabled ?: false,
                configData = uvm?.configData ?: emptyMap()
            )
        }
        return UserMethodsResponse(userId = user.id, methods = methods)
    }

    // 유저 method 단건 upsert (Admin Web 토글/설정 저장용)
    // 비콘 등록 시 distance_m + tx_power 가 들어오면 서버가 rssi_threshold 자동 계산하여 함께 저장
    @Transactional
    fun updateUserMethod(userId: Long, methodType: String, request: UpdateUserMethodRequest): UserMethodResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }
        val type = parseMethodType(methodType)

        val normalizedConfig = normalizeConfigData(type, request.configData)

        val existing = uvmRepository.findByUserIdAndMethodType(userId, type)
        val saved = if (existing != null) {
            existing.isEnabled = request.isEnabled
            existing.configData = normalizedConfig
            existing.updatedAt = OffsetDateTime.now()
            uvmRepository.save(existing)
        } else {
            uvmRepository.save(
                UserVerificationMethod(
                    user = user,
                    methodType = type,
                    isEnabled = request.isEnabled,
                    configData = normalizedConfig
                )
            )
        }
        return UserMethodResponse(
            methodType = saved.methodType.name,
            isEnabled = saved.isEnabled,
            configData = saved.configData
        )
    }

    // 비콘 거리(m)+txPower → rssi_threshold 자동 계산 후 targets 보강
    // 공식: rssi_threshold = txPower - 10 * n * log10(distance_m) (n=2, 일반 환경)
    private fun normalizeConfigData(type: MethodType, configData: Map<String, Any>): Map<String, Any> {
        if (type != MethodType.BEACON) return configData

        @Suppress("UNCHECKED_CAST")
        val targets = configData["targets"] as? List<Map<String, Any>> ?: return configData
        val normalizedTargets = targets.map { target ->
            val distanceM = (target["distance_m"] as? Number)?.toDouble()
            val txPower = (target["tx_power"] as? Number)?.toInt()
            if (distanceM != null && txPower != null && distanceM > 0) {
                val rssiThreshold = (txPower - 20 * log10(distanceM)).toInt()
                target + mapOf("rssi_threshold" to rssiThreshold)
            } else {
                target
            }
        }
        return configData + mapOf("targets" to normalizedTargets)
    }

    // methodType 문자열 (대소문자 무관) → enum
    private fun parseMethodType(raw: String): MethodType {
        return runCatching { MethodType.valueOf(raw.uppercase()) }
            .getOrElse { throw IllegalArgumentException("알 수 없는 method_type: $raw") }
    }

    // User 엔티티를 API 응답 DTO로 변환 (v2: workplace 필드 제거)
    private fun toResponse(user: User, companyCode: String): UserResponse {
        return UserResponse(
            id = user.id,
            companyCode = companyCode,
            employeeId = user.employeeId,
            name = user.name,
            email = user.email,
            department = user.department,
            createdAt = user.createdAt
        )
    }
}
