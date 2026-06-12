// [시각검증 C] 사번21 기기가 거절(REJECTED)된 상태에서 로그인 → D10 취소 안내 다이얼로그(확인 버튼만)
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'visual_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('거절 기기 취소 안내', (t) async {
    await launchApp(t);
    await hold(t, 1.5);
    await doLogin(t, '21', '1111');

    // D10: PPT 취소 문구 다이얼로그
    final title = find.text('접속 요청이 취소 되었습니다');
    expect(await waitFor(t, title, 20), true, reason: 'D10 다이얼로그 미표시');
    // ignore: avoid_print
    print('SHOT:c_rejected_dialog');
    await hold(t, 4);
    await t.tap(find.text('확인').last, warnIfMissed: false);
    await hold(t, 3);
    // ignore: avoid_print
    print('SHOT:c_after_confirm');
    await hold(t, 3);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
