// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PermissionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() requested,
    required TResult Function() openSettingsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? requested,
    TResult? Function()? openSettingsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? requested,
    TResult Function()? openSettingsRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PermissionStarted value) started,
    required TResult Function(PermissionRequested value) requested,
    required TResult Function(PermissionOpenSettingsRequested value)
        openSettingsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PermissionStarted value)? started,
    TResult? Function(PermissionRequested value)? requested,
    TResult? Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PermissionStarted value)? started,
    TResult Function(PermissionRequested value)? requested,
    TResult Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionEventCopyWith<$Res> {
  factory $PermissionEventCopyWith(
          PermissionEvent value, $Res Function(PermissionEvent) then) =
      _$PermissionEventCopyWithImpl<$Res, PermissionEvent>;
}

/// @nodoc
class _$PermissionEventCopyWithImpl<$Res, $Val extends PermissionEvent>
    implements $PermissionEventCopyWith<$Res> {
  _$PermissionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$PermissionStartedImplCopyWith<$Res> {
  factory _$$PermissionStartedImplCopyWith(_$PermissionStartedImpl value,
          $Res Function(_$PermissionStartedImpl) then) =
      __$$PermissionStartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PermissionStartedImplCopyWithImpl<$Res>
    extends _$PermissionEventCopyWithImpl<$Res, _$PermissionStartedImpl>
    implements _$$PermissionStartedImplCopyWith<$Res> {
  __$$PermissionStartedImplCopyWithImpl(_$PermissionStartedImpl _value,
      $Res Function(_$PermissionStartedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PermissionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PermissionStartedImpl implements PermissionStarted {
  const _$PermissionStartedImpl();

  @override
  String toString() {
    return 'PermissionEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PermissionStartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() requested,
    required TResult Function() openSettingsRequested,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? requested,
    TResult? Function()? openSettingsRequested,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? requested,
    TResult Function()? openSettingsRequested,
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
    required TResult Function(PermissionStarted value) started,
    required TResult Function(PermissionRequested value) requested,
    required TResult Function(PermissionOpenSettingsRequested value)
        openSettingsRequested,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PermissionStarted value)? started,
    TResult? Function(PermissionRequested value)? requested,
    TResult? Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PermissionStarted value)? started,
    TResult Function(PermissionRequested value)? requested,
    TResult Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class PermissionStarted implements PermissionEvent {
  const factory PermissionStarted() = _$PermissionStartedImpl;
}

/// @nodoc
abstract class _$$PermissionRequestedImplCopyWith<$Res> {
  factory _$$PermissionRequestedImplCopyWith(_$PermissionRequestedImpl value,
          $Res Function(_$PermissionRequestedImpl) then) =
      __$$PermissionRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PermissionRequestedImplCopyWithImpl<$Res>
    extends _$PermissionEventCopyWithImpl<$Res, _$PermissionRequestedImpl>
    implements _$$PermissionRequestedImplCopyWith<$Res> {
  __$$PermissionRequestedImplCopyWithImpl(_$PermissionRequestedImpl _value,
      $Res Function(_$PermissionRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PermissionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PermissionRequestedImpl implements PermissionRequested {
  const _$PermissionRequestedImpl();

  @override
  String toString() {
    return 'PermissionEvent.requested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() requested,
    required TResult Function() openSettingsRequested,
  }) {
    return requested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? requested,
    TResult? Function()? openSettingsRequested,
  }) {
    return requested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? requested,
    TResult Function()? openSettingsRequested,
    required TResult orElse(),
  }) {
    if (requested != null) {
      return requested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PermissionStarted value) started,
    required TResult Function(PermissionRequested value) requested,
    required TResult Function(PermissionOpenSettingsRequested value)
        openSettingsRequested,
  }) {
    return requested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PermissionStarted value)? started,
    TResult? Function(PermissionRequested value)? requested,
    TResult? Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
  }) {
    return requested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PermissionStarted value)? started,
    TResult Function(PermissionRequested value)? requested,
    TResult Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
    required TResult orElse(),
  }) {
    if (requested != null) {
      return requested(this);
    }
    return orElse();
  }
}

abstract class PermissionRequested implements PermissionEvent {
  const factory PermissionRequested() = _$PermissionRequestedImpl;
}

/// @nodoc
abstract class _$$PermissionOpenSettingsRequestedImplCopyWith<$Res> {
  factory _$$PermissionOpenSettingsRequestedImplCopyWith(
          _$PermissionOpenSettingsRequestedImpl value,
          $Res Function(_$PermissionOpenSettingsRequestedImpl) then) =
      __$$PermissionOpenSettingsRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PermissionOpenSettingsRequestedImplCopyWithImpl<$Res>
    extends _$PermissionEventCopyWithImpl<$Res,
        _$PermissionOpenSettingsRequestedImpl>
    implements _$$PermissionOpenSettingsRequestedImplCopyWith<$Res> {
  __$$PermissionOpenSettingsRequestedImplCopyWithImpl(
      _$PermissionOpenSettingsRequestedImpl _value,
      $Res Function(_$PermissionOpenSettingsRequestedImpl) _then)
      : super(_value, _then);

  /// Create a copy of PermissionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PermissionOpenSettingsRequestedImpl
    implements PermissionOpenSettingsRequested {
  const _$PermissionOpenSettingsRequestedImpl();

  @override
  String toString() {
    return 'PermissionEvent.openSettingsRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionOpenSettingsRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function() requested,
    required TResult Function() openSettingsRequested,
  }) {
    return openSettingsRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function()? requested,
    TResult? Function()? openSettingsRequested,
  }) {
    return openSettingsRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function()? requested,
    TResult Function()? openSettingsRequested,
    required TResult orElse(),
  }) {
    if (openSettingsRequested != null) {
      return openSettingsRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PermissionStarted value) started,
    required TResult Function(PermissionRequested value) requested,
    required TResult Function(PermissionOpenSettingsRequested value)
        openSettingsRequested,
  }) {
    return openSettingsRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PermissionStarted value)? started,
    TResult? Function(PermissionRequested value)? requested,
    TResult? Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
  }) {
    return openSettingsRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PermissionStarted value)? started,
    TResult Function(PermissionRequested value)? requested,
    TResult Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
    required TResult orElse(),
  }) {
    if (openSettingsRequested != null) {
      return openSettingsRequested(this);
    }
    return orElse();
  }
}

abstract class PermissionOpenSettingsRequested implements PermissionEvent {
  const factory PermissionOpenSettingsRequested() =
      _$PermissionOpenSettingsRequestedImpl;
}

/// @nodoc
mixin _$PermissionState {
  /// 권한 항목 목록
  List<PermissionItem> get permissionItems =>
      throw _privateConstructorUsedError;

  /// 모든 권한이 허용되었는지 여부
  bool get allGranted => throw _privateConstructorUsedError;

  /// 현재 UI 상태
  PermissionUiState get uiState => throw _privateConstructorUsedError;

  /// 오류 메시지 (오류 상태일 때만 존재)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionStateCopyWith<PermissionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionStateCopyWith<$Res> {
  factory $PermissionStateCopyWith(
          PermissionState value, $Res Function(PermissionState) then) =
      _$PermissionStateCopyWithImpl<$Res, PermissionState>;
  @useResult
  $Res call(
      {List<PermissionItem> permissionItems,
      bool allGranted,
      PermissionUiState uiState,
      String? errorMessage});
}

/// @nodoc
class _$PermissionStateCopyWithImpl<$Res, $Val extends PermissionState>
    implements $PermissionStateCopyWith<$Res> {
  _$PermissionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissionItems = null,
    Object? allGranted = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      permissionItems: null == permissionItems
          ? _value.permissionItems
          : permissionItems // ignore: cast_nullable_to_non_nullable
              as List<PermissionItem>,
      allGranted: null == allGranted
          ? _value.allGranted
          : allGranted // ignore: cast_nullable_to_non_nullable
              as bool,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as PermissionUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PermissionStateImplCopyWith<$Res>
    implements $PermissionStateCopyWith<$Res> {
  factory _$$PermissionStateImplCopyWith(_$PermissionStateImpl value,
          $Res Function(_$PermissionStateImpl) then) =
      __$$PermissionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PermissionItem> permissionItems,
      bool allGranted,
      PermissionUiState uiState,
      String? errorMessage});
}

/// @nodoc
class __$$PermissionStateImplCopyWithImpl<$Res>
    extends _$PermissionStateCopyWithImpl<$Res, _$PermissionStateImpl>
    implements _$$PermissionStateImplCopyWith<$Res> {
  __$$PermissionStateImplCopyWithImpl(
      _$PermissionStateImpl _value, $Res Function(_$PermissionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? permissionItems = null,
    Object? allGranted = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PermissionStateImpl(
      permissionItems: null == permissionItems
          ? _value._permissionItems
          : permissionItems // ignore: cast_nullable_to_non_nullable
              as List<PermissionItem>,
      allGranted: null == allGranted
          ? _value.allGranted
          : allGranted // ignore: cast_nullable_to_non_nullable
              as bool,
      uiState: null == uiState
          ? _value.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as PermissionUiState,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PermissionStateImpl implements _PermissionState {
  const _$PermissionStateImpl(
      {final List<PermissionItem> permissionItems = const [],
      this.allGranted = false,
      this.uiState = PermissionUiState.initial,
      this.errorMessage = null})
      : _permissionItems = permissionItems;

  /// 권한 항목 목록
  final List<PermissionItem> _permissionItems;

  /// 권한 항목 목록
  @override
  @JsonKey()
  List<PermissionItem> get permissionItems {
    if (_permissionItems is EqualUnmodifiableListView) return _permissionItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissionItems);
  }

  /// 모든 권한이 허용되었는지 여부
  @override
  @JsonKey()
  final bool allGranted;

  /// 현재 UI 상태
  @override
  @JsonKey()
  final PermissionUiState uiState;

  /// 오류 메시지 (오류 상태일 때만 존재)
  @override
  @JsonKey()
  final String? errorMessage;

  @override
  String toString() {
    return 'PermissionState(permissionItems: $permissionItems, allGranted: $allGranted, uiState: $uiState, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionStateImpl &&
            const DeepCollectionEquality()
                .equals(other._permissionItems, _permissionItems) &&
            (identical(other.allGranted, allGranted) ||
                other.allGranted == allGranted) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_permissionItems),
      allGranted,
      uiState,
      errorMessage);

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionStateImplCopyWith<_$PermissionStateImpl> get copyWith =>
      __$$PermissionStateImplCopyWithImpl<_$PermissionStateImpl>(
          this, _$identity);
}

abstract class _PermissionState implements PermissionState {
  const factory _PermissionState(
      {final List<PermissionItem> permissionItems,
      final bool allGranted,
      final PermissionUiState uiState,
      final String? errorMessage}) = _$PermissionStateImpl;

  /// 권한 항목 목록
  @override
  List<PermissionItem> get permissionItems;

  /// 모든 권한이 허용되었는지 여부
  @override
  bool get allGranted;

  /// 현재 UI 상태
  @override
  PermissionUiState get uiState;

  /// 오류 메시지 (오류 상태일 때만 존재)
  @override
  String? get errorMessage;

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionStateImplCopyWith<_$PermissionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
