import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// 전역 서비스 로케이터 인스턴스 (GetIt)
final getIt = GetIt.instance;

/// 의존성 주입 초기화 함수
/// @InjectableInit 어노테이션을 통해 자동 생성된 코드를 실행
@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async => getIt.init();
