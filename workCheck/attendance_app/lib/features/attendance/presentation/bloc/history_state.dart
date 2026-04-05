part of 'history_bloc.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState({
    /// 일별 출퇴근 기록 (day -> record)
    @Default({}) Map<int, DailyRecordEntity> records,

    /// UI 상태
    @Default(HistoryUiState.initial) HistoryUiState uiState,

    /// 에러 메시지
    @Default(null) String? errorMessage,
  }) = _HistoryState;
}

enum HistoryUiState {
  /// 초기 상태
  initial,

  /// 히스토리 로딩 중
  loading,

  /// 히스토리 로드 완료
  loaded,

  /// 에러 발생
  error,
}
