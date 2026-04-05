part of 'history_bloc.dart';

@freezed
class HistoryEvent with _$HistoryEvent {
  /// 화면 초기 로드 - 해당 월 히스토리 조회
  const factory HistoryEvent.started({required DateTime month}) =
      HistoryStarted;

  /// 월 변경
  const factory HistoryEvent.monthChanged({required DateTime month}) =
      HistoryMonthChanged;
}
