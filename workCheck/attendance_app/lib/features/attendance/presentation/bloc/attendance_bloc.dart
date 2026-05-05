import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';
import '../../../verification/data/verification_manager.dart';
import '../../../verification/domain/verification_method.dart';
import '../../../workplace/domain/entities/workplace_config_entity.dart';
import '../../../workplace/domain/usecases/get_workplace_config_usecase.dart';
import '../../domain/entities/attendance_type.dart';
import '../../domain/entities/today_status_entity.dart';
import '../../domain/usecases/get_today_status_usecase.dart';
import '../../domain/usecases/register_attendance_usecase.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';
part 'attendance_bloc.freezed.dart';

@injectable
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayStatusUseCase _getTodayStatus;
  final RegisterAttendanceUseCase _registerAttendance;
  final VerificationManager _verificationManager;
  final GetWorkplaceConfigUseCase _getWorkplaceConfig;
  final AuthLocalDatasource _authLocal;

  /// 근무지 설정 (freezed regeneration 없이 별도 보관)
  WorkplaceConfigEntity? _workplaceConfig;
  WorkplaceConfigEntity? get workplaceConfig => _workplaceConfig;

  AttendanceBloc(
    this._getTodayStatus,
    this._registerAttendance,
    this._verificationManager,
    this._getWorkplaceConfig,
    this._authLocal,
  ) : super(const AttendanceState()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceClockRequested>(_onClockRequested);
    on<AttendanceAvailableMethodsRequested>(_onAvailableMethodsRequested);
  }

  /// 초기 로드: 근무지 설정 + 오늘 상태 + 사용 가능한 인증 방식
  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(uiState: AttendanceUiState.loading));

    // 병렬 실행: 근무지 설정 + 오늘 상태 + 디바이스 가용 방식
    final configFuture = _getWorkplaceConfig(const NoParams());
    final statusFuture = _getTodayStatus(const NoParams());
    final deviceMethodsFuture = _verificationManager.getAvailableMethods();

    final configResult = await configFuture;
    final statusResult = await statusFuture;
    final deviceMethods = await deviceMethodsFuture;

    // 근무지 설정 저장 (설정값 참조용)
    configResult.fold(
      (failure) {},
      (config) { _workplaceConfig = config; },
    );

    // 로그인 시 저장된 서버 활성 인증 방법 조회
    final savedMethodNames = await _authLocal.getEnabledMethods();
    final savedServerMethods = savedMethodNames
        ?.map((name) => VerificationMethod.fromApiName(name))
        .whereType<VerificationMethod>()
        .toList();

    // 서버 활성 인증 방법 (아이콘 표시용, 디바이스 가용 여부 무관)
    var serverMethods = <VerificationMethod>[];
    // 서버 설정이 있으면 그것만 사용. 디바이스 가용 방식과 교집합이 비면 빈 배열로 두어
    // 출근 시 명확한 에러("회사 인증 수단을 사용할 수 없습니다")가 뜨도록 함.
    // 서버 설정이 전혀 없을 때만 디바이스 가용 방식 전체를 폴백으로 사용.
    var methods = <VerificationMethod>[];
    if (savedServerMethods != null && savedServerMethods.isNotEmpty) {
      serverMethods = savedServerMethods;
      methods = savedServerMethods.where(deviceMethods.contains).toList();
    } else if (_workplaceConfig != null &&
        _workplaceConfig!.enabledMethods.isNotEmpty) {
      serverMethods = _workplaceConfig!.enabledMethods;
      methods = _workplaceConfig!.enabledMethods
          .where(deviceMethods.contains)
          .toList();
    } else {
      // 서버 설정이 비어있을 때만 디바이스 가용 방식 전체 폴백
      methods = deviceMethods;
    }

    // 진단 로그: 디바이스/서버/최종 인증 방식
    // ignore: avoid_print
    print('[Attendance.init] saved=$savedMethodNames '
        'parsed=${savedServerMethods?.map((m) => m.name).toList()} '
        'workplaceConfigMethods=${_workplaceConfig?.enabledMethods.map((m) => m.name).toList()} '
        'deviceMethods=${deviceMethods.map((m) => m.name).toList()} '
        'finalMethods=${methods.map((m) => m.name).toList()}');

    statusResult.fold(
      (failure) => emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: failure.message,
        availableMethods: methods,
        serverEnabledMethods: serverMethods,
      )),
      (status) => emit(state.copyWith(
        uiState: AttendanceUiState.loaded,
        todayStatus: status as TodayStatusEntity,
        availableMethods: methods,
        serverEnabledMethods: serverMethods,
      )),
    );
  }

  /// 출퇴근 버튼 클릭 → availableMethods 전체 순차 인증 → 서버 등록
  Future<void> _onClockRequested(
    AttendanceClockRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final methods = state.availableMethods;

    // 진단 로그: 출근 시점 인증 방식 목록
    // ignore: avoid_print
    print('[Attendance.clock] availableMethods=${methods.map((m) => m.name).toList()} '
        'serverEnabled=${state.serverEnabledMethods.map((m) => m.name).toList()}');

    if (methods.isEmpty) {
      // 서버 설정은 있는데 디바이스에서 사용 불가한 경우 안내 메시지 차별화
      final serverHasMethods = state.serverEnabledMethods.isNotEmpty;
      final msg = serverHasMethods
          ? '회사가 허용한 인증 수단(${state.serverEnabledMethods.map((m) => m.label).join(", ")})을 '
              '사용할 수 없습니다. NFC/블루투스/위치 등을 켜주세요.'
          : '사용 가능한 인증 방식이 없습니다.';
      emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: msg,
      ));
      return;
    }

    final todayStatus = state.todayStatus;
    final type = (todayStatus == null || !todayStatus.isClockedIn)
        ? AttendanceType.clockIn
        : AttendanceType.clockOut;

    // Step 1: 모든 인증 방식 순차 검증
    emit(state.copyWith(
      uiState: AttendanceUiState.verifying,
      errorMessage: null,
      successMessage: null,
    ));

    // 인증 결과 판정은 모두 서버(VerificationService)가 수행한다.
    // 클라이언트는 디바이스 스캔 결과를 그대로 verification_data에 담아 전송한다.
    final combinedData = <String, dynamic>{};
    for (final method in methods) {
      final verificationResult = await _verificationManager.verify(method);

      if (!verificationResult.isVerified) {
        // 로컬 인증 실패 → 기본적으로 errorCode 없음
        // 단, GPS 조작 감지 시 errorMessage에 "GPS_SPOOFED:" 프리픽스가 붙어있으면
        // errorCode를 'GPS_SPOOFED'로 설정하여 UI에서 전용 다이얼로그를 띄우게 함
        final rawMessage = verificationResult.errorMessage ?? '';
        final isSpoofed = rawMessage.startsWith('GPS_SPOOFED:');
        final cleanMessage = isSpoofed
            ? rawMessage.substring('GPS_SPOOFED:'.length).trim()
            : rawMessage;

        emit(state.copyWith(
          uiState: AttendanceUiState.error,
          errorMessage: cleanMessage.isNotEmpty
              ? cleanMessage
              : '${method.label} 인증에 실패했습니다.',
          errorCode: isSpoofed ? 'GPS_SPOOFED' : null,
        ));
        return;
      }

      // 성공한 인증 데이터를 평탄 구조로 합산 (서버가 기대하는 형태)
      combinedData.addAll(verificationResult.data);
    }

    // Step 2: 모든 인증 통과 → 서버 등록
    emit(state.copyWith(uiState: AttendanceUiState.registering));

    final result = await _registerAttendance(RegisterAttendanceParams(
      type: type,
      verificationMethod: methods.first,
      verificationData: combinedData,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      )),
      (attendance) {
        // 성공 후 상태 업데이트
        final updatedStatus = type == AttendanceType.clockIn
            ? TodayStatusEntity(
                clockIn: attendance,
                clockOut: todayStatus?.clockOut,
              )
            : TodayStatusEntity(
                clockIn: todayStatus?.clockIn,
                clockOut: attendance,
              );

        emit(state.copyWith(
          uiState: AttendanceUiState.success,
          todayStatus: updatedStatus,
          successMessage: '${type.label} 등록 완료!',
        ));
      },
    );
  }

  /// 사용 가능한 인증 방식 재조회
  Future<void> _onAvailableMethodsRequested(
    AttendanceAvailableMethodsRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final methods = await _verificationManager.getAvailableMethods();
    emit(state.copyWith(
      availableMethods: methods,
    ));
  }
}
