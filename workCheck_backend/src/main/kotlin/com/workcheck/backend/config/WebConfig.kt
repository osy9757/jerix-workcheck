package com.workcheck.backend.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

// 웹 MVC 설정 - CORS 정책과 JWT 인터셉터 등록을 관리
@Configuration
class WebConfig(
    private val jwtAuthInterceptor: JwtAuthInterceptor,
    private val adminJwtAuthInterceptor: AdminJwtAuthInterceptor
) : WebMvcConfigurer {
    // MVP: CORS 전체 허용
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
    }

    // JWT 인증 인터셉터 등록
    override fun addInterceptors(registry: InterceptorRegistry) {
        // ① 앱 유저 JWT — 출퇴근 API + 세션 체크([BACKLOG] 영속 자동로그인)
        registry.addInterceptor(jwtAuthInterceptor)
            .addPathPatterns("/api/v1/attendance/**", "/api/v1/auth/session")

        // ② 관리자 JWT(role=admin) — 관리자 API 보호 ([BACKLOG])
        //    관리자 로그인(/api/v1/auth/admin/login)은 /admin/** 경로 밖이라 제외 불필요
        registry.addInterceptor(adminJwtAuthInterceptor)
            .addPathPatterns("/api/v1/admin/**")
    }
}
