// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'permission_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PermissionEvent {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PermissionEvent);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PermissionEvent()';
  }
}

/// @nodoc
class $PermissionEventCopyWith<$Res> {
  $PermissionEventCopyWith(
      PermissionEvent _, $Res Function(PermissionEvent) __);
}

/// Adds pattern-matching-related methods to [PermissionEvent].
extension PermissionEventPatterns on PermissionEvent {
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
    TResult Function(PermissionStarted value)? started,
    TResult Function(PermissionRequested value)? requested,
    TResult Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted() when started != null:
        return started(_that);
      case PermissionRequested() when requested != null:
        return requested(_that);
      case PermissionOpenSettingsRequested() when openSettingsRequested != null:
        return openSettingsRequested(_that);
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
    required TResult Function(PermissionStarted value) started,
    required TResult Function(PermissionRequested value) requested,
    required TResult Function(PermissionOpenSettingsRequested value)
        openSettingsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted():
        return started(_that);
      case PermissionRequested():
        return requested(_that);
      case PermissionOpenSettingsRequested():
        return openSettingsRequested(_that);
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
    TResult? Function(PermissionStarted value)? started,
    TResult? Function(PermissionRequested value)? requested,
    TResult? Function(PermissionOpenSettingsRequested value)?
        openSettingsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted() when started != null:
        return started(_that);
      case PermissionRequested() when requested != null:
        return requested(_that);
      case PermissionOpenSettingsRequested() when openSettingsRequested != null:
        return openSettingsRequested(_that);
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
    TResult Function()? requested,
    TResult Function()? openSettingsRequested,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted() when started != null:
        return started();
      case PermissionRequested() when requested != null:
        return requested();
      case PermissionOpenSettingsRequested() when openSettingsRequested != null:
        return openSettingsRequested();
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
    required TResult Function() requested,
    required TResult Function() openSettingsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted():
        return started();
      case PermissionRequested():
        return requested();
      case PermissionOpenSettingsRequested():
        return openSettingsRequested();
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
    TResult? Function()? requested,
    TResult? Function()? openSettingsRequested,
  }) {
    final _that = this;
    switch (_that) {
      case PermissionStarted() when started != null:
        return started();
      case PermissionRequested() when requested != null:
        return requested();
      case PermissionOpenSettingsRequested() when openSettingsRequested != null:
        return openSettingsRequested();
      case _:
        return null;
    }
  }
}

/// @nodoc

class PermissionStarted implements PermissionEvent {
  const PermissionStarted();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PermissionStarted);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PermissionEvent.started()';
  }
}

/// @nodoc

class PermissionRequested implements PermissionEvent {
  const PermissionRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is PermissionRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PermissionEvent.requested()';
  }
}

/// @nodoc

class PermissionOpenSettingsRequested implements PermissionEvent {
  const PermissionOpenSettingsRequested();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PermissionOpenSettingsRequested);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'PermissionEvent.openSettingsRequested()';
  }
}

/// @nodoc
mixin _$PermissionState {
  /// 권한 항목 목록
  List<PermissionItem> get permissionItems;

  /// 모든 권한이 허용되었는지 여부
  bool get allGranted;

  /// 현재 UI 상태
  PermissionUiState get uiState;

  /// 오류 메시지 (오류 상태일 때만 존재)
  String? get errorMessage;

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PermissionStateCopyWith<PermissionState> get copyWith =>
      _$PermissionStateCopyWithImpl<PermissionState>(
          this as PermissionState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PermissionState &&
            const DeepCollectionEquality()
                .equals(other.permissionItems, permissionItems) &&
            (identical(other.allGranted, allGranted) ||
                other.allGranted == allGranted) &&
            (identical(other.uiState, uiState) || other.uiState == uiState) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(permissionItems),
      allGranted,
      uiState,
      errorMessage);

  @override
  String toString() {
    return 'PermissionState(permissionItems: $permissionItems, allGranted: $allGranted, uiState: $uiState, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $PermissionStateCopyWith<$Res> {
  factory $PermissionStateCopyWith(
          PermissionState value, $Res Function(PermissionState) _then) =
      _$PermissionStateCopyWithImpl;
  @useResult
  $Res call(
      {List<PermissionItem> permissionItems,
      bool allGranted,
      PermissionUiState uiState,
      String? errorMessage});
}

/// @nodoc
class _$PermissionStateCopyWithImpl<$Res>
    implements $PermissionStateCopyWith<$Res> {
  _$PermissionStateCopyWithImpl(this._self, this._then);

  final PermissionState _self;
  final $Res Function(PermissionState) _then;

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
    return _then(_self.copyWith(
      permissionItems: null == permissionItems
          ? _self.permissionItems
          : permissionItems // ignore: cast_nullable_to_non_nullable
              as List<PermissionItem>,
      allGranted: null == allGranted
          ? _self.allGranted
          : allGranted // ignore: cast_nullable_to_non_nullable
              as bool,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as PermissionUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PermissionState].
extension PermissionStatePatterns on PermissionState {
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
    TResult Function(_PermissionState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PermissionState() when $default != null:
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
    TResult Function(_PermissionState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionState():
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
    TResult? Function(_PermissionState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionState() when $default != null:
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
    TResult Function(List<PermissionItem> permissionItems, bool allGranted,
            PermissionUiState uiState, String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PermissionState() when $default != null:
        return $default(_that.permissionItems, _that.allGranted, _that.uiState,
            _that.errorMessage);
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
    TResult Function(List<PermissionItem> permissionItems, bool allGranted,
            PermissionUiState uiState, String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionState():
        return $default(_that.permissionItems, _that.allGranted, _that.uiState,
            _that.errorMessage);
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
    TResult? Function(List<PermissionItem> permissionItems, bool allGranted,
            PermissionUiState uiState, String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PermissionState() when $default != null:
        return $default(_that.permissionItems, _that.allGranted, _that.uiState,
            _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PermissionState implements PermissionState {
  const _PermissionState(
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

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PermissionStateCopyWith<_PermissionState> get copyWith =>
      __$PermissionStateCopyWithImpl<_PermissionState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PermissionState &&
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

  @override
  String toString() {
    return 'PermissionState(permissionItems: $permissionItems, allGranted: $allGranted, uiState: $uiState, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$PermissionStateCopyWith<$Res>
    implements $PermissionStateCopyWith<$Res> {
  factory _$PermissionStateCopyWith(
          _PermissionState value, $Res Function(_PermissionState) _then) =
      __$PermissionStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PermissionItem> permissionItems,
      bool allGranted,
      PermissionUiState uiState,
      String? errorMessage});
}

/// @nodoc
class __$PermissionStateCopyWithImpl<$Res>
    implements _$PermissionStateCopyWith<$Res> {
  __$PermissionStateCopyWithImpl(this._self, this._then);

  final _PermissionState _self;
  final $Res Function(_PermissionState) _then;

  /// Create a copy of PermissionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? permissionItems = null,
    Object? allGranted = null,
    Object? uiState = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_PermissionState(
      permissionItems: null == permissionItems
          ? _self._permissionItems
          : permissionItems // ignore: cast_nullable_to_non_nullable
              as List<PermissionItem>,
      allGranted: null == allGranted
          ? _self.allGranted
          : allGranted // ignore: cast_nullable_to_non_nullable
              as bool,
      uiState: null == uiState
          ? _self.uiState
          : uiState // ignore: cast_nullable_to_non_nullable
              as PermissionUiState,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
