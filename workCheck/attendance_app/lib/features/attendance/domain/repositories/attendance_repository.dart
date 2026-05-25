import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/attendance_entity.dart';
import '../entities/attendance_init_entity.dart';
import '../entities/attendance_type.dart';
import '../entities/history_entity.dart';
import '../entities/today_status_entity.dart';

abstract class AttendanceRepository {
  /// 출퇴근 init (1차): required_methods + configs 조회
  Future<Either<Failure, AttendanceInitEntity>> init({
    required AttendanceType type,
  });

  /// 출퇴근 submit (2차): 수집된 verification_data 일괄 제출
  ///
  /// [verificationData]는 method 키(소문자) → 방식별 값 맵 형태.
  Future<Either<Failure, AttendanceEntity>> submit({
    required AttendanceType type,
    required Map<String, dynamic> verificationData,
  });

  /// 오늘 출퇴근 상태 조회
  Future<Either<Failure, TodayStatusEntity>> getTodayStatus();

  /// 월별 출퇴근 히스토리 조회
  Future<Either<Failure, HistoryEntity>> getHistory({
    required String from,
    required String to,
  });
}
