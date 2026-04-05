/// 관리자 웹 모델 클래스

/// 근무지 모델
class Workplace {
  final int id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String createdAt;

  Workplace({
    required this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  /// JSON으로부터 근무지 객체 생성
  factory Workplace.fromJson(Map<String, dynamic> json) {
    return Workplace(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// 유저별 인증 오버라이드 설정 모델
class UserVerificationOverride {
  final int id;
  final int userId;
  final String methodType;
  final bool isEnabled;
  final Map<String, dynamic> config;

  UserVerificationOverride({
    required this.id,
    required this.userId,
    required this.methodType,
    required this.isEnabled,
    required this.config,
  });

  factory UserVerificationOverride.fromJson(Map<String, dynamic> json) {
    return UserVerificationOverride(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      methodType: json['method_type'] as String,
      isEnabled: json['is_enabled'] as bool,
      config: Map<String, dynamic>.from(json['config'] ?? json['config_data'] ?? {}),
    );
  }
}

/// 관리자 로그인 응답 모델 (JWT 토큰 + 관리자 정보)
class AdminLoginResponse {
  final String token;
  final AdminInfo admin;

  AdminLoginResponse({required this.token, required this.admin});

  factory AdminLoginResponse.fromJson(Map<String, dynamic> json) {
    return AdminLoginResponse(
      token: json['token'] as String,
      admin: AdminInfo.fromJson(json['admin'] as Map<String, dynamic>),
    );
  }
}

/// 관리자 정보
class AdminInfo {
  final int id;
  final String username;

  AdminInfo({required this.id, required this.username});

  factory AdminInfo.fromJson(Map<String, dynamic> json) {
    return AdminInfo(
      id: json['id'] as int,
      username: json['username'] as String,
    );
  }
}

/// 인증 방법 모델 (8가지 인증 타입별 설정 포함)
class VerificationMethod {
  final int? id;
  final String methodType;
  final bool enabled;
  final Map<String, dynamic> config;
  final bool? isOverridden;

  VerificationMethod({
    this.id,
    required this.methodType,
    required this.enabled,
    required this.config,
    this.isOverridden,
  });

  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    return VerificationMethod(
      id: json['id'] as int?,
      methodType: json['method_type'] as String,
      enabled: json['enabled'] as bool,
      config: Map<String, dynamic>.from((json['config'] ?? json['config_data'] ?? {}) as Map),
      isOverridden: json['is_overridden'] as bool?,
    );
  }

  /// 방법 타입의 한글 이름
  String get displayName {
    switch (methodType) {
      case 'GPS':
        return 'GPS';
      case 'GPS_QR':
        return 'GPS + QR';
      case 'WIFI':
        return 'WiFi';
      case 'WIFI_QR':
        return 'WiFi + QR';
      case 'NFC':
        return 'NFC';
      case 'NFC_GPS':
        return 'NFC + GPS';
      case 'BEACON':
        return 'Beacon';
      case 'BEACON_GPS':
        return 'Beacon + GPS';
      default:
        return methodType;
    }
  }

  /// 방법 타입의 아이콘
  String get iconName {
    switch (methodType) {
      case 'GPS':
      case 'GPS_QR':
        return 'location_on';
      case 'WIFI':
      case 'WIFI_QR':
        return 'wifi';
      case 'NFC':
      case 'NFC_GPS':
        return 'nfc';
      case 'BEACON':
      case 'BEACON_GPS':
        return 'bluetooth';
      default:
        return 'settings';
    }
  }
}

/// 출퇴근 기록 모델 (날짜별 출근/퇴근 엔트리 + 직원 정보)
class AttendanceRecord {
  final String date;
  final String? employeeId; // 사원 번호
  final String? employeeName; // 직원 이름
  final AttendanceEntry? clockIn;
  final AttendanceEntry? clockOut;

  AttendanceRecord({
    required this.date,
    this.employeeId,
    this.employeeName,
    this.clockIn,
    this.clockOut,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'] as String,
      employeeId: json['employee_id'] as String?,
      employeeName: json['employee_name'] as String?,
      clockIn: json['clock_in'] != null
          ? AttendanceEntry.fromJson(json['clock_in'] as Map<String, dynamic>)
          : null,
      clockOut: json['clock_out'] != null
          ? AttendanceEntry.fromJson(json['clock_out'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 출퇴근 엔트리 (출근 또는 퇴근 단일 기록)
class AttendanceEntry {
  final int id;
  final String type;
  final String timestamp;
  final String verificationMethod;

  AttendanceEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.verificationMethod,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      id: json['id'] as int,
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      verificationMethod: json['verification_method'] as String,
    );
  }
}

/// 직원 모델 (회사코드, 사원번호, 근무지 정보 포함)
class Employee {
  final int id;
  final String companyCode;
  final String employeeId;
  final String name;
  final String createdAt;
  final int? workplaceId;
  final String? workplaceName;

  Employee({
    required this.id,
    required this.companyCode,
    required this.employeeId,
    required this.name,
    required this.createdAt,
    this.workplaceId,
    this.workplaceName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      companyCode: json['company_code'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      workplaceId: json['workplace_id'] as int?,
      workplaceName: json['workplace_name'] as String?,
    );
  }
}
