import 'package:equatable/equatable.dart';

import '../../../verification/domain/verification_method.dart';
import 'attendance_type.dart';

/// 출퇴근 기록 엔티티 (도메인 레이어)
class AttendanceEntity extends Equatable {
  /// 기록 고유 ID
  final int id;

  /// 출근 또는 퇴근 유형
  final AttendanceType type;

  /// 기록 시각
  final DateTime timestamp;

  /// 사용된 인증 방식
  final VerificationMethod verificationMethod;

  /// 인증 상세 데이터 (GPS 좌표, WiFi SSID 등 방식별 데이터)
  final Map<String, dynamic> verificationData;

  const AttendanceEntity({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.verificationMethod,
    required this.verificationData,
  });

  @override
  List<Object?> get props => [id, type, timestamp, verificationMethod];
}
