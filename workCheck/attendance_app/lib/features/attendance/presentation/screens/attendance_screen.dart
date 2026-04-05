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
import '../widgets/nfc_check_fail_dialog.dart';
import '../widgets/wifi_unavailable_dialog.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  KakaoMapController? _mapController;
  String _userName = '';

  /// 현위치 주소 (역지오코딩 결과)
  String _currentAddress = '위치 확인 중...';

  /// 출근지 주소 (서버 설정)
  String _workplaceAddress = '-';

  /// 현재 GPS 좌표
  LatLng? _currentLatLng;

  /// 출근지 좌표 (서버 설정)
  LatLng _workplaceLatLng = const LatLng(37.5419, 126.9498);

  /// GPS 허용 반경 (미터)
  double? _gpsRadiusMeters;

  /// 펄스 애니메이션 컨트롤러
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  /// 반경 원 도형 (KakaoMap ShapeLayer)
  Polygon? _radiusPolygon;

  /// 마지막 원 스타일 업데이트 시간 (쓰로틀링용)
  DateTime _lastPulseUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
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

      if (mounted) {
        setState(() => _currentLatLng = latLng);
      }

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

    // 출근지 정보: BLoC의 workplaceConfig에서 가져오기
    _loadWorkplaceInfo();
  }

  /// 출근지 주소 및 좌표를 workplaceConfig에서 로드
  void _loadWorkplaceInfo() {
    final bloc = context.read<AttendanceBloc>();
    final config = bloc.workplaceConfig;
    if (config == null) return;

    // GPS 설정에서 출근지 좌표 + 허용 반경 가져오기
    final gpsConfig = config.getConfig(VerificationMethod.gps);
    if (gpsConfig != null) {
      final lat = gpsConfig['latitude'] as double?;
      final lng = gpsConfig['longitude'] as double?;
      final radius = (gpsConfig['radius_meters'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _workplaceLatLng = LatLng(lat, lng);
        _gpsRadiusMeters = radius;

        // 출근지 좌표로 역지오코딩
        _reverseGeocodeWorkplace(lat, lng);

        // 지도 준비 완료 상태면 반경 원 추가
        _addRadiusCircleIfReady();
      }
    }

    // 출근지 주소가 config에 직접 있으면 사용
    final address = gpsConfig?['address'] as String?;
    if (address != null && address.isNotEmpty && mounted) {
      setState(() => _workplaceAddress = address);
    }
  }

  /// 출근지 좌표 역지오코딩
  Future<void> _reverseGeocodeWorkplace(double lat, double lng) async {
    // 이미 주소가 설정되어 있으면 스킵
    if (_workplaceAddress != '-') return;
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final address = [p.street, p.subLocality, p.locality]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        setState(() {
          _workplaceAddress = address.isNotEmpty ? address : '-';
        });
      }
    } catch (e) {
      debugPrint('[Geocoding] 출근지 역지오코딩 오류: $e');
    }
  }

  /// 지도 + GPS 설정이 모두 준비되면 반경 원 추가
  void _addRadiusCircleIfReady() {
    if (_mapController != null && _gpsRadiusMeters != null) {
      _addRadiusCircle(_mapController!);
    }
  }

  /// GPS 허용 반경 파란색 원 추가 (KakaoMap ShapeLayer)
  Future<void> _addRadiusCircle(KakaoMapController controller) async {
    final radius = _gpsRadiusMeters;
    if (radius == null || radius <= 0) return;
    // 이미 추가된 경우 스킵
    if (_radiusPolygon != null) return;

    try {
      final shapeLayer = await controller.addShapeLayer('radius_circle');
      final style = PolygonStyle(
        Colors.blue.withValues(alpha: 0.2),
        strokeWidth: 1.0,
        strokeColor: Colors.blue.withValues(alpha: 0.4),
      );
      _radiusPolygon = await shapeLayer.addPolygonShape(
        CirclePoint(radius, _workplaceLatLng),
        style,
        id: 'gps_radius',
      );
    } catch (e) {
      debugPrint('[KakaoMap] 반경 원 추가 오류: $e');
    }
  }

  /// 펄스 애니메이션 업데이트 (opacity 변화, ~10fps 쓰로틀링)
  void _onPulseUpdate() {
    final now = DateTime.now();
    if (now.difference(_lastPulseUpdate).inMilliseconds < 100) return;
    _lastPulseUpdate = now;

    final polygon = _radiusPolygon;
    if (polygon == null) return;

    // opacity 범위: 0.08 ~ 0.25
    final opacity = 0.08 + 0.17 * _pulseAnimation.value;
    final newStyle = PolygonStyle(
      Colors.blue.withValues(alpha: opacity),
      strokeWidth: 1.0,
      strokeColor: Colors.blue.withValues(alpha: opacity + 0.15),
    );
    polygon.changeStyle(newStyle);
  }

  /// 지도 마커 설정 (현위치 + 출근지)
  Future<void> _setupMapMarkers(KakaoMapController controller) async {
    try {
      final destination = _workplaceLatLng;

      // 현재 GPS 위치 (_currentLatLng 공유, 없으면 새로 조회)
      LatLng currentLocation;
      if (_currentLatLng != null) {
        currentLocation = _currentLatLng!;
      } else {
        try {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
          currentLocation = LatLng(position.latitude, position.longitude);
          if (mounted) {
            setState(() => _currentLatLng = currentLocation);
          }
        } catch (e) {
          debugPrint('[KakaoMap] GPS 오류: $e');
          currentLocation = destination;
        }
      }

      final destinationIcon = await KImage.fromWidget(
        SvgPicture.asset(
          'assets/icons/destination.svg',
          width: 40,
          height: 40,
        ),
        const Size(40, 40),
        pixelRatio: 2.0,
        context: context,
      );

      final currentLocationIcon = await KImage.fromWidget(
        SvgPicture.asset(
          'assets/icons/current_location.svg',
          width: 40,
          height: 40,
        ),
        const Size(40, 40),
        pixelRatio: 2.0,
        context: context,
      );

      await controller.labelLayer.addPoi(
        destination,
        style: PoiStyle(
          icon: destinationIcon,
          anchor: const KPoint(0.5, 1.0),
        ),
        id: 'destination',
      );

      await controller.labelLayer.addPoi(
        currentLocation,
        style: PoiStyle(
          icon: currentLocationIcon,
          anchor: const KPoint(0.5, 1.0),
        ),
        id: 'current_location',
      );

      await controller.moveCamera(
        CameraUpdate.fitMapPoints(
          [destination, currentLocation],
          padding: 80,
        ),
      );

      // GPS 허용 반경 원 추가
      _addRadiusCircleIfReady();
    } catch (e) {
      debugPrint('[KakaoMap] 마커 추가 오류: $e');
    }
  }

  @override
  void dispose() {
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
        _loadWorkplaceInfo();
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
            case 'BEACON_UUID_MISMATCH':
              BeaconMismatchDialog.show(context);
              break;
            case 'BEACON_NOT_DETECTED':
            case 'BEACON_RSSI_TOO_WEAK':
              BeaconUnavailableDialog.show(context);
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

  Widget _buildGreeting() {
    final displayName = _userName.isNotEmpty ? _userName : '사용자';
    return GestureDetector(
      onTap: () => context.push('/history'),
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
                            _workplaceAddress,
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

    // 활성화된 단일 방법 집합 (복합 인증에 포함된 것도 포함)
    final enabledSingle = <VerificationMethod>{};
    for (final m in methods) {
      if (m.isComposite) {
        // 복합 인증의 구성 요소 추가
        switch (m) {
          case VerificationMethod.gpsQr:
            enabledSingle.addAll([
              VerificationMethod.gps,
              VerificationMethod.qr,
            ]);
            break;
          case VerificationMethod.wifiQr:
            enabledSingle.addAll([
              VerificationMethod.wifi,
              VerificationMethod.qr,
            ]);
            break;
          case VerificationMethod.nfcGps:
            enabledSingle.addAll([
              VerificationMethod.nfc,
              VerificationMethod.gps,
            ]);
            break;
          case VerificationMethod.beaconGps:
            enabledSingle.addAll([
              VerificationMethod.bluetooth,
              VerificationMethod.gps,
            ]);
            break;
          default:
            break;
        }
      } else {
        enabledSingle.add(m);
      }
    }

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
                child: KakaoMap(
                  option: KakaoMapOption(
                    position: _currentLatLng ?? _workplaceLatLng,
                    zoomLevel: 16,
                  ),
                  onMapReady: (controller) {
                    _mapController = controller;
                    _setupMapMarkers(controller);
                  },
                  onMapError: (error) {
                    debugPrint('[KakaoMap] 에러: $error');
                  },
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
