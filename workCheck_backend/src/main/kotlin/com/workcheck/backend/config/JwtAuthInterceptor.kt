package com.workcheck.backend.config

import com.workcheck.backend.util.JwtUtil
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.stereotype.Component
import org.springframework.web.servlet.HandlerInterceptor

// JWT 인증 인터셉터 - Authorization 헤더에서 Bearer 토큰 추출 후 userId를 request attribute에 설정
@Component
class JwtAuthInterceptor(
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

        val userId = jwtUtil.getUserIdFromToken(token)
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "토큰에서 사용자 ID를 추출할 수 없습니다")
            return false
        }

        // Controller에서 @RequestAttribute("userId")로 접근
        request.setAttribute("userId", userId)
        return true
    }
}
