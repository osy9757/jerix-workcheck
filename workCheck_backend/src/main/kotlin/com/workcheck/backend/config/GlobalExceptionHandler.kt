package com.workcheck.backend.config

import com.workcheck.backend.service.AuthenticationFailedException
import com.workcheck.backend.service.DeviceNotAllowedException
import com.workcheck.backend.service.VerificationFailedException
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler

// 전역 예외 핸들러 - 애플리케이션 전체에서 발생하는 예외를 일관된 형식으로 처리
// ResponseEntityExceptionHandler 상속: @Valid 검증 실패(MethodArgumentNotValidException),
// 잘못된 JSON(HttpMessageNotReadableException), 미지원 메서드 등 Spring MVC 표준 예외를
// 부모가 올바른 4xx로 처리 → 아래 catch-all(Exception)은 진짜 예상외 예외(NPE 등)만 500으로 처리
@RestControllerAdvice
class GlobalExceptionHandler : ResponseEntityExceptionHandler() {

    companion object {
        private val logger = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)
    }

    // 잘못된 인자 예외 → 400 Bad Request
    @ExceptionHandler(IllegalArgumentException::class)
    fun handleIllegalArgument(e: IllegalArgumentException): ResponseEntity<Map<String, String>> {
        // 400 에러 원인 로깅 — 다양한 위치에서 발생하므로 예외 객체를 넘겨 스택트레이스로 원인 추적(테스트용)
        logger.warn("[Error] 400 Bad Request: ${e.message}", e)
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

    // 기기 바인딩 차단 → 403 + DEVICE_NOT_ALLOWED
    // ⚠️ Map 반환이라 Jackson SNAKE_CASE 미적용 → 키를 camelCase 리터럴로 직접 작성 (기존 errorCode 컨벤션과 일치)
    @ExceptionHandler(DeviceNotAllowedException::class)
    fun handleDeviceNotAllowed(e: DeviceNotAllowedException): ResponseEntity<Map<String, String>> {
        logger.warn("[Error] 403 Device Not Allowed: ${e.deviceStatus} - ${e.message}")
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
            .body(mapOf(
                "error" to (e.message ?: "등록되지 않은 기기입니다"),
                "errorCode" to "DEVICE_NOT_ALLOWED",
                "deviceStatus" to e.deviceStatus
            ))
    }

    // 포괄 예외 폴백 → 500 Internal Server Error
    // 위에서 처리하지 못한 예상치 못한 예외를 한곳에서 잡아 스택트레이스를 1회 기록(테스트 시 원인 파악용)
    @ExceptionHandler(Exception::class)
    fun handleUnexpected(e: Exception): ResponseEntity<Map<String, String>> {
        // 처리되지 않은 예외의 전체 스택트레이스 기록
        logger.error("처리되지 않은 예외 발생", e)
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(mapOf("error" to (e.message ?: "서버 내부 오류가 발생했습니다")))
    }
}
