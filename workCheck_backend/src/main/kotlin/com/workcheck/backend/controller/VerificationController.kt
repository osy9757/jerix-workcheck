package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.UpdateVerificationRequest
import com.workcheck.backend.dto.response.VerificationMethodListResponse
import com.workcheck.backend.dto.response.VerificationMethodResponse
import com.workcheck.backend.dto.response.WorkplaceConfigResponse
import com.workcheck.backend.service.VerificationService
import com.workcheck.backend.service.WorkplaceService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 기존 앱 호환용 엔드포인트 (첫 번째 근무지 기준)
@RestController
@RequestMapping("/api/v1/verification")
class VerificationController(
    private val verificationService: VerificationService,
    private val workplaceService: WorkplaceService
) {
    // 인증 방법 목록 (기존 앱 호환: 첫 번째 근무지 = workplaceId=1)
    @GetMapping("/methods")
    fun getMethods(): ResponseEntity<VerificationMethodListResponse> {
        // MVP: 첫 번째 근무지 (workplaceId=1)
        return ResponseEntity.ok(verificationService.getMethodsByWorkplace(1L))
    }

    // 특정 인증 방법 상세 조회
    @GetMapping("/methods/{id}")
    fun getMethod(@PathVariable id: Long): ResponseEntity<VerificationMethodResponse> {
        return ResponseEntity.ok(verificationService.getMethod(id))
    }

    // 인증 방법 수정 (ON/OFF + 설정)
    @PutMapping("/methods/{id}")
    fun updateMethod(
        @PathVariable id: Long,
        @RequestBody request: UpdateVerificationRequest
    ): ResponseEntity<VerificationMethodResponse> {
        return ResponseEntity.ok(verificationService.updateMethod(id, request))
    }
}
