import 'package:equatable/equatable.dart';

import '../../../verification/domain/verification_method.dart';

/// 근무지 설정 엔티티
///
/// 백엔드에서 받아온 활성 인증 방법 목록과 방법별 설정값을 담는다.
class WorkplaceConfigEntity extends Equatable {
  /// 활성화된 인증 방법 목록
  final List<VerificationMethod> enabledMethods;

  /// 방법별 설정값 (예: gps → {latitude, longitude, radius_meters})
  final Map<String, Map<String, dynamic>> configs;

  const WorkplaceConfigEntity({
    required this.enabledMethods,
    required this.configs,
  });

  /// 특정 인증 방법의 설정값 조회
  Map<String, dynamic>? getConfig(VerificationMethod method) {
    return configs[method.apiName];
  }

  @override
  List<Object?> get props => [enabledMethods, configs];
}
