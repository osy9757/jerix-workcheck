import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_type.dart';
import '../../domain/entities/history_entity.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

/// 출퇴근 기록 API 응답 모델
@freezed
class AttendanceModel with _$AttendanceModel {
  const AttendanceModel._();

  const factory AttendanceModel({
    required int id,

    /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
    required String type,

    /// ISO 8601 형식의 기록 시각 문자열
    required String timestamp,

    /// 인증 방식 이름
    @JsonKey(name: 'verification_method') required String verificationMethod,

    /// 인증 상세 데이터
    @JsonKey(name: 'verification_data')
    required Map<String, dynamic> verificationData,
  }) = _AttendanceModel;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  /// 도메인 엔티티로 변환
  AttendanceEntity toEntity() => AttendanceEntity(
        id: id,
        // CLOCK_IN이면 clockIn, 나머지는 clockOut으로 매핑
        type: type == 'CLOCK_IN' ? AttendanceType.clockIn : AttendanceType.clockOut,
        timestamp: DateTime.parse(timestamp),
        verificationMethod: VerificationMethod.values.firstWhere(
          (m) => m.name == verificationMethod,
          // 알 수 없는 방식은 GPS로 폴백
          orElse: () => VerificationMethod.gps,
        ),
        verificationData: verificationData,
      );
}

/// 오늘 출퇴근 상태 API 응답 모델
@freezed
class TodayStatusModel with _$TodayStatusModel {
  const TodayStatusModel._();

  const factory TodayStatusModel({
    /// 오늘 출근 기록 (없으면 null)
    @JsonKey(name: 'clock_in') AttendanceModel? clockIn,

    /// 오늘 퇴근 기록 (없으면 null)
    @JsonKey(name: 'clock_out') AttendanceModel? clockOut,
  }) = _TodayStatusModel;

  factory TodayStatusModel.fromJson(Map<String, dynamic> json) =>
      _$TodayStatusModelFromJson(json);
}

/// 출퇴근 등록 요청 모델
@freezed
class RegisterAttendanceRequest with _$RegisterAttendanceRequest {
  const factory RegisterAttendanceRequest({
    /// 출퇴근 유형 (CLOCK_IN / CLOCK_OUT)
    required String type,

    /// 인증 방식 이름
    @JsonKey(name: 'verification_method') required String verificationMethod,

    /// 인증 상세 데이터
    @JsonKey(name: 'verification_data')
    required Map<String, dynamic> verificationData,
  }) = _RegisterAttendanceRequest;

  factory RegisterAttendanceRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterAttendanceRequestFromJson(json);
}

/// 히스토리 응답 모델 (월별 출퇴근 기록)
@freezed
class HistoryModel with _$HistoryModel {
  const HistoryModel._();

  const factory HistoryModel({
    /// 일별 기록 목록
    required List<DailyRecordModel> records,

    /// 총 출근 일수
    required int total,
  }) = _HistoryModel;

  factory HistoryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryModelFromJson(json);

  /// 엔티티 변환
  HistoryEntity toEntity() => HistoryEntity(
        records: records.map((r) => r.toEntity()).toList(),
        total: total,
      );
}

/// 일별 출퇴근 기록 모델
@freezed
class DailyRecordModel with _$DailyRecordModel {
  const DailyRecordModel._();

  const factory DailyRecordModel({
    /// 날짜 문자열 (yyyy-MM-dd 형식)
    required String date,

    /// 해당일 출근 기록
    @JsonKey(name: 'clock_in') AttendanceModel? clockIn,

    /// 해당일 퇴근 기록
    @JsonKey(name: 'clock_out') AttendanceModel? clockOut,
  }) = _DailyRecordModel;

  factory DailyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordModelFromJson(json);

  /// 엔티티 변환
  DailyRecordEntity toEntity() => DailyRecordEntity(
        date: date,
        clockIn: clockIn?.toEntity(),
        clockOut: clockOut?.toEntity(),
      );
}
