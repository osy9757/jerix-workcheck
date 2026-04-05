// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) {
  return _AttendanceModel.fromJson(json);
}

/// @nodoc
mixin _$AttendanceModel {
  int get id => throw _privateConstructorUsedError;

  /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
  String get type => throw _privateConstructorUsedError;

  /// ISO 8601 형식의 기록 시각 문자열
  String get timestamp => throw _privateConstructorUsedError;

  /// 인증 방식 이름
  @JsonKey(name: 'verification_method')
  String get verificationMethod => throw _privateConstructorUsedError;

  /// 인증 상세 데이터
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData =>
      throw _privateConstructorUsedError;

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
          AttendanceModel value, $Res Function(AttendanceModel) then) =
      _$AttendanceModelCopyWithImpl<$Res, AttendanceModel>;
  @useResult
  $Res call(
      {int id,
      String type,
      String timestamp,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res, $Val extends AttendanceModel>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? verificationMethod = null,
    Object? verificationData = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _value.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verificationData: null == verificationData
          ? _value.verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AttendanceModelImplCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$$AttendanceModelImplCopyWith(_$AttendanceModelImpl value,
          $Res Function(_$AttendanceModelImpl) then) =
      __$$AttendanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      String timestamp,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class __$$AttendanceModelImplCopyWithImpl<$Res>
    extends _$AttendanceModelCopyWithImpl<$Res, _$AttendanceModelImpl>
    implements _$$AttendanceModelImplCopyWith<$Res> {
  __$$AttendanceModelImplCopyWithImpl(
      _$AttendanceModelImpl _value, $Res Function(_$AttendanceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? verificationMethod = null,
    Object? verificationData = null,
  }) {
    return _then(_$AttendanceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _value.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verificationData: null == verificationData
          ? _value._verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AttendanceModelImpl extends _AttendanceModel {
  const _$AttendanceModelImpl(
      {required this.id,
      required this.type,
      required this.timestamp,
      @JsonKey(name: 'verification_method') required this.verificationMethod,
      @JsonKey(name: 'verification_data')
      required final Map<String, dynamic> verificationData})
      : _verificationData = verificationData,
        super._();

  factory _$AttendanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AttendanceModelImplFromJson(json);

  @override
  final int id;

  /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
  @override
  final String type;

  /// ISO 8601 형식의 기록 시각 문자열
  @override
  final String timestamp;

  /// 인증 방식 이름
  @override
  @JsonKey(name: 'verification_method')
  final String verificationMethod;

  /// 인증 상세 데이터
  final Map<String, dynamic> _verificationData;

  /// 인증 상세 데이터
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData {
    if (_verificationData is EqualUnmodifiableMapView) return _verificationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_verificationData);
  }

  @override
  String toString() {
    return 'AttendanceModel(id: $id, type: $type, timestamp: $timestamp, verificationMethod: $verificationMethod, verificationData: $verificationData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AttendanceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.verificationMethod, verificationMethod) ||
                other.verificationMethod == verificationMethod) &&
            const DeepCollectionEquality()
                .equals(other._verificationData, _verificationData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      timestamp,
      verificationMethod,
      const DeepCollectionEquality().hash(_verificationData));

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      __$$AttendanceModelImplCopyWithImpl<_$AttendanceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AttendanceModelImplToJson(
      this,
    );
  }
}

abstract class _AttendanceModel extends AttendanceModel {
  const factory _AttendanceModel(
          {required final int id,
          required final String type,
          required final String timestamp,
          @JsonKey(name: 'verification_method')
          required final String verificationMethod,
          @JsonKey(name: 'verification_data')
          required final Map<String, dynamic> verificationData}) =
      _$AttendanceModelImpl;
  const _AttendanceModel._() : super._();

  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =
      _$AttendanceModelImpl.fromJson;

  @override
  int get id;

  /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
  @override
  String get type;

  /// ISO 8601 형식의 기록 시각 문자열
  @override
  String get timestamp;

  /// 인증 방식 이름
  @override
  @JsonKey(name: 'verification_method')
  String get verificationMethod;

  /// 인증 상세 데이터
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AttendanceModelImplCopyWith<_$AttendanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodayStatusModel _$TodayStatusModelFromJson(Map<String, dynamic> json) {
  return _TodayStatusModel.fromJson(json);
}

/// @nodoc
mixin _$TodayStatusModel {
  /// 오늘 출근 기록 (없으면 null)
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn => throw _privateConstructorUsedError;

  /// 오늘 퇴근 기록 (없으면 null)
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut => throw _privateConstructorUsedError;

  /// Serializes this TodayStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodayStatusModelCopyWith<TodayStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodayStatusModelCopyWith<$Res> {
  factory $TodayStatusModelCopyWith(
          TodayStatusModel value, $Res Function(TodayStatusModel) then) =
      _$TodayStatusModelCopyWithImpl<$Res, TodayStatusModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  $AttendanceModelCopyWith<$Res>? get clockIn;
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class _$TodayStatusModelCopyWithImpl<$Res, $Val extends TodayStatusModel>
    implements $TodayStatusModelCopyWith<$Res> {
  _$TodayStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_value.copyWith(
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ) as $Val);
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_value.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_value.clockIn!, (value) {
      return _then(_value.copyWith(clockIn: value) as $Val);
    });
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_value.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_value.clockOut!, (value) {
      return _then(_value.copyWith(clockOut: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TodayStatusModelImplCopyWith<$Res>
    implements $TodayStatusModelCopyWith<$Res> {
  factory _$$TodayStatusModelImplCopyWith(_$TodayStatusModelImpl value,
          $Res Function(_$TodayStatusModelImpl) then) =
      __$$TodayStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  @override
  $AttendanceModelCopyWith<$Res>? get clockIn;
  @override
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class __$$TodayStatusModelImplCopyWithImpl<$Res>
    extends _$TodayStatusModelCopyWithImpl<$Res, _$TodayStatusModelImpl>
    implements _$$TodayStatusModelImplCopyWith<$Res> {
  __$$TodayStatusModelImplCopyWithImpl(_$TodayStatusModelImpl _value,
      $Res Function(_$TodayStatusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_$TodayStatusModelImpl(
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TodayStatusModelImpl extends _TodayStatusModel {
  const _$TodayStatusModelImpl(
      {@JsonKey(name: 'clock_in') this.clockIn,
      @JsonKey(name: 'clock_out') this.clockOut})
      : super._();

  factory _$TodayStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodayStatusModelImplFromJson(json);

  /// 오늘 출근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_in')
  final AttendanceModel? clockIn;

  /// 오늘 퇴근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_out')
  final AttendanceModel? clockOut;

  @override
  String toString() {
    return 'TodayStatusModel(clockIn: $clockIn, clockOut: $clockOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodayStatusModelImpl &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clockIn, clockOut);

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodayStatusModelImplCopyWith<_$TodayStatusModelImpl> get copyWith =>
      __$$TodayStatusModelImplCopyWithImpl<_$TodayStatusModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodayStatusModelImplToJson(
      this,
    );
  }
}

abstract class _TodayStatusModel extends TodayStatusModel {
  const factory _TodayStatusModel(
          {@JsonKey(name: 'clock_in') final AttendanceModel? clockIn,
          @JsonKey(name: 'clock_out') final AttendanceModel? clockOut}) =
      _$TodayStatusModelImpl;
  const _TodayStatusModel._() : super._();

  factory _TodayStatusModel.fromJson(Map<String, dynamic> json) =
      _$TodayStatusModelImpl.fromJson;

  /// 오늘 출근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn;

  /// 오늘 퇴근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodayStatusModelImplCopyWith<_$TodayStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterAttendanceRequest _$RegisterAttendanceRequestFromJson(
    Map<String, dynamic> json) {
  return _RegisterAttendanceRequest.fromJson(json);
}

/// @nodoc
mixin _$RegisterAttendanceRequest {
  /// 출퇴근 유형 (CLOCK_IN / CLOCK_OUT)
  String get type => throw _privateConstructorUsedError;

  /// 인증 방식 이름
  @JsonKey(name: 'verification_method')
  String get verificationMethod => throw _privateConstructorUsedError;

  /// 인증 상세 데이터
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData =>
      throw _privateConstructorUsedError;

  /// Serializes this RegisterAttendanceRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterAttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterAttendanceRequestCopyWith<RegisterAttendanceRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterAttendanceRequestCopyWith<$Res> {
  factory $RegisterAttendanceRequestCopyWith(RegisterAttendanceRequest value,
          $Res Function(RegisterAttendanceRequest) then) =
      _$RegisterAttendanceRequestCopyWithImpl<$Res, RegisterAttendanceRequest>;
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class _$RegisterAttendanceRequestCopyWithImpl<$Res,
        $Val extends RegisterAttendanceRequest>
    implements $RegisterAttendanceRequestCopyWith<$Res> {
  _$RegisterAttendanceRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterAttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? verificationMethod = null,
    Object? verificationData = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _value.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verificationData: null == verificationData
          ? _value.verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterAttendanceRequestImplCopyWith<$Res>
    implements $RegisterAttendanceRequestCopyWith<$Res> {
  factory _$$RegisterAttendanceRequestImplCopyWith(
          _$RegisterAttendanceRequestImpl value,
          $Res Function(_$RegisterAttendanceRequestImpl) then) =
      __$$RegisterAttendanceRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class __$$RegisterAttendanceRequestImplCopyWithImpl<$Res>
    extends _$RegisterAttendanceRequestCopyWithImpl<$Res,
        _$RegisterAttendanceRequestImpl>
    implements _$$RegisterAttendanceRequestImplCopyWith<$Res> {
  __$$RegisterAttendanceRequestImplCopyWithImpl(
      _$RegisterAttendanceRequestImpl _value,
      $Res Function(_$RegisterAttendanceRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterAttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? verificationMethod = null,
    Object? verificationData = null,
  }) {
    return _then(_$RegisterAttendanceRequestImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _value.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verificationData: null == verificationData
          ? _value._verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterAttendanceRequestImpl implements _RegisterAttendanceRequest {
  const _$RegisterAttendanceRequestImpl(
      {required this.type,
      @JsonKey(name: 'verification_method') required this.verificationMethod,
      @JsonKey(name: 'verification_data')
      required final Map<String, dynamic> verificationData})
      : _verificationData = verificationData;

  factory _$RegisterAttendanceRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterAttendanceRequestImplFromJson(json);

  /// 출퇴근 유형 (CLOCK_IN / CLOCK_OUT)
  @override
  final String type;

  /// 인증 방식 이름
  @override
  @JsonKey(name: 'verification_method')
  final String verificationMethod;

  /// 인증 상세 데이터
  final Map<String, dynamic> _verificationData;

  /// 인증 상세 데이터
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData {
    if (_verificationData is EqualUnmodifiableMapView) return _verificationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_verificationData);
  }

  @override
  String toString() {
    return 'RegisterAttendanceRequest(type: $type, verificationMethod: $verificationMethod, verificationData: $verificationData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterAttendanceRequestImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.verificationMethod, verificationMethod) ||
                other.verificationMethod == verificationMethod) &&
            const DeepCollectionEquality()
                .equals(other._verificationData, _verificationData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, verificationMethod,
      const DeepCollectionEquality().hash(_verificationData));

  /// Create a copy of RegisterAttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterAttendanceRequestImplCopyWith<_$RegisterAttendanceRequestImpl>
      get copyWith => __$$RegisterAttendanceRequestImplCopyWithImpl<
          _$RegisterAttendanceRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterAttendanceRequestImplToJson(
      this,
    );
  }
}

abstract class _RegisterAttendanceRequest implements RegisterAttendanceRequest {
  const factory _RegisterAttendanceRequest(
          {required final String type,
          @JsonKey(name: 'verification_method')
          required final String verificationMethod,
          @JsonKey(name: 'verification_data')
          required final Map<String, dynamic> verificationData}) =
      _$RegisterAttendanceRequestImpl;

  factory _RegisterAttendanceRequest.fromJson(Map<String, dynamic> json) =
      _$RegisterAttendanceRequestImpl.fromJson;

  /// 출퇴근 유형 (CLOCK_IN / CLOCK_OUT)
  @override
  String get type;

  /// 인증 방식 이름
  @override
  @JsonKey(name: 'verification_method')
  String get verificationMethod;

  /// 인증 상세 데이터
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData;

  /// Create a copy of RegisterAttendanceRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterAttendanceRequestImplCopyWith<_$RegisterAttendanceRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

HistoryModel _$HistoryModelFromJson(Map<String, dynamic> json) {
  return _HistoryModel.fromJson(json);
}

/// @nodoc
mixin _$HistoryModel {
  /// 일별 기록 목록
  List<DailyRecordModel> get records => throw _privateConstructorUsedError;

  /// 총 출근 일수
  int get total => throw _privateConstructorUsedError;

  /// Serializes this HistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryModelCopyWith<HistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryModelCopyWith<$Res> {
  factory $HistoryModelCopyWith(
          HistoryModel value, $Res Function(HistoryModel) then) =
      _$HistoryModelCopyWithImpl<$Res, HistoryModel>;
  @useResult
  $Res call({List<DailyRecordModel> records, int total});
}

/// @nodoc
class _$HistoryModelCopyWithImpl<$Res, $Val extends HistoryModel>
    implements $HistoryModelCopyWith<$Res> {
  _$HistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<DailyRecordModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryModelImplCopyWith<$Res>
    implements $HistoryModelCopyWith<$Res> {
  factory _$$HistoryModelImplCopyWith(
          _$HistoryModelImpl value, $Res Function(_$HistoryModelImpl) then) =
      __$$HistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<DailyRecordModel> records, int total});
}

/// @nodoc
class __$$HistoryModelImplCopyWithImpl<$Res>
    extends _$HistoryModelCopyWithImpl<$Res, _$HistoryModelImpl>
    implements _$$HistoryModelImplCopyWith<$Res> {
  __$$HistoryModelImplCopyWithImpl(
      _$HistoryModelImpl _value, $Res Function(_$HistoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_$HistoryModelImpl(
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<DailyRecordModel>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryModelImpl extends _HistoryModel {
  const _$HistoryModelImpl(
      {required final List<DailyRecordModel> records, required this.total})
      : _records = records,
        super._();

  factory _$HistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryModelImplFromJson(json);

  /// 일별 기록 목록
  final List<DailyRecordModel> _records;

  /// 일별 기록 목록
  @override
  List<DailyRecordModel> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  /// 총 출근 일수
  @override
  final int total;

  @override
  String toString() {
    return 'HistoryModel(records: $records, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryModelImpl &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_records), total);

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryModelImplCopyWith<_$HistoryModelImpl> get copyWith =>
      __$$HistoryModelImplCopyWithImpl<_$HistoryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryModelImplToJson(
      this,
    );
  }
}

abstract class _HistoryModel extends HistoryModel {
  const factory _HistoryModel(
      {required final List<DailyRecordModel> records,
      required final int total}) = _$HistoryModelImpl;
  const _HistoryModel._() : super._();

  factory _HistoryModel.fromJson(Map<String, dynamic> json) =
      _$HistoryModelImpl.fromJson;

  /// 일별 기록 목록
  @override
  List<DailyRecordModel> get records;

  /// 총 출근 일수
  @override
  int get total;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryModelImplCopyWith<_$HistoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyRecordModel _$DailyRecordModelFromJson(Map<String, dynamic> json) {
  return _DailyRecordModel.fromJson(json);
}

/// @nodoc
mixin _$DailyRecordModel {
  /// 날짜 문자열 (yyyy-MM-dd 형식)
  String get date => throw _privateConstructorUsedError;

  /// 해당일 출근 기록
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn => throw _privateConstructorUsedError;

  /// 해당일 퇴근 기록
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut => throw _privateConstructorUsedError;

  /// Serializes this DailyRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyRecordModelCopyWith<DailyRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyRecordModelCopyWith<$Res> {
  factory $DailyRecordModelCopyWith(
          DailyRecordModel value, $Res Function(DailyRecordModel) then) =
      _$DailyRecordModelCopyWithImpl<$Res, DailyRecordModel>;
  @useResult
  $Res call(
      {String date,
      @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  $AttendanceModelCopyWith<$Res>? get clockIn;
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class _$DailyRecordModelCopyWithImpl<$Res, $Val extends DailyRecordModel>
    implements $DailyRecordModelCopyWith<$Res> {
  _$DailyRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ) as $Val);
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_value.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_value.clockIn!, (value) {
      return _then(_value.copyWith(clockIn: value) as $Val);
    });
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_value.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_value.clockOut!, (value) {
      return _then(_value.copyWith(clockOut: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyRecordModelImplCopyWith<$Res>
    implements $DailyRecordModelCopyWith<$Res> {
  factory _$$DailyRecordModelImplCopyWith(_$DailyRecordModelImpl value,
          $Res Function(_$DailyRecordModelImpl) then) =
      __$$DailyRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String date,
      @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  @override
  $AttendanceModelCopyWith<$Res>? get clockIn;
  @override
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class __$$DailyRecordModelImplCopyWithImpl<$Res>
    extends _$DailyRecordModelCopyWithImpl<$Res, _$DailyRecordModelImpl>
    implements _$$DailyRecordModelImplCopyWith<$Res> {
  __$$DailyRecordModelImplCopyWithImpl(_$DailyRecordModelImpl _value,
      $Res Function(_$DailyRecordModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_$DailyRecordModelImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      clockIn: freezed == clockIn
          ? _value.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _value.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyRecordModelImpl extends _DailyRecordModel {
  const _$DailyRecordModelImpl(
      {required this.date,
      @JsonKey(name: 'clock_in') this.clockIn,
      @JsonKey(name: 'clock_out') this.clockOut})
      : super._();

  factory _$DailyRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyRecordModelImplFromJson(json);

  /// 날짜 문자열 (yyyy-MM-dd 형식)
  @override
  final String date;

  /// 해당일 출근 기록
  @override
  @JsonKey(name: 'clock_in')
  final AttendanceModel? clockIn;

  /// 해당일 퇴근 기록
  @override
  @JsonKey(name: 'clock_out')
  final AttendanceModel? clockOut;

  @override
  String toString() {
    return 'DailyRecordModel(date: $date, clockIn: $clockIn, clockOut: $clockOut)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyRecordModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, clockIn, clockOut);

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyRecordModelImplCopyWith<_$DailyRecordModelImpl> get copyWith =>
      __$$DailyRecordModelImplCopyWithImpl<_$DailyRecordModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyRecordModelImplToJson(
      this,
    );
  }
}

abstract class _DailyRecordModel extends DailyRecordModel {
  const factory _DailyRecordModel(
          {required final String date,
          @JsonKey(name: 'clock_in') final AttendanceModel? clockIn,
          @JsonKey(name: 'clock_out') final AttendanceModel? clockOut}) =
      _$DailyRecordModelImpl;
  const _DailyRecordModel._() : super._();

  factory _DailyRecordModel.fromJson(Map<String, dynamic> json) =
      _$DailyRecordModelImpl.fromJson;

  /// 날짜 문자열 (yyyy-MM-dd 형식)
  @override
  String get date;

  /// 해당일 출근 기록
  @override
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn;

  /// 해당일 퇴근 기록
  @override
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyRecordModelImplCopyWith<_$DailyRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
