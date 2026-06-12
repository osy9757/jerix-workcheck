package com.workcheck.backend.config

import com.workcheck.backend.util.JwtUtil
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Component
import org.springframework.web.servlet.HandlerInterceptor

// [BACKLOG] 관리자 JWT 인증 인터셉터 — /api/v1/admin/** 보호
// 기존 JwtAuthInterceptor 와 동일한 Bearer 추출/검증 + role=admin 검사 (앱 유저 토큰 차단)
@Component
class AdminJwtAuthInterceptor(
    private val jwtUtil: JwtUtil
) : HandlerInterceptor {

    override fun preHandle(request: HttpServletRequest, response: HttpServletResponse, handler: Any): Boolean {
        val authHeader = request.getHeader("Authorization")
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "JWT 토큰이 필요합니다")
            return false
        }

        val token = authHeader.substring(7)
        if (!jwtUtil.validateToken(token)) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "유효하지 않은 JWT 토큰입니다")
            return false
        }

        // role=admin 검사 — 앱 유저 토큰(role=user)으로 관리자 API 접근 차단 (403)
        if (jwtUtil.getRoleFromToken(token) != "admin") {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자 권한이 필요합니다")
            return false
        }

        val adminId = jwtUtil.getAdminIdFromToken(token)
        if (adminId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "토큰에서 관리자 ID를 추출할 수 없습니다")
            return false
        }

        // Controller 에서 @RequestAttribute("adminId") 로 접근 가능
        request.setAttribute("adminId", adminId)
        return true
    }
}
