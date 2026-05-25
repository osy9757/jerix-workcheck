// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VerificationResult _$VerificationResultFromJson(Map<String, dynamic> json) =>
    _VerificationResult(
      method: $enumDecode(_$VerificationMethodEnumMap, json['method']),
      isVerified: json['isVerified'] as bool,
      data: json['data'] as Map<String, dynamic>,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$VerificationResultToJson(_VerificationResult instance) =>
    <String, dynamic>{
      'method': _$VerificationMethodEnumMap[instance.method]!,
      'isVerified': instance.isVerified,
      'data': instance.data,
      'errorMessage': instance.errorMessage,
    };

const _$VerificationMethodEnumMap = {
  VerificationMethod.gps: 'gps',
  VerificationMethod.qr: 'qr',
  VerificationMethod.nfc: 'nfc',
  VerificationMethod.bluetooth: 'bluetooth',
  VerificationMethod.wifi: 'wifi',
};
