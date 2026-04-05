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

    // 유저의 실제 인증 방법 조회 (근무지 기본 + 오버라이드 머지)
    fun getUserVerificationMethods(userId: Long): UserVerificationListResponse {
        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다: $userId") }

        val workplace = user.workplace
            ?: throw IllegalArgumentException("사용자에게 배정된 근무지가 없습니다")

        // 근무지 기본 인증 방법
        val workplaceMethods = verificationMethodRepository.findAllByWorkplaceId(workplace.id)
        // 유저 오버라이드
        val overrides = userVerificationOverrideRepository.findAllByUserId(userId)
        val overrideMap = overrides.associateBy { it.methodType }

        val methods = workplaceMethods.map { method ->
            val config = verificationConfigRepository.findByVerificationMethodId(method.id)
            val override = overrideMap[method.methodType]

            if (override != null) {
                // 오버라이드 사용
                UserVerificationResponse(
                    methodType = method.methodType.name,
                    enabled = override.isEnabled,
                    config = override.configData.ifEmpty { config?.configData ?: emptyMap() },
                    isOverridden = true
                )
            } else {
                // 근무지 기본 사용
                UserVerificationResponse(
                    methodType = method.methodType.name,
                    enabled = method.isEnabled,
                    config = config?.configData ?: emptyMap(),
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
        val wpLat = workplace.latitude
        val wpLon = workplace.longitude
        val verified = when (matchedMethod.methodType) {
            MethodType.GPS -> verifyGps(verificationData, configData, wpLat, wpLon)
            MethodType.GPS_QR -> verifyGps(verificationData, configData, wpLat, wpLon) && verifyQr(verificationData, configData)
            MethodType.WIFI -> verifyWifi(verificationData, configData)
            MethodType.WIFI_QR -> verifyWifi(verificationData, configData) && verifyQr(verificationData, configData)
            MethodType.NFC -> verifyNfc(verificationData, configData)
            MethodType.NFC_GPS -> verifyNfc(verificationData, configData) && verifyGps(verificationData, configData, wpLat, wpLon)
            MethodType.BEACON -> verifyBeacon(verificationData, configData)
            MethodType.BEACON_GPS -> verifyBeacon(verificationData, configData) && verifyGps(verificationData, configData, wpLat, wpLon)
        }

        if (!verified) {
            throw IllegalArgumentException("인증 검증 실패")
        }

        return matchedMethod
    }

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

    // GPS 검증: 근무지 좌표 + config의 반경으로 Haversine 거리 계산
    private fun verifyGps(
        data: Map<String, Any>,
        config: Map<String, Any>,
        workplaceLat: Double?,
        workplaceLon: Double?
    ): Boolean {
        val dataLat = (data["latitude"] as? Number)?.toDouble() ?: return false
        val dataLon = (data["longitude"] as? Number)?.toDouble() ?: return false
        // 근무지 좌표 사용 (없으면 config fallback)
        val targetLat = workplaceLat ?: (config["latitude"] as? Number)?.toDouble() ?: return false
        val targetLon = workplaceLon ?: (config["longitude"] as? Number)?.toDouble() ?: return false
        val radiusMeters = (config["radius_meters"] as? Number)?.toDouble() ?: return false

        val distance = haversineDistance(dataLat, dataLon, targetLat, targetLon)
        return distance <= radiusMeters
    }

    // WiFi 검증: SSID 또는 BSSID 매칭
    private fun verifyWifi(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataSsid = data["ssid"] as? String
        val dataBssid = data["bssid"] as? String
        val configSsid = config["ssid"] as? String
        val configBssid = config["bssid"] as? String

        if (configBssid != null && dataBssid != null) {
            return configBssid.equals(dataBssid, ignoreCase = true)
        }
        if (configSsid != null && dataSsid != null) {
            return configSsid == dataSsid
        }
        return false
    }

    // NFC 검증: tag_id 매칭
    private fun verifyNfc(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataTagId = data["tag_id"] as? String ?: return false
        val configTagId = config["tag_id"] as? String ?: return false
        // 대소문자 무시하여 비교 (NFC tag_id 포맷 차이 허용)
        return dataTagId.equals(configTagId, ignoreCase = true)
    }

    // Beacon 검증: UUID/Major/Minor 매칭 + RSSI 임계값 (에러 코드 분기)
    private fun verifyBeacon(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        @Suppress("UNCHECKED_CAST")
        val devices = data["detected_devices"] as? List<Map<String, Any>>
        val configUuid = config["uuid"] as? String ?: return false
        val configMajor = (config["major"] as? Number)?.toInt()
        val configMinor = (config["minor"] as? Number)?.toInt()
        val rssiThreshold = (config["rssi_threshold"] as? Number)?.toInt() ?: -70

        // 비콘이 아예 감지되지 않음
        if (devices.isNullOrEmpty()) {
            throw VerificationFailedException(
                VerificationErrorCode.BEACON_NOT_DETECTED,
                "비콘이 감지되지 않았습니다"
            )
        }

        // UUID 매칭 (Major/Minor 포함) 되는 디바이스 찾기
        val uuidMatched = devices.filter { device ->
            val deviceUuid = device["uuid"] as? String ?: ""
            deviceUuid.equals(configUuid, ignoreCase = true) &&
                (configMajor == null || configMajor == (device["major"] as? Number)?.toInt()) &&
                (configMinor == null || configMinor == (device["minor"] as? Number)?.toInt())
        }

        // UUID 일치하는 비콘 없음
        if (uuidMatched.isEmpty()) {
            throw VerificationFailedException(
                VerificationErrorCode.BEACON_UUID_MISMATCH,
                "일치하는 비콘을 찾을 수 없습니다"
            )
        }

        // UUID 일치하는 비콘 중 RSSI 임계값 통과하는 것 확인
        val rssiPassed = uuidMatched.any { device ->
            val rssi = (device["rssi"] as? Number)?.toInt() ?: -100
            rssi >= rssiThreshold
        }

        // RSSI 미달
        if (!rssiPassed) {
            throw VerificationFailedException(
                VerificationErrorCode.BEACON_RSSI_TOO_WEAK,
                "비콘 신호가 너무 약합니다 (임계값: $rssiThreshold)"
            )
        }

        return true
    }

    // QR 검증: qr_code 매칭
    private fun verifyQr(data: Map<String, Any>, config: Map<String, Any>): Boolean {
        val dataQr = data["qr_data"] as? String ?: return false
        val configQr = config["qr_code"] as? String ?: return false
        return dataQr == configQr
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
