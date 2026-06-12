// [시각검증 B] 사번21(타 기기 바인딩됨) 로그인 → 403 요청 다이얼로그 → 대기화면 폴링 → 외부 승인 → 버튼 활성화
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'visual_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('기기 등록 요청/승인 흐름', (t) async {
    await launchApp(t);
    await hold(t, 1.5);
    await doLogin(t, '21', '1111');

    // D9: 403 NONE_MATCH 다이얼로그 + 요청 버튼
    final reqBtn = find.text('담당자에게 접속 허용 요청');
    expect(await waitFor(t, reqBtn, 20), true, reason: '403 다이얼로그 미표시');
    // ignore: avoid_print
    print('SHOT:b_403_dialog');
    await hold(t, 4);
    await t.tap(reqBtn, warnIfMissed: false);

    // D11: 대기 화면 (승인 대기 중 비활성 버튼)
    expect(await waitFor(t, find.text('승인 대기 중'), 20), true,
        reason: '대기화면 미도달');
    // ignore: avoid_print
    print('SHOT:b_waiting_pending');
    await hold(t, 4);

    // 외부에서 관리자 승인 → 5초 폴링이 감지 → '접속하기' 활성화 (최대 75초 대기)
    expect(await waitFor(t, find.text('접속하기'), 75), true,
        reason: '승인 감지 실패 (폴링)');
    // ignore: avoid_print
    print('SHOT:b_waiting_approved');
    await hold(t, 4);
    await t.tap(find.text('접속하기'), warnIfMissed: false);
    await hold(t, 3);
    // ignore: avoid_print
    print('SHOT:b_back_to_login');
    await hold(t, 3);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
