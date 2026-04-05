// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VerificationResult _$VerificationResultFromJson(Map<String, dynamic> json) {
  return _VerificationResult.fromJson(json);
}

/// @nodoc
mixin _$VerificationResult {
  /// 어떤 방식으로 인증했는지 (gps, qr, bluetooth 등)
  VerificationMethod get method => throw _privateConstructorUsedError;

  /// 인증 성공 여부
  bool get isVerified => throw _privateConstructorUsedError;

  /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
  Map<String, dynamic> get data => throw _privateConstructorUsedError;

  /// 인증 실패 시 사유 메시지 (성공 시 null)
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this VerificationResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerificationResultCopyWith<VerificationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerificationResultCopyWith<$Res> {
  factory $VerificationResultCopyWith(
          VerificationResult value, $Res Function(VerificationResult) then) =
      _$VerificationResultCopyWithImpl<$Res, VerificationResult>;
  @useResult
  $Res call(
      {VerificationMethod method,
      bool isVerified,
      Map<String, dynamic> data,
      String? errorMessage});
}

/// @nodoc
class _$VerificationResultCopyWithImpl<$Res, $Val extends VerificationResult>
    implements $VerificationResultCopyWith<$Res> {
  _$VerificationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as VerificationMethod,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerificationResultImplCopyWith<$Res>
    implements $VerificationResultCopyWith<$Res> {
  factory _$$VerificationResultImplCopyWith(_$VerificationResultImpl value,
          $Res Function(_$VerificationResultImpl) then) =
      __$$VerificationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {VerificationMethod method,
      bool isVerified,
      Map<String, dynamic> data,
      String? errorMessage});
}

/// @nodoc
class __$$VerificationResultImplCopyWithImpl<$Res>
    extends _$VerificationResultCopyWithImpl<$Res, _$VerificationResultImpl>
    implements _$$VerificationResultImplCopyWith<$Res> {
  __$$VerificationResultImplCopyWithImpl(_$VerificationResultImpl _value,
      $Res Function(_$VerificationResultImpl) _then)
      : super(_value, _then);

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
    return _then(_$VerificationResultImpl(
      method: null == method
          ? _value.method
          : method // ignore: cast_nullable_to_non_nullable
              as VerificationMethod,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerificationResultImpl implements _VerificationResult {
  const _$VerificationResultImpl(
      {required this.method,
      required this.isVerified,
      required final Map<String, dynamic> data,
      this.errorMessage})
      : _data = data;

  factory _$VerificationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerificationResultImplFromJson(json);

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

  @override
  String toString() {
    return 'VerificationResult(method: $method, isVerified: $isVerified, data: $data, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerificationResultImpl &&
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

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerificationResultImplCopyWith<_$VerificationResultImpl> get copyWith =>
      __$$VerificationResultImplCopyWithImpl<_$VerificationResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerificationResultImplToJson(
      this,
    );
  }
}

abstract class _VerificationResult implements VerificationResult {
  const factory _VerificationResult(
      {required final VerificationMethod method,
      required final bool isVerified,
      required final Map<String, dynamic> data,
      final String? errorMessage}) = _$VerificationResultImpl;

  factory _VerificationResult.fromJson(Map<String, dynamic> json) =
      _$VerificationResultImpl.fromJson;

  /// 어떤 방식으로 인증했는지 (gps, qr, bluetooth 등)
  @override
  VerificationMethod get method;

  /// 인증 성공 여부
  @override
  bool get isVerified;

  /// 인증 과정에서 수집된 데이터 (위도/경도, SSID, QR 값 등)
  @override
  Map<String, dynamic> get data;

  /// 인증 실패 시 사유 메시지 (성공 시 null)
  @override
  String? get errorMessage;

  /// Create a copy of VerificationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerificationResultImplCopyWith<_$VerificationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
