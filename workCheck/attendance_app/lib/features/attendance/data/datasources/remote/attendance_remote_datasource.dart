import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/attendance_model.dart';

part 'attendance_remote_datasource.g.dart';

/// 출퇴근 원격 데이터소스 (Retrofit REST API)
@RestApi()
@lazySingleton
abstract class AttendanceRemoteDataSource {
  @factoryMethod
  factory AttendanceRemoteDataSource(Dio dio) = _AttendanceRemoteDataSource;

  /// 출근 등록 API
  @POST('/api/v1/attendance/clock-in')
  Future<AttendanceModel> clockIn(
    @Body() Map<String, dynamic> body,
  );

  /// 퇴근 등록 API
  @POST('/api/v1/attendance/clock-out')
  Future<AttendanceModel> clockOut(
    @Body() Map<String, dynamic> body,
  );

  /// 오늘 출퇴근 상태 조회 API
  @GET('/api/v1/attendance/today')
  Future<TodayStatusModel> getTodayStatus();

  /// 월별 출퇴근 히스토리 조회
  @GET('/api/v1/attendance/history')
  Future<HistoryModel> getHistory(
    /// 조회 시작일 (yyyy-MM-dd)
    @Query('from') String from,

    /// 조회 종료일 (yyyy-MM-dd)
    @Query('to') String to,
  );
}
