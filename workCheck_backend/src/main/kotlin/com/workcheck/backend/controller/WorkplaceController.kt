package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.CreateWorkplaceRequest
import com.workcheck.backend.dto.request.UpdateWorkplaceRequest
import com.workcheck.backend.dto.response.VerificationMethodListResponse
import com.workcheck.backend.dto.response.VerificationMethodResponse
import com.workcheck.backend.dto.response.WorkplaceConfigResponse
import com.workcheck.backend.dto.response.WorkplaceListResponse
import com.workcheck.backend.dto.response.WorkplaceResponse
import com.workcheck.backend.dto.request.UpdateVerificationRequest
import com.workcheck.backend.service.VerificationService
import com.workcheck.backend.service.WorkplaceService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 근무지 관리 API 컨트롤러
@RestController
@RequestMapping("/api/v1/workplaces")
class WorkplaceController(
    private val workplaceService: WorkplaceService,
    private val verificationService: VerificationService
) {
    // 근무지 목록
    @GetMapping
    fun getWorkplaces(): ResponseEntity<WorkplaceListResponse> {
        // MVP: 단일 회사 (companyId=1)
        return ResponseEntity.ok(workplaceService.getWorkplaces(1L))
    }

    // 근무지 생성
    @PostMapping
    fun createWorkplace(@RequestBody request: CreateWorkplaceRequest): ResponseEntity<WorkplaceResponse> {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(workplaceService.createWorkplace(1L, request))
    }

    // 근무지 수정
    @PutMapping("/{id}")
    fun updateWorkplace(
        @PathVariable id: Long,
        @RequestBody request: UpdateWorkplaceRequest
    ): ResponseEntity<WorkplaceResponse> {
        return ResponseEntity.ok(workplaceService.updateWorkplace(id, request))
    }

    // 근무지 삭제
    @DeleteMapping("/{id}")
    fun deleteWorkplace(@PathVariable id: Long): ResponseEntity<Void> {
        workplaceService.deleteWorkplace(id)
        return ResponseEntity.noContent().build()
    }

    // 근무지의 인증 방법 목록
    @GetMapping("/{id}/verification-methods")
    fun getVerificationMethods(@PathVariable id: Long): ResponseEntity<VerificationMethodListResponse> {
        return ResponseEntity.ok(verificationService.getMethodsByWorkplace(id))
    }

    // 근무지 인증 방법 수정
    @PutMapping("/{id}/verification-methods/{methodId}")
    fun updateVerificationMethod(
        @PathVariable id: Long,
        @PathVariable methodId: Long,
        @RequestBody request: UpdateVerificationRequest
    ): ResponseEntity<VerificationMethodResponse> {
        return ResponseEntity.ok(verificationService.updateMethod(methodId, request))
    }

    // 앱용 활성 인증 방법 + 설정값 일괄 조회 (근무지 기준)
    @GetMapping("/{id}/config")
    fun getWorkplaceConfig(@PathVariable id: Long): ResponseEntity<WorkplaceConfigResponse> {
        return ResponseEntity.ok(workplaceService.getWorkplaceConfig(id))
    }
}
