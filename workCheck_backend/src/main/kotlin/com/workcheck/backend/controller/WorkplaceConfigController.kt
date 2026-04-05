package com.workcheck.backend.controller

import com.workcheck.backend.dto.response.WorkplaceConfigResponse
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.service.WorkplaceService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 앱용 - /api/v1/workplace/config (JWT 토큰에서 사용자의 근무지 자동 조회)
@RestController
@RequestMapping("/api/v1/workplace")
class WorkplaceConfigController(
    private val workplaceService: WorkplaceService,
    private val userRepository: UserRepository
) {
    // 근무지 설정 조회 (로그인 사용자의 근무지 기준)
    @GetMapping("/config")
    fun getConfig(@RequestAttribute userId: Long): ResponseEntity<WorkplaceConfigResponse> {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다") }
        val workplaceId = user.workplace?.id
            ?: throw IllegalArgumentException("사용자에게 배정된 근무지가 없습니다")
        return ResponseEntity.ok(workplaceService.getWorkplaceConfig(workplaceId))
    }
}
