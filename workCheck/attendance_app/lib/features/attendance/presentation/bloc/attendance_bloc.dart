import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';
import '../../../verification/data/verification_manager.dart';
import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/attendance_init_entity.dart';
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
  final InitAttendanceUseCase _initAttendance;
  final SubmitAttendanceUseCase _submitAttendance;
  final VerificationManager _verificationManager;
  final AuthLocalDatasource _authLocal;

  /// 최근 init 응답 캐시 (지도 GPS 마커/반경 표시용)
  /// state에 보관 시 freezed 재생성 비용이 높아 별도 필드로 유지한다.
  AttendanceInitEntity? _lastInit;
  AttendanceInitEntity? get lastInit => _lastInit;

  AttendanceBloc(
    this._getTodayStatus,
    this._initAttendance,
    this._submitAttendance,
    this._verificationManager,
    this._authLocal,
  ) : super(const AttendanceState()) {
    on<AttendanceStarted>(_onStarted);
    on<AttendanceClockRequested>(_onClockRequested);
    on<AttendanceAvailableMethodsRequested>(_onAvailableMethodsRequested);
  }

  /// 초기 로드: 오늘 상태 + 디바이스 가용 인증 방식 + (가능하면) init 미리 호출
  Future<void> _onStarted(
    AttendanceStarted event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(uiState: AttendanceUiState.loading));

    // 병렬 실행: 오늘 상태 + 디바이스 가용 방식
    final statusFuture = _getTodayStatus(const NoParams());
    final deviceMethodsFuture = _verificationManager.getAvailableMethods();

    final statusResult = await statusFuture;
    final deviceMethods = await deviceMethodsFuture;

    // 다음 액션 타입 결정 (출근 전이면 clockIn init, 출근 후면 clockOut init)
    final TodayStatusEntity? statusEntity = statusResult.fold(
      (_) => null,
      (status) => status,
    );
    final nextType = (statusEntity == null || !statusEntity.isClockedIn)
        ? AttendanceType.clockIn
        : AttendanceType.clockOut;

    // 다음 액션 기준으로 init을 미리 한 번 호출하여 지도/아이콘 표시에 사용한다.
    // 실패해도 화면 표시는 계속 진행 (출근/퇴근 후 완료 상태에서 init 400이 날 수 있음)
    final initResult = await _initAttendance(InitAttendanceParams(type: nextType));
    initResult.fold(
      (_) {},
      (init) => _lastInit = init,
    );

    // 서버 활성 인증 방법 (아이콘 표시용). init이 성공하면 init 결과 우선, 실패 시 로컬 저장값 폴백.
    final savedMethodNames = await _authLocal.getEnabledMethods();
    final savedServerMethods = savedMethodNames
        ?.map((name) => VerificationMethod.fromApiName(name))
        .whereType<VerificationMethod>()
        .toList();

    final serverMethods = _lastInit?.requiredMethods.isNotEmpty == true
        ? _lastInit!.requiredMethods
        : (savedServerMethods ?? <VerificationMethod>[]);

    // 디바이스 가용 ∩ 서버 활성 = 실제 실행 가능 method
    // 서버 활성이 비어있을 때만 디바이스 가용 전체를 폴백으로 사용
    final methods = serverMethods.isNotEmpty
        ? serverMethods.where(deviceMethods.contains).toList()
        : deviceMethods;

    // 진단 로그: 디바이스/서버/최종 인증 방식
    logD('Attendance',
        'init saved=$savedMethodNames '
        'parsed=${savedServerMethods?.map((m) => m.name).toList()} '
        'initMethods=${_lastInit?.requiredMethods.map((m) => m.name).toList()} '
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
        todayStatus: status,
        availableMethods: methods,
        serverEnabledMethods: serverMethods,
      )),
    );
  }

  /// 출퇴근 버튼 클릭 → init 재호출 → required_methods 순차 인증 → submit
  Future<void> _onClockRequested(
    AttendanceClockRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final todayStatus = state.todayStatus;
    final type = (todayStatus == null || !todayStatus.isClockedIn)
        ? AttendanceType.clockIn
        : AttendanceType.clockOut;

    emit(state.copyWith(
      uiState: AttendanceUiState.verifying,
      errorMessage: null,
      successMessage: null,
      errorCode: null,
    ));

    // Step 1: init 호출하여 최신 required_methods + configs 확보
    final initResult = await _initAttendance(InitAttendanceParams(type: type));
    final init = initResult.fold<AttendanceInitEntity?>((_) => null, (v) => v);
    if (init == null) {
      final failure = initResult.swap().getOrElse(
            () => const UnknownFailure(message: '알 수 없는 오류'),
          );
      // 진단 로그: init 실패 사유 (민감값 없음)
      logE('Attendance',
          'clock init 실패 type=${type.name} '
          'code=${failure is ServerFailure ? failure.errorCode : null} '
          'msg=${failure.message}');
      emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: failure.message,
        errorCode: failure is ServerFailure ? failure.errorCode : null,
      ));
      return;
    }
    _lastInit = init;

    final requiredMethods = init.requiredMethods;
    // 진단 로그: 출퇴근 시점 init 결과
    logD('Attendance',
        'clock type=${type.name} '
        'requiredMethods=${requiredMethods.map((m) => m.name).toList()} '
        'rawRequired=${init.rawRequiredMethods} '
        'configs=${init.configs.keys.toList()}');

    if (requiredMethods.isEmpty) {
      emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: '활성화된 인증 방법이 없습니다. 관리자에게 문의하세요.',
      ));
      return;
    }

    // 디바이스 가용 여부 확인
    final deviceMethods = await _verificationManager.getAvailableMethods();
    final missing =
        requiredMethods.where((m) => !deviceMethods.contains(m)).toList();
    if (missing.isNotEmpty) {
      emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: '회사가 허용한 인증 수단(${missing.map((m) => m.label).join(', ')})을 '
            '사용할 수 없습니다. NFC/블루투스/위치 등을 켜주세요.',
      ));
      return;
    }

    // Step 2: 각 method 순차 검증 (감지 데이터 수집 단계, 판정은 서버가 수행)
    final verificationData = <String, dynamic>{};
    for (final method in requiredMethods) {
      final result = await _verificationManager.verify(method);

      // 진단 로그: 인증수단별 통과/실패 여부 (정답·원시 비밀값 제외, 사유만)
      logD('Attendance',
          'verify ${method.apiName} → '
          '${result.isVerified ? "OK" : "FAIL"}'
          '${result.isVerified ? "" : " reason=${result.errorMessage}"}');

      if (!result.isVerified) {
        // 로컬 인증 실패 → 기본적으로 errorCode 없음
        // 단, GPS 조작 감지 시 errorMessage에 "GPS_SPOOFED:" 프리픽스가 붙어있으면
        // errorCode를 'GPS_SPOOFED'로 설정하여 UI에서 전용 다이얼로그를 띄우게 함
        final rawMessage = result.errorMessage ?? '';
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

      // method 키(소문자) → 방식별 값 맵으로 묶어 보낸다.
      // 서버 contract: verification_data: { gps: {...}, wifi: {...}, beacon: {...}, ... }
      verificationData[method.apiName] = result.data;
    }

    // Step 3: 모든 method 수집 완료 → submit
    emit(state.copyWith(uiState: AttendanceUiState.registering));

    final submitResult = await _submitAttendance(SubmitAttendanceParams(
      type: type,
      verificationData: verificationData,
    ));

    submitResult.fold(
      (failure) {
        // 진단 로그: 출퇴근 제출 실패 (사유/상태코드만)
        logE('Attendance',
            'submit 실패 type=${type.name} '
            'code=${failure is ServerFailure ? failure.errorCode : null} '
            'msg=${failure.message}');
        emit(state.copyWith(
          uiState: AttendanceUiState.error,
          errorMessage: failure.message,
          errorCode: failure is ServerFailure ? failure.errorCode : null,
        ));
      },
      (attendance) {
        // 진단 로그: 출퇴근 제출 성공
        logD('Attendance', 'submit 성공 type=${type.name}');
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
