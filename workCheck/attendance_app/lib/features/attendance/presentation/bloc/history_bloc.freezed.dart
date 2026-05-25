// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryEvent {
  DateTime get month;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryEventCopyWith<HistoryEvent> get copyWith =>
      _$HistoryEventCopyWithImpl<HistoryEvent>(
          this as HistoryEvent, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryEvent &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  @override
  String toString() {
    return 'HistoryEvent(month: $month)';
  }
}

/// @nodoc
abstract mixin class $HistoryEventCopyWith<$Res> {
  factory $HistoryEventCopyWith(
          HistoryEvent value, $Res Function(HistoryEvent) _then) =
      _$HistoryEventCopyWithImpl;
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class _$HistoryEventCopyWithImpl<$Res> implements $HistoryEventCopyWith<$Res> {
  _$HistoryEventCopyWithImpl(this._self, this._then);

  final HistoryEvent _self;
  final $Res Function(HistoryEvent) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? month = null,
  }) {
    return _then(_self.copyWith(
      month: null == month
          ? _self.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [HistoryEvent].
extension HistoryEventPatterns on HistoryEvent {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HistoryStarted value)? started,
    TResult Function(HistoryMonthChanged value)? monthChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted() when started != null:
        return started(_that);
      case HistoryMonthChanged() when monthChanged != null:
        return monthChanged(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HistoryStarted value) started,
    required TResult Function(HistoryMonthChanged value) monthChanged,
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted():
        return started(_that);
      case HistoryMonthChanged():
        return monthChanged(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HistoryStarted value)? started,
    TResult? Function(HistoryMonthChanged value)? monthChanged,
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted() when started != null:
        return started(_that);
      case HistoryMonthChanged() when monthChanged != null:
        return monthChanged(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTime month)? started,
    TResult Function(DateTime month)? monthChanged,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted() when started != null:
        return started(_that.month);
      case HistoryMonthChanged() when monthChanged != null:
        return monthChanged(_that.month);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTime month) started,
    required TResult Function(DateTime month) monthChanged,
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted():
        return started(_that.month);
      case HistoryMonthChanged():
        return monthChanged(_that.month);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTime month)? started,
    TResult? Function(DateTime month)? monthChanged,
  }) {
    final _that = this;
    switch (_that) {
      case HistoryStarted() when started != null:
        return started(_that.month);
      case HistoryMonthChanged() when monthChanged != null:
        return monthChanged(_that.month);
      case _:
        return null;
    }
  }
}

/// @nodoc

class HistoryStarted implements HistoryEvent {
  const HistoryStarted({required this.month});

  @override
  final DateTime month;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryStartedCopyWith<HistoryStarted> get copyWith =>
      _$HistoryStartedCopyWithImpl<HistoryStarted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryStarted &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  @override
  String toString() {
    return 'HistoryEvent.started(month: $month)';
  }
}

/// @nodoc
abstract mixin class $HistoryStartedCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory $HistoryStartedCopyWith(
          HistoryStarted value, $Res Function(HistoryStarted) _then) =
      _$HistoryStartedCopyWithImpl;
  @override
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class _$HistoryStartedCopyWithImpl<$Res>
    implements $HistoryStartedCopyWith<$Res> {
  _$HistoryStartedCopyWithImpl(this._self, this._then);

  final HistoryStarted _self;
  final $Res Function(HistoryStarted) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? month = null,
  }) {
    return _then(HistoryStarted(
      month: null == month
          ? _self.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class HistoryMonthChanged implements HistoryEvent {
  const HistoryMonthChanged({required this.month});

  @override
  final DateTime month;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryMonthChangedCopyWith<HistoryMonthChanged> get copyWith =>
      _$HistoryMonthChangedCopyWithImpl<HistoryMonthChanged>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryMonthChanged &&
            (identical(other.month, month) || other.month == month));
  }

  @override
  int get hashCode => Object.hash(runtimeType, month);

  @override
  String toString() {
    return 'HistoryEvent.monthChanged(month: $month)';
  }
}

/// @nodoc
abstract mixin class $HistoryMonthChangedCopyWith<$Res>
    implements $HistoryEventCopyWith<$Res> {
  factory $HistoryMonthChangedCopyWith(
          HistoryMonthChanged value, $Res Function(HistoryMonthChanged) _then) =
      _$HistoryMonthChangedCopyWithImpl;
  @override
  @useResult
  $Res call({DateTime month});
}

/// @nodoc
class _$HistoryMonthChangedCopyWithImpl<$Res>
    implements $HistoryMonthChangedCopyWith<$Res> {
  _$HistoryMonthChangedCopyWithImpl(this._self, this._then);

  final HistoryMonthChanged _self;
  final $Res Function(HistoryMonthChanged) _then;

  /// Create a copy of HistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? month = null,
  }) {
    return _then(HistoryMonthChanged(
      month: null == month
          ? _self.month
          : month // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
mixin _$HistoryState {
  /// 일별 출퇴근 기록 (day -> record)
  Map<int, DailyRecordEntity> get records;

  /// UI 상태
  HistoryUiState get uiState;

  /// 에러 메시지
  String? get errorMessage;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryStateCopyWith<HistoryState> get copyWith =>
      _$HistoryStateCopyWithImpl<HistoryState>(
          this as HistoryState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryState &&
            const DeepCollectionEquality().equals(other.records, records) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(records), uiState, errorMessage);

  @override
  String toString() {
    return 'HistoryState(records: $records, uiState: $uiState, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $HistoryStateCopyWith<$Res> {
  factory $HistoryStateCopyWith(
          HistoryState value, $Res Function(HistoryState) _then) =
      _$HistoryStateCopyWithImpl;
  @useResult
  $Res call(
      {Map<int, DailyRecordEntity> records,
      HistoryUiState uiState,
      String? errorMessage});
}

/// @nodoc
class _$HistoryStateCopyWithImpl<$Res> implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._self, this._then);

  final HistoryState _self;
  final $Res Function(HistoryState) _then;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      records: null == records
          ? _self.records
          : records // ignore: cast_nullable_to_non_nullable
              as Map<int, DailyRecordEntity>,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as HistoryUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [HistoryState].
extension HistoryStatePatterns on HistoryState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_HistoryState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HistoryState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_HistoryState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_HistoryState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(Map<int, DailyRecordEntity> records,
            HistoryUiState uiState, String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HistoryState() when $default != null:
        return $default(_that.records, _that.uiState, _that.errorMessage);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(Map<int, DailyRecordEntity> records,
            HistoryUiState uiState, String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryState():
        return $default(_that.records, _that.uiState, _that.errorMessage);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(Map<int, DailyRecordEntity> records,
            HistoryUiState uiState, String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryState() when $default != null:
        return $default(_that.records, _that.uiState, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HistoryState implements HistoryState {
  const _HistoryState(
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

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HistoryStateCopyWith<_HistoryState> get copyWith =>
      __$HistoryStateCopyWithImpl<_HistoryState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HistoryState &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_records), uiState, errorMessage);

  @override
  String toString() {
    return 'HistoryState(records: $records, uiState: $uiState, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$HistoryStateCopyWith<$Res>
    implements $HistoryStateCopyWith<$Res> {
  factory _$HistoryStateCopyWith(
          _HistoryState value, $Res Function(_HistoryState) _then) =
      __$HistoryStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {Map<int, DailyRecordEntity> records,
      HistoryUiState uiState,
      String? errorMessage});
}

/// @nodoc
class __$HistoryStateCopyWithImpl<$Res>
    implements _$HistoryStateCopyWith<$Res> {
  __$HistoryStateCopyWithImpl(this._self, this._then);

  final _HistoryState _self;
  final $Res Function(_HistoryState) _then;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? records = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_HistoryState(
      records: null == records
          ? _self._records
          : records // ignore: cast_nullable_to_non_nullable
              as Map<int, DailyRecordEntity>,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as HistoryUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
