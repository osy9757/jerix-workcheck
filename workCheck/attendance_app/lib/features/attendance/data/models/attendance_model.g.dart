// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceModelImpl _$$AttendanceModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceModelImpl(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      verificationMethod: json['verification_method'] as String,
      verificationData: json['verification_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$AttendanceModelImplToJson(
        _$AttendanceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'verification_method': instance.verificationMethod,
      'verification_data': instance.verificationData,
    };

_$TodayStatusModelImpl _$$TodayStatusModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TodayStatusModelImpl(
      clockIn: json['clock_in'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_in'] as Map<String, dynamic>),
      clockOut: json['clock_out'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_out'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TodayStatusModelImplToJson(
        _$TodayStatusModelImpl instance) =>
    <String, dynamic>{
      'clock_in': instance.clockIn,
      'clock_out': instance.clockOut,
    };

_$RegisterAttendanceRequestImpl _$$RegisterAttendanceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterAttendanceRequestImpl(
      type: json['type'] as String,
      verificationMethod: json['verification_method'] as String,
      verificationData: json['verification_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$RegisterAttendanceRequestImplToJson(
        _$RegisterAttendanceRequestImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'verification_method': instance.verificationMethod,
      'verification_data': instance.verificationData,
    };

_$HistoryModelImpl _$$HistoryModelImplFromJson(Map<String, dynamic> json) =>
    _$HistoryModelImpl(
      records: (json['records'] as List<dynamic>)
          .map((e) => DailyRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$$HistoryModelImplToJson(_$HistoryModelImpl instance) =>
    <String, dynamic>{
      'records': instance.records,
      'total': instance.total,
    };

_$DailyRecordModelImpl _$$DailyRecordModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyRecordModelImpl(
      date: json['date'] as String,
      clockIn: json['clock_in'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_in'] as Map<String, dynamic>),
      clockOut: json['clock_out'] == null
          ? null
          : AttendanceModel.fromJson(json['clock_out'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DailyRecordModelImplToJson(
        _$DailyRecordModelImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'clock_in': instance.clockIn,
      'clock_out': instance.clockOut,
    };
