import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_entity.dart';
import '../repositories/attendance_repository.dart';

/// 출퇴근 히스토리 조회 유스케이스
@lazySingleton
class GetHistoryUseCase implements UseCase<HistoryEntity, GetHistoryParams> {
  final AttendanceRepository _repository;

  const GetHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, HistoryEntity>> call(GetHistoryParams params) {
    return _repository.getHistory(from: params.from, to: params.to);
  }
}

/// 히스토리 조회 파라미터
class GetHistoryParams extends Equatable {
  final String from;
  final String to;

  const GetHistoryParams({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
