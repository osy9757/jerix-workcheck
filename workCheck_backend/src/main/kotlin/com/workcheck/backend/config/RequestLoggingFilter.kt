package com.workcheck.backend.config

import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import org.springframework.web.util.ContentCachingRequestWrapper
import org.springframework.web.util.ContentCachingResponseWrapper

// 모든 HTTP 요청/응답을 로깅하는 필터
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
class RequestLoggingFilter : OncePerRequestFilter() {

    companion object {
        private val log = LoggerFactory.getLogger(RequestLoggingFilter::class.java)
    }

    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain
    ) {
        val cachedRequest = ContentCachingRequestWrapper(request)
        val cachedResponse = ContentCachingResponseWrapper(response)

        val startTime = System.currentTimeMillis()

        log.info("====== REQUEST START ======")
        log.info("[REQ] {} {} from {}", request.method, request.requestURI, request.remoteAddr)
        log.info("[REQ] Query: {}", request.queryString ?: "none")
        log.info("[REQ] Content-Type: {}", request.contentType ?: "none")
        log.info("[REQ] Authorization: {}", request.getHeader("Authorization")?.let {
            if (it.length > 20) "${it.substring(0, 20)}..." else it
        } ?: "none")

        try {
            filterChain.doFilter(cachedRequest, cachedResponse)
        } finally {
            val duration = System.currentTimeMillis() - startTime

            // 요청 바디 로깅
            val requestBody = String(cachedRequest.contentAsByteArray, Charsets.UTF_8)
            if (requestBody.isNotBlank()) {
                log.info("[REQ] Body: {}", requestBody)
            }

            // 응답 로깅
            val responseBody = String(cachedResponse.contentAsByteArray, Charsets.UTF_8)
            log.info("[RES] Status: {} | Duration: {}ms", cachedResponse.status, duration)
            if (responseBody.isNotBlank()) {
                log.info("[RES] Body: {}", if (responseBody.length > 2000) "${responseBody.substring(0, 2000)}..." else responseBody)
            }
            log.info("====== REQUEST END ({} {} -> {} in {}ms) ======", request.method, request.requestURI, cachedResponse.status, duration)

            // 반드시 응답 바디를 원래 response에 복사
            cachedResponse.copyBodyToResponse()
        }
    }
}
