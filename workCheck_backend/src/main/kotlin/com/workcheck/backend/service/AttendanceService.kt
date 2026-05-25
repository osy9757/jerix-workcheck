package com.workcheck.backend.service

import com.workcheck.backend.dto.request.ClockInRequest
import com.workcheck.backend.dto.request.ClockOutRequest
import com.workcheck.backend.dto.response.*
import com.workcheck.backend.entity.AttendanceRecord
import com.workcheck.backend.entity.AttendanceType
import com.workcheck.backend.repository.AttendanceRecordRepository
import com.workcheck.backend.repository.UserRepository
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDate
import java.time.OffsetDateTime
import java.time.ZoneId

// 출퇴근 기록 등록 및 조회 서비스 (v2: AND 결합 검증, init 응답 별도 분리)
@Service
class AttendanceService(
    private val attendanceRecordRepository: AttendanceRecordRepository,
    private val userRepository: UserRepository,
    private val verificationService: VerificationService
) {
    companion object {
        private val logger = LoggerFactory.getLogger(AttendanceService::class.java)
    }

    private val koreaZone = ZoneId.of("Asia/Seoul")

    // init: 어떤 method 데이터가 필요한지 + 각 method config 반환
    fun clockInInit(userId: Long): AttendanceInitResponse = verificationService.getInitData(userId)
    fun clockOutInit(userId: Long): AttendanceInitResponse = verificationService.getInitData(userId)

    // 출근 submit
    @Transactional
    fun clockIn(userId: Long, request: ClockInRequest): AttendanceResponse =
        registerAttendance(userId, AttendanceType.CLOCK_IN, request.verificationData)

    // 퇴근 submit
    @Transactional
    fun clockOut(userId: Long, request: ClockOutRequest): AttendanceResponse =
        registerAttendance(userId, AttendanceType.CLOCK_OUT, request.verificationData)

    // 출퇴근 공통 등록 로직 (AND 결합 검증)
    private fun registerAttendance(
        userId: Long,
        type: AttendanceType,
        verificationData: Map<String, Map<String, Any>>
    ): AttendanceResponse {
        val typeLabel = if (type == AttendanceType.CLOCK_IN) "출근" else "퇴근"
        logger.info("[Attendance] ${type.name} userId=$userId, methods=${verificationData.keys}")

        val user = userRepository.findById(userId)
            .orElseThrow { IllegalArgumentException("사용자를 찾을 수 없습니다") }

        // 오늘 이미 등록했는지 확인
        val (startOfDay, endOfDay) = todayRange()
        val existing = attendanceRecordRepository.findFirstByUserIdAndTypeAndRecordedAtBetweenOrderByRecordedAtDesc(
            userId, type, startOfDay, endOfDay
        )
        if (existing != null) {
            throw IllegalArgumentException("오늘 이미 ${typeLabel} 등록되었습니다")
        }

        // 활성 method 모두 AND 결합 검증 (실패 시 throw)
        val primaryMethod = verificationService.verifyAll(userId, verificationData)

        // 통과한 모든 method 키 (요청에 들어온 키 = 활성 method 키)
        val verifiedKeys = verificationData.keys.toList()

        // verification_data 는 method 별 데이터를 그대로 JSONB 로 저장 (감사 추적)
        val flatData: Map<String, Any> = verificationData

        val record = AttendanceRecord(
            user = user,
            type = type,
            methodType = primaryMethod,
            verificationData = flatData,
            recordedAt = OffsetDateTime.now()
        )
        val saved = attendanceRecordRepository.save(record)
        return toResponse(saved, verifiedKeys)
    }

    // 오늘 출퇴근 상태
    fun getTodayStatus(userId: Long): TodayStatusResponse {
        val (startOfDay, endOfDay) = todayRange()
        val clockIn = attendanceRecordRepository.findFirstByUserIdAndTypeAndRecordedAtBetweenOrderByRecordedAtDesc(
            userId, AttendanceType.CLOCK_IN, startOfDay, endOfDay
        )
        val clockOut = attendanceRecordRepository.findFirstByUserIdAndTypeAndRecordedAtBetweenOrderByRecordedAtDesc(
            userId, AttendanceType.CLOCK_OUT, startOfDay, endOfDay
        )
        return TodayStatusResponse(
            clockIn = clockIn?.let { toResponse(it) },
            clockOut = clockOut?.let { toResponse(it) }
        )
    }

    // 본인 기간별 기록
    fun getHistory(userId: Long, from: String, to: String): HistoryResponse {
        val fromDate = LocalDate.parse(from)
        val toDate = LocalDate.parse(to)
        val startDateTime = fromDate.atStartOfDay(koreaZone).toOffsetDateTime()
        val endDateTime = toDate.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()

        val records = attendanceRecordRepository.findAllByUserIdAndRecordedAtBetweenOrderByRecordedAtDesc(
            userId, startDateTime, endDateTime
        )

        val dailyMap = mutableMapOf<String, Pair<AttendanceRecord?, AttendanceRecord?>>()
        for (record in records) {
            val date = record.recordedAt.atZoneSameInstant(koreaZone).toLocalDate().toString()
            val current = dailyMap.getOrDefault(date, Pair(null, null))
            dailyMap[date] = when (record.type) {
                AttendanceType.CLOCK_IN -> current.copy(first = record)
                AttendanceType.CLOCK_OUT -> current.copy(second = record)
            }
        }

        val dailyRecords = dailyMap.entries
            .sortedByDescending { it.key }
            .map { (date, pair) ->
                DailyRecord(
                    date = date,
                    clockIn = pair.first?.let { toResponse(it) },
                    clockOut = pair.second?.let { toResponse(it) }
                )
            }
        return HistoryResponse(records = dailyRecords, total = dailyRecords.size)
    }

    // 관리자용 전체 기록
    fun getAllHistory(from: String, to: String): AdminHistoryResponse {
        val fromDate = LocalDate.parse(from)
        val toDate = LocalDate.parse(to)
        val startDateTime = fromDate.atStartOfDay(koreaZone).toOffsetDateTime()
        val endDateTime = toDate.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()

        val records = attendanceRecordRepository.findAllByRecordedAtBetweenOrderByRecordedAtDesc(
            startDateTime, endDateTime
        )

        data class DailyKey(val date: String, val userId: Long)
        val dailyMap = mutableMapOf<DailyKey, Triple<AttendanceRecord?, AttendanceRecord?, com.workcheck.backend.entity.User>>()
        for (record in records) {
            val date = record.recordedAt.atZoneSameInstant(koreaZone).toLocalDate().toString()
            val key = DailyKey(date, record.user.id)
            val current = dailyMap[key]
            val clockIn = if (record.type == AttendanceType.CLOCK_IN) record else current?.first
            val clockOut = if (record.type == AttendanceType.CLOCK_OUT) record else current?.second
            dailyMap[key] = Triple(clockIn, clockOut, record.user)
        }

        val dailyRecords = dailyMap.entries
            .sortedWith(compareByDescending<Map.Entry<DailyKey, Triple<AttendanceRecord?, AttendanceRecord?, com.workcheck.backend.entity.User>>> { it.key.date }
                .thenBy { it.value.third.name })
            .map { (key, triple) ->
                AdminDailyRecord(
                    date = key.date,
                    employeeId = triple.third.employeeId,
                    employeeName = triple.third.name,
                    clockIn = triple.first?.let { toResponse(it) },
                    clockOut = triple.second?.let { toResponse(it) }
                )
            }
        return AdminHistoryResponse(records = dailyRecords, total = dailyRecords.size)
    }

    private fun todayRange(): Pair<OffsetDateTime, OffsetDateTime> {
        val today = LocalDate.now(koreaZone)
        val start = today.atStartOfDay(koreaZone).toOffsetDateTime()
        val end = today.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()
        return Pair(start, end)
    }

    // AttendanceRecord → AttendanceResponse
    private fun toResponse(record: AttendanceRecord, verifiedKeys: List<String> = emptyList()): AttendanceResponse {
        return AttendanceResponse(
            id = record.id,
            type = record.type.name,
            timestamp = record.recordedAt,
            verificationMethod = record.methodType.name.lowercase(),
            verifiedMethods = verifiedKeys.ifEmpty {
                // 과거 기록 조회 시: verification_data 의 키들을 그대로 노출
                @Suppress("UNCHECKED_CAST")
                val asNested = record.verificationData as? Map<String, Any> ?: emptyMap()
                asNested.keys.toList()
            },
            verificationData = record.verificationData
        )
    }
}
