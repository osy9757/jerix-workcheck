// [시각검증 A] 사번12 로그인 → 출퇴근 지도 (현위치 중앙·현위치 원·출근지 반경 원·펄스)
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'visual_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('지도 시각 검증', (t) async {
    await launchApp(t);
    await hold(t, 1.5);
    // ignore: avoid_print
    print('SHOT:a_login_screen');
    await hold(t, 3);
    await doLogin(t, '12', '1111');
    // 지도 로드 단계별 캡처 (타일/마커/원/펄스 렌더 시간 확보)
    await hold(t, 4);
    // ignore: avoid_print
    print('SHOT:a_map_t4');
    await hold(t, 4);
    // ignore: avoid_print
    print('SHOT:a_map_t8');
    await hold(t, 6);
    // ignore: avoid_print
    print('SHOT:a_map_t14');
    await hold(t, 6);
    // ignore: avoid_print
    print('SHOT:a_map_t20');
    await hold(t, 5);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
