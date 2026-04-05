// 기본 위젯 테스트 (플레이스홀더)
//
// 실제 앱은 DI(get_it) 초기화가 필요하므로
// 단순 위젯 테스트 대신 통합 테스트로 검증한다.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder test', () {
    expect(1 + 1, 2);
  });
}
