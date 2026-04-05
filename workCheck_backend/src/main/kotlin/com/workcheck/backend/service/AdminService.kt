package com.workcheck.backend.service

import com.workcheck.backend.dto.request.AdminLoginRequest
import com.workcheck.backend.dto.response.AdminInfo
import com.workcheck.backend.dto.response.AdminLoginResponse
import com.workcheck.backend.repository.AdminUserRepository
import com.workcheck.backend.util.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

// 관리자 계정 인증 및 토큰 발급 서비스
@Service
class AdminService(
    private val adminUserRepository: AdminUserRepository,
    private val jwtUtil: JwtUtil,
    private val passwordEncoder: PasswordEncoder
) {
    // 관리자 로그인: 사용자명 + 비밀번호 검증 후 JWT 토큰 반환
    fun login(request: AdminLoginRequest): AdminLoginResponse {
        val admin = adminUserRepository.findByUsername(request.username)
            ?: throw IllegalArgumentException("관리자를 찾을 수 없습니다")

        if (!passwordEncoder.matches(request.password, admin.passwordHash)) {
            throw IllegalArgumentException("비밀번호가 일치하지 않습니다")
        }

        val token = jwtUtil.generateToken(admin.id, admin.username)
        return AdminLoginResponse(
            token = token,
            admin = AdminInfo(id = admin.id, username = admin.username)
        )
    }
}
