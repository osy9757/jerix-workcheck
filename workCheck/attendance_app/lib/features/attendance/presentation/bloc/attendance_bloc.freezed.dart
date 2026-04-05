// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AttendanceEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() clockRequested,
    required TResult Function() availableMethodsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? clockRequested,
    TResult? Function()? availableMethodsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? clockRequested,
    TResult Function()? availableMethodsRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttendanceStarted value) started,
    required TResult Function(AttendanceClockRequested value) clockRequested,
    required TResult Function(AttendanceAvailableMethodsRequested value)
        availableMethodsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttendanceStarted value)? started,
    TResult? Function(AttendanceClockRequested value)? clockRequested,
    TResult? Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttendanceStarted value)? started,
    TResult Function(AttendanceClockRequested value)? clockRequested,
    TResult Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceEventCopyWith<$Res> {
  factory $AttendanceEventCopyWith(
          AttendanceEvent value, $Res Function(AttendanceEvent) then) =
      _$AttendanceEventCopyWithImpl<$Res, AttendanceEvent>;
}

/// @nodoc
class _$AttendanceEventCopyWithImpl<$Res, $Val extends AttendanceEvent>
    implements $AttendanceEventCopyWith<$Res> {
  _$AttendanceEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AttendanceStartedImplCopyWith<$Res> {
  factory _$$AttendanceStartedImplCopyWith(_$AttendanceStartedImpl value,
          $Res Function(_$AttendanceStartedImpl) then) =
      __$$AttendanceStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AttendanceStartedImplCopyWithImpl<$Res>
    extends _$AttendanceEventCopyWithImpl<$Res, _$AttendanceStartedImpl>
    implements _$$AttendanceStartedImplCopyWith<$Res> {
  __$$AttendanceStartedImplCopyWithImpl(_$AttendanceStartedImpl _value,
      $Res Function(_$AttendanceStartedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AttendanceStartedImpl implements AttendanceStarted {
  const _$AttendanceStartedImpl();

  @override
  String toString() {
    return 'AttendanceEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AttendanceStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() clockRequested,
    required TResult Function() availableMethodsRequested,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? clockRequested,
    TResult? Function()? availableMethodsRequested,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? clockRequested,
    TResult Function()? availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttendanceStarted value) started,
    required TResult Function(AttendanceClockRequested value) clockRequested,
    required TResult Function(AttendanceAvailableMethodsRequested value)
        availableMethodsRequested,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttendanceStarted value)? started,
    TResult? Function(AttendanceClockRequested value)? clockRequested,
    TResult? Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttendanceStarted value)? started,
    TResult Function(AttendanceClockRequested value)? clockRequested,
    TResult Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class AttendanceStarted implements AttendanceEvent {
  const factory AttendanceStarted() = _$AttendanceStartedImpl;
}

/// @nodoc
abstract class _$$AttendanceClockRequestedImplCopyWith<$Res> {
  factory _$$AttendanceClockRequestedImplCopyWith(
          _$AttendanceClockRequestedImpl value,
          $Res Function(_$AttendanceClockRequestedImpl) then) =
      __$$AttendanceClockRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AttendanceClockRequestedImplCopyWithImpl<$Res>
    extends _$AttendanceEventCopyWithImpl<$Res, _$AttendanceClockRequestedImpl>
    implements _$$AttendanceClockRequestedImplCopyWith<$Res> {
  __$$AttendanceClockRequestedImplCopyWithImpl(
      _$AttendanceClockRequestedImpl _value,
      $Res Function(_$AttendanceClockRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AttendanceClockRequestedImpl implements AttendanceClockRequested {
  const _$AttendanceClockRequestedImpl();

  @override
  String toString() {
    return 'AttendanceEvent.clockRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceClockRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() clockRequested,
    required TResult Function() availableMethodsRequested,
  }) {
    return clockRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? clockRequested,
    TResult? Function()? availableMethodsRequested,
  }) {
    return clockRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? clockRequested,
    TResult Function()? availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (clockRequested != null) {
      return clockRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttendanceStarted value) started,
    required TResult Function(AttendanceClockRequested value) clockRequested,
    required TResult Function(AttendanceAvailableMethodsRequested value)
        availableMethodsRequested,
  }) {
    return clockRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttendanceStarted value)? started,
    TResult? Function(AttendanceClockRequested value)? clockRequested,
    TResult? Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
  }) {
    return clockRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttendanceStarted value)? started,
    TResult Function(AttendanceClockRequested value)? clockRequested,
    TResult Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (clockRequested != null) {
      return clockRequested(this);
    }
    return orElse();
  }
}

abstract class AttendanceClockRequested implements AttendanceEvent {
  const factory AttendanceClockRequested() = _$AttendanceClockRequestedImpl;
}

/// @nodoc
abstract class _$$AttendanceAvailableMethodsRequestedImplCopyWith<$Res> {
  factory _$$AttendanceAvailableMethodsRequestedImplCopyWith(
          _$AttendanceAvailableMethodsRequestedImpl value,
          $Res Function(_$AttendanceAvailableMethodsRequestedImpl) then) =
      __$$AttendanceAvailableMethodsRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AttendanceAvailableMethodsRequestedImplCopyWithImpl<$Res>
    extends _$AttendanceEventCopyWithImpl<$Res,
        _$AttendanceAvailableMethodsRequestedImpl>
    implements _$$AttendanceAvailableMethodsRequestedImplCopyWith<$Res> {
  __$$AttendanceAvailableMethodsRequestedImplCopyWithImpl(
      _$AttendanceAvailableMethodsRequestedImpl _value,
      $Res Function(_$AttendanceAvailableMethodsRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AttendanceAvailableMethodsRequestedImpl
    implements AttendanceAvailableMethodsRequested {
  const _$AttendanceAvailableMethodsRequestedImpl();

  @override
  String toString() {
    return 'AttendanceEvent.availableMethodsRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceAvailableMethodsRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() clockRequested,
    required TResult Function() availableMethodsRequested,
  }) {
    return availableMethodsRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? clockRequested,
    TResult? Function()? availableMethodsRequested,
  }) {
    return availableMethodsRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? clockRequested,
    TResult Function()? availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (availableMethodsRequested != null) {
      return availableMethodsRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AttendanceStarted value) started,
    required TResult Function(AttendanceClockRequested value) clockRequested,
    required TResult Function(AttendanceAvailableMethodsRequested value)
        availableMethodsRequested,
  }) {
    return availableMethodsRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AttendanceStarted value)? started,
    TResult? Function(AttendanceClockRequested value)? clockRequested,
    TResult? Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
  }) {
    return availableMethodsRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AttendanceStarted value)? started,
    TResult Function(AttendanceClockRequested value)? clockRequested,
    TResult Function(AttendanceAvailableMethodsRequested value)?
        availableMethodsRequested,
    required TResult orElse(),
  }) {
    if (availableMethodsRequested != null) {
      return availableMethodsRequested(this);
    }
    return orElse();
  }
}

abstract class AttendanceAvailableMethodsRequested implements AttendanceEvent {
  const factory AttendanceAvailableMethodsRequested() =
      _$AttendanceAvailableMethodsRequestedImpl;
}

/// @nodoc
mixin _$AttendanceState {
  /// 오늘 출퇴근 상태
  TodayStatusEntity? get todayStatus => throw _privateConstructorUsedError;

  /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
  List<VerificationMethod> get availableMethods =>
      throw _privateConstructorUsedError;

  /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
  List<VerificationMethod> get serverEnabledMethods =>
      throw _privateConstructorUsedError;

  /// UI 상태
  AttendanceUiState get uiState => throw _privateConstructorUsedError;

  /// 에러 메시지
  String? get errorMessage => throw _privateConstructorUsedError;

  /// 서버 에러 코드 (예: BEACON_UUID_MISMATCH)
  String? get errorCode => throw _privateConstructorUsedError;

  /// 성공 메시지
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceStateCopyWith<AttendanceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceStateCopyWith<$Res> {
  factory $AttendanceStateCopyWith(
          AttendanceState value, $Res Function(AttendanceState) then) =
      _$AttendanceStateCopyWithImpl<$Res, AttendanceState>;
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
class _$AttendanceStateCopyWithImpl<$Res, $Val extends AttendanceState>
    implements $AttendanceStateCopyWith<$Res> {
  _$AttendanceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      todayStatus: freezed == todayStatus
          ? _value.todayStatus
          : todayStatus // ignore: cast_nullable_to_non_nullable
              as TodayStatusEntity?,
      availableMethods: null == availableMethods
          ? _value.availableMethods
          : availableMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      serverEnabledMethods: null == serverEnabledMethods
          ? _value.serverEnabledMethods
          : serverEnabledMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as AttendanceUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceStateImplCopyWith<$Res>
    implements $AttendanceStateCopyWith<$Res> {
  factory _$$AttendanceStateImplCopyWith(_$AttendanceStateImpl value,
          $Res Function(_$AttendanceStateImpl) then) =
      __$$AttendanceStateImplCopyWithImpl<$Res>;
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
class __$$AttendanceStateImplCopyWithImpl<$Res>
    extends _$AttendanceStateCopyWithImpl<$Res, _$AttendanceStateImpl>
    implements _$$AttendanceStateImplCopyWith<$Res> {
  __$$AttendanceStateImplCopyWithImpl(
      _$AttendanceStateImpl _value, $Res Function(_$AttendanceStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$AttendanceStateImpl(
      todayStatus: freezed == todayStatus
          ? _value.todayStatus
          : todayStatus // ignore: cast_nullable_to_non_nullable
              as TodayStatusEntity?,
      availableMethods: null == availableMethods
          ? _value._availableMethods
          : availableMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      serverEnabledMethods: null == serverEnabledMethods
          ? _value._serverEnabledMethods
          : serverEnabledMethods // ignore: cast_nullable_to_non_nullable
              as List<VerificationMethod>,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as AttendanceUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AttendanceStateImpl implements _AttendanceState {
  const _$AttendanceStateImpl(
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

  @override
  String toString() {
    return 'AttendanceState(todayStatus: $todayStatus, availableMethods: $availableMethods, serverEnabledMethods: $serverEnabledMethods, uiState: $uiState, errorMessage: $errorMessage, errorCode: $errorCode, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceStateImpl &&
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

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceStateImplCopyWith<_$AttendanceStateImpl> get copyWith =>
      __$$AttendanceStateImplCopyWithImpl<_$AttendanceStateImpl>(
          this, _$identity);
}

abstract class _AttendanceState implements AttendanceState {
  const factory _AttendanceState(
      {final TodayStatusEntity? todayStatus,
      final List<VerificationMethod> availableMethods,
      final List<VerificationMethod> serverEnabledMethods,
      final AttendanceUiState uiState,
      final String? errorMessage,
      final String? errorCode,
      final String? successMessage}) = _$AttendanceStateImpl;

  /// 오늘 출퇴근 상태
  @override
  TodayStatusEntity? get todayStatus;

  /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
  @override
  List<VerificationMethod> get availableMethods;

  /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
  @override
  List<VerificationMethod> get serverEnabledMethods;

  /// UI 상태
  @override
  AttendanceUiState get uiState;

  /// 에러 메시지
  @override
  String? get errorMessage;

  /// 서버 에러 코드 (예: BEACON_UUID_MISMATCH)
  @override
  String? get errorCode;

  /// 성공 메시지
  @override
  String? get successMessage;

  /// Create a copy of AttendanceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceStateImplCopyWith<_$AttendanceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
