import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/workplace_config_entity.dart';

/// 근무지 설정 API 응답 모델
///
/// GET /api/v1/workplace/config 응답을 파싱한다.
class WorkplaceConfigModel {
  final List<String> enabledMethods;
  final Map<String, dynamic> configs;

  const WorkplaceConfigModel({
    required this.enabledMethods,
    required this.configs,
  });

  factory WorkplaceConfigModel.fromJson(Map<String, dynamic> json) {
    return WorkplaceConfigModel(
      enabledMethods: List<String>.from(json['enabled_methods'] ?? []),
      configs: Map<String, dynamic>.from(json['configs'] ?? {}),
    );
  }

  /// API 모델 → 도메인 엔티티 변환
  WorkplaceConfigEntity toEntity() {
    // API 문자열을 VerificationMethod enum으로 변환
    final methods = enabledMethods
        .map((name) => VerificationMethod.fromApiName(name))
        .whereType<VerificationMethod>()
        .toList();

    // 방법별 config를 Map<String, Map<String, dynamic>>으로 변환
    final configMap = <String, Map<String, dynamic>>{};
    configs.forEach((key, value) {
      if (value is Map) {
        configMap[key] = Map<String, dynamic>.from(value);
      }
    });

    return WorkplaceConfigEntity(
      enabledMethods: methods,
      configs: configMap,
    );
  }
}
