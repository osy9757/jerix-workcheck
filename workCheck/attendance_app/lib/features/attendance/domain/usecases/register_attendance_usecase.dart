import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../verification/domain/verification_method.dart';
import '../entities/attendance_entity.dart';
import '../entities/attendance_type.dart';
import '../repositories/attendance_repository.dart';

/// 출퇴근 등록 유스케이스
@lazySingleton
class RegisterAttendanceUseCase
    implements UseCase<AttendanceEntity, RegisterAttendanceParams> {
  final AttendanceRepository _repository;

  const RegisterAttendanceUseCase(this._repository);

  /// 파라미터를 받아 레포지터리의 register를 호출
  @override
  Future<Either<Failure, AttendanceEntity>> call(
      RegisterAttendanceParams params) {
    return _repository.register(
      type: params.type,
      verificationMethod: params.verificationMethod,
      verificationData: params.verificationData,
    );
  }
}

/// 출퇴근 등록 파라미터
class RegisterAttendanceParams extends Equatable {
  /// 출근 또는 퇴근 유형
  final AttendanceType type;

  /// 사용할 인증 방식
  final VerificationMethod verificationMethod;

  /// 인증 상세 데이터 (방식별 값)
  final Map<String, dynamic> verificationData;

  const RegisterAttendanceParams({
    required this.type,
    required this.verificationMethod,
    required this.verificationData,
  });

  @override
  List<Object?> get props => [type, verificationMethod, verificationData];
}
