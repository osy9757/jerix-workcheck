import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_entity.dart';
import '../entities/attendance_init_entity.dart';
import '../entities/attendance_type.dart';
import '../repositories/attendance_repository.dart';

/// 출퇴근 init 유스케이스 (1차)
///
/// 서버가 안내하는 required_methods + configs를 조회한다.
@lazySingleton
class InitAttendanceUseCase
    implements UseCase<AttendanceInitEntity, InitAttendanceParams> {
  final AttendanceRepository _repository;

  const InitAttendanceUseCase(this._repository);

  @override
  Future<Either<Failure, AttendanceInitEntity>> call(
      InitAttendanceParams params) {
    return _repository.init(type: params.type);
  }
}

/// init 유스케이스 파라미터
class InitAttendanceParams extends Equatable {
  final AttendanceType type;

  const InitAttendanceParams({required this.type});

  @override
  List<Object?> get props => [type];
}

/// 출퇴근 submit 유스케이스 (2차)
///
/// 수집한 verification_data를 서버에 일괄 전송하여 AND 검증 후 기록을 생성한다.
@lazySingleton
class SubmitAttendanceUseCase
    implements UseCase<AttendanceEntity, SubmitAttendanceParams> {
  final AttendanceRepository _repository;

  const SubmitAttendanceUseCase(this._repository);

  @override
  Future<Either<Failure, AttendanceEntity>> call(
      SubmitAttendanceParams params) {
    return _repository.submit(
      type: params.type,
      verificationData: params.verificationData,
    );
  }
}

/// submit 유스케이스 파라미터
class SubmitAttendanceParams extends Equatable {
  final AttendanceType type;

  /// method 키(소문자) → 방식별 값 맵
  final Map<String, dynamic> verificationData;

  const SubmitAttendanceParams({
    required this.type,
    required this.verificationData,
  });

  @override
  List<Object?> get props => [type, verificationData];
}
