package com.workcheck.backend.controller

import com.workcheck.backend.dto.request.UpdateDeviceBindingModeRequest
import com.workcheck.backend.dto.response.AdminDeviceResponse
import com.workcheck.backend.dto.response.AdminHistoryResponse
import com.workcheck.backend.dto.response.DeviceBindingModeResponse
import com.workcheck.backend.entity.DeviceStatus
import com.workcheck.backend.service.AttendanceService
import com.workcheck.backend.service.DeviceAdminService
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

// 관리자 전용 데이터 조회 API (로그인은 AuthController 로 분리됨)
@RestController
@RequestMapping("/api/v1/admin")
class AdminController(
    private val attendanceService: AttendanceService,
    private val deviceAdminService: DeviceAdminService
) {
    // 관리자용 전체 출퇴근 기록 조회 (모든 직원)
    @GetMapping("/attendance/records")
    fun getAttendanceRecords(
        @RequestParam from: String,
        @RequestParam to: String
    ): ResponseEntity<AdminHistoryResponse> {
        return ResponseEntity.ok(attendanceService.getAllHistory(from, to))
    }

    // 기기 승인 대기열/목록 조회 (status 필터 옵션) — 응답은 직접 배열 (presets 컨벤션)
    @GetMapping("/devices")
    fun getDevices(@RequestParam(required = false) status: DeviceStatus?): ResponseEntity<List<AdminDeviceResponse>> {
        return ResponseEntity.ok(deviceAdminService.listDevices(status))
    }

    // 기기 승인 (기존 APPROVED 교체) — 단일 객체 반환 (클라가 즉시 행 갱신)
    @PostMapping("/devices/{id}/approve")
    fun approveDevice(@PathVariable id: Long): ResponseEntity<AdminDeviceResponse> {
        return ResponseEntity.ok(deviceAdminService.approve(id))
    }

    // 기기 거부 — 단일 객체 반환
    @PostMapping("/devices/{id}/reject")
    fun rejectDevice(@PathVariable id: Long): ResponseEntity<AdminDeviceResponse> {
        return ResponseEntity.ok(deviceAdminService.reject(id))
    }

    // 기기 삭제 — row 제거 후 {"deleted":true} 반환 (관리자 JWT 필요: AdminJwtAuthInterceptor)
    @DeleteMapping("/devices/{id}")
    fun deleteDevice(@PathVariable id: Long): ResponseEntity<Map<String, Boolean>> {
        deviceAdminService.delete(id)
        return ResponseEntity.ok(mapOf("deleted" to true))
    }

    // [D4] 기기 등록 방식 조회 (AUTO/APPROVAL) — companyCode 쿼리파라미터 (기존 camelCase 컨벤션 유지)
    @GetMapping("/settings/device-binding")
    fun getDeviceBindingMode(@RequestParam companyCode: String): ResponseEntity<DeviceBindingModeResponse> {
        return ResponseEntity.ok(deviceAdminService.getBindingMode(companyCode))
    }

    // [D4] 기기 등록 방식 변경 — body {company_code, mode}
    @PutMapping("/settings/device-binding")
    fun updateDeviceBindingMode(@Valid @RequestBody request: UpdateDeviceBindingModeRequest): ResponseEntity<DeviceBindingModeResponse> {
        return ResponseEntity.ok(deviceAdminService.updateBindingMode(request.companyCode, request.mode))
    }
}
