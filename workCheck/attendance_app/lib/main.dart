import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/bloc_observer.dart';

/// 앱 진입점
void main() async {
  // 전역 에러 핸들러 설치 (테스트 가시성 위해 게이팅 없이 항상 설치)
  // 1) Flutter 프레임워크 위젯/렌더 예외 → 콘솔 덤프 + logE 기록
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    logE('FlutterError', details.summary, details.exception, details.stack);
  };

  // 2) 엔진(플랫폼) 레벨의 미처리 예외 → logE 기록 후 true(처리됨) 반환
  PlatformDispatcher.instance.onError = (error, stack) {
    logE('PlatformError', '미처리 플랫폼 예외', error, stack);
    return true;
  };

  // 3) runZonedGuarded로 감싸 async 미처리 예외까지 logE로 포착
  // (앱 수명 전체를 감싸는 zone이므로 반환 Future는 await 하지 않음)
  unawaited(runZonedGuarded(() async {
    // Flutter 엔진 바인딩 초기화 (비동기 작업 전 필수)
    WidgetsFlutterBinding.ensureInitialized();

    // 상태바 스타일을 다크 모드로 설정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // 화면 방향을 세로(portrait)로 고정
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // 한국어 날짜 포맷 데이터 초기화
    await initializeDateFormatting('ko_KR');

    // 의존성 주입 초기화 (GetIt + Injectable)
    await configureDependencies();

    // 카카오맵 SDK 초기화
    await KakaoMapSdk.instance.initialize('251dc7720258f298d08ac0f7cec438b3');

    // BLoC 전역 옵저버 등록 (상태 변화 로깅) — 테스트 가시성 위해 게이팅 없음
    Bloc.observer = AppBlocObserver();

    runApp(const App());
  }, (error, stack) {
    // Zone 내 async 미처리 예외 기록
    logE('ZoneError', '미처리 async 예외', error, stack);
  }));
}
