import 'package:injectable/injectable.dart';

import '../domain/verification_method.dart';
import '../domain/verification_result.dart';
import '../domain/verification_strategy.dart';

/// 인증 방식 레지스트리 + 실행기
///
/// 단일 인증 및 복합 인증(순차 실행 + 결과 합산)을 모두 지원.
/// Bloc에서는 이 매니저만 의존하면 됨.
@lazySingleton
class VerificationManager {
  final Map<VerificationMethod, VerificationStrategy> _strategies;

  VerificationManager({
    @Named('gps') required VerificationStrategy gps,
    @Named('qr') required VerificationStrategy qr,
    @Named('nfc') required VerificationStrategy nfc,
    @Named('bluetooth') required VerificationStrategy bluetooth,
    @Named('wifi') required VerificationStrategy wifi,
  }) : _strategies = {
          VerificationMethod.gps: gps,
          VerificationMethod.qr: qr,
          VerificationMethod.nfc: nfc,
          VerificationMethod.bluetooth: bluetooth,
          VerificationMethod.wifi: wifi,
        };

  /// 인증 실행 (단일 + 복합 모두 지원)
  Future<VerificationResult> verify(VerificationMethod method) async {
    // 복합 인증: 순차 실행 후 결과 합산
    if (method.isComposite) {
      return _verifyComposite(method, method.components);
    }

    // 단일 인증
    final strategy = _strategies[method];
    if (strategy == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '지원하지 않는 인증 방식입니다.',
      );
    }
    return strategy.verify();
  }

  /// 복합 인증: 각 구성 요소를 순차 실행, 하나라도 실패하면 중단
  Future<VerificationResult> _verifyComposite(
    VerificationMethod compositeMethod,
    List<VerificationMethod> components,
  ) async {
    final combinedData = <String, dynamic>{};

    for (final component in components) {
      final strategy = _strategies[component];
      if (strategy == null) {
        return VerificationResult(
          method: compositeMethod,
          isVerified: false,
          data: {},
          errorMessage: '${component.label} 인증을 사용할 수 없습니다.',
        );
      }

      final result = await strategy.verify();
      if (!result.isVerified) {
        return VerificationResult(
          method: compositeMethod,
          isVerified: false,
          data: result.data,
          errorMessage: result.errorMessage,
        );
      }

      // 구성 요소별 데이터를 평탄 구조로 합침 (서버가 기대하는 형태)
      combinedData.addAll(result.data);
    }

    return VerificationResult(
      method: compositeMethod,
      isVerified: true,
      data: {
        ...combinedData,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// 현재 사용 가능한 인증 방식 목록 (복합 인증 포함)
  Future<List<VerificationMethod>> getAvailableMethods() async {
    final available = <VerificationMethod>[];
    for (final entry in _strategies.entries) {
      if (await entry.value.isAvailable()) {
        available.add(entry.key);
      }
    }
    // 복합 인증: 구성 요소가 모두 사용 가능하면 추가
    for (final method in VerificationMethod.values.where((m) => m.isComposite)) {
      final allAvailable = method.components.every(
        (m) => available.contains(m),
      );
      if (allAvailable) {
        available.add(method);
      }
    }
    return available;
  }

  /// 특정 방식의 Strategy 반환 (QR 스캐너 UI 등에서 직접 접근 필요 시)
  VerificationStrategy? getStrategy(VerificationMethod method) {
    return _strategies[method];
  }
}
