// 시각 검증용 통합 테스트 헬퍼 (일회성 — 검증 후 삭제 가능)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance_app/app.dart';
import 'package:attendance_app/core/di/injection.dart';
import 'package:attendance_app/core/utils/bloc_observer.dart';
import 'package:attendance_app/features/permission/data/datasources/permission_local_datasource.dart';
import 'package:attendance_app/features/permission/domain/entities/permission_status_entity.dart';

/// 시뮬레이터에서 부여 불가한 권한(블루투스) 탓에 다이얼로그가 안 닫히므로
/// 테스트에서만 권한 데이터소스를 전부 granted 로 스텁 (제품 코드 무변경)
class _GrantedPermissionDataSource extends PermissionLocalDataSource {
  List<PermissionItem> get _granted => const [
        PermissionItem(
          permission: Permission.location,
          title: '위치 (필수)',
          description: '내 위치 정보 활용',
          iconAsset: 'assets/icons/Property_gps.svg',
          status: PermissionStatus.granted,
          requiredBy: [],
        ),
      ];

  @override
  Future<List<PermissionItem>> checkAll() async => _granted;

  @override
  Future<List<PermissionItem>> requestAll() async => _granted;

  @override
  Future<bool> areAllGranted() async => true;
}

/// 네이티브 위치 권한 알림/TCC 를 우회하기 위한 위치 플랫폼 스텁
/// (시뮬레이터 좌표 주입 — 출근지 37.4979,127.0276 의 반경 150m 안)
class _FakeGeolocator extends GeolocatorPlatform {
  Position get _pos => Position(
        latitude: 37.4981,
        longitude: 127.0274,
        timestamp: DateTime.now(),
        accuracy: 15,
        altitude: 0,
        altitudeAccuracy: 1,
        heading: 0,
        headingAccuracy: 1,
        speed: 0,
        speedAccuracy: 1,
      );

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async =>
      _pos;

  @override
  Future<Position?> getLastKnownPosition({bool forceLocationManager = false}) async =>
      _pos;

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) =>
      Stream<Position>.value(_pos);
}

/// main() 을 복제하되 권한 데이터소스/위치 플랫폼만 스텁으로 교체해 앱 기동
Future<void> launchApp(WidgetTester t) async {
  await prepPrefs();
  GeolocatorPlatform.instance = _FakeGeolocator();
  await initializeDateFormatting('ko_KR');
  await configureDependencies();
  await getIt.unregister<PermissionLocalDataSource>();
  getIt.registerLazySingleton<PermissionLocalDataSource>(
      () => _GrantedPermissionDataSource());
  await KakaoMapSdk.instance.initialize('251dc7720258f298d08ac0f7cec438b3');
  Bloc.observer = AppBlocObserver();
  runApp(const App());
  await hold(t, 1.5);
}

/// 실시간으로 N초 대기하며 프레임 펌프 (지도 펄스 무한 애니메이션 때문에 pumpAndSettle 금지)
Future<void> hold(WidgetTester t, double seconds) async {
  final end =
      DateTime.now().add(Duration(milliseconds: (seconds * 1000).round()));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

/// 파인더가 나타날 때까지 대기 (최대 timeout초). 성공 여부 반환
Future<bool> waitFor(WidgetTester t, Finder f, double timeout) async {
  final end =
      DateTime.now().add(Duration(milliseconds: (timeout * 1000).round()));
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
    if (f.evaluate().isNotEmpty) return true;
  }
  return false;
}

/// 로컬 도커 API 로 baseUrl 강제 + 이전 토큰/상태 제거
Future<void> prepPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await prefs.setString('server_base_url', 'http://127.0.0.1:8081');
}

/// 권한 다이얼로그가 떠 있으면 '확인' 을 닫힐 때까지 재탭
/// (외부에서 simctl privacy grant 가 반복 실행되므로 곧 granted 로 전환됨)
Future<void> passPermissionDialog(WidgetTester t) async {
  await hold(t, 2);
  if (find.text('확인').evaluate().isEmpty) return;
  // ignore: avoid_print
  print('SHOT:permission_dialog');
  await hold(t, 3);
  for (var i = 0; i < 8; i++) {
    final confirm = find.text('확인');
    if (confirm.evaluate().isEmpty) return; // 다이얼로그 닫힘
    await t.tap(confirm.last, warnIfMissed: false);
    await hold(t, 3);
  }
  expect(find.text('확인').evaluate().isEmpty, true,
      reason: '권한 다이얼로그가 닫히지 않음');
}

/// 로그인: 회사코드/사번/비밀번호 입력 후 SVG 로그인 버튼 탭
Future<void> doLogin(WidgetTester t, String emp, String pw) async {
  final ok = await waitFor(t, find.byType(TextField), 25);
  expect(ok, true, reason: '로그인 화면 미도달');
  await passPermissionDialog(t);
  final fields = find.byType(TextField);
  expect(fields.evaluate().length >= 3, true, reason: '입력 필드 3개 미만');
  await t.enterText(fields.at(0), 'jerix');
  await hold(t, 0.3);
  await t.enterText(fields.at(1), emp);
  await hold(t, 0.3);
  // 비밀번호 필드는 readOnly + 보안 키패드 → 필드 탭 후 키패드 숫자를 직접 탭
  await t.tap(fields.at(2), warnIfMissed: false);
  expect(await waitFor(t, find.text('입력완료'), 10), true,
      reason: '보안 키패드 미표시');
  for (final ch in pw.split('')) {
    final key = find.text(ch);
    expect(key.evaluate().isNotEmpty, true, reason: '키패드 숫자 $ch 미발견');
    await t.tap(key.last, warnIfMissed: false);
    await hold(t, 0.3);
  }
  await t.tap(find.text('입력완료'), warnIfMissed: false);
  await hold(t, 0.8);
  // 로그인 버튼 = btn_on.svg 를 감싼 GestureDetector
  final btn = find.byWidgetPredicate((w) =>
      w is SvgPicture &&
      w.bytesLoader is SvgAssetLoader &&
      (w.bytesLoader as SvgAssetLoader).assetName.contains('btn_'));
  expect(btn.evaluate().isNotEmpty, true, reason: '로그인 버튼 미발견');
  await t.tap(btn.first, warnIfMissed: false);
}
