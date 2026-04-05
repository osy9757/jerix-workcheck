// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verification_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerificationResultImpl _$$VerificationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$VerificationResultImpl(
      method: $enumDecode(_$VerificationMethodEnumMap, json['method']),
      isVerified: json['isVerified'] as bool,
      data: json['data'] as Map<String, dynamic>,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$VerificationResultImplToJson(
        _$VerificationResultImpl instance) =>
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
  VerificationMethod.gpsQr: 'gpsQr',
  VerificationMethod.wifiQr: 'wifiQr',
  VerificationMethod.nfcGps: 'nfcGps',
  VerificationMethod.beaconGps: 'beaconGps',
};
