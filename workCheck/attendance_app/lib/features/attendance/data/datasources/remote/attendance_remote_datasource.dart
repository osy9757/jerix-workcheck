import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/attendance_model.dart';

part 'attendance_remote_datasource.g.dart';

/// 출퇴근 원격 데이터소스 (Retrofit REST API)
///
/// v2 리팩토링: 출퇴근은 2단계 호출 구조다.
/// 1) init  → 어떤 method 데이터를 수집해야 하는지 + method별 서버 설정값 안내
/// 2) submit → 수집한 verification_data 일괄 검증 후 출퇴근 기록 생성
@RestApi()
@lazySingleton
abstract class AttendanceRemoteDataSource {
  @factoryMethod
  factory AttendanceRemoteDataSource(Dio dio) = _AttendanceRemoteDataSource;

  /// 출근 1차: required_methods + configs 안내
  @POST('/api/v1/attendance/clock-in/init')
  Future<AttendanceInitModel> clockInInit();

  /// 출근 2차: 수집된 verification_data 일괄 제출 → AND 검증 후 등록
  @POST('/api/v1/attendance/clock-in/submit')
  Future<AttendanceModel> clockInSubmit(
    @Body() Map<String, dynamic> body,
  );

  /// 퇴근 1차: required_methods + configs 안내
  @POST('/api/v1/attendance/clock-out/init')
  Future<AttendanceInitModel> clockOutInit();

  /// 퇴근 2차: 수집된 verification_data 일괄 제출 → AND 검증 후 등록
  @POST('/api/v1/attendance/clock-out/submit')
  Future<AttendanceModel> clockOutSubmit(
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
