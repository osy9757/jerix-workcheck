import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_init_entity.dart';
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

  /// 출퇴근 init: 서버가 안내하는 required_methods + configs 조회
  @override
  Future<Either<Failure, AttendanceInitEntity>> init({
    required AttendanceType type,
  }) async {
    try {
      final model = type == AttendanceType.clockIn
          ? await _remoteDataSource.clockInInit()
          : await _remoteDataSource.clockOutInit();

      // required_methods 소문자 키 → enum 매핑 (매핑 실패는 무시)
      final methods = model.requiredMethods
          .map((name) => VerificationMethod.fromApiName(name))
          .whereType<VerificationMethod>()
          .toList();

      // configs는 method 키별 Map 형태로 정규화
      final configMap = <String, Map<String, dynamic>>{};
      model.configs.forEach((key, value) {
        if (value is Map) {
          configMap[key] = Map<String, dynamic>.from(value);
        }
      });

      return Right(AttendanceInitEntity(
        requiredMethods: methods,
        rawRequiredMethods: model.requiredMethods,
        configs: configMap,
      ));
    } on DioException catch (e) {
      final data = e.response?.data;
      return Left(ServerFailure(
        message: data?['error'] ?? '인증 정보를 불러올 수 없습니다.',
        statusCode: e.response?.statusCode,
        errorCode: data?['errorCode'] as String?,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// 출퇴근 submit: 수집된 verification_data 일괄 제출
  @override
  Future<Either<Failure, AttendanceEntity>> submit({
    required AttendanceType type,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      final request = AttendanceSubmitRequest(verificationData: verificationData);

      final model = type == AttendanceType.clockIn
          ? await _remoteDataSource.clockInSubmit(request.toJson())
          : await _remoteDataSource.clockOutSubmit(request.toJson());

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
