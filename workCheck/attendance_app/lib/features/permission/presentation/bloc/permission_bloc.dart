import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/permission_status_entity.dart';
import '../../domain/usecases/check_permissions_usecase.dart';
import '../../domain/usecases/request_permissions_usecase.dart';

part 'permission_event.dart';
part 'permission_state.dart';
part 'permission_bloc.freezed.dart';

@injectable
class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  final CheckPermissionsUseCase _checkPermissions;
  final RequestPermissionsUseCase _requestPermissions;

  PermissionBloc(
    this._checkPermissions,
    this._requestPermissions,
  ) : super(const PermissionState()) {
    on<PermissionStarted>(_onStarted);
    on<PermissionRequested>(_onRequested);
    on<PermissionOpenSettingsRequested>(_onOpenSettings);
  }

  /// 화면 진입 시: 현재 권한 상태 조회
  Future<void> _onStarted(
    PermissionStarted event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(uiState: PermissionUiState.loading));

    final result = await _checkPermissions(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        uiState: PermissionUiState.error,
        errorMessage: failure.message,
      )),
      (items) {
        final allGranted = items.every((e) => e.isGranted);
        emit(state.copyWith(
          uiState: PermissionUiState.loaded,
          permissionItems: items,
          allGranted: allGranted,
        ));
      },
    );
  }

  /// "확인" 버튼 클릭 시: 모든 권한 일괄 요청
  Future<void> _onRequested(
    PermissionRequested event,
    Emitter<PermissionState> emit,
  ) async {
    emit(state.copyWith(uiState: PermissionUiState.requesting));

    final result = await _requestPermissions(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        uiState: PermissionUiState.error,
        errorMessage: failure.message,
      )),
      (items) {
        final allGranted = items.every((e) => e.isGranted);
        final hasPermanentlyDenied =
            items.any((e) => e.status.isPermanentlyDenied);

        if (allGranted) {
          emit(state.copyWith(
            uiState: PermissionUiState.allGranted,
            permissionItems: items,
            allGranted: true,
          ));
        } else if (hasPermanentlyDenied) {
          emit(state.copyWith(
            uiState: PermissionUiState.permanentlyDenied,
            permissionItems: items,
            allGranted: false,
          ));
        } else {
          emit(state.copyWith(
            uiState: PermissionUiState.partiallyDenied,
            permissionItems: items,
            allGranted: false,
          ));
        }
      },
    );
  }

  /// 설정 앱 열기
  Future<void> _onOpenSettings(
    PermissionOpenSettingsRequested event,
    Emitter<PermissionState> emit,
  ) async {
    await openAppSettings();
  }
}
