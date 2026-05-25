// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VerificationResult {
  /// 어떤 방식으로 인증했는지 (gps, qr, bluetooth 등)
  VerificationMethod get method;

  /// 인증 성공 여부
  bool get isVerified;

  /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
  Map<String, dynamic> get data;

  /// 인증 실패 시 사유 메시지 (성공 시 null)
  String? get errorMessage;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VerificationResultCopyWith<VerificationResult> get copyWith =>
      _$VerificationResultCopyWithImpl<VerificationResult>(
          this as VerificationResult, _$identity);

  /// Serializes this VerificationResult to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VerificationResult &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, method, isVerified,
      const DeepCollectionEquality().hash(data), errorMessage);

  @override
  String toString() {
    return 'VerificationResult(method: $method, isVerified: $isVerified, data: $data, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $VerificationResultCopyWith<$Res> {
  factory $VerificationResultCopyWith(
          VerificationResult value, $Res Function(VerificationResult) _then) =
      _$VerificationResultCopyWithImpl;
  @useResult
  $Res call(
      {VerificationMethod method,
      bool isVerified,
      Map<String, dynamic> data,
      String? errorMessage});
}

/// @nodoc
class _$VerificationResultCopyWithImpl<$Res>
    implements $VerificationResultCopyWith<$Res> {
  _$VerificationResultCopyWithImpl(this._self, this._then);

  final VerificationResult _self;
  final $Res Function(VerificationResult) _then;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? method = null,
    Object? isVerified = null,
    Object? data = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as VerificationMethod,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [VerificationResult].
extension VerificationResultPatterns on VerificationResult {
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
    TResult Function(_VerificationResult value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VerificationResult() when $default != null:
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
    TResult Function(_VerificationResult value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VerificationResult():
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
    TResult? Function(_VerificationResult value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VerificationResult() when $default != null:
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
    TResult Function(VerificationMethod method, bool isVerified,
            Map<String, dynamic> data, String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VerificationResult() when $default != null:
        return $default(
            _that.method, _that.isVerified, _that.data, _that.errorMessage);
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
    TResult Function(VerificationMethod method, bool isVerified,
            Map<String, dynamic> data, String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VerificationResult():
        return $default(
            _that.method, _that.isVerified, _that.data, _that.errorMessage);
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
    TResult? Function(VerificationMethod method, bool isVerified,
            Map<String, dynamic> data, String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VerificationResult() when $default != null:
        return $default(
            _that.method, _that.isVerified, _that.data, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _VerificationResult implements VerificationResult {
  const _VerificationResult(
      {required this.method,
      required this.isVerified,
      required final Map<String, dynamic> data,
      this.errorMessage})
      : _data = data;
  factory _VerificationResult.fromJson(Map<String, dynamic> json) =>
      _$VerificationResultFromJson(json);

  /// 어떤 방식으로 인증했는지 (gps, qr, bluetooth 등)
  @override
  final VerificationMethod method;

  /// 인증 성공 여부
  @override
  final bool isVerified;

  /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
  final Map<String, dynamic> _data;

  /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  /// 인증 실패 시 사유 메시지 (성공 시 null)
  @override
  final String? errorMessage;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VerificationResultCopyWith<_VerificationResult> get copyWith =>
      __$VerificationResultCopyWithImpl<_VerificationResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VerificationResultToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VerificationResult &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, method, isVerified,
      const DeepCollectionEquality().hash(_data), errorMessage);

  @override
  String toString() {
    return 'VerificationResult(method: $method, isVerified: $isVerified, data: $data, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$VerificationResultCopyWith<$Res>
    implements $VerificationResultCopyWith<$Res> {
  factory _$VerificationResultCopyWith(
          _VerificationResult value, $Res Function(_VerificationResult) _then) =
      __$VerificationResultCopyWithImpl;
  @override
  @useResult
  $Res call(
      {VerificationMethod method,
      bool isVerified,
      Map<String, dynamic> data,
      String? errorMessage});
}

/// @nodoc
class __$VerificationResultCopyWithImpl<$Res>
    implements _$VerificationResultCopyWith<$Res> {
  __$VerificationResultCopyWithImpl(this._self, this._then);

  final _VerificationResult _self;
  final $Res Function(_VerificationResult) _then;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? method = null,
    Object? isVerified = null,
    Object? data = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_VerificationResult(
      method: null == method
          ? _self.method
          : method // ignore: cast_nullable_to_non_nullable
              as VerificationMethod,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
