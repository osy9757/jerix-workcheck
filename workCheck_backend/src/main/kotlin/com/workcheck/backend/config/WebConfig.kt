package com.workcheck.backend.config

import org.springframework.context.annotation.Configuration
import org.springframework.web.servlet.config.annotation.CorsRegistry
import org.springframework.web.servlet.config.annotation.InterceptorRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

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
