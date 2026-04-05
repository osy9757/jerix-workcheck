import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/utils/bloc_observer.dart';

/// 앱 진입점
void main() async {
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

  // BLoC 전역 옵저버 등록 (상태 변화 로깅)
  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
