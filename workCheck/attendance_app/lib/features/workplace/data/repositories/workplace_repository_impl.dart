import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/workplace_config_entity.dart';
import '../../domain/repositories/workplace_repository.dart';
import '../datasources/remote/workplace_remote_datasource.dart';

/// 근무지 설정 리포지토리 구현체
///
/// 원격 데이터소스에서 데이터를 받아 도메인 엔티티로 변환하고,
/// 네트워크 오류를 Failure 타입으로 래핑하여 반환한다.
@LazySingleton(as: WorkplaceRepository)
class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceRemoteDataSource _remoteDataSource;

  const WorkplaceRepositoryImpl(this._remoteDataSource);

  /// 근무지 설정 조회
  ///
  /// - DioException: 서버 오류 → ServerFailure (상태코드 + 메시지 포함)
  /// - 기타 예외: UnknownFailure
  @override
  Future<Either<Failure, WorkplaceConfigEntity>> getConfig() async {
    try {
      final model = await _remoteDataSource.getConfig();
      // API 모델을 도메인 엔티티로 변환하여 반환
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['error'] ?? '설정을 불러올 수 없습니다.',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
