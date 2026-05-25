// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceModel {
  int get id;

  /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
  String get type;

  /// ISO 8601 형식의 기록 시각 문자열
  String get timestamp;

  /// 대표 인증 방식 이름 (활성 method 중 첫 번째, 소문자)
  @JsonKey(name: 'verification_method')
  String get verificationMethod;

  /// AND 통과한 모든 method 키 (소문자). 누락 시 빈 배열.
  @JsonKey(name: 'verified_methods')
  List<String> get verifiedMethods;

  /// 인증 상세 데이터 (method 키 → 방식별 값 맵)
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      _$AttendanceModelCopyWithImpl<AttendanceModel>(
          this as AttendanceModel, _$identity);

  /// Serializes this AttendanceModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.verificationMethod, verificationMethod) ||
                other.verificationMethod == verificationMethod) &&
            const DeepCollectionEquality()
                .equals(other.verifiedMethods, verifiedMethods) &&
            const DeepCollectionEquality()
                .equals(other.verificationData, verificationData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      timestamp,
      verificationMethod,
      const DeepCollectionEquality().hash(verifiedMethods),
      const DeepCollectionEquality().hash(verificationData));

  @override
  String toString() {
    return 'AttendanceModel(id: $id, type: $type, timestamp: $timestamp, verificationMethod: $verificationMethod, verifiedMethods: $verifiedMethods, verificationData: $verificationData)';
  }
}

/// @nodoc
abstract mixin class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
          AttendanceModel value, $Res Function(AttendanceModel) _then) =
      _$AttendanceModelCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String type,
      String timestamp,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verified_methods') List<String> verifiedMethods,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class _$AttendanceModelCopyWithImpl<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._self, this._then);

  final AttendanceModel _self;
  final $Res Function(AttendanceModel) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? verificationMethod = null,
    Object? verifiedMethods = null,
    Object? verificationData = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _self.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedMethods: null == verifiedMethods
          ? _self.verifiedMethods
          : verifiedMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      verificationData: null == verificationData
          ? _self.verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceModel].
extension AttendanceModelPatterns on AttendanceModel {
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
    TResult Function(_AttendanceModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
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
    TResult Function(_AttendanceModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel():
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
    TResult? Function(_AttendanceModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
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
            int id,
            String type,
            String timestamp,
            @JsonKey(name: 'verification_method') String verificationMethod,
            @JsonKey(name: 'verified_methods') List<String> verifiedMethods,
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.timestamp,
            _that.verificationMethod,
            _that.verifiedMethods,
            _that.verificationData);
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
            int id,
            String type,
            String timestamp,
            @JsonKey(name: 'verification_method') String verificationMethod,
            @JsonKey(name: 'verified_methods') List<String> verifiedMethods,
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel():
        return $default(
            _that.id,
            _that.type,
            _that.timestamp,
            _that.verificationMethod,
            _that.verifiedMethods,
            _that.verificationData);
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
            int id,
            String type,
            String timestamp,
            @JsonKey(name: 'verification_method') String verificationMethod,
            @JsonKey(name: 'verified_methods') List<String> verifiedMethods,
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceModel() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.timestamp,
            _that.verificationMethod,
            _that.verifiedMethods,
            _that.verificationData);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceModel extends AttendanceModel {
  const _AttendanceModel(
      {required this.id,
      required this.type,
      required this.timestamp,
      @JsonKey(name: 'verification_method') required this.verificationMethod,
      @JsonKey(name: 'verified_methods')
      final List<String> verifiedMethods = const [],
      @JsonKey(name: 'verification_data')
      required final Map<String, dynamic> verificationData})
      : _verifiedMethods = verifiedMethods,
        _verificationData = verificationData,
        super._();
  factory _AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  @override
  final int id;

  /// 출퇴근 유형 문자열 (CLOCK_IN / CLOCK_OUT)
  @override
  final String type;

  /// ISO 8601 형식의 기록 시각 문자열
  @override
  final String timestamp;

  /// 대표 인증 방식 이름 (활성 method 중 첫 번째, 소문자)
  @override
  @JsonKey(name: 'verification_method')
  final String verificationMethod;

  /// AND 통과한 모든 method 키 (소문자). 누락 시 빈 배열.
  final List<String> _verifiedMethods;

  /// AND 통과한 모든 method 키 (소문자). 누락 시 빈 배열.
  @override
  @JsonKey(name: 'verified_methods')
  List<String> get verifiedMethods {
    if (_verifiedMethods is EqualUnmodifiableListView) return _verifiedMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verifiedMethods);
  }

  /// 인증 상세 데이터 (method 키 → 방식별 값 맵)
  final Map<String, dynamic> _verificationData;

  /// 인증 상세 데이터 (method 키 → 방식별 값 맵)
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData {
    if (_verificationData is EqualUnmodifiableMapView) return _verificationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_verificationData);
  }

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceModelCopyWith<_AttendanceModel> get copyWith =>
      __$AttendanceModelCopyWithImpl<_AttendanceModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.verificationMethod, verificationMethod) ||
                other.verificationMethod == verificationMethod) &&
            const DeepCollectionEquality()
                .equals(other._verifiedMethods, _verifiedMethods) &&
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
      const DeepCollectionEquality().hash(_verifiedMethods),
      const DeepCollectionEquality().hash(_verificationData));

  @override
  String toString() {
    return 'AttendanceModel(id: $id, type: $type, timestamp: $timestamp, verificationMethod: $verificationMethod, verifiedMethods: $verifiedMethods, verificationData: $verificationData)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceModelCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$AttendanceModelCopyWith(
          _AttendanceModel value, $Res Function(_AttendanceModel) _then) =
      __$AttendanceModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      String timestamp,
      @JsonKey(name: 'verification_method') String verificationMethod,
      @JsonKey(name: 'verified_methods') List<String> verifiedMethods,
      @JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class __$AttendanceModelCopyWithImpl<$Res>
    implements _$AttendanceModelCopyWith<$Res> {
  __$AttendanceModelCopyWithImpl(this._self, this._then);

  final _AttendanceModel _self;
  final $Res Function(_AttendanceModel) _then;

  /// Create a copy of AttendanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? timestamp = null,
    Object? verificationMethod = null,
    Object? verifiedMethods = null,
    Object? verificationData = null,
  }) {
    return _then(_AttendanceModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
      verificationMethod: null == verificationMethod
          ? _self.verificationMethod
          : verificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      verifiedMethods: null == verifiedMethods
          ? _self._verifiedMethods
          : verifiedMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      verificationData: null == verificationData
          ? _self._verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$TodayStatusModel {
  /// 오늘 출근 기록 (없으면 null)
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn;

  /// 오늘 퇴근 기록 (없으면 null)
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TodayStatusModelCopyWith<TodayStatusModel> get copyWith =>
      _$TodayStatusModelCopyWithImpl<TodayStatusModel>(
          this as TodayStatusModel, _$identity);

  /// Serializes this TodayStatusModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TodayStatusModel &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clockIn, clockOut);

  @override
  String toString() {
    return 'TodayStatusModel(clockIn: $clockIn, clockOut: $clockOut)';
  }
}

/// @nodoc
abstract mixin class $TodayStatusModelCopyWith<$Res> {
  factory $TodayStatusModelCopyWith(
          TodayStatusModel value, $Res Function(TodayStatusModel) _then) =
      _$TodayStatusModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  $AttendanceModelCopyWith<$Res>? get clockIn;
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class _$TodayStatusModelCopyWithImpl<$Res>
    implements $TodayStatusModelCopyWith<$Res> {
  _$TodayStatusModelCopyWithImpl(this._self, this._then);

  final TodayStatusModel _self;
  final $Res Function(TodayStatusModel) _then;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_self.copyWith(
      clockIn: freezed == clockIn
          ? _self.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _self.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_self.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockIn!, (value) {
      return _then(_self.copyWith(clockIn: value));
    });
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_self.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockOut!, (value) {
      return _then(_self.copyWith(clockOut: value));
    });
  }
}

/// Adds pattern-matching-related methods to [TodayStatusModel].
extension TodayStatusModelPatterns on TodayStatusModel {
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
    TResult Function(_TodayStatusModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel() when $default != null:
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
    TResult Function(_TodayStatusModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel():
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
    TResult? Function(_TodayStatusModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel() when $default != null:
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
    TResult Function(@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel() when $default != null:
        return $default(_that.clockIn, _that.clockOut);
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
    TResult Function(@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel():
        return $default(_that.clockIn, _that.clockOut);
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
    TResult? Function(@JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TodayStatusModel() when $default != null:
        return $default(_that.clockIn, _that.clockOut);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TodayStatusModel extends TodayStatusModel {
  const _TodayStatusModel(
      {@JsonKey(name: 'clock_in') this.clockIn,
      @JsonKey(name: 'clock_out') this.clockOut})
      : super._();
  factory _TodayStatusModel.fromJson(Map<String, dynamic> json) =>
      _$TodayStatusModelFromJson(json);

  /// 오늘 출근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_in')
  final AttendanceModel? clockIn;

  /// 오늘 퇴근 기록 (없으면 null)
  @override
  @JsonKey(name: 'clock_out')
  final AttendanceModel? clockOut;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TodayStatusModelCopyWith<_TodayStatusModel> get copyWith =>
      __$TodayStatusModelCopyWithImpl<_TodayStatusModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TodayStatusModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TodayStatusModel &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, clockIn, clockOut);

  @override
  String toString() {
    return 'TodayStatusModel(clockIn: $clockIn, clockOut: $clockOut)';
  }
}

/// @nodoc
abstract mixin class _$TodayStatusModelCopyWith<$Res>
    implements $TodayStatusModelCopyWith<$Res> {
  factory _$TodayStatusModelCopyWith(
          _TodayStatusModel value, $Res Function(_TodayStatusModel) _then) =
      __$TodayStatusModelCopyWithImpl;
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
class __$TodayStatusModelCopyWithImpl<$Res>
    implements _$TodayStatusModelCopyWith<$Res> {
  __$TodayStatusModelCopyWithImpl(this._self, this._then);

  final _TodayStatusModel _self;
  final $Res Function(_TodayStatusModel) _then;

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_TodayStatusModel(
      clockIn: freezed == clockIn
          ? _self.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _self.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_self.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockIn!, (value) {
      return _then(_self.copyWith(clockIn: value));
    });
  }

  /// Create a copy of TodayStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_self.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockOut!, (value) {
      return _then(_self.copyWith(clockOut: value));
    });
  }
}

/// @nodoc
mixin _$AttendanceInitModel {
  /// 수집해야 할 method 키 목록 (소문자: gps/wifi/nfc/beacon/qr)
  @JsonKey(name: 'required_methods')
  List<String> get requiredMethods;

  /// method 키 → 서버 설정값 (예: gps.targets[].lat/lng/radius_m)
  Map<String, dynamic> get configs;

  /// Create a copy of AttendanceInitModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceInitModelCopyWith<AttendanceInitModel> get copyWith =>
      _$AttendanceInitModelCopyWithImpl<AttendanceInitModel>(
          this as AttendanceInitModel, _$identity);

  /// Serializes this AttendanceInitModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceInitModel &&
            const DeepCollectionEquality()
                .equals(other.requiredMethods, requiredMethods) &&
            const DeepCollectionEquality().equals(other.configs, configs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(requiredMethods),
      const DeepCollectionEquality().hash(configs));

  @override
  String toString() {
    return 'AttendanceInitModel(requiredMethods: $requiredMethods, configs: $configs)';
  }
}

/// @nodoc
abstract mixin class $AttendanceInitModelCopyWith<$Res> {
  factory $AttendanceInitModelCopyWith(
          AttendanceInitModel value, $Res Function(AttendanceInitModel) _then) =
      _$AttendanceInitModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'required_methods') List<String> requiredMethods,
      Map<String, dynamic> configs});
}

/// @nodoc
class _$AttendanceInitModelCopyWithImpl<$Res>
    implements $AttendanceInitModelCopyWith<$Res> {
  _$AttendanceInitModelCopyWithImpl(this._self, this._then);

  final AttendanceInitModel _self;
  final $Res Function(AttendanceInitModel) _then;

  /// Create a copy of AttendanceInitModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? requiredMethods = null,
    Object? configs = null,
  }) {
    return _then(_self.copyWith(
      requiredMethods: null == requiredMethods
          ? _self.requiredMethods
          : requiredMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      configs: null == configs
          ? _self.configs
          : configs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceInitModel].
extension AttendanceInitModelPatterns on AttendanceInitModel {
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
    TResult Function(_AttendanceInitModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel() when $default != null:
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
    TResult Function(_AttendanceInitModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel():
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
    TResult? Function(_AttendanceInitModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel() when $default != null:
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
            @JsonKey(name: 'required_methods') List<String> requiredMethods,
            Map<String, dynamic> configs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel() when $default != null:
        return $default(_that.requiredMethods, _that.configs);
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
            @JsonKey(name: 'required_methods') List<String> requiredMethods,
            Map<String, dynamic> configs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel():
        return $default(_that.requiredMethods, _that.configs);
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
            @JsonKey(name: 'required_methods') List<String> requiredMethods,
            Map<String, dynamic> configs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceInitModel() when $default != null:
        return $default(_that.requiredMethods, _that.configs);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceInitModel implements AttendanceInitModel {
  const _AttendanceInitModel(
      {@JsonKey(name: 'required_methods')
      final List<String> requiredMethods = const [],
      final Map<String, dynamic> configs = const {}})
      : _requiredMethods = requiredMethods,
        _configs = configs;
  factory _AttendanceInitModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceInitModelFromJson(json);

  /// 수집해야 할 method 키 목록 (소문자: gps/wifi/nfc/beacon/qr)
  final List<String> _requiredMethods;

  /// 수집해야 할 method 키 목록 (소문자: gps/wifi/nfc/beacon/qr)
  @override
  @JsonKey(name: 'required_methods')
  List<String> get requiredMethods {
    if (_requiredMethods is EqualUnmodifiableListView) return _requiredMethods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requiredMethods);
  }

  /// method 키 → 서버 설정값 (예: gps.targets[].lat/lng/radius_m)
  final Map<String, dynamic> _configs;

  /// method 키 → 서버 설정값 (예: gps.targets[].lat/lng/radius_m)
  @override
  @JsonKey()
  Map<String, dynamic> get configs {
    if (_configs is EqualUnmodifiableMapView) return _configs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_configs);
  }

  /// Create a copy of AttendanceInitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceInitModelCopyWith<_AttendanceInitModel> get copyWith =>
      __$AttendanceInitModelCopyWithImpl<_AttendanceInitModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceInitModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceInitModel &&
            const DeepCollectionEquality()
                .equals(other._requiredMethods, _requiredMethods) &&
            const DeepCollectionEquality().equals(other._configs, _configs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_requiredMethods),
      const DeepCollectionEquality().hash(_configs));

  @override
  String toString() {
    return 'AttendanceInitModel(requiredMethods: $requiredMethods, configs: $configs)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceInitModelCopyWith<$Res>
    implements $AttendanceInitModelCopyWith<$Res> {
  factory _$AttendanceInitModelCopyWith(_AttendanceInitModel value,
          $Res Function(_AttendanceInitModel) _then) =
      __$AttendanceInitModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'required_methods') List<String> requiredMethods,
      Map<String, dynamic> configs});
}

/// @nodoc
class __$AttendanceInitModelCopyWithImpl<$Res>
    implements _$AttendanceInitModelCopyWith<$Res> {
  __$AttendanceInitModelCopyWithImpl(this._self, this._then);

  final _AttendanceInitModel _self;
  final $Res Function(_AttendanceInitModel) _then;

  /// Create a copy of AttendanceInitModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? requiredMethods = null,
    Object? configs = null,
  }) {
    return _then(_AttendanceInitModel(
      requiredMethods: null == requiredMethods
          ? _self._requiredMethods
          : requiredMethods // ignore: cast_nullable_to_non_nullable
              as List<String>,
      configs: null == configs
          ? _self._configs
          : configs // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$AttendanceSubmitRequest {
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData;

  /// Create a copy of AttendanceSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceSubmitRequestCopyWith<AttendanceSubmitRequest> get copyWith =>
      _$AttendanceSubmitRequestCopyWithImpl<AttendanceSubmitRequest>(
          this as AttendanceSubmitRequest, _$identity);

  /// Serializes this AttendanceSubmitRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceSubmitRequest &&
            const DeepCollectionEquality()
                .equals(other.verificationData, verificationData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(verificationData));

  @override
  String toString() {
    return 'AttendanceSubmitRequest(verificationData: $verificationData)';
  }
}

/// @nodoc
abstract mixin class $AttendanceSubmitRequestCopyWith<$Res> {
  factory $AttendanceSubmitRequestCopyWith(AttendanceSubmitRequest value,
          $Res Function(AttendanceSubmitRequest) _then) =
      _$AttendanceSubmitRequestCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class _$AttendanceSubmitRequestCopyWithImpl<$Res>
    implements $AttendanceSubmitRequestCopyWith<$Res> {
  _$AttendanceSubmitRequestCopyWithImpl(this._self, this._then);

  final AttendanceSubmitRequest _self;
  final $Res Function(AttendanceSubmitRequest) _then;

  /// Create a copy of AttendanceSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? verificationData = null,
  }) {
    return _then(_self.copyWith(
      verificationData: null == verificationData
          ? _self.verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [AttendanceSubmitRequest].
extension AttendanceSubmitRequestPatterns on AttendanceSubmitRequest {
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
    TResult Function(_AttendanceSubmitRequest value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest() when $default != null:
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
    TResult Function(_AttendanceSubmitRequest value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest():
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
    TResult? Function(_AttendanceSubmitRequest value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest() when $default != null:
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
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest() when $default != null:
        return $default(_that.verificationData);
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
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest():
        return $default(_that.verificationData);
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
            @JsonKey(name: 'verification_data')
            Map<String, dynamic> verificationData)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AttendanceSubmitRequest() when $default != null:
        return $default(_that.verificationData);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceSubmitRequest implements AttendanceSubmitRequest {
  const _AttendanceSubmitRequest(
      {@JsonKey(name: 'verification_data')
      required final Map<String, dynamic> verificationData})
      : _verificationData = verificationData;
  factory _AttendanceSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSubmitRequestFromJson(json);

  final Map<String, dynamic> _verificationData;
  @override
  @JsonKey(name: 'verification_data')
  Map<String, dynamic> get verificationData {
    if (_verificationData is EqualUnmodifiableMapView) return _verificationData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_verificationData);
  }

  /// Create a copy of AttendanceSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceSubmitRequestCopyWith<_AttendanceSubmitRequest> get copyWith =>
      __$AttendanceSubmitRequestCopyWithImpl<_AttendanceSubmitRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceSubmitRequestToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceSubmitRequest &&
            const DeepCollectionEquality()
                .equals(other._verificationData, _verificationData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_verificationData));

  @override
  String toString() {
    return 'AttendanceSubmitRequest(verificationData: $verificationData)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceSubmitRequestCopyWith<$Res>
    implements $AttendanceSubmitRequestCopyWith<$Res> {
  factory _$AttendanceSubmitRequestCopyWith(_AttendanceSubmitRequest value,
          $Res Function(_AttendanceSubmitRequest) _then) =
      __$AttendanceSubmitRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'verification_data')
      Map<String, dynamic> verificationData});
}

/// @nodoc
class __$AttendanceSubmitRequestCopyWithImpl<$Res>
    implements _$AttendanceSubmitRequestCopyWith<$Res> {
  __$AttendanceSubmitRequestCopyWithImpl(this._self, this._then);

  final _AttendanceSubmitRequest _self;
  final $Res Function(_AttendanceSubmitRequest) _then;

  /// Create a copy of AttendanceSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? verificationData = null,
  }) {
    return _then(_AttendanceSubmitRequest(
      verificationData: null == verificationData
          ? _self._verificationData
          : verificationData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
mixin _$HistoryModel {
  /// 일별 기록 목록
  List<DailyRecordModel> get records;

  /// 총 출근 일수
  int get total;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryModelCopyWith<HistoryModel> get copyWith =>
      _$HistoryModelCopyWithImpl<HistoryModel>(
          this as HistoryModel, _$identity);

  /// Serializes this HistoryModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HistoryModel &&
            const DeepCollectionEquality().equals(other.records, records) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(records), total);

  @override
  String toString() {
    return 'HistoryModel(records: $records, total: $total)';
  }
}

/// @nodoc
abstract mixin class $HistoryModelCopyWith<$Res> {
  factory $HistoryModelCopyWith(
          HistoryModel value, $Res Function(HistoryModel) _then) =
      _$HistoryModelCopyWithImpl;
  @useResult
  $Res call({List<DailyRecordModel> records, int total});
}

/// @nodoc
class _$HistoryModelCopyWithImpl<$Res> implements $HistoryModelCopyWith<$Res> {
  _$HistoryModelCopyWithImpl(this._self, this._then);

  final HistoryModel _self;
  final $Res Function(HistoryModel) _then;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_self.copyWith(
      records: null == records
          ? _self.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<DailyRecordModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [HistoryModel].
extension HistoryModelPatterns on HistoryModel {
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
    TResult Function(_HistoryModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HistoryModel() when $default != null:
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
    TResult Function(_HistoryModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryModel():
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
    TResult? Function(_HistoryModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryModel() when $default != null:
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
    TResult Function(List<DailyRecordModel> records, int total)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HistoryModel() when $default != null:
        return $default(_that.records, _that.total);
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
    TResult Function(List<DailyRecordModel> records, int total) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryModel():
        return $default(_that.records, _that.total);
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
    TResult? Function(List<DailyRecordModel> records, int total)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HistoryModel() when $default != null:
        return $default(_that.records, _that.total);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HistoryModel extends HistoryModel {
  const _HistoryModel(
      {required final List<DailyRecordModel> records, required this.total})
      : _records = records,
        super._();
  factory _HistoryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryModelFromJson(json);

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

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HistoryModelCopyWith<_HistoryModel> get copyWith =>
      __$HistoryModelCopyWithImpl<_HistoryModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HistoryModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HistoryModel &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_records), total);

  @override
  String toString() {
    return 'HistoryModel(records: $records, total: $total)';
  }
}

/// @nodoc
abstract mixin class _$HistoryModelCopyWith<$Res>
    implements $HistoryModelCopyWith<$Res> {
  factory _$HistoryModelCopyWith(
          _HistoryModel value, $Res Function(_HistoryModel) _then) =
      __$HistoryModelCopyWithImpl;
  @override
  @useResult
  $Res call({List<DailyRecordModel> records, int total});
}

/// @nodoc
class __$HistoryModelCopyWithImpl<$Res>
    implements _$HistoryModelCopyWith<$Res> {
  __$HistoryModelCopyWithImpl(this._self, this._then);

  final _HistoryModel _self;
  final $Res Function(_HistoryModel) _then;

  /// Create a copy of HistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? records = null,
    Object? total = null,
  }) {
    return _then(_HistoryModel(
      records: null == records
          ? _self._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<DailyRecordModel>,
      total: null == total
          ? _self.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$DailyRecordModel {
  /// 날짜 문자열 (yyyy-MM-dd 형식)
  String get date;

  /// 해당일 출근 기록
  @JsonKey(name: 'clock_in')
  AttendanceModel? get clockIn;

  /// 해당일 퇴근 기록
  @JsonKey(name: 'clock_out')
  AttendanceModel? get clockOut;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DailyRecordModelCopyWith<DailyRecordModel> get copyWith =>
      _$DailyRecordModelCopyWithImpl<DailyRecordModel>(
          this as DailyRecordModel, _$identity);

  /// Serializes this DailyRecordModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DailyRecordModel &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, clockIn, clockOut);

  @override
  String toString() {
    return 'DailyRecordModel(date: $date, clockIn: $clockIn, clockOut: $clockOut)';
  }
}

/// @nodoc
abstract mixin class $DailyRecordModelCopyWith<$Res> {
  factory $DailyRecordModelCopyWith(
          DailyRecordModel value, $Res Function(DailyRecordModel) _then) =
      _$DailyRecordModelCopyWithImpl;
  @useResult
  $Res call(
      {String date,
      @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
      @JsonKey(name: 'clock_out') AttendanceModel? clockOut});

  $AttendanceModelCopyWith<$Res>? get clockIn;
  $AttendanceModelCopyWith<$Res>? get clockOut;
}

/// @nodoc
class _$DailyRecordModelCopyWithImpl<$Res>
    implements $DailyRecordModelCopyWith<$Res> {
  _$DailyRecordModelCopyWithImpl(this._self, this._then);

  final DailyRecordModel _self;
  final $Res Function(DailyRecordModel) _then;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_self.copyWith(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      clockIn: freezed == clockIn
          ? _self.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _self.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_self.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockIn!, (value) {
      return _then(_self.copyWith(clockIn: value));
    });
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_self.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockOut!, (value) {
      return _then(_self.copyWith(clockOut: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DailyRecordModel].
extension DailyRecordModelPatterns on DailyRecordModel {
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
    TResult Function(_DailyRecordModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel() when $default != null:
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
    TResult Function(_DailyRecordModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel():
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
    TResult? Function(_DailyRecordModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel() when $default != null:
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
            String date,
            @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel() when $default != null:
        return $default(_that.date, _that.clockIn, _that.clockOut);
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
            String date,
            @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel():
        return $default(_that.date, _that.clockIn, _that.clockOut);
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
            String date,
            @JsonKey(name: 'clock_in') AttendanceModel? clockIn,
            @JsonKey(name: 'clock_out') AttendanceModel? clockOut)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyRecordModel() when $default != null:
        return $default(_that.date, _that.clockIn, _that.clockOut);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DailyRecordModel extends DailyRecordModel {
  const _DailyRecordModel(
      {required this.date,
      @JsonKey(name: 'clock_in') this.clockIn,
      @JsonKey(name: 'clock_out') this.clockOut})
      : super._();
  factory _DailyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordModelFromJson(json);

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

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DailyRecordModelCopyWith<_DailyRecordModel> get copyWith =>
      __$DailyRecordModelCopyWithImpl<_DailyRecordModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DailyRecordModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DailyRecordModel &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.clockIn, clockIn) || other.clockIn == clockIn) &&
            (identical(other.clockOut, clockOut) ||
                other.clockOut == clockOut));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, clockIn, clockOut);

  @override
  String toString() {
    return 'DailyRecordModel(date: $date, clockIn: $clockIn, clockOut: $clockOut)';
  }
}

/// @nodoc
abstract mixin class _$DailyRecordModelCopyWith<$Res>
    implements $DailyRecordModelCopyWith<$Res> {
  factory _$DailyRecordModelCopyWith(
          _DailyRecordModel value, $Res Function(_DailyRecordModel) _then) =
      __$DailyRecordModelCopyWithImpl;
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
class __$DailyRecordModelCopyWithImpl<$Res>
    implements _$DailyRecordModelCopyWith<$Res> {
  __$DailyRecordModelCopyWithImpl(this._self, this._then);

  final _DailyRecordModel _self;
  final $Res Function(_DailyRecordModel) _then;

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? clockIn = freezed,
    Object? clockOut = freezed,
  }) {
    return _then(_DailyRecordModel(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      clockIn: freezed == clockIn
          ? _self.clockIn
          : clockIn // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
      clockOut: freezed == clockOut
          ? _self.clockOut
          : clockOut // ignore: cast_nullable_to_non_nullable
              as AttendanceModel?,
    ));
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockIn {
    if (_self.clockIn == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockIn!, (value) {
      return _then(_self.copyWith(clockIn: value));
    });
  }

  /// Create a copy of DailyRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<$Res>? get clockOut {
    if (_self.clockOut == null) {
      return null;
    }

    return $AttendanceModelCopyWith<$Res>(_self.clockOut!, (value) {
      return _then(_self.copyWith(clockOut: value));
    });
  }
}

// dart format on
