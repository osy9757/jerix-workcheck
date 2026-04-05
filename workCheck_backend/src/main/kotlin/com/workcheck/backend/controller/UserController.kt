package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.CreateUserRequest
import com.workcheck.backend.dto.request.UpdateUserVerificationRequest
import com.workcheck.backend.dto.response.UserListResponse
import com.workcheck.backend.dto.response.UserResponse
import com.workcheck.backend.dto.response.UserVerificationListResponse
import com.workcheck.backend.service.UserService
import com.workcheck.backend.service.VerificationService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 직원 관리 API 컨트롤러
@RestController
@RequestMapping("/api/v1/users")
class UserController(
    private val userService: UserService,
    private val verificationService: VerificationService
) {
    // 직원 목록
    @GetMapping
    fun getUsers(): ResponseEntity<UserListResponse> {
        // MVP: 단일 회사 (companyId=1)
        return ResponseEntity.ok(userService.getUsers(1L))
    }

    // 직원 등록
    @PostMapping
    fun createUser(@Valid @RequestBody request: CreateUserRequest): ResponseEntity<UserResponse> {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(request))
    }

    // 유저 근무지 배정
    @PutMapping("/{userId}/workplace")
    fun assignWorkplace(
        @PathVariable userId: Long,
        @RequestBody body: Map<String, Long>
    ): ResponseEntity<UserResponse> {
        val workplaceId = body["workplace_id"]
            ?: throw IllegalArgumentException("workplace_id가 필요합니다")
        return ResponseEntity.ok(userService.assignWorkplace(userId, workplaceId))
    }

    // 유저의 실제 인증 방법 조회 (근무지 기본 + 오버라이드 머지)
    @GetMapping("/{userId}/verification-methods")
    fun getUserVerificationMethods(
        @PathVariable userId: Long
    ): ResponseEntity<UserVerificationListResponse> {
        return ResponseEntity.ok(verificationService.getUserVerificationMethods(userId))
    }

    // 유저 인증 오버라이드 설정
    @PutMapping("/{userId}/verification-overrides")
    fun setUserVerificationOverride(
        @PathVariable userId: Long,
        @RequestBody request: UpdateUserVerificationRequest
    ): ResponseEntity<Void> {
        userService.setUserVerificationOverride(userId, request)
        return ResponseEntity.ok().build()
    }

    // 유저 인증 오버라이드 삭제 (근무지 기본으로 복귀)
    @DeleteMapping("/{userId}/verification-overrides/{methodType}")
    fun deleteUserVerificationOverride(
        @PathVariable userId: Long,
        @PathVariable methodType: String
    ): ResponseEntity<Void> {
        userService.deleteUserVerificationOverride(userId, methodType)
        return ResponseEntity.noContent().build()
    }
}
