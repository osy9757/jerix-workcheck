// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HistoryEvent {
  DateTime get month => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime month) started,
    required TResult Function(DateTime month) monthChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime month)? started,
    TResult? Function(DateTime month)? monthChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime month)? started,
    TResult Function(DateTime month)? monthChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HistoryStarted value) started,
    required TResult Function(HistoryMonthChanged value) monthChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HistoryStarted value)? started,
    TResult? Function(HistoryMonthChanged value)? monthChanged,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HistoryStarted value)? started,
    TResult Function(HistoryMonthChanged value)? monthChanged,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryEventCopyWith<HistoryEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryEventCopyWith<$Res> {
  factory $HistoryEventCopyWith(
          HistoryEvent value, $Res Function(HistoryEvent) then) =
      _$HistoryEventCopyWithImpl<$Res, HistoryEvent>;
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class _$HistoryEventCopyWithImpl<$Res, $Val extends HistoryEvent>
    implements $HistoryEventCopyWith<$Res> {
  _$HistoryEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_value.copyWith(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryStartedImplCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory _$$HistoryStartedImplCopyWith(_$HistoryStartedImpl value,
          $Res Function(_$HistoryStartedImpl) then) =
      __$$HistoryStartedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class __$$HistoryStartedImplCopyWithImpl<$Res>
    extends _$HistoryEventCopyWithImpl<$Res, _$HistoryStartedImpl>
    implements _$$HistoryStartedImplCopyWith<$Res> {
  __$$HistoryStartedImplCopyWithImpl(
      _$HistoryStartedImpl _value, $Res Function(_$HistoryStartedImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_$HistoryStartedImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$HistoryStartedImpl implements HistoryStarted {
  const _$HistoryStartedImpl({required this.month});

  @override
  final DateTime month;

  @override
  String toString() {
    return 'HistoryEvent.started(month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryStartedImpl &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryStartedImplCopyWith<_$HistoryStartedImpl> get copyWith =>
      __$$HistoryStartedImplCopyWithImpl<_$HistoryStartedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime month) started,
    required TResult Function(DateTime month) monthChanged,
  }) {
    return started(month);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime month)? started,
    TResult? Function(DateTime month)? monthChanged,
  }) {
    return started?.call(month);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime month)? started,
    TResult Function(DateTime month)? monthChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(month);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HistoryStarted value) started,
    required TResult Function(HistoryMonthChanged value) monthChanged,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HistoryStarted value)? started,
    TResult? Function(HistoryMonthChanged value)? monthChanged,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HistoryStarted value)? started,
    TResult Function(HistoryMonthChanged value)? monthChanged,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class HistoryStarted implements HistoryEvent {
  const factory HistoryStarted({required final DateTime month}) =
      _$HistoryStartedImpl;

  @override
  DateTime get month;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryStartedImplCopyWith<_$HistoryStartedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HistoryMonthChangedImplCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory _$$HistoryMonthChangedImplCopyWith(_$HistoryMonthChangedImpl value,
          $Res Function(_$HistoryMonthChangedImpl) then) =
      __$$HistoryMonthChangedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class __$$HistoryMonthChangedImplCopyWithImpl<$Res>
    extends _$HistoryEventCopyWithImpl<$Res, _$HistoryMonthChangedImpl>
    implements _$$HistoryMonthChangedImplCopyWith<$Res> {
  __$$HistoryMonthChangedImplCopyWithImpl(_$HistoryMonthChangedImpl _value,
      $Res Function(_$HistoryMonthChangedImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_$HistoryMonthChangedImpl(
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$HistoryMonthChangedImpl implements HistoryMonthChanged {
  const _$HistoryMonthChangedImpl({required this.month});

  @override
  final DateTime month;

  @override
  String toString() {
    return 'HistoryEvent.monthChanged(month: $month)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryMonthChangedImpl &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryMonthChangedImplCopyWith<_$HistoryMonthChangedImpl> get copyWith =>
      __$$HistoryMonthChangedImplCopyWithImpl<_$HistoryMonthChangedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime month) started,
    required TResult Function(DateTime month) monthChanged,
  }) {
    return monthChanged(month);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime month)? started,
    TResult? Function(DateTime month)? monthChanged,
  }) {
    return monthChanged?.call(month);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime month)? started,
    TResult Function(DateTime month)? monthChanged,
    required TResult orElse(),
  }) {
    if (monthChanged != null) {
      return monthChanged(month);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HistoryStarted value) started,
    required TResult Function(HistoryMonthChanged value) monthChanged,
  }) {
    return monthChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HistoryStarted value)? started,
    TResult? Function(HistoryMonthChanged value)? monthChanged,
  }) {
    return monthChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HistoryStarted value)? started,
    TResult Function(HistoryMonthChanged value)? monthChanged,
    required TResult orElse(),
  }) {
    if (monthChanged != null) {
      return monthChanged(this);
    }
    return orElse();
  }
}

abstract class HistoryMonthChanged implements HistoryEvent {
  const factory HistoryMonthChanged({required final DateTime month}) =
      _$HistoryMonthChangedImpl;

  @override
  DateTime get month;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryMonthChangedImplCopyWith<_$HistoryMonthChangedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HistoryState {
  /// 일별 출퇴근 기록 (day -> record)
  Map<int, DailyRecordEntity> get records => throw _privateConstructorUsedError;

  /// UI 상태
  HistoryUiState get uiState => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryStateCopyWith<HistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryStateCopyWith<$Res> {
  factory $HistoryStateCopyWith(
          HistoryState value, $Res Function(HistoryState) then) =
      _$HistoryStateCopyWithImpl<$Res, HistoryState>;
  @useResult
  $Res call(
      {Map<int, DailyRecordEntity> records,
      HistoryUiState uiState,
      String? errorMessage});
}

/// @nodoc
class _$HistoryStateCopyWithImpl<$Res, $Val extends HistoryState>
    implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as Map<int, DailyRecordEntity>,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as HistoryUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryStateImplCopyWith<$Res>
    implements $HistoryStateCopyWith<$Res> {
  factory _$$HistoryStateImplCopyWith(
          _$HistoryStateImpl value, $Res Function(_$HistoryStateImpl) then) =
      __$$HistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<int, DailyRecordEntity> records,
      HistoryUiState uiState,
      String? errorMessage});
}

/// @nodoc
class __$$HistoryStateImplCopyWithImpl<$Res>
    extends _$HistoryStateCopyWithImpl<$Res, _$HistoryStateImpl>
    implements _$$HistoryStateImplCopyWith<$Res> {
  __$$HistoryStateImplCopyWithImpl(
      _$HistoryStateImpl _value, $Res Function(_$HistoryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$HistoryStateImpl(
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as Map<int, DailyRecordEntity>,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as HistoryUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HistoryStateImpl implements _HistoryState {
  const _$HistoryStateImpl(
      {final Map<int, DailyRecordEntity> records = const {},
      this.uiState = HistoryUiState.initial,
      this.errorMessage = null})
      : _records = records;

  /// 일별 출퇴근 기록 (day -> record)
  final Map<int, DailyRecordEntity> _records;

  /// 일별 출퇴근 기록 (day -> record)
  @override
  @JsonKey()
  Map<int, DailyRecordEntity> get records {
    if (_records is EqualUnmodifiableMapView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_records);
  }

  /// UI 상태
  @override
  @JsonKey()
  final HistoryUiState uiState;

  /// 에러 메시지
  @override
  @JsonKey()
  final String? errorMessage;

  @override
  String toString() {
    return 'HistoryState(records: $records, uiState: $uiState, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryStateImpl &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_records), uiState, errorMessage);

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      __$$HistoryStateImplCopyWithImpl<_$HistoryStateImpl>(this, _$identity);
}

abstract class _HistoryState implements HistoryState {
  const factory _HistoryState(
      {final Map<int, DailyRecordEntity> records,
      final HistoryUiState uiState,
      final String? errorMessage}) = _$HistoryStateImpl;

  /// 일별 출퇴근 기록 (day -> record)
  @override
  Map<int, DailyRecordEntity> get records;

  /// UI 상태
  @override
  HistoryUiState get uiState;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
