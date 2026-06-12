package com.workcheck.backend.service

import com.workcheck.backend.dto.request.AppLoginRequest
import com.workcheck.backend.dto.request.DeviceAccessRequest
import com.workcheck.backend.dto.request.DeviceStatusRequest
import com.workcheck.backend.dto.request.RegisterRequest
import com.workcheck.backend.dto.response.AppLoginResponse
import com.workcheck.backend.dto.response.AppUserInfo
import com.workcheck.backend.dto.response.DeviceAccessResponse
import com.workcheck.backend.entity.DeviceBindingMode
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

    // [BACKLOG] 세션 체크 (영속 자동로그인): JWT 검증 통과한 userId 로 기기 바인딩 재검증 + 토큰 재발급(슬라이딩 만료)
    // @Transactional: D4 이후 LAZY company 접근 + AUTO 모드 자동 바인딩 save 가 트랜잭션 안에서 실행돼야 함 (OSIV 의존 금지)
    // 잔여위험(MVP 수용): JwtAuthInterceptor 가 role 미검사 → admin 토큰 subject id 가 user id 와 충돌 시 통과 가능(존재 안 하면 401)
    @Transactional
    fun checkSession(userId: Long, deviceId: String?): AppLoginResponse {
        // 1. 유저 조회 (없거나 비활성 → 401)
        val user = userRepository.findById(userId).orElse(null)
            ?: throw AuthenticationFailedException("유효하지 않은 세션입니다")
        if (!user.isActive) {
            throw AuthenticationFailedException("비활성화된 계정입니다")
        }

        // 2. 기기 바인딩 재검증 (로그인과 동일 — 불일치 시 DeviceNotAllowedException → 403+deviceStatus)
        verifyDeviceBinding(user, deviceId)

        // 3. 토큰 재발급 (슬라이딩 만료)
        val token = jwtUtil.generateUserToken(user.id, user.employeeId)

        // 4. 활성 인증 방법 재조회
        val enabledMethods = verificationService.getActiveMethodTypes(user.id)
            .map { it.name.lowercase() }

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

    // 앱 회원가입: 관리자가 사전 등록한 미가입 직원(password_hash NULL) 에 비밀번호 설정 + 활성화
    // 인사정보 미등재/회사 불일치는 PPT 지정 통일 문구, 이미 가입된 사번은 명확 안내.
    @Transactional
    fun register(request: RegisterRequest) {
        // 1. 회사코드 미발견 → PPT 통일 문구
        val company = companyRepository.findByCode(request.companyCode)
            ?: throw IllegalArgumentException(MSG_HR_MISMATCH)

        // 2. 회사 + 사번 미발견(인사정보 미등재) → 동일 PPT 통일 문구
        val user = userRepository.findByCompanyIdAndEmployeeId(company.id, request.employeeId)
            ?: throw IllegalArgumentException(MSG_HR_MISMATCH)

        // 3. 이미 비밀번호가 설정됨 = 이미 가입 완료된 사번
        if (user.passwordHash != null) {
            throw IllegalArgumentException("이미 등록된 사원번호입니다")
        }

        // 4. 일치 + 미가입 → 비밀번호 설정 + 활성화 (가입 완료)
        user.passwordHash = passwordEncoder.encode(request.password)
        user.isActive = true
        userRepository.save(user)
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

    // 기기 상태 조회 (대기화면 5초 폴링용 — 비번 미포함 읽기전용)
    // 인사정보 미발견 시 정보누출 방지 위해 예외 대신 status="NONE" 통일 반환
    @Transactional(readOnly = true)
    fun getDeviceStatus(request: DeviceStatusRequest): DeviceAccessResponse {
        // 회사코드 → 회사 (미발견 시 NONE)
        val company = companyRepository.findByCode(request.companyCode)
            ?: return DeviceAccessResponse(status = "NONE", message = "등록된 기기 정보가 없습니다")
        // 회사 + 사번 → 유저 (미발견 시 NONE)
        val user = userRepository.findByCompanyIdAndEmployeeId(company.id, request.employeeId)
            ?: return DeviceAccessResponse(status = "NONE", message = "등록된 기기 정보가 없습니다")

        // 기기 row 조회 → 상태별 안내 문구
        val device = userDeviceRepository.findByUserIdAndDeviceId(user.id, request.deviceId)
            ?: return DeviceAccessResponse(status = "NONE", message = "등록된 기기 정보가 없습니다")

        val message = when (device.status) {
            DeviceStatus.APPROVED -> "기기가 승인되었습니다. 접속할 수 있습니다"
            DeviceStatus.PENDING -> "관리자 승인을 기다리는 중입니다"
            DeviceStatus.REJECTED -> "기기 접속 요청이 거부되었습니다"
        }
        return DeviceAccessResponse(status = device.status.name, message = message)
    }

    // 기기 접근 요청 취소 (대기화면 '요청취소' → 서버 PENDING row 완전 삭제)
    // 무단 취소 방지 위해 비번 포함 재검증. PENDING 만 삭제하고 APPROVED/REJECTED 는 보존.
    @Transactional
    fun cancelDeviceRequest(request: DeviceAccessRequest): DeviceAccessResponse {
        // 자격 재검증 (비번 포함 — 틀리면 401)
        val user = authenticate(request.companyCode, request.employeeId, request.password)

        val device = userDeviceRepository.findByUserIdAndDeviceId(user.id, request.deviceId)
            ?: return DeviceAccessResponse(status = "NONE", message = "취소할 기기 요청이 없습니다")

        return when (device.status) {
            // 대기 중 요청 → row 삭제 후 CANCELED 반환
            DeviceStatus.PENDING -> {
                userDeviceRepository.delete(device)
                DeviceAccessResponse(status = "CANCELED", message = "기기 접속 요청을 취소했습니다")
            }
            // 이미 승인된 기기 → 삭제 거부 (취소 불가)
            DeviceStatus.APPROVED ->
                DeviceAccessResponse(status = "APPROVED", message = "이미 승인된 기기는 취소할 수 없습니다")
            // 거부 이력 → 삭제하지 않고 그대로 반환
            DeviceStatus.REJECTED ->
                DeviceAccessResponse(status = "REJECTED", message = "거부된 기기 요청입니다")
        }
    }

    // 자격 검증 공통 로직 (회사/사번/비번/활성) → User 반환
    private fun authenticate(companyCode: String, employeeId: String, password: String): User {
        // 1. 회사코드로 회사 찾기 (PPT 지정 문구: 인사정보 불일치는 사유 노출 없이 통일)
        val company = companyRepository.findByCode(companyCode)
            ?: throw IllegalArgumentException(MSG_HR_MISMATCH)

        // 2. 회사 + 사원번호로 유저 찾기 (PPT 지정 문구: 회사코드 미발견과 동일 문구)
        val user = userRepository.findByCompanyIdAndEmployeeId(company.id, employeeId)
            ?: throw IllegalArgumentException(MSG_HR_MISMATCH)

        // 3. 미가입자(비밀번호 미설정) 로그인 시도 → NPE 방지 + PPT 통일 문구
        val hash = user.passwordHash
            ?: throw IllegalArgumentException(MSG_HR_MISMATCH)

        // 4. 비밀번호 검증 (BCrypt)
        if (!passwordEncoder.matches(password, hash)) {
            throw AuthenticationFailedException("비밀번호가 일치하지 않습니다")
        }

        // 5. 활성 유저 확인
        if (!user.isActive) {
            throw IllegalArgumentException("비활성화된 계정입니다")
        }
        return user
    }

    companion object {
        // PPT 지정 통일 문구 (회사/사번/미가입 불일치 모두 동일 — 정보누출 방지)
        private const val MSG_HR_MISMATCH = "입력한 정보가 일치하지 않습니다. 인사부서에 문의하세요"
    }

    // 기기 바인딩 상태머신 (자격검증 통과 후 호출)
    // deviceId 가 null 이면 구버전 앱 → 검증 스킵(점진 롤아웃)
    // 신규 판정 규칙: '바인드된 기기(APPROVED) 유무' 로만 판단 (이력 기기 차단 옵션A 제거)
    private fun verifyDeviceBinding(user: User, deviceId: String?) {
        if (deviceId == null) return  // 구버전 호환: 기기검증 스킵

        // 이 유저의 APPROVED(바인드) 기기 조회 (유저당 1대)
        val approved = userDeviceRepository.findFirstByUserIdAndStatus(user.id, DeviceStatus.APPROVED)

        if (approved == null) {
            // [D4] 바인드된 기기 없음 → 회사의 기기 등록 방식(AUTO/APPROVAL)에 따라 분기
            //   APPROVAL(b안): 자동 승인하지 않고 403 차단 → 앱이 기존 NONE_MATCH/PENDING/REJECTED 분기 재사용
            //   (login 이 @Transactional 이라 LAZY company 접근 안전)
            if (user.company.deviceBindingMode == DeviceBindingMode.APPROVAL) {
                val existing = userDeviceRepository.findByUserIdAndDeviceId(user.id, deviceId)
                throw DeviceNotAllowedException(
                    deviceStatus = existing?.status?.name ?: "NONE_MATCH",
                    message = "등록된 기기가 아닙니다. 관리자 승인 후 이용 가능합니다"
                )
            }

            // AUTO(a안): 신규 계정/재바인딩 → 현재 기기를 자동 승인
            val existing = userDeviceRepository.findByUserIdAndDeviceId(user.id, deviceId)
            if (existing != null) {
                // 이 기기의 기존 row(PENDING/REJECTED 이력) 가 있으면 그 row 를 APPROVED 로 전환
                existing.status = DeviceStatus.APPROVED
                existing.approvedAt = OffsetDateTime.now()
                userDeviceRepository.save(existing)
            } else {
                // 기존 row 없음 → 새 APPROVED row 생성
                userDeviceRepository.save(
                    UserDevice(
                        user = user,
                        deviceId = deviceId,
                        status = DeviceStatus.APPROVED,
                        requestedAt = OffsetDateTime.now(),
                        approvedAt = OffsetDateTime.now()
                    )
                )
            }
            return  // 통과
        }

        // 바인드 기기 있음 → deviceId 일치 여부
        if (approved.deviceId == deviceId) {
            return  // 일치 → 통과
        }
        // 불일치 → 다른 기기로 로그인 시도 (대리 출퇴근 의심)
        // 이 기기의 기존 row 상태로 앱 UI 분기 (없으면 NONE_MATCH)
        val existing = userDeviceRepository.findByUserIdAndDeviceId(user.id, deviceId)
        throw DeviceNotAllowedException(
            deviceStatus = existing?.status?.name ?: "NONE_MATCH",  // "PENDING" | "REJECTED" | "NONE_MATCH"
            message = "등록된 기기가 아닙니다. 관리자에게 기기 등록을 요청하세요"
        )
    }
}

// 인증 실패 예외 (401 매핑용)
class AuthenticationFailedException(message: String) : RuntimeException(message)
