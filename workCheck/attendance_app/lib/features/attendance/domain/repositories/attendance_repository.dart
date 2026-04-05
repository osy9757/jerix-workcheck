import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../verification/domain/verification_method.dart';
import '../entities/attendance_entity.dart';
import '../entities/attendance_type.dart';
import '../entities/history_entity.dart';
import '../entities/today_status_entity.dart';

abstract class AttendanceRepository {
  /// 출근/퇴근 등록
  Future<Either<Failure, AttendanceEntity>> register({
    required AttendanceType type,
    required VerificationMethod verificationMethod,
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
