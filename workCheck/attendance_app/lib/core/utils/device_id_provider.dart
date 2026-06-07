import 'package:flutter_udid/flutter_udid.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 기기 식별자 제공자 (기기 바인딩)
///
/// 로그인/기기등록 요청에 보낼 deviceId를 제공한다.
/// - iOS: Keychain에 저장된 UUID (앱 재설치 후에도 유지)
/// - Android: ANDROID_ID
/// 동일 기기에서 항상 같은 값이 나오도록 [FlutterUdid.consistentUdid] 사용.
///
/// 한 번 조회한 값은 SharedPreferences에 캐시해 매번 OS 호출을 피한다.
@lazySingleton
class DeviceIdProvider {
  /// SharedPreferences 캐시 키
  static const _cacheKey = 'device_id_cache';

  /// 기기 식별자 조회
  ///
  /// 1) 캐시에 있으면 즉시 반환
  /// 2) 없으면 flutter_udid로 조회 후 캐시에 저장하고 반환
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) 캐시 우선
    final cached = prefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // 2) OS에서 일관된 기기 ID 조회 후 캐시 저장
    final deviceId = await FlutterUdid.consistentUdid;
    await prefs.setString(_cacheKey, deviceId);
    return deviceId;
  }
}
