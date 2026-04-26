package com.workcheck.backend.service

import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.response.AppLoginResponse
import com.workcheck.backend.dto.response.AppUserInfo
import com.workcheck.backend.repository.CompanyRepository
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.util.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

// 앱 사용자 로그인 인증 및 토큰 발급 서비스
@Service
class AuthService(
    private val companyRepository: CompanyRepository,
    private val userRepository: UserRepository,
    private val verificationService: VerificationService,
    private val jwtUtil: JwtUtil,
    private val passwordEncoder: PasswordEncoder
) {
    // 앱 로그인: 회사코드 + 사원번호 + 비밀번호
    fun login(request: AppLoginRequest): AppLoginResponse {
        // 1. 회사코드로 회사 찾기
        val company = companyRepository.findByCode(request.companyCode)
            ?: throw IllegalArgumentException("회사를 찾을 수 없습니다")

        // 2. 회사 + 사원번호로 유저 찾기
        val user = userRepository.findByCompanyIdAndEmployeeId(company.id, request.employeeId)
            ?: throw IllegalArgumentException("사원번호를 찾을 수 없습니다")

        // 3. 비밀번호 검증 (BCrypt)
        if (!passwordEncoder.matches(request.password, user.passwordHash)) {
            throw AuthenticationFailedException("비밀번호가 일치하지 않습니다")
        }

        // 4. 활성 유저 확인
        if (!user.isActive) {
            throw IllegalArgumentException("비활성화된 계정입니다")
        }

        // 5. JWT 토큰 생성
        val token = jwtUtil.generateUserToken(user.id, user.employeeId)

        // 6. 활성 인증 방법 조회 (근무지 기본값 + 유저 오버라이드 머지)
        val enabledMethods = verificationService.getUserVerificationMethods(user.id)
            .methods
            .filter { it.enabled }
            .map { it.methodType }

        return AppLoginResponse(
            token = token,
            user = AppUserInfo(
                id = user.id,
                name = user.name,
                employeeId = user.employeeId,
                department = user.department,
                workplaceId = user.workplace?.id
            ),
            enabledMethods = enabledMethods
        )
    }
}

// 인증 실패 예외 (401 매핑용)
class AuthenticationFailedException(message: String) : RuntimeException(message)
