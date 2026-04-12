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
import java.time.format.DateTimeFormatter

// 출퇴근 기록 등록 및 조회 서비스
@Service
class AttendanceService(
    private val attendanceRecordRepository: AttendanceRecordRepository,
    private val userRepository: UserRepository,
    private val verificationService: VerificationService
) {
    companion object {
        private val logger = LoggerFactory.getLogger(AttendanceService::class.java)
    }

    // 한국 표준시(KST) 기준으로 날짜 계산
    private val koreaZone = ZoneId.of("Asia/Seoul")

    // 출근 등록
    @Transactional
    fun clockIn(userId: Long, request: ClockInRequest): AttendanceResponse {
        return registerAttendance(
            userId = userId,
            type = AttendanceType.CLOCK_IN,
            verificationMethod = request.verificationMethod,
            verificationData = request.verificationData
        )
    }

    // 퇴근 등록
    @Transactional
    fun clockOut(userId: Long, request: ClockOutRequest): AttendanceResponse {
        return registerAttendance(
            userId = userId,
            type = AttendanceType.CLOCK_OUT,
            verificationMethod = request.verificationMethod,
            verificationData = request.verificationData
        )
    }

    // 출퇴근 공통 등록 로직
    private fun registerAttendance(
        userId: Long,
        type: AttendanceType,
        verificationMethod: String,
        verificationData: Map<String, Any>
    ): AttendanceResponse {
        val typeLabel = if (type == AttendanceType.CLOCK_IN) "출근" else "퇴근"

        logger.info("[Attendance] ${type.name} userId: $userId, method: $verificationMethod, verification_data: $verificationData")

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

        // 인증 검증 (유저 기반: 근무지 기본 + 오버라이드 반영)
        val verifiedMethod = verificationService.verify(
            userId, verificationMethod, verificationData
        )

        val record = AttendanceRecord(
            user = user,
            type = type,
            verificationMethod = verifiedMethod,
            verificationData = verificationData,
            recordedAt = OffsetDateTime.now()
        )
        val saved = attendanceRecordRepository.save(record)
        return toResponse(saved)
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

    // 출퇴근 기록 조회 (기간별)
    fun getHistory(userId: Long, from: String, to: String): HistoryResponse {
        val fromDate = LocalDate.parse(from)
        val toDate = LocalDate.parse(to)
        val startDateTime = fromDate.atStartOfDay(koreaZone).toOffsetDateTime()
        val endDateTime = toDate.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()

        val records = attendanceRecordRepository.findAllByUserIdAndRecordedAtBetweenOrderByRecordedAtDesc(
            userId, startDateTime, endDateTime
        )

        // 날짜별 그룹핑
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

    // 관리자용 전체 출퇴근 기록 조회 (모든 유저, 기간별)
    fun getAllHistory(from: String, to: String): AdminHistoryResponse {
        val fromDate = LocalDate.parse(from)
        val toDate = LocalDate.parse(to)
        val startDateTime = fromDate.atStartOfDay(koreaZone).toOffsetDateTime()
        val endDateTime = toDate.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()

        val records = attendanceRecordRepository.findAllByRecordedAtBetweenOrderByRecordedAtDesc(
            startDateTime, endDateTime
        )

        // (날짜, userId) 기준으로 그룹핑
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

    // 오늘(KST 기준) 시작~종료 OffsetDateTime 범위 반환
    private fun todayRange(): Pair<OffsetDateTime, OffsetDateTime> {
        val today = LocalDate.now(koreaZone)
        val start = today.atStartOfDay(koreaZone).toOffsetDateTime()
        val end = today.plusDays(1).atStartOfDay(koreaZone).toOffsetDateTime()
        return Pair(start, end)
    }

    // AttendanceRecord 엔티티를 API 응답 DTO로 변환
    private fun toResponse(record: AttendanceRecord): AttendanceResponse {
        return AttendanceResponse(
            id = record.id,
            type = record.type.name,
            timestamp = record.recordedAt,
            verificationMethod = record.verificationMethod.methodType.name.lowercase(),
            verificationData = record.verificationData
        )
    }
}
