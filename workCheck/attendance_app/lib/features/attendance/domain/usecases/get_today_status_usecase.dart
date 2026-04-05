import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/today_status_entity.dart';
import '../repositories/attendance_repository.dart';

/// 오늘 출퇴근 상태 조회 유스케이스
@lazySingleton
class GetTodayStatusUseCase
    implements UseCase<TodayStatusEntity, NoParams> {
  final AttendanceRepository _repository;

  const GetTodayStatusUseCase(this._repository);

  /// 파라미터 없이 오늘의 출퇴근 상태를 조회
  @override
  Future<Either<Failure, TodayStatusEntity>> call(NoParams params) {
    return _repository.getTodayStatus();
  }
}
