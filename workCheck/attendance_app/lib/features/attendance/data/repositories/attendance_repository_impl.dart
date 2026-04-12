import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_type.dart';
import '../../domain/entities/history_entity.dart';
import '../../domain/entities/today_status_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/remote/attendance_remote_datasource.dart';
import '../models/attendance_model.dart';

/// 출퇴근 리포지토리 구현체
///
/// 원격 데이터소스에서 데이터를 받아 도메인 엔티티로 변환하고,
/// 네트워크 오류를 Failure 타입으로 래핑하여 반환한다.
@LazySingleton(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  const AttendanceRepositoryImpl(this._remoteDataSource);

  /// 출퇴근 등록 (출근 또는 퇴근)
  ///
  /// 인증 데이터를 포함한 요청을 서버에 전송하고 결과 엔티티를 반환.
  @override
  Future<Either<Failure, AttendanceEntity>> register({
    required AttendanceType type,
    required VerificationMethod verificationMethod,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      final request = RegisterAttendanceRequest(
        type: type == AttendanceType.clockIn ? 'CLOCK_IN' : 'CLOCK_OUT',
        verificationMethod: verificationMethod.apiName,
        verificationData: verificationData,
      );

      final model = type == AttendanceType.clockIn
          ? await _remoteDataSource.clockIn(request.toJson())
          : await _remoteDataSource.clockOut(request.toJson());

      return Right(model.toEntity());
    } on DioException catch (e) {
      final data = e.response?.data;
      return Left(ServerFailure(
        message: data?['error'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
        errorCode: data?['errorCode'] as String?,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// 오늘 출퇴근 상태 조회
  @override
  Future<Either<Failure, TodayStatusEntity>> getTodayStatus() async {
    try {
      final model = await _remoteDataSource.getTodayStatus();
      return Right(TodayStatusEntity(
        clockIn: model.clockIn?.toEntity(),
        clockOut: model.clockOut?.toEntity(),
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['error'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// 월별 출퇴근 히스토리 조회
  @override
  Future<Either<Failure, HistoryEntity>> getHistory({
    required String from,
    required String to,
  }) async {
    try {
      final model = await _remoteDataSource.getHistory(from, to);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        message: e.response?.data?['error'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
