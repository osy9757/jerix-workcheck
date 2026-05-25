package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.CreateUserRequest
import com.workcheck.backend.dto.request.UpdateUserMethodRequest
import com.workcheck.backend.dto.response.UserListResponse
import com.workcheck.backend.dto.response.UserMethodResponse
import com.workcheck.backend.dto.response.UserMethodsResponse
import com.workcheck.backend.dto.response.UserResponse
import com.workcheck.backend.service.UserService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 직원 관리 API (v2: 근무지 엔드포인트 폐기, user-direct 인증 방법 CRUD)
@RestController
@RequestMapping("/api/v1/users")
class UserController(
    private val userService: UserService
) {
    // 직원 목록
    @GetMapping
    fun getUsers(): ResponseEntity<UserListResponse> {
        // MVP: 단일 회사 (companyId=1)
        return ResponseEntity.ok(userService.getUsers(1L))
    }

    // 직원 등록 (등록 시 5개 method row 자동 생성, 모두 disabled)
    @PostMapping
    fun createUser(@Valid @RequestBody request: CreateUserRequest): ResponseEntity<UserResponse> {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(request))
    }

    // 유저의 5개 method 전체 조회 (Admin Web 인증 페이지 진입 시)
    @GetMapping("/{userId}/methods")
    fun getUserMethods(@PathVariable userId: Long): ResponseEntity<UserMethodsResponse> {
        return ResponseEntity.ok(userService.getUserMethods(userId))
    }

    // 유저 단일 method upsert (토글 + 설정 저장)
    // methodType: GPS/WIFI/NFC/BEACON/QR (대소문자 무관)
    @PutMapping("/{userId}/methods/{methodType}")
    fun updateUserMethod(
        @PathVariable userId: Long,
        @PathVariable methodType: String,
        @Valid @RequestBody request: UpdateUserMethodRequest
    ): ResponseEntity<UserMethodResponse> {
        return ResponseEntity.ok(userService.updateUserMethod(userId, methodType, request))
    }
}
