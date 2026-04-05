package com.workcheck.backend.repository

import com.workcheck.backend.entity.AttendanceRecord
import com.workcheck.backend.entity.AttendanceType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import java.time.OffsetDateTime

// 출퇴근 기록 레포지토리
interface AttendanceRecordRepository : JpaRepository<AttendanceRecord, Long> {

    // 오늘 특정 타입(CLOCK_IN/CLOCK_OUT) 기록 조회
    fun findFirstByUserIdAndTypeAndRecordedAtBetweenOrderByRecordedAtDesc(
        userId: Long,
        type: AttendanceType,
        start: OffsetDateTime,
        end: OffsetDateTime
    ): AttendanceRecord?

    // 기간별 기록 조회
    fun findAllByUserIdAndRecordedAtBetweenOrderByRecordedAtDesc(
        userId: Long,
        start: OffsetDateTime,
        end: OffsetDateTime
    ): List<AttendanceRecord>

    // 오늘 출퇴근 기록 조회
    fun findAllByUserIdAndRecordedAtBetweenOrderByRecordedAtAsc(
        userId: Long,
        start: OffsetDateTime,
        end: OffsetDateTime
    ): List<AttendanceRecord>

    // 전체 유저 기간별 기록 조회 (관리자용)
    fun findAllByRecordedAtBetweenOrderByRecordedAtDesc(
        start: OffsetDateTime,
        end: OffsetDateTime
    ): List<AttendanceRecord>

    // 특정 인증 방법 ID 목록 중 하나라도 참조하는 기록이 있는지 확인
    fun existsByVerificationMethodIdIn(verificationMethodIds: List<Long>): Boolean
}
