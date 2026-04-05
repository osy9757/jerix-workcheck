package com.workcheck.backend.config

import com.workcheck.backend.service.AuthenticationFailedException
import com.workcheck.backend.service.VerificationFailedException
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

// 전역 예외 핸들러 - 애플리케이션 전체에서 발생하는 예외를 일관된 형식으로 처리
@RestControllerAdvice
class GlobalExceptionHandler {

    companion object {
        private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)
    }

    // 잘못된 인자 예외 → 400 Bad Request
    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgument(e: IllegalArgumentException): ResponseEntity<Map<String, String>> {
        // 400 에러 원인 로깅
        logger.warn("[Error] 400 Bad Request: ${e.message}")
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(mapOf("error" to (e.message ?: "잘못된 요청")))
    }

    // 인증 검증 실패 → 400 + errorCode (비콘 에러 분기 등)
    @ExceptionHandler(VerificationFailedException::class)
    fun handleVerificationFailed(e: VerificationFailedException): ResponseEntity<Map<String, String>> {
        logger.warn("[Error] 400 Verification Failed: ${e.errorCode} - ${e.message}")
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(mapOf(
                "error" to (e.message ?: "인증 검증 실패"),
                "errorCode" to e.errorCode.name
            ))
    }

    // 인증 실패 → 401
    @ExceptionHandler(AuthenticationFailedException::class)
    fun handleAuthenticationFailed(e: AuthenticationFailedException): ResponseEntity<Map<String, String>> {
        // 401 에러 원인 로깅
        logger.warn("[Error] 401 Unauthorized: ${e.message}")
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body(mapOf("error" to (e.message ?: "인증 실패")))
    }
}
