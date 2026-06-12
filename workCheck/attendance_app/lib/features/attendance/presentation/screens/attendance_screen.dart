import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';
import '../../../verification/domain/verification_method.dart';
import '../bloc/attendance_bloc.dart';
import '../widgets/beacon_mismatch_dialog.dart';
import '../widgets/beacon_unavailable_dialog.dart';
import '../widgets/clock_in_confirm_dialog.dart';
import '../widgets/clock_in_unavailable_dialog.dart';
import '../widgets/gps_spoofing_dialog.dart';
import '../widgets/nfc_check_fail_dialog.dart';
import '../widgets/wifi_unavailable_dialog.dart';

/// 출퇴근 메인 화면
///
/// 현재 시간, 출근지/현위치 정보, 지도, 출퇴근 버튼을 표시.
/// BLoC을 통해 출퇴근 상태를 관리하며 인증 결과에 따라 다이얼로그를 분기.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  static const LatLng _fallbackMapPosition = LatLng(37.5419, 126.9498);
  static const double _baseMarkerSize = 40;
  static const int _defaultMapZoomLevel = 16;

  // 현위치 원 반경(미터) 테스트 조정용 상수 — GPS 정확도가 없거나 범위를 벗어날 때 사용
  static const double _currentCircleFallbackRadiusM = 30.0; // 정확도 미상 시 폴백 반경
  static const double _currentCircleMinRadiusM = 15.0; // 너무 작아 안 보이는 것 방지
  static const double _currentCircleMaxRadiusM = 60.0; // 너무 커서 화면을 덮는 것 방지

  KakaoMapController? _mapController;
  String _userName = '';

  /// 현위치 GPS 정확도(미터) — 현위치 원 반경 계산에 사용
  double? _currentAccuracyMeters;

  /// 현위치 중심 원 도형 (GPS 정확도 기반, 메인 컬러)
  Polygon? _currentCirclePolygon;

  /// 출근지/현위치 마커 전용 LabelController.
  ///
  /// ⚠️ 실험적: CompetitionType.none + 높은 zOrder 로 기본맵 라벨 경쟁/LOD 컬링에서
  /// 제외시켜 저줌·라벨 밀집 지역에서도 마커가 항상 렌더되도록 시도한다. 실기기 없이
  /// 검증 불가하므로, 실패 시 Flutter 오버레이 마커 폴백으로 전환해야 한다
  /// (아래 _markerStyle 주석 참조).
  LabelController? _markerLayer;

  /// 현위치 주소 (역지오코딩 결과)
  String _currentAddress = '위치 확인 중...';

  /// 출근지 주소 (서버 설정)
  String _attendanceAddress = '-';

  /// 현재 GPS 좌표
  LatLng? _currentLatLng;

  /// 지도에 표시할 출근지 좌표 (GPS 인증 설정이 있을 때만 사용)
  LatLng? _attendanceLatLng;

  /// 현재 지도에서 GPS 인증 위치를 표시해야 하는지 여부
  bool _usesGpsOnMap = false;

  /// GPS 허용 반경 (미터)
  double? _gpsRadiusMeters;

  /// 펄스 애니메이션 컨트롤러
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  /// 반경 원 도형 (KakaoMap ShapeLayer) - 출근 가능 거리(radius_m) 경계, 정적
  Polygon? _radiusPolygon;

  /// 하트비트 펄스 링 도형 - 중심에서 radius_m까지 맥동(커졌다 작아짐 + 페이드)
  Polygon? _pulseRingPolygon;

  /// 반경 원/펄스 링을 그릴 ShapeLayer (생성 후 재사용)
  ShapeController? _radiusShapeLayer;

  /// 현위치 / 출근지 마커
  Poi? _currentLocationPoi;
  Poi? _destinationPoi;

  /// 비동기 지도 갱신 충돌 방지 토큰
  int _mapSyncToken = 0;

  /// 마지막 적용된 마커 스케일
  double _lastMarkerScale = 1.0;

  /// 마지막 원 스타일 업데이트 시간 (쓰로틀링용)
  DateTime _lastPulseUpdate = DateTime.now();

  /// 펄스 페이드 단계별 PolygonStyle 캐시 (단계 인덱스 → 등록 완료 스타일)
  ///
  /// 매 틱마다 새 PolygonStyle을 만들면 네이티브에 스타일이 무한 누적되므로,
  /// 페이드 값을 N단계로 양자화해 미리 등록한 스타일을 재사용한다.
  final Map<int, PolygonStyle> _pulseStyleCache = {};

  /// 펄스 페이드 양자화 단계 수
  static const int _pulseFadeSteps = 12;

  /// 마지막으로 적용한 펄스 페이드 단계 (동일 단계면 스타일 갱신 스킵)
  int _lastPulseStep = -1;

  @override
  void initState() {
    super.initState();
    // 하트비트 펄스: 0→1 반복(reverse 없음) → 링이 밖으로 퍼졌다가 다시 중심에서 시작
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    )..addListener(_onPulseUpdate);
    _loadUserInfo();
    _loadLocationInfo();
  }

  /// 로그인 시 저장한 사용자 이름 로드
  Future<void> _loadUserInfo() async {
    final authLocal = getIt<AuthLocalDatasource>();
    final name = await authLocal.getUserName();
    if (mounted && name != null) {
      setState(() => _userName = name);
    }
  }

  /// GPS 현재 위치 조회 + 역지오코딩 + 출근지 정보 로드
  Future<void> _loadLocationInfo() async {
    // 현재 GPS 위치 조회
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);

      // GPS 정확도(미터) 저장 → 현위치 원 반경 계산에 사용
      _currentAccuracyMeters = position.accuracy;

      if (mounted) {
        setState(() => _currentLatLng = latLng);
      }
      unawaited(_syncMapIfReady());

      // 역지오코딩: 좌표 → 주소
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty && mounted) {
          final p = placemarks.first;
          // 한국 주소 형식으로 조합
          final address = [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
          setState(() {
            _currentAddress = address.isNotEmpty ? address : '주소를 찾을 수 없음';
          });
        }
      } catch (e) {
        debugPrint('[Geocoding] 역지오코딩 오류: $e');
        if (mounted) {
          setState(() => _currentAddress = '주소 변환 실패');
        }
      }
    } catch (e) {
      debugPrint('[GPS] 위치 조회 오류: $e');
      if (mounted) {
        setState(() => _currentAddress = '위치 조회 실패');
      }
    }

    // 출근지 정보: init 응답(`bloc.lastInit`)의 gps.targets 좌표/반경에서 가져오기
    _loadAttendanceLocation();
  }

  /// 출근지 주소 및 좌표를 init 응답(`gps.targets[]`)에서 로드
  ///
  /// v2 리팩토링: workplace 개념 폐기. 출근지 정보는 출퇴근 init 응답의
  /// gps 설정(`targets[].lat/lng/radius_m`)에서 가져온다.
  void _loadAttendanceLocation() {
    final bloc = context.read<AttendanceBloc>();
    final init = bloc.lastInit;
    if (init == null) return;

    // GPS가 required_methods에 포함된 경우에만 지도에 출근지 마커/반경을 표시
    final serverEnabledMethods = bloc.state.serverEnabledMethods;
    final usesGps = serverEnabledMethods.contains(VerificationMethod.gps) ||
        init.requiredMethods.contains(VerificationMethod.gps);
    final gpsTarget = usesGps ? _resolveGpsMapTarget() : null;

    _usesGpsOnMap = gpsTarget != null;
    _attendanceLatLng = gpsTarget?.position;
    _gpsRadiusMeters = gpsTarget?.radiusMeters;

    if (!_usesGpsOnMap && mounted) {
      setState(() => _attendanceAddress = '-');
    }

    if (gpsTarget != null) {
      _reverseGeocodeAttendance(
        gpsTarget.position.latitude,
        gpsTarget.position.longitude,
      );
    }
    _syncMapIfReady();
  }

  /// init 응답의 gps 설정에서 지도에 표시할 첫 GPS 타겟을 추출
  ///
  /// 새 contract 스키마: `gps.targets[].lat/lng/radius_m` (snake_case)
  _GpsMapTarget? _resolveGpsMapTarget() {
    final init = context.read<AttendanceBloc>().lastInit;
    if (init == null) return null;

    final gpsConfig = init.getConfig(VerificationMethod.gps);
    if (gpsConfig == null) return null;

    final rawTargets = gpsConfig['targets'];
    if (rawTargets is! List) return null;

    for (final rawTarget in rawTargets) {
      if (rawTarget is Map) {
        final target = _targetFromMap(Map<String, dynamic>.from(rawTarget));
        if (target != null) return target;
      }
    }
    return null;
  }

  _GpsMapTarget? _targetFromMap(Map<String, dynamic> raw) {
    // 새 contract: lat/lng (구 latitude/longitude 호환도 유지)
    final lat = (raw['lat'] as num?)?.toDouble() ??
        (raw['latitude'] as num?)?.toDouble();
    final lng = (raw['lng'] as num?)?.toDouble() ??
        (raw['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return _GpsMapTarget(
      position: LatLng(lat, lng),
      // 새 contract: radius_m (구 radius_meters 호환도 유지)
      radiusMeters: (raw['radius_m'] as num?)?.toDouble() ??
          (raw['radius_meters'] as num?)?.toDouble(),
      address: raw['address'] as String?,
    );
  }

  /// 출근지 좌표 역지오코딩
  Future<void> _reverseGeocodeAttendance(double lat, double lng) async {
    // 이미 주소가 설정되어 있으면 스킵
    if (_attendanceAddress != '-') return;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final address = [p.street, p.subLocality, p.locality]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        setState(() {
          _attendanceAddress = address.isNotEmpty ? address : '-';
        });
      }
    } catch (e) {
      debugPrint('[Geocoding] 출근지 역지오코딩 오류: $e');
    }
  }

  /// GPS 허용 반경 파란색 원 추가 (KakaoMap ShapeLayer)
  ///
  /// 두 도형을 그린다:
  /// - `_radiusPolygon`: 출근 가능 거리(radius_m) 경계를 나타내는 정적 파란 원
  /// - `_pulseRingPolygon`: 중심에서 radius_m까지 맥동하는 하트비트 펄스 링
  Future<void> _addRadiusCircle(KakaoMapController controller) async {
    final radius = _gpsRadiusMeters;
    final attendanceLatLng = _attendanceLatLng;
    if (!_usesGpsOnMap || radius == null || radius <= 0 || attendanceLatLng == null) {
      await _removeRadiusCircle();
      return;
    }

    // 이미 추가된 경우 위치/반경만 갱신
    if (_radiusPolygon != null) {
      await _radiusPolygon!.changePosition(CirclePoint(radius, attendanceLatLng));
      return;
    }

    try {
      // 반경 원과 펄스 링은 동일한 ShapeLayer를 공유.
      // ⚠️ 기본 ShapeLayer(vector_layer_0)는 SDK가 Dart 객체로만 생성하고
      // 네이티브 ShapeManager에는 만들지 않는다(마커용 LabelLayer와 달리 자동
      // 생성 대상이 아님). 그래서 도형 추가 전 ensureDefaultShapeLayer()로
      // 네이티브 레이어를 1회 생성해야 한다(멱등). 이를 생략하면 네이티브
      // addPolygonShape 핸들러의 getLayer/getPolygonStyles가 null이 되어
      // NullPointerException으로 도형 렌더가 실패한다.
      // 폴리곤 스타일 등록/조회·추가 채널 모두 동일한 vector_layer_0 레이어를
      // 가리키므로, 레이어가 실제 네이티브에 존재하면 NPE 없이 일관 동작한다.
      final shapeLayer =
          _radiusShapeLayer ??= await controller.ensureDefaultShapeLayer();

      // 1) 정적 경계 원: 실제 출근 가능 거리(radius_m) 기준
      final boundaryStyle = PolygonStyle(
        Colors.blue.withValues(alpha: 0.12),
        strokeWidth: 1.5,
        strokeColor: Colors.blue.withValues(alpha: 0.5),
      );
      _radiusPolygon = await shapeLayer.addPolygonShape(
        CirclePoint(radius, attendanceLatLng),
        boundaryStyle,
        id: 'gps_radius',
      );

      // 2) 하트비트 펄스 링: 초기엔 작은 반경에서 시작 (프레임마다 갱신)
      final pulseStyle = PolygonStyle(
        Colors.blue.withValues(alpha: 0.25),
        strokeWidth: 2.0,
        strokeColor: Colors.blue.withValues(alpha: 0.6),
      );
      _pulseRingPolygon = await shapeLayer.addPolygonShape(
        CirclePoint(radius * 0.2, attendanceLatLng),
        pulseStyle,
        id: 'gps_pulse_ring',
      );
    } catch (e) {
      debugPrint('[KakaoMap] 반경 원 추가 오류: $e');
    }
  }

  Future<void> _removeRadiusCircle() async {
    final pulse = _pulseRingPolygon;
    final polygon = _radiusPolygon;
    _pulseRingPolygon = null;
    _radiusPolygon = null;
    // 펄스 단계 초기화 → 다음에 다시 추가되면 스타일이 재적용되도록
    _lastPulseStep = -1;
    try {
      if (pulse != null) await pulse.remove();
      if (polygon != null) await polygon.remove();
    } catch (e) {
      debugPrint('[KakaoMap] 반경 원 제거 오류: $e');
    }
  }

  /// 현위치 중심 원 추가/갱신 (GPS 정확도 기반 동적 반경, 메인 컬러 #2DDAA9)
  ///
  /// 출근지 파란 반경 원(_addRadiusCircle)과 동일한 ShapeLayer 패턴을 따른다.
  /// 반경은 GPS 정확도(미터)를 15~60m로 클램프(폴백 30m)하며, 출근지 파란 원과
  /// 시각적으로 구분되도록 메인 컬러(#2DDAA9)를 사용한다. PPT 슬라이드3 A상태
  /// (현위치 중심 원)를 충족한다.
  Future<void> _upsertCurrentLocationCircle(
    KakaoMapController controller,
  ) async {
    final center = _currentLatLng;
    if (center == null) {
      await _removeCurrentLocationCircle();
      return;
    }

    // 정확도 기반 동적 반경 (없으면 폴백, 항상 min~max로 클램프)
    final radius = (_currentAccuracyMeters ?? _currentCircleFallbackRadiusM)
        .clamp(_currentCircleMinRadiusM, _currentCircleMaxRadiusM);

    // 이미 추가된 경우 위치/반경만 갱신
    if (_currentCirclePolygon != null) {
      await _currentCirclePolygon!.changePosition(CirclePoint(radius, center));
      return;
    }

    try {
      // 출근지 원과 동일한 ShapeLayer 재사용 (네이티브 레이어 멱등 생성)
      final shapeLayer =
          _radiusShapeLayer ??= await controller.ensureDefaultShapeLayer();

      // 메인 컬러 원: 출근지 파란 원과 색상으로 구분
      const mainColor = Color(0xFF2DDAA9);
      final style = PolygonStyle(
        mainColor.withValues(alpha: 0.15),
        strokeWidth: 1.5,
        strokeColor: mainColor.withValues(alpha: 0.5),
      );
      _currentCirclePolygon = await shapeLayer.addPolygonShape(
        CirclePoint(radius, center),
        style,
        id: 'current_location_circle',
      );
    } catch (e) {
      debugPrint('[KakaoMap] 현위치 원 추가 오류: $e');
    }
  }

  /// 현위치 원 제거 (위치 조회 실패/권한 거부 시 대비, dispose 외 호출처는 없음)
  Future<void> _removeCurrentLocationCircle() async {
    final polygon = _currentCirclePolygon;
    if (polygon == null) return;
    _currentCirclePolygon = null;
    try {
      await polygon.remove();
    } catch (e) {
      debugPrint('[KakaoMap] 현위치 원 제거 오류: $e');
    }
  }

  /// 하트비트 펄스 애니메이션 업데이트 (~10fps 쓰로틀링)
  ///
  /// 펄스 링이 중심(radius_m * 0.2)에서 경계(radius_m)까지 커지면서
  /// 동시에 투명해지도록(페이드 아웃) 갱신 → 심장 박동처럼 퍼지는 효과.
  void _onPulseUpdate() {
    final now = DateTime.now();
    if (now.difference(_lastPulseUpdate).inMilliseconds < 100) return;
    _lastPulseUpdate = now;

    final pulse = _pulseRingPolygon;
    final radius = _gpsRadiusMeters;
    final center = _attendanceLatLng;
    if (pulse == null || radius == null || center == null) return;

    // 애니메이션 값(0~1) → 펄스 링 반경: radius_m의 20% ~ 100%
    final t = _pulseAnimation.value;
    final pulseRadius = radius * (0.2 + 0.8 * t);

    // 반경(맥동)은 매 틱 갱신 (changePosition은 우리 ShapeLayer 경로라 안전)
    pulse.changePosition(CirclePoint(pulseRadius, center));

    // 페이드(스타일)는 단계로 양자화 → 캐시된 스타일 재사용 (네이티브 누적 방지)
    final step = (t * (_pulseFadeSteps - 1)).round().clamp(0, _pulseFadeSteps - 1);
    if (step == _lastPulseStep) return;
    _lastPulseStep = step;
    pulse.changeStyle(_pulseStyleForStep(step));
  }

  /// 페이드 단계(step)에 해당하는 펄스 PolygonStyle을 반환 (없으면 생성·캐시)
  ///
  /// step이 클수록(링이 커질수록) 더 투명해지는 파란 링.
  PolygonStyle _pulseStyleForStep(int step) {
    return _pulseStyleCache.putIfAbsent(step, () {
      final t = step / (_pulseFadeSteps - 1);
      // 커질수록 투명해지는 페이드 아웃 (중심에서 진하고 밖으로 갈수록 옅게)
      final fade = (1.0 - t).clamp(0.0, 1.0);
      final fillAlpha = 0.04 + 0.18 * fade;
      final strokeAlpha = 0.10 + 0.45 * fade;
      return PolygonStyle(
        Colors.blue.withValues(alpha: fillAlpha),
        strokeWidth: 2.0,
        strokeColor: Colors.blue.withValues(alpha: strokeAlpha),
      );
    });
  }

  /// 지도 상태 동기화 (현위치 중심 또는 현위치+근무지 fit)
  Future<void> _syncMapIfReady() async {
    final controller = _mapController;
    final currentLocation = _currentLatLng;
    if (controller == null || currentLocation == null) return;

    final token = ++_mapSyncToken;
    try {
      await _configureMapGestures(controller);
      if (token != _mapSyncToken) return;

      await _upsertCurrentLocationPoi(controller, currentLocation);
      if (token != _mapSyncToken) return;

      // 현위치 원은 GPS 타겟 유무와 무관하게 항상 표시 (PPT A상태 충족)
      await _upsertCurrentLocationCircle(controller);
      if (token != _mapSyncToken) return;

      final attendanceLatLng = _usesGpsOnMap ? _attendanceLatLng : null;
      if (attendanceLatLng == null) {
        // 출근지 마커/파란 반경 원만 제거(현위치 원은 유지)
        await _removeDestinationPoi();
        await _removeRadiusCircle();
        await _moveCameraCurrentCentered(controller, currentLocation, null);
        await _updateMarkerScaleForCurrentZoom(controller);
        return;
      }

      await _upsertDestinationPoi(controller, attendanceLatLng);
      if (token != _mapSyncToken) return;

      await _addRadiusCircle(controller);
      await _moveCameraCurrentCentered(
        controller,
        currentLocation,
        attendanceLatLng,
      );
      await _updateMarkerScaleForCurrentZoom(controller);
    } catch (e) {
      debugPrint('[KakaoMap] 지도 동기화 오류: $e');
    }
  }

  /// 재중심(recenter) - 지도를 드래그해 이동한 뒤 현재 위치를 다시 중앙으로
  ///
  /// PPT slide3 B 버튼. '현위치 항상 중앙 고정' 정책(_moveCameraCurrentCentered)
  /// 으로 _syncMapIfReady와 동일하게 동작한다. 출근지가 있으면 mirror-point fit으로
  /// 현위치 정중앙 + 출근지 화면 내 포함, 없으면 현위치만 중앙에 둔다.
  Future<void> _recenterMap() async {
    final controller = _mapController;
    final currentLocation = _currentLatLng;
    if (controller == null || currentLocation == null) return;

    try {
      // B버튼도 '현위치 중앙 고정' 동일 정책 적용
      await _moveCameraCurrentCentered(
        controller,
        currentLocation,
        _usesGpsOnMap ? _attendanceLatLng : null,
      );
      await _updateMarkerScaleForCurrentZoom(controller);
    } catch (e) {
      debugPrint('[KakaoMap] 재중심 오류: $e');
    }
  }

  Future<void> _configureMapGestures(KakaoMapController controller) async {
    final gestures = [
      GestureType.pan,
      GestureType.zoom,
      GestureType.rotateZoom,
      GestureType.twoFingerSingleTap,
      GestureType.oneFingerZoom,
      GestureType.oneFingerDoubleTap,
    ];
    for (final gesture in gestures) {
      try {
        await controller.setGesture(gesture, true);
      } catch (e) {
        debugPrint('[KakaoMap] 제스처 활성화 오류($gesture): $e');
      }
    }
  }

  Future<KImage> _markerImage(String assetPath, double size) {
    return KImage.fromWidget(
      SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
      ),
      Size(size, size),
      pixelRatio: 2.0,
      context: context,
    );
  }

  Future<PoiStyle> _markerStyle(String assetPath) async {
    // 단일 줌스타일(zoomLevel 0, 모든 줌 적용)로 단순화. 기존 다중 브레이크포인트
    // (0/15/17, 아이콘 3회 래스터화)를 1회로 줄임.
    // 참고: 출근지 마커가 fit(저)줌에서 안 보이는 이슈는 이 변경으로 해결되지 않았음
    // (라벨 밀집 지역 카카오 라벨 LOD 추정). 후속으로 Flutter 오버레이 마커로 대응 예정.
    return PoiStyle(
      icon: await _markerImage(assetPath, _baseMarkerSize),
      anchor: const KPoint(0.5, 1.0),
      zoomLevel: 0,
    );
  }

  /// 마커 전용 LabelController를 1회 생성(멱등)해 반환.
  ///
  /// ⚠️ 실험적: CompetitionType.none 으로 기본맵 라벨 경쟁/LOD 컬링에서 제외되어
  /// 저줌·밀집 지역(예: 공덕역)에서도 출근지/현위치 마커가 항상 렌더되는 것을 노린다.
  /// 기본 labelLayer 도 Dart 선언상 이미 none 이지만, 여기서는 명시 파라미터로
  /// 네이티브 레이어를 새로 생성(_createLabelLayer)한다는 점이 실질 차이다.
  /// 실기기 검증 불가하므로 효과 없으면 Flutter 오버레이 마커 폴백으로 전환할 것.
  Future<LabelController> _ensureMarkerLayer(
    KakaoMapController controller,
  ) async {
    return _markerLayer ??= await controller.addLabelLayer(
      'attendance_markers',
      competitionType: CompetitionType.none,
      zOrder: 10010,
    );
  }

  Future<void> _upsertCurrentLocationPoi(
    KakaoMapController controller,
    LatLng position,
  ) async {
    final existing = _currentLocationPoi;
    if (existing != null) {
      await existing.move(position);
      return;
    }

    final layer = await _ensureMarkerLayer(controller);
    _currentLocationPoi = await layer.addPoi(
      position,
      style: await _markerStyle('assets/icons/current_location.svg'),
      id: 'current_location',
      // 높은 rank: 저줌/밀집 지역에서 기본맵 라벨에 밀려 컬링되지 않도록
      rank: 10000,
    );
  }

  Future<void> _upsertDestinationPoi(
    KakaoMapController controller,
    LatLng position,
  ) async {
    final existing = _destinationPoi;
    if (existing != null) {
      await existing.move(position);
      return;
    }

    final layer = await _ensureMarkerLayer(controller);
    _destinationPoi = await layer.addPoi(
      position,
      style: await _markerStyle('assets/icons/destination.svg'),
      id: 'destination',
      // 출근지 마커 최우선 rank: 공덕역 등 라벨 밀집 지역에서도 저줌에 항상 표시
      rank: 20000,
    );
  }

  Future<void> _removeDestinationPoi() async {
    final poi = _destinationPoi;
    if (poi == null) return;
    _destinationPoi = null;
    try {
      await poi.remove();
    } catch (e) {
      debugPrint('[KakaoMap] 출근지 마커 제거 오류: $e');
    }
  }

  /// 현위치를 항상 화면 중앙에 고정하는 카메라 이동.
  ///
  /// PPT 슬라이드3 A상태. [attendanceLatLng] 가 null 이면 단순히 현위치를 중앙에
  /// 두고, 있으면 현위치 기준 출근지의 대칭점(mirror)을 fitMapPoints에 함께 넣어
  /// '현위치 정중앙 + 출근지(원 포함) 화면 내 포함' 두 요구를 동시에 만족시킨다.
  Future<void> _moveCameraCurrentCentered(
    KakaoMapController controller,
    LatLng currentLocation,
    LatLng? attendanceLatLng,
  ) async {
    // (1) 출근지가 없으면 현위치만 중앙에 둔다
    if (attendanceLatLng == null) {
      await controller.moveCamera(
        CameraUpdate.newCenterPosition(
          currentLocation,
          zoomLevel: _defaultMapZoomLevel,
        ),
      );
      return;
    }

    // (2) 현위치 기준 출근지의 대칭점(mirror) — 현위치가 두 점의 정중앙이 됨
    final mirror = LatLng(
      2 * currentLocation.latitude - attendanceLatLng.latitude,
      2 * currentLocation.longitude - attendanceLatLng.longitude,
    );

    // 엣지 케이스: 출근지와 현위치가 거의 일치 → mirror≈att → fit이 단일점이 되어
    // 의미 없으므로 현위치 중앙 고정으로 처리(줌 클램프와 동일 결과).
    final dLat = (mirror.latitude - attendanceLatLng.latitude).abs();
    final dLng = (mirror.longitude - attendanceLatLng.longitude).abs();
    if (dLat < 1e-6 && dLng < 1e-6) {
      await controller.moveCamera(
        CameraUpdate.newCenterPosition(
          currentLocation,
          zoomLevel: _defaultMapZoomLevel,
        ),
      );
      return;
    }

    final padding = _markerSafePadding();
    await controller.moveCamera(
      CameraUpdate.fitMapPoints(
        [attendanceLatLng, mirror],
        padding: padding,
      ),
    );

    // (3) 출근지가 가까우면 과확대되므로 _defaultMapZoomLevel 로 클램프
    try {
      final camera = await controller.getCameraPosition();
      if (camera.zoomLevel > _defaultMapZoomLevel) {
        await controller.moveCamera(
          CameraUpdate.newCenterPosition(
            currentLocation,
            zoomLevel: _defaultMapZoomLevel,
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('[KakaoMap] 카메라 줌 클램프 오류: $e');
    }

    // (4) 마커 외곽이 잘리지 않도록 [출근지, 현위치]로 안전 검증.
    //     부족하면 재시도 — 단, fit은 반드시 [출근지, mirror] 기준이어야
    //     '현위치 중앙' 불변식이 유지된다([att, current] 로 재시도하면 중앙이 깨짐).
    final hasSafeBounds = await _markersFitInsideViewport(
      controller,
      [attendanceLatLng, currentLocation],
      padding,
    );
    if (!hasSafeBounds) {
      await controller.moveCamera(
        CameraUpdate.fitMapPoints(
          [attendanceLatLng, mirror],
          padding: padding + 36,
        ),
      );
    }
  }

  int _markerSafePadding() {
    final markerExtent = (_baseMarkerSize * _lastMarkerScale).ceil();
    final verticalPadding = (markerExtent * 2.2).ceil();
    final minPadding = 96.w.ceil();
    return verticalPadding > minPadding ? verticalPadding : minPadding;
  }

  Future<bool> _markersFitInsideViewport(
    KakaoMapController controller,
    List<LatLng> positions,
    int padding,
  ) async {
    final mapWidth = (343.w - 16.w).round();
    final mapHeight = 230.h.round();
    final markerWidth = (_baseMarkerSize * _lastMarkerScale).ceil();
    final markerHeight = (_baseMarkerSize * _lastMarkerScale).ceil();
    final leftRightMargin = markerWidth ~/ 2 + 8;
    const topMargin = 8;
    final bottomMargin = markerHeight + 8;

    for (final position in positions) {
      final point = await controller.toScreenPoint(position);
      if (point == null) return false;
      if (point.x < leftRightMargin ||
          point.x > mapWidth - leftRightMargin ||
          point.y < topMargin ||
          point.y > mapHeight - bottomMargin) {
        return false;
      }
    }
    return true;
  }

  Future<void> _updateMarkerScaleForCurrentZoom(
    KakaoMapController controller,
  ) async {
    try {
      final camera = await controller.getCameraPosition();
      _updateMarkerScale(camera.zoomLevel);
    } catch (e) {
      debugPrint('[KakaoMap] 마커 스케일 갱신 오류: $e');
    }
  }

  void _updateMarkerScale(int zoomLevel) {
    _lastMarkerScale = _markerScaleForZoom(zoomLevel);
  }

  double _markerScaleForZoom(int zoomLevel) {
    final rawScale = 0.7 + ((zoomLevel - 13) * 0.1);
    return rawScale.clamp(0.75, 1.35).toDouble();
  }

  /// 지도 마커 설정 (현위치 + 필요한 경우 출근지)
  Future<void> _setupMapMarkers(KakaoMapController controller) async {
    try {
      if (_currentLatLng == null) {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        // GPS 정확도(미터) 저장 → 현위치 원 반경 계산에 사용
        _currentAccuracyMeters = position.accuracy;
        if (mounted) {
          setState(() {
            _currentLatLng = LatLng(position.latitude, position.longitude);
          });
        }
      }

      await _syncMapIfReady();
    } catch (e) {
      debugPrint('[KakaoMap] 마커 추가 오류: $e');
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _pulseAnimation.removeListener(_onPulseUpdate);
    _pulseController.dispose();
    super.dispose();
  }

  /// 출퇴근 버튼 핸들러 - BLoC 이벤트 디스패치
  void _handleClockAction() {
    // 모든 availableMethods를 순차 검증 (BLoC에서 처리)
    context.read<AttendanceBloc>().add(const AttendanceEvent.clockRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: BlocConsumer<AttendanceBloc, AttendanceState>(
            listener: _blocListener,
            builder: (context, state) {
              final todayStatus = state.todayStatus;
              final isClockedIn = todayStatus?.isClockedIn ?? false;
              final isCompleted = todayStatus?.isCompleted ?? false;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(child: _buildGreeting()),
                          GestureDetector(
                            onTap: () => context.push('/settings'),
                            child: Icon(
                              Icons.settings_outlined,
                              size: 24.w,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      _buildAttendanceCard(
                        state: state,
                        isClockedIn: isClockedIn,
                        isCompleted: isCompleted,
                        isLoading:
                            state.uiState == AttendanceUiState.verifying ||
                                state.uiState == AttendanceUiState.registering,
                      ),
                      SizedBox(height: 14.h),
                      _buildMapSection(),
                      SizedBox(height: 14.h),
                      _buildStatusCard(
                        clockInTime: todayStatus?.clockIn?.timestamp,
                        clockOutTime: todayStatus?.clockOut?.timestamp,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// BLoC 상태 변화 리스너 (사이드 이펙트)
  void _blocListener(BuildContext context, AttendanceState state) {
    switch (state.uiState) {
      case AttendanceUiState.loaded:
        // 초기 로드 완료 시 출근지 정보 갱신
        _loadAttendanceLocation();
        break;
      case AttendanceUiState.success:
        // 출퇴근 등록 성공 다이얼로그
        final todayStatus = state.todayStatus;
        final isClockOut = todayStatus?.isClockedOut ?? false;
        ClockInConfirmDialog.show(
          context,
          clockInTime: DateTime.now(),
          isClockOut: isClockOut,
        );
        break;
      case AttendanceUiState.error:
        // 서버 에러 코드 기반 다이얼로그 분기 (우선)
        final errorCode = state.errorCode;
        if (errorCode != null) {
          switch (errorCode) {
            case 'NFC_VERIFICATION_FAILED':
              // NFC 태그 불일치/누락 → NFC 전용 실패 모달
              NfcCheckFailDialog.show(context);
              break;
            case 'GPS_VERIFICATION_FAILED':
              // GPS 반경 밖/좌표 누락 → GPS 전용 실패 모달
              ClockInUnavailableDialog.show(context);
              break;
            case 'WIFI_VERIFICATION_FAILED':
              // WiFi SSID/BSSID 불일치 → WiFi 전용 실패 모달
              WifiUnavailableDialog.show(context);
              break;
            case 'BEACON_UUID_MISMATCH':
              BeaconMismatchDialog.show(context);
              break;
            case 'BEACON_NOT_DETECTED':
            case 'BEACON_RSSI_TOO_WEAK':
              BeaconUnavailableDialog.show(context);
              break;
            case 'QR_VERIFICATION_FAILED':
              // QR 코드 불일치/누락 → 일반 출근 불가 다이얼로그 (QR 전용 위젯 없음 → 가장 가까운 ClockInUnavailableDialog 재사용)
              ClockInUnavailableDialog.show(context);
              break;
            case 'GPS_SPOOFED':
              // GPS 조작(가상 위치) 감지 → 경고 다이얼로그
              GpsSpoofingDialog.show(context, reason: state.errorMessage);
              break;
            default:
              // 알 수 없는 에러 코드 → 기존 메시지 기반 분기로 폴백
              _showErrorByMessage(context, state.errorMessage ?? '');
              break;
          }
          break;
        }
        // 에러 코드가 없을 때 기존 메시지 기반 분기
        _showErrorByMessage(context, state.errorMessage ?? '');
        break;
      default:
        break;
    }
  }

  /// 에러 메시지 기반 다이얼로그 분기 (에러 코드 없을 때 폴백)
  void _showErrorByMessage(BuildContext context, String msg) {
    if (msg.contains('NFC') || msg.contains('nfc')) {
      NfcCheckFailDialog.show(context);
    } else if (msg.contains('비콘') || msg.contains('블루투스')) {
      BeaconUnavailableDialog.show(context);
    } else if (msg.contains('WiFi') || msg.contains('wifi') || msg.contains('WIFI')) {
      WifiUnavailableDialog.show(context);
    } else if (msg.contains('GPS') || msg.contains('gps')) {
      ClockInUnavailableDialog.show(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : '인증에 실패했습니다.'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 5초 롱프레스 타이머 (디버그 스캔 진입용)
  Timer? _longPressTimer;

  /// 사용자 인사말 + 히스토리 이동 버튼
  /// 5초 롱프레스 시 디버그 스캔 화면으로 이동
  Widget _buildGreeting() {
    final displayName = _userName.isNotEmpty ? _userName : '사용자';
    return GestureDetector(
      onTap: () => context.push('/history'),
      onLongPressStart: (_) {
        _longPressTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) context.push('/debug-scan');
        });
      },
      onLongPressEnd: (_) {
        _longPressTimer?.cancel();
        _longPressTimer = null;
      },
      child: Container(
        width: 343.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              '안녕하세요 $displayName님',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 22.sp,
                height: 1.4,
                letterSpacing: -0.5,
                color: const Color(0xFF242424),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF242424),
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }

  /// 출퇴근 카드 (날짜, 시간, 출근지/현위치, 출퇴근 버튼 포함)
  Widget _buildAttendanceCard({
    required AttendanceState state,
    required bool isClockedIn,
    required bool isCompleted,
    required bool isLoading,
  }) {
    return Center(
      child: Container(
        width: 343.w,
        decoration: BoxDecoration(
          color: const Color(0xFF2DDAA9),
          borderRadius: BorderRadius.circular(20.r),
        ),
        padding: EdgeInsets.fromLTRB(12.w, 20.h, 12.w, 20.h),
        child: StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            final now = DateTime.now();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(now),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 1.4,
                    letterSpacing: -0.5,
                    color: const Color(0xFFF3F3F3),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(now),
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 26.sp,
                        height: 1.4,
                        letterSpacing: 0,
                        color: Colors.white,
                      ),
                    ),
                    // 서버 활성 인증 방법 아이콘 (로그인 정보 기반)
                    _buildVerificationIcons(state.serverEnabledMethods),
                  ],
                ),
                SizedBox(height: 4.h),
                // 출근지 / 현위치 정보
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '출근지',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              height: 1.4,
                              letterSpacing: -0.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _attendanceAddress,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              height: 1.4,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '현위치',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                              height: 1.4,
                              letterSpacing: -0.5,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _currentAddress,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              height: 1.4,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // 출퇴근 버튼
                GestureDetector(
                  onTap: isCompleted || isLoading ? null : _handleClockAction,
                  child: Container(
                    width: double.infinity,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    alignment: Alignment.center,
                    child: isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              color: Color(0xFF2DDAA9),
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isCompleted
                                ? '오늘 출퇴근 완료'
                                : isClockedIn
                                    ? '퇴근하기'
                                    : '출근하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                              height: 1.4,
                              letterSpacing: -0.5,
                              color: isCompleted
                                  ? const Color(0xFF2DDAA9)
                                      .withValues(alpha: 0.5)
                                  : const Color(0xFF2DDAA9),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 활성화된 인증 방법 아이콘 표시 (동적)
  Widget _buildVerificationIcons(List<VerificationMethod> methods) {
    // 단일 인증 방법별 아이콘 매핑
    final iconMap = {
      VerificationMethod.wifi: {
        'on': 'assets/icons/WIFI_ON.svg',
        'off': 'assets/icons/WIFI_OFF.svg',
      },
      VerificationMethod.gps: {
        'on': 'assets/icons/GPS_on.svg',
        'off': 'assets/icons/GPS_off.svg',
      },
      VerificationMethod.nfc: {
        'on': 'assets/icons/nfc_on.svg',
        'off': 'assets/icons/nfc_off.svg',
      },
      VerificationMethod.bluetooth: {
        'on': 'assets/icons/Beacon_on.svg',
        'off': 'assets/icons/Beacon_off.svg',
      },
    };

    // v2 리팩토링: 합성 인증 제거. 모든 method가 단일이므로 그대로 사용.
    final enabledSingle = methods.toSet();

    return Row(
      children: iconMap.entries.map((entry) {
        final isEnabled = enabledSingle.contains(entry.key);
        final iconPath =
            isEnabled ? entry.value['on']! : entry.value['off']!;
        return Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: SvgPicture.asset(
            iconPath,
            width: 26.w,
            height: 26.h,
          ),
        );
      }).toList(),
    );
  }

  /// 오늘 출퇴근 시간 요약 카드
  Widget _buildStatusCard({
    DateTime? clockInTime,
    DateTime? clockOutTime,
  }) {
    return Center(
      child: Container(
        width: 343.w,
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildStatusColumn('출근', clockInTime),
            _buildStatusColumn('퇴근', clockOutTime),
          ],
        ),
      ),
    );
  }

  /// 출근/퇴근 시간 표시 컬럼 (날짜 + 시간)
  Widget _buildStatusColumn(String title, DateTime? time) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        spacing: 8.h,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFF000000),
            ),
          ),
          Text(
            time != null
                ? DateFormat('MM월 dd일 EEEE', 'ko_KR').format(time)
                : '-',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFF000000),
            ),
          ),
          Text(
            time != null ? DateFormat('HH:mm:ss').format(time) : '-',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 24.sp,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  /// 재중심(B) 버튼 - 현재 위치를 다시 지도 중앙으로 (my_location 아이콘)
  Widget _buildRecenterButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _recenterMap,
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          child: Icon(
            Icons.my_location,
            size: 22.w,
            color: const Color(0xFF2DDAA9),
          ),
        ),
      ),
    );
  }

  /// 카카오맵 섹션 (출근지 + 현위치 마커, GPS 반경 원)
  Widget _buildMapSection() {
    return Center(
      child: Container(
        width: 343.w,
        height: 281.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
        ),
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 230.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                // 지도 위에 재중심(B) 버튼을 오버레이로 배치
                child: Stack(
                  children: [
                    KakaoMap(
                      option: KakaoMapOption(
                        position: _currentLatLng ??
                            _attendanceLatLng ??
                            _fallbackMapPosition,
                        zoomLevel: _defaultMapZoomLevel,
                      ),
                      onMapReady: (controller) {
                        _mapController = controller;
                        _setupMapMarkers(controller);
                      },
                      onCameraMoveEnd: (position, gestureType) {
                        _updateMarkerScale(position.zoomLevel);
                      },
                      onMapError: (error) {
                        debugPrint('[KakaoMap] 에러: $error');
                      },
                    ),
                    // PPT slide3 B 버튼: 현재 위치 재중심
                    Positioned(
                      right: 8.w,
                      bottom: 8.h,
                      child: _buildRecenterButton(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/current_location.svg',
                    width: 20.w,
                    height: 20.h,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '출퇴근 등록 가능',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      height: 1.4,
                      letterSpacing: 12.sp * -0.02,
                      color: const Color(0xFF1400FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GpsMapTarget {
  const _GpsMapTarget({
    required this.position,
    this.radiusMeters,
    this.address,
  });

  final LatLng position;
  final double? radiusMeters;
  final String? address;
}
