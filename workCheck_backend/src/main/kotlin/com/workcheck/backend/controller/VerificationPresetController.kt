package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.VerificationPresetRequest
import com.workcheck.backend.dto.response.VerificationPresetResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.service.VerificationPresetService
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 인증 프리셋 카탈로그 API (자주 쓰는 GPS/WIFI/NFC/BEACON/QR 설정값을 이름 붙여 저장/재사용)
@RestController
@RequestMapping("/api/v1/verification-presets")
class VerificationPresetController(
    private val presetService: VerificationPresetService
) {
    // 목록 (methodType 필터 옵션)
    @GetMapping
    fun getAll(@RequestParam(required = false) methodType: MethodType?): ResponseEntity<List<VerificationPresetResponse>> {
        return ResponseEntity.ok(presetService.getAllPresets(methodType))
    }

    @GetMapping("/{id}")
    fun get(@PathVariable id: Long): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.ok(presetService.getPreset(id))
    }

    @PostMapping
    fun create(@Valid @RequestBody request: VerificationPresetRequest): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.status(HttpStatus.CREATED).body(presetService.createPreset(request))
    }

    @PutMapping("/{id}")
    fun update(
        @PathVariable id: Long,
        @Valid @RequestBody request: VerificationPresetRequest
    ): ResponseEntity<VerificationPresetResponse> {
        return ResponseEntity.ok(presetService.updatePreset(id, request))
    }

    @DeleteMapping("/{id}")
    fun delete(@PathVariable id: Long): ResponseEntity<Void> {
        presetService.deletePreset(id)
        return ResponseEntity.noContent().build()
    }
}
