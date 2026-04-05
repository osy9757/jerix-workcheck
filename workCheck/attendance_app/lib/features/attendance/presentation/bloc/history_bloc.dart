import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/history_entity.dart';
import '../../domain/usecases/get_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

/// 출퇴근 히스토리 BLoC
@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase _getHistory;

  HistoryBloc(this._getHistory) : super(const HistoryState()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryMonthChanged>(_onMonthChanged);
  }

  /// 초기 로드
  Future<void> _onStarted(
    HistoryStarted event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(uiState: HistoryUiState.loading));
    await _loadHistory(event.month, emit);
  }

  /// 월 변경
  Future<void> _onMonthChanged(
    HistoryMonthChanged event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(uiState: HistoryUiState.loading));
    await _loadHistory(event.month, emit);
  }

  /// API 호출로 히스토리 데이터 로드
  Future<void> _loadHistory(
    DateTime month,
    Emitter<HistoryState> emit,
  ) async {
    // 선택된 월의 첫째날~마지막날 계산
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0);

    final fromStr =
        '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    final toStr =
        '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';

    final result = await _getHistory(
      GetHistoryParams(from: fromStr, to: toStr),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        uiState: HistoryUiState.error,
        errorMessage: failure.message,
      )),
      (history) {
        // 응답의 date를 파싱하여 Map<int, DailyRecordEntity> 변환
        final recordMap = <int, DailyRecordEntity>{};
        for (final record in history.records) {
          final date = DateTime.parse(record.date);
          recordMap[date.day] = record;
        }
        emit(state.copyWith(
          uiState: HistoryUiState.loaded,
          records: recordMap,
        ));
      },
    );
  }
}
