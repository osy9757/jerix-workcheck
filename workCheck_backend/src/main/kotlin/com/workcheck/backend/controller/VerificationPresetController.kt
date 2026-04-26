package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.VerificationPresetRequest
import com.workcheck.backend.dto.response.VerificationPresetResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.service.VerificationPresetService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 인증 프리셋 카탈로그 API 컨트롤러 (관리자 웹 전용)
@RestController
@RequestMapping("/api/v1/verification-presets")
class VerificationPresetController(
    private val verificationPresetService: VerificationPresetService
) {
    // 프리셋 목록 조회 (methodType 필터 옵션)
    @GetMapping
    fun getPresets(
        @RequestParam(required = false) methodType: MethodType?
    ): ResponseEntity<List<VerificationPresetResponse>> {
        return ResponseEntity.ok(verificationPresetService.getAllPresets(methodType))
    }

    // 프리셋 단건 조회
    @GetMapping("/{id}")
    fun getPreset(@PathVariable id: Long): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.ok(verificationPresetService.getPreset(id))
    }

    // 프리셋 생성
    @PostMapping
    fun createPreset(
        @RequestBody request: VerificationPresetRequest
    ): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(verificationPresetService.createPreset(request))
    }

    // 프리셋 수정
    @PutMapping("/{id}")
    fun updatePreset(
        @PathVariable id: Long,
        @RequestBody request: VerificationPresetRequest
    ): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.ok(verificationPresetService.updatePreset(id, request))
    }

    // 프리셋 삭제
    @DeleteMapping("/{id}")
    fun deletePreset(@PathVariable id: Long): ResponseEntity<Void> {
        verificationPresetService.deletePreset(id)
        return ResponseEntity.noContent().build()
    }
}
