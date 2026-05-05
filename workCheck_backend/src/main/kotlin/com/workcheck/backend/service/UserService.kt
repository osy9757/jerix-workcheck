package com.workcheck.backend.service

import com.workcheck.backend.dto.request.CreateUserRequest
import com.workcheck.backend.dto.request.UpdateUserVerificationRequest
import com.workcheck.backend.dto.response.UserListResponse
import com.workcheck.backend.dto.response.UserResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.User
import com.workcheck.backend.entity.UserVerificationOverride
import com.workcheck.backend.repository.CompanyRepository
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.repository.UserVerificationOverrideRepository
import com.workcheck.backend.repository.WorkplaceRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime

// 직원 등록, 근무지 배정, 인증 방법 오버라이드 관리 서비스
@Service
class UserService(
    private val userRepository: UserRepository,
    private val companyRepository: CompanyRepository,
    private val workplaceRepository: WorkplaceRepository,
    private val userVerificationOverrideRepository: UserVerificationOverrideRepository,
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

    // 직원 등록
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
        return toResponse(saved, company.code)
    }

    // 유저 근무지 배정
    @Transactional
    fun assignWorkplace(userId: Long, workplaceId: Long): UserResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }
        val workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow { IllegalArgumentException("근무지를 찾을 수 없습니다: $workplaceId") }

        user.workplace = workplace
        val saved = userRepository.save(user)
        return toResponse(saved, saved.company.code)
    }

    // 유저 인증 오버라이드 설정
    // 단일 활성 제약: enabled=true 요청 시 같은 유저의 다른 모든 method_type 을 isEnabled=false 로 자동 upsert
    @Transactional
    fun setUserVerificationOverride(userId: Long, request: UpdateUserVerificationRequest) {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }

        val methodType = MethodType.valueOf(request.methodType)

        // QR 은 프리셋 카탈로그 전용 - 유저 오버라이드로 사용 불가
        if (methodType == MethodType.QR) {
            throw IllegalArgumentException("QR 은 프리셋 카탈로그 전용 타입입니다")
        }

        // 단일 활성 제약: 활성화 요청이면 같은 유저의 다른 method_type 을 모두 비활성으로 강제
        if (request.isEnabled) {
            val now = OffsetDateTime.now()
            MethodType.values()
                .filter { it != methodType && it != MethodType.QR }
                .forEach { other ->
                    val otherOverride = userVerificationOverrideRepository.findByUserIdAndMethodType(userId, other)
                    if (otherOverride != null) {
                        // 이미 비활성화된 항목은 건드리지 않음
                        if (otherOverride.isEnabled) {
                            otherOverride.isEnabled = false
                            otherOverride.updatedAt = now
                            userVerificationOverrideRepository.save(otherOverride)
                        }
                    } else {
                        // 오버라이드가 없으면 비활성 상태로 신규 upsert
                        userVerificationOverrideRepository.save(
                            UserVerificationOverride(
                                user = user,
                                methodType = other,
                                isEnabled = false,
                                configData = emptyMap()
                            )
                        )
                    }
                }
        }

        // 기존 오버라이드가 있으면 수정, 없으면 생성 (본 메서드 타입)
        val existing = userVerificationOverrideRepository.findByUserIdAndMethodType(userId, methodType)
        if (existing != null) {
            existing.isEnabled = request.isEnabled
            existing.configData = request.configData
            existing.updatedAt = OffsetDateTime.now()
            userVerificationOverrideRepository.save(existing)
        } else {
            userVerificationOverrideRepository.save(
                UserVerificationOverride(
                    user = user,
                    methodType = methodType,
                    isEnabled = request.isEnabled,
                    configData = request.configData
                )
            )
        }
    }

    // 유저 인증 오버라이드 삭제 (근무지 기본으로 복귀)
    @Transactional
    fun deleteUserVerificationOverride(userId: Long, methodType: String) {
        val type = MethodType.valueOf(methodType)
        userVerificationOverrideRepository.deleteByUserIdAndMethodType(userId, type)
    }

    // User 엔티티를 API 응답 DTO로 변환
    private fun toResponse(user: User, companyCode: String): UserResponse {
        return UserResponse(
            id = user.id,
            companyCode = companyCode,
            employeeId = user.employeeId,
            name = user.name,
            workplaceId = user.workplace?.id,
            workplaceName = user.workplace?.name,
            createdAt = user.createdAt
        )
    }
}
