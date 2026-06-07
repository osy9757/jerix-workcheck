/// 관리자 웹 모델 (api_contract v2 — workplace 폐기, 5-enum)

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

/// 인증 방법 모델 (5-enum: GPS / WIFI / NFC / BEACON / QR)
/// - api_contract v2: workplace 폐기, user 단위 method 5 row
/// - 응답 키: `method_type`, `is_enabled`, `config_data` (snake_case)
class VerificationMethod {
  final String methodType; // 'GPS' | 'WIFI' | 'NFC' | 'BEACON' | 'QR'
  final bool enabled;
  final Map<String, dynamic> config;

  VerificationMethod({
    required this.methodType,
    required this.enabled,
    required this.config,
  });

  factory VerificationMethod.fromJson(Map<String, dynamic> json) {
    return VerificationMethod(
      methodType: json['method_type'] as String,
      // 호환: is_enabled (v2) 우선, 구버전 enabled 폴백
      enabled: (json['is_enabled'] ?? json['enabled']) as bool,
      config: Map<String, dynamic>.from(
        (json['config_data'] ?? json['config'] ?? {}) as Map,
      ),
    );
  }

  /// 방법 타입의 한글 이름
  String get displayName {
    switch (methodType) {
      case 'GPS':
        return 'GPS';
      case 'WIFI':
        return 'WiFi';
      case 'NFC':
        return 'NFC';
      case 'BEACON':
        return 'Beacon';
      case 'QR':
        return 'QR';
      default:
        return methodType;
    }
  }

  /// 방법 타입의 아이콘 이름 (참고용)
  String get iconName {
    switch (methodType) {
      case 'GPS':
        return 'location_on';
      case 'WIFI':
        return 'wifi';
      case 'NFC':
        return 'nfc';
      case 'BEACON':
        return 'bluetooth';
      case 'QR':
        return 'qr_code';
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
  final String verificationMethod; // 대표 method (소문자: 'gps' 등)
  final List<String> verifiedMethods; // AND 통과한 모든 method (소문자)

  AttendanceEntry({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.verificationMethod,
    required this.verifiedMethods,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    final vm = json['verified_methods'];
    return AttendanceEntry(
      id: json['id'] as int,
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      verificationMethod: json['verification_method'] as String? ?? '',
      verifiedMethods: vm is List
          ? vm.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

/// 인증 프리셋 모델 (NFC/WiFi/GPS/Beacon/QR 자주 쓰는 값 카탈로그)
/// JSON은 snake_case (백엔드 JacksonConfig SNAKE_CASE 전략)
class VerificationPreset {
  final int id;
  final String name; // 프리셋 이름
  final String methodType; // 'NFC' / 'WIFI' / 'GPS' / 'BEACON' / 'QR'
  final Map<String, dynamic> configData; // method_type별 설정값 (자유 JSONB)
  final String? memo; // 부가 메모
  final String createdAt; // ISO-8601
  final String updatedAt; // ISO-8601

  VerificationPreset({
    required this.id,
    required this.name,
    required this.methodType,
    required this.configData,
    this.memo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON → 객체 (snake_case 키 매핑)
  factory VerificationPreset.fromJson(Map<String, dynamic> json) {
    return VerificationPreset(
      id: json['id'] as int,
      name: json['name'] as String,
      methodType: json['method_type'] as String,
      configData: Map<String, dynamic>.from(
        (json['config_data'] ?? <String, dynamic>{}) as Map,
      ),
      memo: json['memo'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

/// 기기 승인 요청 모델 (기기 바인딩 — 계획 A ④Admin)
/// - 응답 키는 snake_case (백엔드 data class Jackson SNAKE_CASE)
/// - status: 'PENDING' | 'APPROVED' | 'REJECTED'
class DeviceRequest {
  final int id;
  final int userId; // 소속 유저 PK
  final String employeeId; // 사번
  final String name; // 직원 이름 (employee_name)
  final String? department; // 부서 (선택)
  final String deviceId; // 기기 식별자 (flutter_udid)
  final String status; // PENDING / APPROVED / REJECTED
  final String requestedAt; // 요청일 ISO-8601
  final String? approvedAt; // 승인일 ISO-8601 (미승인 시 null)

  DeviceRequest({
    required this.id,
    required this.userId,
    required this.employeeId,
    required this.name,
    this.department,
    required this.deviceId,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
  });

  /// JSON → 객체 (snake_case 키 매핑)
  factory DeviceRequest.fromJson(Map<String, dynamic> json) {
    return DeviceRequest(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      employeeId: json['employee_id'] as String,
      name: json['employee_name'] as String,
      department: json['department'] as String?,
      deviceId: json['device_id'] as String,
      status: json['status'] as String,
      requestedAt: json['requested_at'] as String? ?? '',
      approvedAt: json['approved_at'] as String?,
    );
  }
}

/// 직원 모델 (api_contract v2 — workplace 필드 제거, email/department 추가)
class Employee {
  final int id;
  final String companyCode;
  final String employeeId;
  final String name;
  final String? email;
  final String? department;
  final String createdAt;

  Employee({
    required this.id,
    required this.companyCode,
    required this.employeeId,
    required this.name,
    this.email,
    this.department,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      companyCode: json['company_code'] as String,
      employeeId: json['employee_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      department: json['department'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
