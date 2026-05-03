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

    // NFC 인증 시 기대 태그 ID 목록 설정 (로컬 OR 매칭용)
    // NFC 단독(nfc) + 복합(nfc_gps) 양쪽 config에서 nfc_targets 합산
    final nfcStrategy = _verificationManager.getStrategy(VerificationMethod.nfc);
    if (nfcStrategy is NfcVerificationService) {
      nfcStrategy.expectedTagIds = _collectTargetField(
        methods: const [VerificationMethod.nfc, VerificationMethod.nfcGps],
        partKey: 'nfc_targets',
        field: 'tag_id',
      );
    }

    // Beacon 인증 시 타겟 UUID 목록 설정 (iOS CoreLocation 다중 Region ranging에 필요)
    // Beacon 단독(beacon) + 복합(beacon_gps) 양쪽 config에서 beacon_targets 합산
    final btStrategy = _verificationManager.getStrategy(VerificationMethod.bluetooth);
    if (btStrategy is BluetoothVerificationService) {
      btStrategy.targetUuids = _collectTargetField(
        methods: const [VerificationMethod.bluetooth, VerificationMethod.beaconGps],
        partKey: 'beacon_targets',
        field: 'uuid',
      );
    }

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

  /// 단독+복합 메서드의 config에서 동일 부품 필드값을 모두 합산 (중복 제거)
  ///
  /// 예) NFC 사전 비교용 tag_id 목록은 nfc 단독 config + nfc_gps 복합 config 양쪽에서 수집해야
  /// 워크플레이스가 복합 메서드만 활성화한 경우에도 사전 비교가 동작한다.
  List<String> _collectTargetField({
    required List<VerificationMethod> methods,
    required String partKey,
    required String field,
  }) {
    final values = <String>{};
    for (final method in methods) {
      final config = _workplaceConfig?.getConfig(method);
      if (config == null) continue;
      var targets = _extractTargets(config, key: partKey);
      if (targets.isEmpty) targets = _extractTargets(config);
      values.addAll(targets.map((t) => t[field]).whereType<String>());
    }
    return values.toList();
  }

  /// config_data에서 타겟 배열을 추출 (신/구 schema 호환)
  ///
  /// - 신 schema: `{"targets": [{...}, ...]}` 또는 `{"nfc_targets": [...]}`/`{"beacon_targets": [...]}` 등
  /// - 구 schema: 단일 dict (예: `{"tag_id": "..."}`) → 1개 target으로 감쌈
  /// - 키가 존재하지만 List가 아니거나 비어있으면 빈 리스트 반환
  List<Map<String, dynamic>> _extractTargets(
    Map<String, dynamic>? config, {
    String key = 'targets',
  }) {
    if (config == null) return const [];
    final raw = config[key];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    // 신 schema 키가 명시적으로 요청된 경우 (예: nfc_targets) 폴백 없음
    if (key != 'targets') return const [];
    // 구 schema 폴백: config 자체를 1개 target으로 취급
    return [config];
  }
}
