import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';
import '../../../verification/data/services/bluetooth_service.dart';
import '../../../verification/data/services/nfc_service.dart';
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
    // savedServerMethods 우선, 없으면 workplaceConfig 폴백
    var methods = deviceMethods;
    if (savedServerMethods != null && savedServerMethods.isNotEmpty) {
      serverMethods = savedServerMethods;
      // 로그인 응답 활성 방법 ∩ 디바이스 가용 방법
      final filtered = savedServerMethods
          .where((m) => deviceMethods.contains(m))
          .toList();
      if (filtered.isNotEmpty) {
        methods = filtered;
      }
    } else if (_workplaceConfig != null) {
      serverMethods = _workplaceConfig!.enabledMethods;
      // 폴백: 근무지 설정 활성 방법 ∩ 디바이스 가용 방법
      final filtered = _workplaceConfig!.enabledMethods
          .where((m) => deviceMethods.contains(m))
          .toList();
      if (filtered.isNotEmpty) {
        methods = filtered;
      }
    }

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
    if (methods.isEmpty) {
      emit(state.copyWith(
        uiState: AttendanceUiState.error,
        errorMessage: '사용 가능한 인증 방식이 없습니다.',
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

    // NFC 인증 시 기대 태그 ID 설정 (로컬 비교용)
    final nfcStrategy = _verificationManager.getStrategy(VerificationMethod.nfc);
    if (nfcStrategy is NfcVerificationService) {
      nfcStrategy.expectedTagId =
          _workplaceConfig?.getConfig(VerificationMethod.nfc)?['tag_id'] as String?;
    }

    // Beacon 인증 시 타겟 UUID 설정 (iOS CoreLocation ranging에 필요)
    final btStrategy = _verificationManager.getStrategy(VerificationMethod.bluetooth);
    if (btStrategy is BluetoothVerificationService) {
      btStrategy.targetUuid =
          _workplaceConfig?.getConfig(VerificationMethod.bluetooth)?['uuid'] as String?;
    }

    final combinedData = <String, dynamic>{};
    for (final method in methods) {
      final verificationResult = await _verificationManager.verify(method);

      if (!verificationResult.isVerified) {
        // 하나라도 실패 시 에러 emit 후 종료 (로컬 인증 실패 → errorCode 없음)
        emit(state.copyWith(
          uiState: AttendanceUiState.error,
          errorMessage: verificationResult.errorMessage ??
              '${method.label} 인증에 실패했습니다.',
          errorCode: null,
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
