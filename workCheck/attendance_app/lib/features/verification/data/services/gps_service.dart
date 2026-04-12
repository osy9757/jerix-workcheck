import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// GPS 위치 기반 출퇴근 인증 서비스
///
/// geolocator 패키지를 사용하여 현재 기기의 GPS 좌표를 수집한다.
/// 수집된 좌표는 백엔드에서 근무지 반경 내 여부를 검증한다.
@Named('gps')
@LazySingleton(as: VerificationStrategy)
class GpsVerificationService implements VerificationStrategy {
  @override
  VerificationMethod get method => VerificationMethod.gps;

  /// GPS(위치 서비스)가 기기에서 활성화되어 있는지 확인
  @override
  Future<bool> isAvailable() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// 위치 권한 요청
  ///
  /// 이미 거부된 경우 다시 요청한다.
  /// whileInUse 또는 always 권한이 있어야 true 반환.
  @override
  Future<bool> requestPermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// GPS 인증 실행
  ///
  /// 권한 확인 → 현재 위치 수집 → VerificationResult 반환.
  /// 타임아웃: 10초. 실패 시 errorMessage를 포함한 결과 반환.
  @override
  Future<VerificationResult> verify() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: '위치 권한이 필요합니다.',
        );
      }

      // 높은 정확도로 현재 위치 수집 (최대 10초 대기)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // GPS 조작(Mock Location) 감지
      // Android: Position.isMocked 필드로 직접 확인 (geolocator_android 지원)
      // iOS: 공식 Mock Location API가 없어 accuracy=0 등 비정상 패턴으로 휴리스틱 판단
      final spoofReason = _detectSpoofing(position);
      if (spoofReason != null) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          // errorMessage 앞에 "GPS_SPOOFED:" 프리픽스를 붙여 Bloc이 errorCode로 분기 가능하게 함
          errorMessage: 'GPS_SPOOFED:$spoofReason',
        );
      }

      return VerificationResult(
        method: method,
        isVerified: true,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,  // 정확도 (미터 단위)
          'timestamp': position.timestamp.toIso8601String(),
        },
      );
    } catch (e) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'GPS 위치를 가져올 수 없습니다: ${e.toString()}',
      );
    }
  }

  /// GPS 조작 감지
  ///
  /// 감지 시 사유 문자열 반환, 정상이면 null.
  /// - Android: Position.isMocked가 true면 즉시 조작으로 판단
  /// - 공통: accuracy가 0.0이거나 비정상적으로 낮으면(<0.5m) 조작 가능성
  ///   (일반 GPS는 최소 3~5m 오차, 0m에 가까운 값은 조작 시그널)
  String? _detectSpoofing(Position position) {
    // 1순위: Android의 isMocked 플래그 (가장 신뢰 가능)
    if (position.isMocked) {
      return '가상 위치 앱이 감지되었습니다';
    }

    // 2순위: 비정상적으로 완벽한 accuracy (iOS/탈옥 기기 휴리스틱)
    // 실제 GPS는 물리적으로 0.5m 미만의 오차를 낼 수 없음
    if (position.accuracy > 0 && position.accuracy < 0.5) {
      return '위치 정확도가 비정상적입니다';
    }

    // 3순위: accuracy가 정확히 0 또는 음수 (센서 오류 또는 조작)
    if (position.accuracy <= 0) {
      return '위치 정확도를 확인할 수 없습니다';
    }

    return null;
  }
}
