// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    _AttendanceModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      verificationMethod: json['verification_method'] as String,
      verifiedMethods: (json['verified_methods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      verificationData: json['verification_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AttendanceModelToJson(_AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'verification_method': instance.verificationMethod,
      'verified_methods': instance.verifiedMethods,
      'verification_data': instance.verificationData,
    };

_TodayStatusModel _$TodayStatusModelFromJson(Map<String, dynamic> json) =>
    _TodayStatusModel(
      clockIn: json['clock_in'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_in'] as Map<String, dynamic>),
      clockOut: json['clock_out'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_out'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TodayStatusModelToJson(_TodayStatusModel instance) =>
    <String, dynamic>{
      'clock_in': instance.clockIn,
      'clock_out': instance.clockOut,
    };

_AttendanceInitModel _$AttendanceInitModelFromJson(Map<String, dynamic> json) =>
    _AttendanceInitModel(
      requiredMethods: (json['required_methods'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      configs: json['configs'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AttendanceInitModelToJson(
        _AttendanceInitModel instance) =>
    <String, dynamic>{
      'required_methods': instance.requiredMethods,
      'configs': instance.configs,
    };

_AttendanceSubmitRequest _$AttendanceSubmitRequestFromJson(
        Map<String, dynamic> json) =>
    _AttendanceSubmitRequest(
      verificationData: json['verification_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AttendanceSubmitRequestToJson(
        _AttendanceSubmitRequest instance) =>
    <String, dynamic>{
      'verification_data': instance.verificationData,
    };

_HistoryModel _$HistoryModelFromJson(Map<String, dynamic> json) =>
    _HistoryModel(
      records: (json['records'] as List<dynamic>)
          .map((e) => DailyRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$HistoryModelToJson(_HistoryModel instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
    };

_DailyRecordModel _$DailyRecordModelFromJson(Map<String, dynamic> json) =>
    _DailyRecordModel(
      date: json['date'] as String,
      clockIn: json['clock_in'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_in'] as Map<String, dynamic>),
      clockOut: json['clock_out'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_out'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyRecordModelToJson(_DailyRecordModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'clock_in': instance.clockIn,
      'clock_out': instance.clockOut,
    };
