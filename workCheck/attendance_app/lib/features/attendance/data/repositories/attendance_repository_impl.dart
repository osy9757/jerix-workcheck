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

@LazySingleton(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _remoteDataSource;

  const AttendanceRepositoryImpl(this._remoteDataSource);

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
        message: data?['message'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
        errorCode: data?['errorCode'] as String?,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

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
        message: e.response?.data?['message'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

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
        message: e.response?.data?['message'] ?? '서버 오류가 발생했습니다.',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
