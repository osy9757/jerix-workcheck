// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/attendance/data/datasources/remote/attendance_remote_datasource.dart'
    as _i150;
import '../../features/attendance/data/repositories/attendance_repository_impl.dart'
    as _i719;
import '../../features/attendance/domain/repositories/attendance_repository.dart'
    as _i477;
import '../../features/attendance/domain/usecases/get_history_usecase.dart'
    as _i1054;
import '../../features/attendance/domain/usecases/get_today_status_usecase.dart'
    as _i317;
import '../../features/attendance/domain/usecases/register_attendance_usecase.dart'
    as _i21;
import '../../features/attendance/presentation/bloc/attendance_bloc.dart'
    as _i700;
import '../../features/attendance/presentation/bloc/history_bloc.dart' as _i677;
import '../../features/auth/data/datasources/local/auth_local_datasource.dart'
    as _i814;
import '../../features/permission/data/datasources/permission_local_datasource.dart'
    as _i397;
import '../../features/permission/data/repositories/permission_repository_impl.dart'
    as _i519;
import '../../features/permission/domain/repositories/permission_repository.dart'
    as _i606;
import '../../features/permission/domain/usecases/check_permissions_usecase.dart'
    as _i420;
import '../../features/permission/domain/usecases/request_permissions_usecase.dart'
    as _i509;
import '../../features/permission/presentation/bloc/permission_bloc.dart'
    as _i714;
import '../../features/verification/data/services/bluetooth_service.dart'
    as _i993;
import '../../features/verification/data/services/gps_service.dart' as _i404;
import '../../features/verification/data/services/nfc_service.dart' as _i1018;
import '../../features/verification/data/services/qr_service.dart' as _i1069;
import '../../features/verification/data/services/wifi_service.dart' as _i1036;
import '../../features/verification/data/verification_manager.dart' as _i630;
import '../../features/verification/domain/verification_strategy.dart' as _i626;
import '../../features/workplace/data/datasources/remote/workplace_remote_datasource.dart'
    as _i127;
import '../../features/workplace/data/repositories/workplace_repository_impl.dart'
    as _i334;
import '../../features/workplace/domain/repositories/workplace_repository.dart'
    as _i38;
import '../../features/workplace/domain/usecases/get_workplace_config_usecase.dart'
    as _i360;
import '../network/dio_client.dart' as _i667;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final networkModule = _$NetworkModule();
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio);
    gh.lazySingleton<_i814.AuthLocalDatasource>(
        () => _i814.AuthLocalDatasource());
    gh.lazySingleton<_i397.PermissionLocalDataSource>(
        () => _i397.PermissionLocalDataSource());
    gh.lazySingleton<_i626.VerificationStrategy>(
      () => _i1018.NfcVerificationService(),
      instanceName: 'nfc',
    );
    gh.lazySingleton<_i626.VerificationStrategy>(
      () => _i1069.QrVerificationService(),
      instanceName: 'qr',
    );
    gh.lazySingleton<_i626.VerificationStrategy>(
      () => _i1036.WifiVerificationService(),
      instanceName: 'wifi',
    );
    gh.lazySingleton<_i626.VerificationStrategy>(
      () => _i404.GpsVerificationService(),
      instanceName: 'gps',
    );
    gh.lazySingleton<_i626.VerificationStrategy>(
      () => _i993.BluetoothVerificationService(),
      instanceName: 'bluetooth',
    );
    gh.lazySingleton<_i150.AttendanceRemoteDataSource>(
        () => _i150.AttendanceRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i127.WorkplaceRemoteDataSource>(
        () => _i127.WorkplaceRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i606.PermissionRepository>(() =>
        _i519.PermissionRepositoryImpl(gh<_i397.PermissionLocalDataSource>()));
    gh.lazySingleton<_i420.CheckPermissionsUseCase>(
        () => _i420.CheckPermissionsUseCase(gh<_i606.PermissionRepository>()));
    gh.lazySingleton<_i509.RequestPermissionsUseCase>(() =>
        _i509.RequestPermissionsUseCase(gh<_i606.PermissionRepository>()));
    gh.lazySingleton<_i630.VerificationManager>(() => _i630.VerificationManager(
          gps: gh<_i626.VerificationStrategy>(instanceName: 'gps'),
          qr: gh<_i626.VerificationStrategy>(instanceName: 'qr'),
          nfc: gh<_i626.VerificationStrategy>(instanceName: 'nfc'),
          bluetooth: gh<_i626.VerificationStrategy>(instanceName: 'bluetooth'),
          wifi: gh<_i626.VerificationStrategy>(instanceName: 'wifi'),
        ));
    gh.lazySingleton<_i38.WorkplaceRepository>(() =>
        _i334.WorkplaceRepositoryImpl(gh<_i127.WorkplaceRemoteDataSource>()));
    gh.lazySingleton<_i477.AttendanceRepository>(() =>
        _i719.AttendanceRepositoryImpl(gh<_i150.AttendanceRemoteDataSource>()));
    gh.factory<_i714.PermissionBloc>(() => _i714.PermissionBloc(
          gh<_i420.CheckPermissionsUseCase>(),
          gh<_i509.RequestPermissionsUseCase>(),
        ));
    gh.lazySingleton<_i360.GetWorkplaceConfigUseCase>(
        () => _i360.GetWorkplaceConfigUseCase(gh<_i38.WorkplaceRepository>()));
    gh.lazySingleton<_i1054.GetHistoryUseCase>(
        () => _i1054.GetHistoryUseCase(gh<_i477.AttendanceRepository>()));
    gh.lazySingleton<_i317.GetTodayStatusUseCase>(
        () => _i317.GetTodayStatusUseCase(gh<_i477.AttendanceRepository>()));
    gh.lazySingleton<_i21.RegisterAttendanceUseCase>(
        () => _i21.RegisterAttendanceUseCase(gh<_i477.AttendanceRepository>()));
    gh.factory<_i677.HistoryBloc>(
        () => _i677.HistoryBloc(gh<_i1054.GetHistoryUseCase>()));
    gh.factory<_i700.AttendanceBloc>(() => _i700.AttendanceBloc(
          gh<_i317.GetTodayStatusUseCase>(),
          gh<_i21.RegisterAttendanceUseCase>(),
          gh<_i630.VerificationManager>(),
          gh<_i360.GetWorkplaceConfigUseCase>(),
          gh<_i814.AuthLocalDatasource>(),
        ));
    return this;
  }
}

class _$NetworkModule extends _i667.NetworkModule {}
