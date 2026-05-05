import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// WiFi 네트워크 기반 출퇴근 인증 서비스
///
/// network_info_plus 패키지를 사용하여 현재 연결된 WiFi의
/// SSID(네트워크 이름)와 BSSID(공유기 MAC 주소)를 수집한다.
/// 백엔드에서 등록된 근무지 WiFi와 일치 여부를 검증한다.
@Named('wifi')
@LazySingleton(as: VerificationStrategy)
class WifiVerificationService implements VerificationStrategy {
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  VerificationMethod get method => VerificationMethod.wifi;

  /// 현재 WiFi에 연결되어 있는지 확인 (SSID 존재 여부로 판단)
  @override
  Future<bool> isAvailable() async {
    final wifiName = await _networkInfo.getWifiName();
    return wifiName != null;
  }

  /// WiFi 정보 접근에 필요한 권한 요청
  ///
  /// - iOS: 위치 권한(locationWhenInUse) 필요
  /// - Android 13+ (API 33+): NEARBY_WIFI_DEVICES 권한 필요
  /// - Android 12 이하: ACCESS_FINE_LOCATION 권한 필요
  /// (permission_handler 가 OS 미지원 권한은 자동으로 granted 처리)
  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // 두 권한 모두 시도 - OS 버전에 따라 둘 중 적합한 것이 채택됨
      final nearby = await Permission.nearbyWifiDevices.request();
      final loc = await Permission.locationWhenInUse.request();
      return nearby.isGranted || loc.isGranted;
    }
    // iOS: 기존 동작 유지 (위치 권한)
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// WiFi 인증 실행
  ///
  /// 권한 확인 → SSID/BSSID/IP 수집 → VerificationResult 반환.
  /// WiFi에 연결되지 않은 경우 실패 결과를 반환한다.
  @override
  Future<VerificationResult> verify() async {
    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: 'WiFi 정보 접근을 위해 위치 권한이 필요합니다.',
        );
      }

      final wifiName = await _networkInfo.getWifiName();     // SSID (네트워크 이름)
      final wifiBSSID = await _networkInfo.getWifiBSSID();   // BSSID (공유기 MAC 주소)
      final wifiIP = await _networkInfo.getWifiIP();         // 기기 IP 주소

      // SSID와 BSSID 모두 없으면 WiFi 미연결 상태
      if (wifiName == null && wifiBSSID == null) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: 'WiFi에 연결되어 있지 않습니다.',
        );
      }

      return VerificationResult(
        method: method,
        isVerified: true,
        data: {
          'ssid': wifiName?.replaceAll('"', ''),  // Android에서 따옴표 포함되므로 제거
          'bssid': wifiBSSID,
          'ip': wifiIP,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'WiFi 정보를 가져올 수 없습니다: ${e.toString()}',
      );
    }
  }
}
