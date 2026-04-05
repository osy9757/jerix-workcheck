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
}
