import 'dart:io';
import 'dart:typed_data';

import 'package:nfc_manager/nfc_manager.dart';
// 내부 import를 이 헬퍼에 격리 (nfc_manager 4.x에서 플랫폼별 태그 클래스가 미export)
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_ios/tags/mifare.dart';
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso7816.dart';
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_ios/tags/iso15693.dart';
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_ios/tags/felica.dart';
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_android/tags/tag.dart';

/// NFC 태그에서 추출한 식별 정보
class NfcTagInfo {
  /// 태그 identifier 바이트 (null이면 추출 실패)
  final Uint8List? identifier;

  /// 태그 타입 이름 (디버그/로깅용)
  final String tagType;

  const NfcTagInfo({this.identifier, required this.tagType});

  /// identifier를 hex 문자열로 변환 (예: "04:a3:2b:...")
  String get uid {
    final id = identifier;
    if (id == null || id.isEmpty) return 'unknown';
    return id.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');
  }
}

/// NfcTag에서 플랫폼별 identifier와 태그 타입을 추출
///
/// nfc_manager 4.x의 내부 API에 의존하므로 이 헬퍼 파일에 격리.
/// 패키지 업데이트 시 이 파일만 수정하면 됨.
NfcTagInfo extractTagInfo(NfcTag tag) {
  if (Platform.isIOS) {
    return _extractIos(tag);
  } else if (Platform.isAndroid) {
    return _extractAndroid(tag);
  }
  return const NfcTagInfo(tagType: 'unsupported_platform');
}

/// iOS: MiFare → ISO 7816 → ISO 15693 → FeliCa 순으로 identifier 추출
NfcTagInfo _extractIos(NfcTag tag) {
  final mifare = MiFareIos.from(tag);
  if (mifare != null) {
    return NfcTagInfo(identifier: mifare.identifier, tagType: 'mifare');
  }

  final iso7816 = Iso7816Ios.from(tag);
  if (iso7816 != null) {
    return NfcTagInfo(identifier: iso7816.identifier, tagType: 'iso7816');
  }

  final iso15693 = Iso15693Ios.from(tag);
  if (iso15693 != null) {
    return NfcTagInfo(identifier: iso15693.identifier, tagType: 'iso15693');
  }

  final felica = FeliCaIos.from(tag);
  if (felica != null) {
    // FeliCa는 identifier 대신 IDm을 사용
    return NfcTagInfo(identifier: felica.currentIDm, tagType: 'felica');
  }

  return const NfcTagInfo(tagType: 'unknown_ios');
}

/// Android: NfcTagAndroid에서 id + techList 추출
NfcTagInfo _extractAndroid(NfcTag tag) {
  final androidTag = NfcTagAndroid.from(tag);
  if (androidTag != null) {
    return NfcTagInfo(
      identifier: androidTag.id,
      tagType: 'android(${androidTag.techList.join(",")})',
    );
  }
  return const NfcTagInfo(tagType: 'unknown_android');
}
