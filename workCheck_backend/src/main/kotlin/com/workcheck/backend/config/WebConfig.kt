package com.workcheck.backend.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

// 웹 MVC 설정 - CORS 정책과 JWT 인터셉터 등록을 관리
@Configuration
class WebConfig(
    private val jwtAuthInterceptor: JwtAuthInterceptor
) : WebMvcConfigurer {
    // MVP: CORS 전체 허용
    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/**")
            .allowedOrigins("*")
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
    }

    // JWT 인증 인터셉터 등록 - 출퇴근 + 근무지 설정 API에 적용
    override fun addInterceptors(registry: InterceptorRegistry) {
        registry.addInterceptor(jwtAuthInterceptor)
            .addPathPatterns("/api/v1/attendance/**")
            .addPathPatterns("/api/v1/workplace/config")
    }
}
