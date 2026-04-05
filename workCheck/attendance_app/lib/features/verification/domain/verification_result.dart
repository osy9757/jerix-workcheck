import 'package:freezed_annotation/freezed_annotation.dart';

import 'verification_method.dart';

part 'verification_result.freezed.dart';
part 'verification_result.g.dart';

/// 인증 실행 결과를 담는 불변 값 객체
///
/// freezed로 생성된 sealed class이며, 성공/실패 여부와
/// 인증에서 수집된 데이터(좌표, QR 데이터 등)를 함께 포함한다.
@freezed
class VerificationResult with _$VerificationResult {
  const factory VerificationResult({
    /// 어떤 방식으로 인증했는지 (gps, qr, bluetooth 등)
    required VerificationMethod method,

    /// 인증 성공 여부
    required bool isVerified,

    /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
    required Map<String, dynamic> data,

    /// 인증 실패 시 사유 메시지 (성공 시 null)
    String? errorMessage,
  }) = _VerificationResult;

  /// JSON → VerificationResult 역직렬화
  factory VerificationResult.fromJson(Map<String, dynamic> json) =>
      _$VerificationResultFromJson(json);
}
