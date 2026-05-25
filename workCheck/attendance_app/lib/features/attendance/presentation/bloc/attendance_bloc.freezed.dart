// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AttendanceEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AttendanceEvent()';
  }
}

/// @nodoc
class $AttendanceEventCopyWith<$Res> {
  $AttendanceEventCopyWith(
      AttendanceEvent _, $Res Function(AttendanceEvent) __);
}

/// Adds pattern-matching-related methods to [AttendanceEvent].
extension AttendanceEventPatterns on AttendanceEvent {
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
    TResult Function(AttendanceStarted value)? started,
    TResult Function(AttendanceClockRequested value)? clockRequested,
    TResult Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted() when started != null:
        return started(_that);
      case AttendanceClockRequested() when clockRequested != null:
        return clockRequested(_that);
      case AttendanceAvailableMethodsRequested()
          when availableMethodsRequested != null:
        return availableMethodsRequested(_that);
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
    required TResult Function(AttendanceStarted value) started,
    required TResult Function(AttendanceClockRequested value) clockRequested,
    required TResult Function(AttendanceAvailableMethodsRequested value)
        availableMethodsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted():
        return started(_that);
      case AttendanceClockRequested():
        return clockRequested(_that);
      case AttendanceAvailableMethodsRequested():
        return availableMethodsRequested(_that);
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
    TResult? Function(AttendanceStarted value)? started,
    TResult? Function(AttendanceClockRequested value)? clockRequested,
    TResult? Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted() when started != null:
        return started(_that);
      case AttendanceClockRequested() when clockRequested != null:
        return clockRequested(_that);
      case AttendanceAvailableMethodsRequested()
          when availableMethodsRequested != null:
        return availableMethodsRequested(_that);
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
    TResult Function()? started,
    TResult Function()? clockRequested,
    TResult Function()? availableMethodsRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted() when started != null:
        return started();
      case AttendanceClockRequested() when clockRequested != null:
        return clockRequested();
      case AttendanceAvailableMethodsRequested()
          when availableMethodsRequested != null:
        return availableMethodsRequested();
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
    required TResult Function() started,
    required TResult Function() clockRequested,
    required TResult Function() availableMethodsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted():
        return started();
      case AttendanceClockRequested():
        return clockRequested();
      case AttendanceAvailableMethodsRequested():
        return availableMethodsRequested();
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
    TResult? Function()? started,
    TResult? Function()? clockRequested,
    TResult? Function()? availableMethodsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case AttendanceStarted() when started != null:
        return started();
      case AttendanceClockRequested() when clockRequested != null:
        return clockRequested();
      case AttendanceAvailableMethodsRequested()
          when availableMethodsRequested != null:
        return availableMethodsRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class AttendanceStarted implements AttendanceEvent {
  const AttendanceStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AttendanceStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AttendanceEvent.started()';
  }
}

/// @nodoc

class AttendanceClockRequested implements AttendanceEvent {
  const AttendanceClockRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AttendanceClockRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AttendanceEvent.clockRequested()';
  }
}

/// @nodoc

class AttendanceAvailableMethodsRequested implements AttendanceEvent {
  const AttendanceAvailableMethodsRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceAvailableMethodsRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AttendanceEvent.availableMethodsRequested()';
  }
}

/// @nodoc
mixin _$AttendanceState {
  /// 오늘 출퇴근 상태
  TodayStatusEntity? get todayStatus;

  /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
  List<VerificationMethod> get availableMethods;

  /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
  List<VerificationMethod> get serverEnabledMethods;

  /// UI 상태
  AttendanceUiState get uiState;

  /// 에러 메시지
  String? get errorMessage;

  /// 서버 에러 코드 (예: BEACON_UUID_MISMATCH)
  String? get errorCode;

  /// 성공 메시지
  String? get successMessage;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceStateCopyWith<AttendanceState> get copyWith =>
      _$AttendanceStateCopyWithImpl<AttendanceState>(
          this as AttendanceState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceState &&
            (identical(other.todayStatus, todayStatus) ||
                other.todayStatus == todayStatus) &&
            const DeepCollectionEquality()
                .equals(other.availableMethods, availableMethods) &&
            const DeepCollectionEquality()
                .equals(other.serverEnabledMethods, serverEnabledMethods) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      todayStatus,
      const DeepCollectionEquality().hash(availableMethods),
      const DeepCollectionEquality().hash(serverEnabledMethods),
      uiState,
      errorMessage,
      errorCode,
      successMessage);

  @override
  String toString() {
    return 'AttendanceState(todayStatus: $todayStatus, availableMethods: $availableMethods, serverEnabledMethods: $serverEnabledMethods, uiState: $uiState, errorMessage: $errorMessage, errorCode: $errorCode, successMessage: $successMessage)';
  }
}

/// @nodoc
abstract mixin class $AttendanceStateCopyWith<$Res> {
  factory $AttendanceStateCopyWith(
          AttendanceState value, $Res Function(AttendanceState) _then) =
      _$AttendanceStateCopyWithImpl;
  @useResult
  $Res call(
      {TodayStatusEntity? todayStatus,
      List<VerificationMethod> availableMethods,
      List<VerificationMethod> serverEnabledMethods,
      AttendanceUiState uiState,
      String? errorMessage,
      String? errorCode,
      String? successMessage});
}

/// @nodoc
class _$AttendanceStateCopyWithImpl<$Res>
    implements $AttendanceStateCopyWith<$Res> {
  _$AttendanceStateCopyWithImpl(this._self, this._then);

  final AttendanceState _self;
  final $Res Function(AttendanceState) _then;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? todayStatus = freezed,
    Object? availableMethods = null,
    Object? serverEnabledMethods = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_self.copyWith(
      todayStatus: freezed == todayStatus
          ? _self.todayStatus
          : todayStatus // ignore: cast_nullable_to_non_nullable
              as TodayStatusEntity?,
      availableMethods: null == availableMethods
          ? _self.availableMethods
          : availableMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      serverEnabledMethods: null == serverEnabledMethods
          ? _self.serverEnabledMethods
          : serverEnabledMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as AttendanceUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _self.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _self.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceState].
extension AttendanceStatePatterns on AttendanceState {
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
    TResult Function(_AttendanceState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceState() when $default != null:
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
    TResult Function(_AttendanceState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceState():
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
    TResult? Function(_AttendanceState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceState() when $default != null:
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
    TResult Function(
            TodayStatusEntity? todayStatus,
            List<VerificationMethod> availableMethods,
            List<VerificationMethod> serverEnabledMethods,
            AttendanceUiState uiState,
            String? errorMessage,
            String? errorCode,
            String? successMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceState() when $default != null:
        return $default(
            _that.todayStatus,
            _that.availableMethods,
            _that.serverEnabledMethods,
            _that.uiState,
            _that.errorMessage,
            _that.errorCode,
            _that.successMessage);
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
    TResult Function(
            TodayStatusEntity? todayStatus,
            List<VerificationMethod> availableMethods,
            List<VerificationMethod> serverEnabledMethods,
            AttendanceUiState uiState,
            String? errorMessage,
            String? errorCode,
            String? successMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceState():
        return $default(
            _that.todayStatus,
            _that.availableMethods,
            _that.serverEnabledMethods,
            _that.uiState,
            _that.errorMessage,
            _that.errorCode,
            _that.successMessage);
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
    TResult? Function(
            TodayStatusEntity? todayStatus,
            List<VerificationMethod> availableMethods,
            List<VerificationMethod> serverEnabledMethods,
            AttendanceUiState uiState,
            String? errorMessage,
            String? errorCode,
            String? successMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceState() when $default != null:
        return $default(
            _that.todayStatus,
            _that.availableMethods,
            _that.serverEnabledMethods,
            _that.uiState,
            _that.errorMessage,
            _that.errorCode,
            _that.successMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AttendanceState implements AttendanceState {
  const _AttendanceState(
      {this.todayStatus = null,
      final List<VerificationMethod> availableMethods = const [],
      final List<VerificationMethod> serverEnabledMethods = const [],
      this.uiState = AttendanceUiState.initial,
      this.errorMessage = null,
      this.errorCode = null,
      this.successMessage = null})
      : _availableMethods = availableMethods,
        _serverEnabledMethods = serverEnabledMethods;

  /// 오늘 출퇴근 상태
  @override
  @JsonKey()
  final TodayStatusEntity? todayStatus;

  /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
  final List<VerificationMethod> _availableMethods;

  /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
  @override
  @JsonKey()
  List<VerificationMethod> get availableMethods {
    if (_availableMethods is EqualUnmodifiableListView)
      return _availableMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableMethods);
  }

  /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
  final List<VerificationMethod> _serverEnabledMethods;

  /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
  @override
  @JsonKey()
  List<VerificationMethod> get serverEnabledMethods {
    if (_serverEnabledMethods is EqualUnmodifiableListView)
      return _serverEnabledMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_serverEnabledMethods);
  }

  /// UI 상태
  @override
  @JsonKey()
  final AttendanceUiState uiState;

  /// 에러 메시지
  @override
  @JsonKey()
  final String? errorMessage;

  /// 서버 에러 코드 (예: BEACON_UUID_MISMATCH)
  @override
  @JsonKey()
  final String? errorCode;

  /// 성공 메시지
  @override
  @JsonKey()
  final String? successMessage;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceStateCopyWith<_AttendanceState> get copyWith =>
      __$AttendanceStateCopyWithImpl<_AttendanceState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceState &&
            (identical(other.todayStatus, todayStatus) ||
                other.todayStatus == todayStatus) &&
            const DeepCollectionEquality()
                .equals(other._availableMethods, _availableMethods) &&
            const DeepCollectionEquality()
                .equals(other._serverEnabledMethods, _serverEnabledMethods) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      todayStatus,
      const DeepCollectionEquality().hash(_availableMethods),
      const DeepCollectionEquality().hash(_serverEnabledMethods),
      uiState,
      errorMessage,
      errorCode,
      successMessage);

  @override
  String toString() {
    return 'AttendanceState(todayStatus: $todayStatus, availableMethods: $availableMethods, serverEnabledMethods: $serverEnabledMethods, uiState: $uiState, errorMessage: $errorMessage, errorCode: $errorCode, successMessage: $successMessage)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceStateCopyWith<$Res>
    implements $AttendanceStateCopyWith<$Res> {
  factory _$AttendanceStateCopyWith(
          _AttendanceState value, $Res Function(_AttendanceState) _then) =
      __$AttendanceStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {TodayStatusEntity? todayStatus,
      List<VerificationMethod> availableMethods,
      List<VerificationMethod> serverEnabledMethods,
      AttendanceUiState uiState,
      String? errorMessage,
      String? errorCode,
      String? successMessage});
}

/// @nodoc
class __$AttendanceStateCopyWithImpl<$Res>
    implements _$AttendanceStateCopyWith<$Res> {
  __$AttendanceStateCopyWithImpl(this._self, this._then);

  final _AttendanceState _self;
  final $Res Function(_AttendanceState) _then;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? todayStatus = freezed,
    Object? availableMethods = null,
    Object? serverEnabledMethods = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
    Object? errorCode = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_AttendanceState(
      todayStatus: freezed == todayStatus
          ? _self.todayStatus
          : todayStatus // ignore: cast_nullable_to_non_nullable
              as TodayStatusEntity?,
      availableMethods: null == availableMethods
          ? _self._availableMethods
          : availableMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      serverEnabledMethods: null == serverEnabledMethods
          ? _self._serverEnabledMethods
          : serverEnabledMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as AttendanceUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _self.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _self.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
