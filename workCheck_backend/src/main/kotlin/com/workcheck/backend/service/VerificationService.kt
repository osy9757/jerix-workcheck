package com.workcheck.backend.service

import com.workcheck.backend.dto.request.UpdateVerificationRequest
import com.workcheck.backend.dto.response.VerificationMethodListResponse
import com.workcheck.backend.dto.response.VerificationMethodResponse
import com.workcheck.backend.dto.response.UserVerificationListResponse
import com.workcheck.backend.dto.response.UserVerificationResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.VerificationMethod
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.repository.UserVerificationOverrideRepository
import com.workcheck.backend.repository.VerificationConfigRepository
import com.workcheck.backend.repository.VerificationMethodRepository
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import kotlin.math.*

// 근무지 인증 방법 관리 및 출퇴근 인증 데이터 검증 서비스
@Service
class VerificationService(
    private val verificationMethodRepository: VerificationMethodRepository,
    private val verificationConfigRepository: VerificationConfigRepository,
    private val userRepository: UserRepository,
    private val userVerificationOverrideRepository: UserVerificationOverrideRepository
) {
    companion object {
        private val logger = LoggerFactory.getLogger(VerificationService::class.java)
    }

    // 근무지의 전체 인증 방법 목록
    fun getMethodsByWorkplace(workplaceId: Long): VerificationMethodListResponse {
        val methods = verificationMethodRepository.findAllByWorkplaceId(workplaceId)
        return VerificationMethodListResponse(
            methods = methods.map { toResponse(it) }
        )
    }

    // 특정 인증 방법 상세
    fun getMethod(methodId: Long): VerificationMethodResponse {
        val method = verificationMethodRepository.findById(methodId)
            .orElseThrow { IllegalArgumentException("인증 방법을 찾을 수 없습니다: $methodId") }
        return toResponse(method)
    }

    // 인증 방법 수정 (ON/OFF + 설정)
    @Transactional
    fun updateMethod(methodId: Long, request: UpdateVerificationRequest): VerificationMethodResponse {
        val method = verificationMethodRepository.findById(methodId)
            .orElseThrow { IllegalArgumentException("인증 방법을 찾을 수 없습니다: $methodId") }

        // enabled 토글
        request.enabled?.let { method.isEnabled = it }
        method.updatedAt = OffsetDateTime.now()
        verificationMethodRepository.save(method)

        // config 수정
        request.config?.let { newConfig ->
            val config = verificationConfigRepository.findByVerificationMethodId(methodId)
                ?: throw IllegalArgumentException("설정을 찾을 수 없습니다: $methodId")
            config.configData = newConfig
            config.updatedAt = OffsetDateTime.now()
            verificationConfigRepository.save(config)
        }

        return toResponse(method)
    }

    // 유저의 실제 인증 방법 조회 (근무지 무관, 8가지 항상 반환)
    fun getUserVerificationMethods(userId: Long): UserVerificationListResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }

        // 유저 오버라이드 로드
        val overrides = userVerificationOverrideRepository.findAllByUserId(userId)
        val overrideMap = overrides.associateBy { it.methodType }

        // 근무지 기본값 (배정된 경우에만 참조용 기본값으로 사용)
        val workplaceMethodMap = user.workplace?.let { wp ->
            verificationMethodRepository.findAllByWorkplaceId(wp.id).associateBy { it.methodType }
        } ?: emptyMap()

        // 8가지 메서드 타입 모두 반환 (override > 근무지 기본 > 기본값(disabled/empty))
        // QR 은 카탈로그 전용 타입이라 사용자 인증 수단 노출에서 제외
        val methods = MethodType.values().filter { it != MethodType.QR }.map { type ->
            val override = overrideMap[type]
            val workplaceMethod = workplaceMethodMap[type]
            val workplaceConfig = workplaceMethod?.let { verificationConfigRepository.findByVerificationMethodId(it.id) }

            if (override != null) {
                // 오버라이드 사용 (config 비어 있으면 근무지 기본 config로 fallback)
                UserVerificationResponse(
                    methodType = type.name,
                    enabled = override.isEnabled,
                    config = override.configData.ifEmpty { workplaceConfig?.configData ?: emptyMap() },
                    isOverridden = true
                )
            } else if (workplaceMethod != null) {
                // 근무지 기본 사용
                UserVerificationResponse(
                    methodType = type.name,
                    enabled = workplaceMethod.isEnabled,
                    config = workplaceConfig?.configData ?: emptyMap(),
                    isOverridden = false
                )
            } else {
                // 근무지 미배정 & 오버라이드 없음 → 비활성 + 빈 config
                UserVerificationResponse(
                    methodType = type.name,
                    enabled = false,
                    config = emptyMap(),
                    isOverridden = false
                )
            }
        }

        return UserVerificationListResponse(methods = methods, total = methods.size)
    }

    // 인증 데이터 검증 - 근무지 기본 + 유저 오버라이드 반영
    fun verify(userId: Long, verificationMethod: String, verificationData: Map<String, Any>): VerificationMethod {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다") }

        val workplace = user.workplace
            ?: throw IllegalArgumentException("사용자에게 배정된 근무지가 없습니다")

        // 유저 오버라이드 확인
        val overrides = userVerificationOverrideRepository.findAllByUserId(userId)
        val overrideMap = overrides.associateBy { it.methodType }

        // 오버라이드 반영: enabled 상태가 오버라이드된 경우 그 값 사용
        val effectiveMethods = verificationMethodRepository.findAllByWorkplaceId(workplace.id)
            .filter { method ->
                val override = overrideMap[method.methodType]
                if (override != null) override.isEnabled else method.isEnabled
            }

        val matchedMethod = findMatchingMethod(effectiveMethods, verificationMethod)
            ?: throw IllegalArgumentException("활성화된 인증 방법이 아닙니다: $verificationMethod")

        logger.info("[Verify] userId=$userId, method=${matchedMethod.methodType}, workplace=${workplace.name}")

        // 설정값: 오버라이드 config가 있으면 오버라이드, 없으면 근무지 기본
        val override = overrideMap[matchedMethod.methodType]
        val configData = if (override != null && override.configData.isNotEmpty()) {
            override.configData
        } else {
            val config = verificationConfigRepository.findByVerificationMethodId(matchedMethod.id)
                ?: throw IllegalArgumentException("인증 설정을 찾을 수 없습니다")
            config.configData
        }

        // method_type별 검증 (GPS는 근무지 좌표 사용)
        // 실패 시 어떤 단계에서 실패했는지 식별 가능한 errorCode를 던져 앱에서 전용 모달 분기
        val wpLat = workplace.latitude
        val wpLon = workplace.longitude
        when (matchedMethod.methodType) {
            MethodType.GPS -> {
                if (!verifyGps(verificationData, configData, wpLat, wpLon)) throwGpsFailed()
            }
            MethodType.GPS_QR -> {
                if (!verifyGps(verificationData, configData, wpLat, wpLon)) throwGpsFailed()
                if (!verifyQr(verificationData, configData)) throwQrFailed()
            }
            MethodType.WIFI -> {
                if (!verifyWifi(verificationData, configData)) throwWifiFailed()
            }
            MethodType.WIFI_QR -> {
                if (!verifyWifi(verificationData, configData)) throwWifiFailed()
                if (!verifyQr(verificationData, configData)) throwQrFailed()
            }
            MethodType.NFC -> {
                if (!verifyNfc(verificationData, configData)) throwNfcFailed()
            }
            MethodType.NFC_GPS -> {
                if (!verifyNfc(verificationData, configData)) throwNfcFailed()
                if (!verifyGps(verificationData, configData, wpLat, wpLon)) throwGpsFailed()
            }
            MethodType.BEACON -> {
                // verifyBeacon은 자체적으로 BEACON_* errorCode를 던지므로 boolean 결과 별도 분기 불필요
                verifyBeacon(verificationData, configData)
            }
            MethodType.BEACON_GPS -> {
                verifyBeacon(verificationData, configData)
                if (!verifyGps(verificationData, configData, wpLat, wpLon)) throwGpsFailed()
            }
            MethodType.QR -> {
                // QR 단독은 카탈로그 전용 - 인증 수단으로 사용 불가
                throw IllegalArgumentException("QR 단독은 인증 수단으로 사용할 수 없습니다")
            }
        }

        return matchedMethod
    }

    // 인증 방식별 실패 예외 헬퍼 - 앱에서 errorCode로 전용 모달 분기
    private fun throwNfcFailed(): Nothing =
        throw VerificationFailedException(VerificationErrorCode.NFC_VERIFICATION_FAILED, "NFC 인증 검증 실패")

    private fun throwGpsFailed(): Nothing =
        throw VerificationFailedException(VerificationErrorCode.GPS_VERIFICATION_FAILED, "GPS 인증 검증 실패")

    private fun throwWifiFailed(): Nothing =
        throw VerificationFailedException(VerificationErrorCode.WIFI_VERIFICATION_FAILED, "WiFi 인증 검증 실패")

    private fun throwQrFailed(): Nothing =
        throw VerificationFailedException(VerificationErrorCode.QR_VERIFICATION_FAILED, "QR 인증 검증 실패")

    // 앱의 verification_method 문자열 → 활성화된 VerificationMethod 매칭
    private fun findMatchingMethod(enabledMethods: List<VerificationMethod>, appMethod: String): VerificationMethod? {
        val methodMapping = mapOf(
            "gps" to listOf(MethodType.GPS, MethodType.GPS_QR),
            "wifi" to listOf(MethodType.WIFI, MethodType.WIFI_QR),
            "nfc" to listOf(MethodType.NFC, MethodType.NFC_GPS),
            "bluetooth" to listOf(MethodType.BEACON, MethodType.BEACON_GPS),
            "beacon" to listOf(MethodType.BEACON, MethodType.BEACON_GPS),
            "qr" to listOf(MethodType.GPS_QR, MethodType.WIFI_QR),
            // 복합 인증 방식 직접 매핑
            "gps_qr" to listOf(MethodType.GPS_QR),
            "wifi_qr" to listOf(MethodType.WIFI_QR),
            "nfc_gps" to listOf(MethodType.NFC_GPS),
            "beacon_gps" to listOf(MethodType.BEACON_GPS)
        )
        val possibleTypes = methodMapping[appMethod.lowercase()] ?: return null
        return enabledMethods.firstOrNull { it.methodType in possibleTypes }
    }

    // 신 schema(targets[] + 부품별 prefix 키) ↔ 기존 단일 dict 모두 호환되게 타겟 배열 추출
    // 우선순위: config[primaryKey] (예: gps_targets) → config["targets"] → config 자체를 단일 target 으로
    private fun extractTargets(config: Map<String, Any>, primaryKey: String): List<Map<String, Any>> {
        @Suppress("UNCHECKED_CAST")
        val prefixed = config[primaryKey] as? List<*>
        if (prefixed != null) {
            return prefixed.filterIsInstance<Map<String, Any>>()
        }
        val generic = config["targets"] as? List<*>
        if (generic != null) {
            return generic.filterIsInstance<Map<String, Any>>()
        }
        // 기존 단일 dict (key 자체가 최상위에 있는 경우)
        return listOf(config)
    }

    // QR 코드 후보 추출: qr_codes:[] (신) 또는 qr_code:String (기존) 모두 지원
    private fun extractQrCodes(config: Map<String, Any>): List<String> {
        val list = config["qr_codes"] as? List<*>
        if (list != null) {
            return list.filterIsInstance<String>().filter { it.isNotBlank() }
        }
        return listOfNotNull((config["qr_code"] as? String)?.takeIf { it.isNotBlank() })
    }

    // GPS 검증: targets[] 중 어느 하나라도 반경 안이면 통과 (Haversine 거리)
    private fun verifyGps(
        data: Map<String, Any>,
        config: Map<String, Any>,
        workplaceLat: Double?,
        workplaceLon: Double?
    ): Boolean {
        val dataLat = (data["latitude"] as? Number)?.toDouble() ?: return false
        val dataLon = (data["longitude"] as? Number)?.toDouble() ?: return false

        val targets = extractTargets(config, "gps_targets")
        logger.info("[GPS] 앱좌표=($dataLat, $dataLon), 타겟 수=${targets.size}")

        // 어느 한 타겟이라도 반경 안이면 통과
        for ((i, target) in targets.withIndex()) {
            // target 의 lat/lng 가 없으면 근무지 컬럼 좌표로 폴백
            val targetLat = (target["latitude"] as? Number)?.toDouble() ?: workplaceLat
            val targetLon = (target["longitude"] as? Number)?.toDouble() ?: workplaceLon
            val radiusMeters = (target["radius_meters"] as? Number)?.toDouble()
            if (targetLat == null || targetLon == null || radiusMeters == null) {
                logger.info("[GPS]   [$i] 좌표/반경 누락 - 스킵")
                continue
            }
            val distance = haversineDistance(dataLat, dataLon, targetLat, targetLon)
            val passed = distance <= radiusMeters
            logger.info("[GPS]   [$i] 타겟=($targetLat, $targetLon), 거리=${String.format("%.1f", distance)}m, 반경=${radiusMeters}m → ${if (passed) "✅통과" else "❌실패"}")
            if (passed) return true
        }
        return false
    }

    // SSID 정규화: 앞뒤 공백/큰따옴표 제거 (대소문자는 SSID 표준상 그대로 유지)
    private fun normalizeSsid(value: String?): String? =
        value?.trim()?.removeSurrounding("\"")?.takeIf { it.isNotEmpty() }

    // BSSID 정규화: 공백/콜론/하이픈 구분자 제거 후 소문자 (ignoreCase 비교 용)
    private fun normalizeBssid(value: String?): String? =
        value?.trim()?.replace(Regex("[:\\-\\s]"), "")?.lowercase()?.takeIf { it.isNotEmpty() }

    // WiFi 검증: targets[] 중 SSID 또는 BSSID 매칭 (정규화 후 비교) 어느 하나라도 통과
    private fun verifyWifi(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataSsid = normalizeSsid(data["ssid"] as? String)
        val dataBssid = normalizeBssid(data["bssid"] as? String)

        val targets = extractTargets(config, "wifi_targets")
        logger.info("[WiFi] 앱={ssid=$dataSsid, bssid=$dataBssid}, 타겟 수=${targets.size}")

        for ((i, target) in targets.withIndex()) {
            val configSsid = normalizeSsid(target["ssid"] as? String)
            val configBssid = normalizeBssid(target["bssid"] as? String)
            val matched = if (!configBssid.isNullOrEmpty() && dataBssid != null) {
                // BSSID 우선 비교 (이미 lowercase + 구분자 제거 정규화 됨)
                val r = configBssid == dataBssid
                logger.info("[WiFi]   [$i] BSSID 비교: $dataBssid vs $configBssid → ${if (r) "✅통과" else "❌실패"}")
                r
            } else if (configSsid != null && dataSsid != null) {
                val r = configSsid == dataSsid
                logger.info("[WiFi]   [$i] SSID 비교: $dataSsid vs $configSsid → ${if (r) "✅통과" else "❌실패"}")
                r
            } else {
                logger.info("[WiFi]   [$i] 비교 불가: 앱 또는 타겟 데이터 부족")
                false
            }
            if (matched) return true
        }
        return false
    }

    // NFC 검증: targets[] 중 tag_id 매칭 어느 하나라도 통과
    private fun verifyNfc(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataTagId = data["tag_id"] as? String ?: return false
        val targets = extractTargets(config, "nfc_targets")
        logger.info("[NFC] 앱태그=$dataTagId, 타겟 수=${targets.size}")

        for ((i, target) in targets.withIndex()) {
            val configTagId = target["tag_id"] as? String ?: continue
            val passed = dataTagId.equals(configTagId, ignoreCase = true)
            logger.info("[NFC]   [$i] 설정태그=$configTagId → ${if (passed) "✅통과" else "❌실패"}")
            if (passed) return true
        }
        return false
    }

    // Beacon 검증: targets[] 중 UUID/Major/Minor + RSSI 통과 어느 하나라도 OK
    // 실패 시 가장 진척된 단계의 에러 코드 보고 (NOT_DETECTED < UUID_MISMATCH < RSSI_TOO_WEAK)
    private fun verifyBeacon(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        @Suppress("UNCHECKED_CAST")
        val devices = data["detected_devices"] as? List<Map<String, Any>>

        val targets = extractTargets(config, "beacon_targets")
        logger.info("[Beacon] 타겟 수=${targets.size}, 감지된 기기 수: ${devices?.size ?: 0}")
        devices?.forEachIndexed { i, d ->
            logger.info("[Beacon]   감지[$i] uuid=${d["uuid"]}, major=${d["major"]}, minor=${d["minor"]}, rssi=${d["rssi"]}")
        }

        // 비콘이 아예 감지되지 않음 - 어떤 타겟도 검증 불가
        if (devices.isNullOrEmpty()) {
            throw VerificationFailedException(
                VerificationErrorCode.BEACON_NOT_DETECTED,
                "비콘이 감지되지 않았습니다"
            )
        }

        var anyUuidMatched = false
        var lastRssiThreshold = -70

        for ((i, target) in targets.withIndex()) {
            val configUuid = target["uuid"] as? String ?: continue
            val configMajor = (target["major"] as? Number)?.toInt()
            val configMinor = (target["minor"] as? Number)?.toInt()
            val rssiThreshold = (target["rssi_threshold"] as? Number)?.toInt() ?: -70
            lastRssiThreshold = rssiThreshold

            logger.info("[Beacon]   타겟[$i] uuid=$configUuid, major=$configMajor, minor=$configMinor, rssi임계=$rssiThreshold")

            // UUID + Major + Minor 매칭 디바이스
            val uuidMatched = devices.filter { device ->
                val deviceUuid = device["uuid"] as? String ?: ""
                deviceUuid.equals(configUuid, ignoreCase = true) &&
                    (configMajor == null || configMajor == (device["major"] as? Number)?.toInt()) &&
                    (configMinor == null || configMinor == (device["minor"] as? Number)?.toInt())
            }
            logger.info("[Beacon]   타겟[$i] UUID+M+m 매칭 결과: ${uuidMatched.size}개")

            if (uuidMatched.isEmpty()) {
                continue
            }
            anyUuidMatched = true

            // RSSI 임계값 통과 여부
            val rssiPassed = uuidMatched.any { device ->
                val rssi = (device["rssi"] as? Number)?.toInt() ?: -100
                rssi >= rssiThreshold
            }
            logger.info("[Beacon]   타겟[$i] RSSI 통과: ${if (rssiPassed) "✅통과" else "❌미달"}")

            if (rssiPassed) return true
        }

        // 모든 타겟이 UUID 매칭 실패
        if (!anyUuidMatched) {
            throw VerificationFailedException(
                VerificationErrorCode.BEACON_UUID_MISMATCH,
                "일치하는 비콘을 찾을 수 없습니다"
            )
        }
        // UUID 매칭은 됐으나 RSSI 모두 미달
        throw VerificationFailedException(
            VerificationErrorCode.BEACON_RSSI_TOO_WEAK,
            "비콘 신호가 너무 약합니다 (임계값: $lastRssiThreshold)"
        )
    }

    // QR 검증: qr_codes[] 중 하나라도 매칭 통과
    private fun verifyQr(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataQr = data["qr_data"] as? String ?: return false
        val codes = extractQrCodes(config)
        logger.info("[QR] 앱QR=$dataQr, 설정 코드 수=${codes.size}")
        for ((i, code) in codes.withIndex()) {
            val passed = dataQr == code
            logger.info("[QR]   [$i] 설정QR=$code → ${if (passed) "✅통과" else "❌실패"}")
            if (passed) return true
        }
        return false
    }

    // Haversine 거리 계산 (미터)
    private fun haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val R = 6371000.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).pow(2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(dLon / 2).pow(2)
        val c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }

    // VerificationMethod 엔티티를 API 응답 DTO로 변환 (config 포함)
    private fun toResponse(method: VerificationMethod): VerificationMethodResponse {
        val config = verificationConfigRepository.findByVerificationMethodId(method.id)
        return VerificationMethodResponse(
            id = method.id,
            methodType = method.methodType.name,
            enabled = method.isEnabled,
            config = config?.configData
        )
    }
}
