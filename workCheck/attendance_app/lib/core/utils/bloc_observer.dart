import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// 앱 전역 BLoC 옵저버
/// 모든 BLoC/Cubit의 생명주기와 상태 변화를 로깅
class AppBlocObserver extends BlocObserver {
  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
  );

  /// BLoC/Cubit 생성 시 호출
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.d('🟢 Created: ${bloc.runtimeType}');
  }

  /// BLoC 이벤트 발생 시 호출
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('📩 Event: ${bloc.runtimeType} → $event');
  }

  /// 상태 변경 시 호출 (이전 상태 → 다음 상태 로깅)
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.d('🔄 State: ${bloc.runtimeType}\n'
        '   Current: ${change.currentState}\n'
        '   Next:    ${change.nextState}');
  }

  /// BLoC 내부 오류 발생 시 호출
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e('❌ Error: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
  }

  /// BLoC/Cubit 소멸 시 호출
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.d('🔴 Closed: ${bloc.runtimeType}');
  }
}
