package com.workcheck.backend.util

import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.*
import javax.crypto.SecretKey

// JWT 토큰 생성 및 검증 유틸리티
@Component
class JwtUtil(
    @Value("\${jwt.secret}") private val secret: String,
    @Value("\${jwt.expiration}") private val expiration: Long
) {
    // HMAC-SHA 알고리즘용 서명 키 (지연 초기화)
    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(secret.toByteArray())
    }

    // 관리자 JWT 토큰 생성
    fun generateToken(adminId: Long, username: String): String {
        return Jwts.builder()
            .subject(adminId.toString())
            .claim("username", username)
            .claim("role", "admin")
            .issuedAt(Date())
            .expiration(Date(System.currentTimeMillis() + expiration))
            .signWith(key)
            .compact()
    }

    // 앱 유저 JWT 토큰 생성
    fun generateUserToken(userId: Long, employeeId: String): String {
        return Jwts.builder()
            .subject(userId.toString())
            .claim("employee_id", employeeId)
            .claim("role", "user")
            .issuedAt(Date())
            .expiration(Date(System.currentTimeMillis() + expiration))
            .signWith(key)
            .compact()
    }

    // JWT 토큰에서 userId 추출 (subject = userId)
    fun getUserIdFromToken(token: String): Long? {
        return getAdminIdFromToken(token)
    }

    // JWT 토큰에서 관리자 ID 추출
    fun getAdminIdFromToken(token: String): Long? {
        return try {
            val claims = Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
                .payload
            claims.subject.toLong()
        } catch (e: Exception) {
            null
        }
    }

    // JWT 토큰 유효성 검증
    fun validateToken(token: String): Boolean {
        return try {
            Jwts.parser()
                .verifyWith(key)
                .build()
                .parseSignedClaims(token)
            true
        } catch (e: Exception) {
            false
        }
    }
}
