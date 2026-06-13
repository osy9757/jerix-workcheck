// 운영 배포 전 게이팅/마스킹 검토 필요
import 'package:flutter/foundation.dart';

/// 앱 공용 진단 로그 헬퍼
///
/// 릴리스 빌드에서도 기기 콘솔(예: Xcode/Console.app)에 출력되도록
/// kDebugMode 게이팅 없이 debugPrint를 사용한다.
/// 태그는 기존 `[NFC]`/`[API]` 스타일을 따른다.
/// 주의: 비밀번호/JWT/원시 NFC UID/비콘 UUID 등 민감값은 절대 출력하지 말 것.

/// 정보 로그
void logD(String tag, Object? msg) {
  debugPrint('[$tag] $msg');
}

/// 경고 로그
void logW(String tag, Object? msg) {
  debugPrint('[$tag] ⚠️ $msg');
}

/// 에러 로그 (error/stack 함께 출력)
void logE(String tag, Object? msg, [Object? error, StackTrace? stack]) {
  debugPrint('[$tag] ❌ $msg');
  if (error != null) debugPrint('[$tag] error: $error');
  if (stack != null) debugPrint('[$tag] stack: $stack');
}
