package com.workcheck.backend.service

import com.workcheck.backend.dto.response.AttendanceInitResponse
import com.workcheck.backend.entity.MethodType
import com.workcheck.backend.entity.UserVerificationMethod
import com.workcheck.backend.repository.UserRepository
import com.workcheck.backend.repository.UserVerificationMethodRepository
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import kotlin.math.*

// 인증 검증 서비스 (v2)
// - 핵심 변화: 근무지(workplace) 의존 제거. 모든 인증 설정은 user_verification_methods 에서 조회
// - AND 결합: 활성 method 모두 통과해야 인증 성공. 한 개라도 실패 시 첫 실패 method + errorCode 반환
// - WIFI 식별자: identifier_type ("bssid"|"ip") 에 따라 택1 비교
// - 비콘 RSSI 임계값: UserService.updateUserMethod 에서 distance_m + tx_power → rssi_threshold 자동 계산 후 저장
@Service
class VerificationService(
    private val uvmRepository: UserVerificationMethodRepository,
    private val userRepository: UserRepository
) {
    companion object {
        private val logger = LoggerFactory.getLogger(VerificationService::class.java)
    }

    // 활성 method type 목록 반환 (AuthService 로그인 응답용)
    fun getActiveMethodTypes(userId: Long): List<MethodType> {
        return uvmRepository.findAllByUserIdAndIsEnabledTrue(userId).map { it.methodType }
    }

    // init 응답 생성: 어떤 method 데이터를 모아 submit 해야 하는지 + 각 method 의 config_data 안내
    fun getInitData(userId: Long): AttendanceInitResponse {
        // 사용자 존재 확인
        userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }

        val active = uvmRepository.findAllByUserIdAndIsEnabledTrue(userId)
        if (active.isEmpty()) {
            throw IllegalStateException("활성화된 인증 방법이 없습니다. 관리자에게 문의하세요.")
        }
        val requiredMethods = active.map { it.methodType.name.lowercase() }
        val configs = active.associate { it.methodType.name.lowercase() to it.configData }
        return AttendanceInitResponse(requiredMethods = requiredMethods, configs = configs)
    }

    // 출퇴근 submit 검증 - 활성 method 모두 verify, 모두 통과해야 성공. 한 개라도 실패 시 즉시 예외
    // verificationDataMap 예: { "gps": {...}, "wifi": {...}, "nfc": {...} }
    // 반환: 인증에 사용된 대표 method (활성 method 의 첫 번째)
    fun verifyAll(userId: Long, verificationDataMap: Map<String, Map<String, Any>>): MethodType {
        val active = uvmRepository.findAllByUserIdAndIsEnabledTrue(userId)
        if (active.isEmpty()) {
            throw IllegalStateException("활성화된 인증 방법이 없습니다")
        }

        // 모든 활성 method 순회. 데이터 누락 또는 검증 실패 시 즉시 throw (AND 결합)
        for (uvm in active) {
            val key = uvm.methodType.name.lowercase()
            val data = verificationDataMap[key]
                ?: throw missingDataException(uvm.methodType, key)

            logger.info("[Verify] userId=$userId method=${uvm.methodType}")
            verifyOne(uvm, data)
        }

        return active.first().methodType
    }

    // 단일 method 검증 - 실패 시 method 별 errorCode 로 예외
    private fun verifyOne(uvm: UserVerificationMethod, data: Map<String, Any>) {
        when (uvm.methodType) {
            MethodType.GPS    -> if (!verifyGps(data, uvm.configData))    throwFail(MethodType.GPS, "GPS 인증 실패")
            MethodType.WIFI   -> if (!verifyWifi(data, uvm.configData))   throwFail(MethodType.WIFI, "WiFi 인증 실패")
            MethodType.NFC    -> if (!verifyNfc(data, uvm.configData))    throwFail(MethodType.NFC, "NFC 인증 실패")
            MethodType.BEACON -> verifyBeacon(data, uvm.configData)       // 자체적으로 세부 errorCode throw
            MethodType.QR     -> if (!verifyQr(data, uvm.configData))     throwFail(MethodType.QR, "QR 인증 실패")
        }
    }

    private fun missingDataException(type: MethodType, key: String): VerificationFailedException {
        val code = when (type) {
            MethodType.GPS    -> VerificationErrorCode.GPS_VERIFICATION_FAILED
            MethodType.WIFI   -> VerificationErrorCode.WIFI_VERIFICATION_FAILED
            MethodType.NFC    -> VerificationErrorCode.NFC_VERIFICATION_FAILED
            MethodType.BEACON -> VerificationErrorCode.BEACON_NOT_DETECTED
            MethodType.QR     -> VerificationErrorCode.QR_VERIFICATION_FAILED
        }
        return VerificationFailedException(code, "필수 인증 데이터 누락: $key")
    }

    private fun throwFail(type: MethodType, msg: String): Nothing {
        val code = when (type) {
            MethodType.GPS    -> VerificationErrorCode.GPS_VERIFICATION_FAILED
            MethodType.WIFI   -> VerificationErrorCode.WIFI_VERIFICATION_FAILED
            MethodType.NFC    -> VerificationErrorCode.NFC_VERIFICATION_FAILED
            MethodType.BEACON -> VerificationErrorCode.BEACON_UUID_MISMATCH
            MethodType.QR     -> VerificationErrorCode.QR_VERIFICATION_FAILED
        }
        throw VerificationFailedException(code, msg)
    }

    // targets[] 추출 (config_data 의 표준 키)
    @Suppress("UNCHECKED_CAST")
    private fun extractTargets(config: Map<String, Any>): List<Map<String, Any>> {
        return (config["targets"] as? List<*>)?.filterIsInstance<Map<String, Any>>() ?: emptyList()
    }

    // QR 코드 후보 (codes[])
    private fun extractCodes(config: Map<String, Any>): List<String> {
        return (config["codes"] as? List<*>)?.filterIsInstance<String>()?.filter { it.isNotBlank() } ?: emptyList()
    }

    // GPS 검증: targets[] 중 어느 하나의 반경 안이면 통과
    private fun verifyGps(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataLat = (data["lat"] as? Number)?.toDouble()
            ?: (data["latitude"] as? Number)?.toDouble() ?: return false
        val dataLon = (data["lng"] as? Number)?.toDouble()
            ?: (data["longitude"] as? Number)?.toDouble() ?: return false

        val targets = extractTargets(config)
        for ((i, target) in targets.withIndex()) {
            val targetLat = (target["lat"] as? Number)?.toDouble() ?: continue
            val targetLon = (target["lng"] as? Number)?.toDouble() ?: continue
            val radiusM = (target["radius_m"] as? Number)?.toDouble() ?: continue
            val distance = haversineDistance(dataLat, dataLon, targetLat, targetLon)
            logger.info("[GPS] target[$i] dist=${String.format("%.1f", distance)}m / r=${radiusM}m")
            if (distance <= radiusM) return true
        }
        return false
    }

    // SSID/BSSID 정규화
    private fun normalizeSsid(s: String?): String? =
        s?.trim()?.removeSurrounding("\"")?.takeIf { it.isNotEmpty() }

    private fun normalizeBssid(s: String?): String? =
        s?.trim()?.replace(Regex("[:\\-\\s]"), "")?.lowercase()?.takeIf { it.isNotEmpty() }

    private fun normalizeIp(s: String?): String? =
        s?.trim()?.takeIf { it.isNotEmpty() }

    // WiFi 검증: targets[] 중 SSID + (BSSID OR IP) 매칭. identifier_type 으로 택1
    private fun verifyWifi(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataSsid  = normalizeSsid(data["ssid"] as? String)
        val dataBssid = normalizeBssid(data["bssid"] as? String)
        val dataIp    = normalizeIp(data["ip"] as? String)

        val targets = extractTargets(config)
        for ((i, target) in targets.withIndex()) {
            val targetSsid = normalizeSsid(target["ssid"] as? String)
            val idType  = (target["identifier_type"] as? String)?.lowercase()  // "bssid" or "ip"
            val idValue = target["identifier_value"] as? String

            // SSID 비교 (있을 때만)
            if (targetSsid != null && targetSsid != dataSsid) {
                logger.info("[WIFI] target[$i] SSID 불일치: $dataSsid vs $targetSsid")
                continue
            }

            // 식별자 비교 (택1)
            val matched = when (idType) {
                "bssid" -> {
                    val targetBssid = normalizeBssid(idValue)
                    val ok = targetBssid != null && dataBssid != null && targetBssid == dataBssid
                    logger.info("[WIFI] target[$i] BSSID: $dataBssid vs $targetBssid → $ok")
                    ok
                }
                "ip" -> {
                    val targetIp = normalizeIp(idValue)
                    val ok = targetIp != null && dataIp != null && targetIp == dataIp
                    logger.info("[WIFI] target[$i] IP: $dataIp vs $targetIp → $ok")
                    ok
                }
                else -> {
                    // identifier 미설정 → SSID 만으로 판정 (이미 위에서 통과)
                    targetSsid != null
                }
            }
            if (matched) return true
        }
        return false
    }

    // NFC 검증: targets[] 중 tag_id 매칭 (대소문자 무관)
    private fun verifyNfc(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataTagId = data["tag_id"] as? String ?: return false
        val targets = extractTargets(config)
        for ((i, target) in targets.withIndex()) {
            val configTagId = target["tag_id"] as? String ?: continue
            val ok = dataTagId.equals(configTagId, ignoreCase = true)
            logger.info("[NFC] target[$i] $dataTagId vs $configTagId → $ok")
            if (ok) return true
        }
        return false
    }

    // 비콘 검증: 자체적으로 BEACON_* errorCode 던짐
    private fun verifyBeacon(data: Map<String, Any>, config: Map<String, Any>) {
        @Suppress("UNCHECKED_CAST")
        val devices = data["detected_devices"] as? List<Map<String, Any>>

        val targets = extractTargets(config)
        if (devices.isNullOrEmpty()) {
            throw VerificationFailedException(VerificationErrorCode.BEACON_NOT_DETECTED, "비콘이 감지되지 않았습니다")
        }

        var anyUuidMatched = false
        var lastRssiThreshold = -70

        for ((i, target) in targets.withIndex()) {
            val configUuid = target["uuid"] as? String ?: continue
            val configMajor = (target["major"] as? Number)?.toInt()
            val configMinor = (target["minor"] as? Number)?.toInt()
            val rssiThreshold = (target["rssi_threshold"] as? Number)?.toInt() ?: -70
            lastRssiThreshold = rssiThreshold

            val uuidMatched = devices.filter { device ->
                val deviceUuid = device["uuid"] as? String ?: ""
                deviceUuid.equals(configUuid, ignoreCase = true) &&
                    (configMajor == null || configMajor == (device["major"] as? Number)?.toInt()) &&
                    (configMinor == null || configMinor == (device["minor"] as? Number)?.toInt())
            }
            logger.info("[BEACON] target[$i] uuid 매칭 ${uuidMatched.size}개 / threshold=$rssiThreshold")
            if (uuidMatched.isEmpty()) continue
            anyUuidMatched = true

            val rssiPassed = uuidMatched.any { device ->
                val rssi = (device["rssi"] as? Number)?.toInt() ?: -100
                rssi >= rssiThreshold
            }
            if (rssiPassed) return
        }

        if (!anyUuidMatched) {
            throw VerificationFailedException(VerificationErrorCode.BEACON_UUID_MISMATCH, "일치하는 비콘이 없습니다")
        }
        throw VerificationFailedException(
            VerificationErrorCode.BEACON_RSSI_TOO_WEAK,
            "비콘 신호가 너무 약합니다 (임계값: $lastRssiThreshold)"
        )
    }

    // QR 검증: codes[] 중 매칭
    private fun verifyQr(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataQr = data["qr_data"] as? String ?: data["code"] as? String ?: return false
        val codes = extractCodes(config)
        for ((i, c) in codes.withIndex()) {
            val ok = dataQr == c
            logger.info("[QR] codes[$i] $dataQr vs $c → $ok")
            if (ok) return true
        }
        return false
    }

    // Haversine 거리 (m)
    private fun haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double): Double {
        val R = 6371000.0
        val dLat = Math.toRadians(lat2 - lat1)
        val dLon = Math.toRadians(lon2 - lon1)
        val a = sin(dLat / 2).pow(2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(dLon / 2).pow(2)
        return R * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
