package com.workcheck.backend.service

import com.workcheck.backend.dto.request.VerificationPresetRequest
import com.workcheck.backend.dto.response.VerificationPresetResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.VerificationPreset
import com.workcheck.backend.repository.VerificationPresetRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime

// 인증 프리셋 카탈로그 서비스 - 자주 쓰이는 NFC/WiFi/GPS/Beacon 값을 이름 붙여 저장/재사용
@Service
class VerificationPresetService(
    private val verificationPresetRepository: VerificationPresetRepository
) {
    // 프리셋 목록 조회 (methodType 필터 옵션)
    fun getAllPresets(methodType: MethodType?): List<VerificationPresetResponse> {
        val presets = if (methodType != null) {
            verificationPresetRepository.findAllByMethodTypeOrderByNameAsc(methodType)
        } else {
            verificationPresetRepository.findAllByOrderByMethodTypeAscNameAsc()
        }
        return presets.map { toResponse(it) }
    }

    // 단건 프리셋 조회
    fun getPreset(id: Long): VerificationPresetResponse {
        val preset = verificationPresetRepository.findById(id)
            .orElseThrow { IllegalArgumentException("프리셋을 찾을 수 없습니다: $id") }
        return toResponse(preset)
    }

    // 프리셋 생성
    @Transactional
    fun createPreset(request: VerificationPresetRequest): VerificationPresetResponse {
        validateName(request.name)

        val preset = verificationPresetRepository.save(
            VerificationPreset(
                name = request.name.trim(),
                methodType = request.methodType,
                configData = request.configData,
                memo = request.memo
            )
        )
        return toResponse(preset)
    }

    // 프리셋 수정 (전체 갱신)
    @Transactional
    fun updatePreset(id: Long, request: VerificationPresetRequest): VerificationPresetResponse {
        validateName(request.name)

        val preset = verificationPresetRepository.findById(id)
            .orElseThrow { IllegalArgumentException("프리셋을 찾을 수 없습니다: $id") }

        preset.name = request.name.trim()
        preset.methodType = request.methodType
        preset.configData = request.configData
        preset.memo = request.memo
        preset.updatedAt = OffsetDateTime.now()

        return toResponse(verificationPresetRepository.save(preset))
    }

    // 프리셋 삭제
    @Transactional
    fun deletePreset(id: Long) {
        if (!verificationPresetRepository.existsById(id)) {
            throw IllegalArgumentException("프리셋을 찾을 수 없습니다: $id")
        }
        verificationPresetRepository.deleteById(id)
    }

    // 이름 유효성 검증 (빈 값 거부)
    private fun validateName(name: String) {
        if (name.isBlank()) {
            throw IllegalArgumentException("프리셋 이름은 필수입니다")
        }
    }

    // 엔티티 → 응답 DTO 변환
    private fun toResponse(preset: VerificationPreset): VerificationPresetResponse {
        return VerificationPresetResponse(
            id = preset.id,
            name = preset.name,
            methodType = preset.methodType.name,
            configData = preset.configData,
            memo = preset.memo,
            createdAt = preset.createdAt,
            updatedAt = preset.updatedAt
        )
    }
}
