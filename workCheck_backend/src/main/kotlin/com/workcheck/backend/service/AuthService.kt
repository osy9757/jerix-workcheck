package com.workcheck.backend.service

import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.request.DeviceAccessRequest
import com.workcheck.backend.dto.response.AppLoginResponse
import com.workcheck.backend.dto.response.AppUserInfo
import com.workcheck.backend.dto.response.DeviceAccessResponse
import com.workcheck.backend.entity.DeviceStatus
import com.workcheck.backend.entity.User
import com.workcheck.backend.entity.UserDevice
import com.workcheck.backend.repository.CompanyRepository
import com.workcheck.backend.repository.UserDeviceRepository
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.util.JwtUtil
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime

// 앱 사용자 로그인 인증 및 토큰 발급 서비스
@Service
class AuthService(
    private val companyRepository: CompanyRepository,
    private val userRepository: UserRepository,
    private val userDeviceRepository: UserDeviceRepository,
    private val verificationService: VerificationService,
    private val jwtUtil: JwtUtil,
    private val passwordEncoder: PasswordEncoder
) {
    // 앱 로그인: 회사코드 + 사원번호 + 비밀번호 (+ 기기 식별자)
    // @Transactional: 첫 기기 자동 APPROVED row 생성이 트랜잭션 안에서 일어나야 함
    @Transactional
    fun login(request: AppLoginRequest): AppLoginResponse {
        // 1~4. 자격(회사/사번/비번/활성) 검증
        val user = authenticate(request.companyCode, request.employeeId, request.password)

        // 5. 기기 바인딩 상태머신 (deviceId 동봉 시에만 — null 이면 구버전 호환으로 스킵)
        verifyDeviceBinding(user, request.deviceId)

        // 6. JWT 토큰 생성
        val token = jwtUtil.generateUserToken(user.id, user.employeeId)

        // 7. 활성 인증 방법 조회 (v2: user_verification_methods 의 is_enabled=TRUE 만)
        val enabledMethods = verificationService.getActiveMethodTypes(user.id)
            .map { it.name.lowercase() }  // API 응답은 소문자 키 (gps,wifi,nfc,beacon,qr)

        return AppLoginResponse(
            token = token,
            user = AppUserInfo(
                id = user.id,
                name = user.name,
                employeeId = user.employeeId,
                department = user.department
            ),
            enabledMethods = enabledMethods
        )
    }

    // 기기 접근 요청: 새 기기를 PENDING 으로 등록 (관리자 승인 대기)
    // 인사정보 + 비번 재검증으로 무단 PENDING 생성 방지. 멱등(이미 존재하면 상태에 따라 처리).
    @Transactional
    fun requestDeviceAccess(request: DeviceAccessRequest): DeviceAccessResponse {
        // 자격 재검증
        val user = authenticate(request.companyCode, request.employeeId, request.password)

        // 기존 row 조회 (멱등 처리)
        val existing = userDeviceRepository.findByUserIdAndDeviceId(user.id, request.deviceId)
        if (existing != null) {
            when (existing.status) {
                // 이미 승인된 기기 → 그대로 안내
                DeviceStatus.APPROVED ->
                    return DeviceAccessResponse(status = "APPROVED", message = "이미 승인된 기기입니다")
                // 이미 요청 대기 중 → 멱등 (중복 요청 무시)
                DeviceStatus.PENDING ->
                    return DeviceAccessResponse(status = "PENDING", message = "이미 승인 요청된 기기입니다. 관리자 승인을 기다려주세요")
                // 거부 이력 → PENDING 으로 되돌림 허용 (관리자 재판단)
                DeviceStatus.REJECTED -> {
                    existing.status = DeviceStatus.PENDING
                    existing.requestedAt = OffsetDateTime.now()
                    existing.approvedAt = null
                    userDeviceRepository.save(existing)
                    return DeviceAccessResponse(status = "PENDING", message = "기기 승인을 다시 요청했습니다. 관리자 승인을 기다려주세요")
                }
            }
        }

        // 신규 row → PENDING 생성
        userDeviceRepository.save(
            UserDevice(
                user = user,
                deviceId = request.deviceId,
                status = DeviceStatus.PENDING,
                requestedAt = OffsetDateTime.now()
            )
        )
        return DeviceAccessResponse(status = "PENDING", message = "기기 승인을 요청했습니다. 관리자 승인을 기다려주세요")
    }

    // 자격 검증 공통 로직 (회사/사번/비번/활성) → User 반환
    private fun authenticate(companyCode: String, employeeId: String, password: String): User {
        // 1. 회사코드로 회사 찾기 (PPT 지정 문구: 인사정보 불일치는 사유 노출 없이 통일)
        val company = companyRepository.findByCode(companyCode)
            ?: throw IllegalArgumentException("입력한 정보가 일치하지 않습니다. 인사부서에 문의하세요")

        // 2. 회사 + 사원번호로 유저 찾기 (PPT 지정 문구: 회사코드 미발견과 동일 문구)
        val user = userRepository.findByCompanyIdAndEmployeeId(company.id, employeeId)
            ?: throw IllegalArgumentException("입력한 정보가 일치하지 않습니다. 인사부서에 문의하세요")

        // 3. 비밀번호 검증 (BCrypt)
        if (!passwordEncoder.matches(password, user.passwordHash)) {
            throw AuthenticationFailedException("비밀번호가 일치하지 않습니다")
        }

        // 4. 활성 유저 확인
        if (!user.isActive) {
            throw IllegalArgumentException("비활성화된 계정입니다")
        }
        return user
    }

    // 기기 바인딩 상태머신 (자격검증 통과 후 호출)
    // deviceId 가 null 이면 구버전 앱 → 검증 스킵(점진 롤아웃)
    private fun verifyDeviceBinding(user: User, deviceId: String?) {
        if (deviceId == null) return  // 구버전 호환: 기기검증 스킵

        // 이 유저의 APPROVED 기기 조회 (유저당 1대)
        val approved = userDeviceRepository.findFirstByUserIdAndStatus(user.id, DeviceStatus.APPROVED)

        if (approved == null) {
            // APPROVED 없음 → 이 device_id 의 기존 row 확인
            val existing = userDeviceRepository.findByUserIdAndDeviceId(user.id, deviceId)
            if (existing == null) {
                // 첫 기기 (row 없음) → 자동 APPROVED 생성 후 통과
                userDeviceRepository.save(
                    UserDevice(
                        user = user,
                        deviceId = deviceId,
                        status = DeviceStatus.APPROVED,
                        requestedAt = OffsetDateTime.now(),
                        approvedAt = OffsetDateTime.now()
                    )
                )
                return  // 통과
            }
            // 옵션A: 이미 PENDING/REJECTED 이력이 있는 기기는 자동승급 금지 → 차단
            throw DeviceNotAllowedException(
                deviceStatus = existing.status.name,  // "PENDING" | "REJECTED"
                message = "관리자 승인이 필요한 기기입니다"
            )
        }

        // APPROVED 있음 → deviceId 일치 여부
        if (approved.deviceId == deviceId) {
            return  // 일치 → 통과
        }
        // 불일치 → 다른 기기로 로그인 시도 (대리 출퇴근 의심)
        throw DeviceNotAllowedException(
            deviceStatus = "NONE_MATCH",
            message = "등록된 기기가 아닙니다. 관리자에게 기기 등록을 요청하세요"
        )
    }
}

// 인증 실패 예외 (401 매핑용)
class AuthenticationFailedException(message: String) : RuntimeException(message)
