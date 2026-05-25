import 'package:equatable/equatable.dart';

import '../../../verification/domain/verification_method.dart';

/// `/clock-in/init` 또는 `/clock-out/init` 응답을 담는 도메인 엔티티
///
/// 서버가 안내한 수집 대상 method와 각 method의 설정값을 보관한다.
/// configs는 method 키(소문자) → 설정 맵 형태. 예: gps → {targets: [{lat, lng, radius_m}]}.
class AttendanceInitEntity extends Equatable {
  /// 수집해야 할 method 목록
  final List<VerificationMethod> requiredMethods;

  /// 원본 메서드 키 (서버가 보낸 소문자 문자열 그대로). 매핑 누락 진단용.
  final List<String> rawRequiredMethods;

  /// method 키(소문자) → 서버 설정값
  final Map<String, Map<String, dynamic>> configs;

  const AttendanceInitEntity({
    required this.requiredMethods,
    required this.rawRequiredMethods,
    required this.configs,
  });

  /// 특정 method의 설정값 조회 (없으면 null)
  Map<String, dynamic>? getConfig(VerificationMethod method) {
    return configs[method.apiName];
  }

  @override
  List<Object?> get props => [requiredMethods, rawRequiredMethods, configs];
}
