import 'package:dio/dio.dart';
import 'dart:html' as html;
import '../models/models.dart';

/// API 통신 서비스 (api_contract v2)
/// - workplace 관련 메서드 모두 제거
/// - 유저 단위 method CRUD (getUserMethods / updateUserMethod)
class ApiService {
  // nginx 프록시를 통해 API 서버로 연결 (/api/ → http://api:8080/api/)
  static const String _baseUrl = '/api/v1';
  static const String _tokenKey = 'admin_token';

  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // JWT 토큰 인터셉터
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      // [BACKLOG] 401(토큰 만료/무효) 응답 시 자동 로그아웃 후 리로드
      // - 로그인 요청 자체의 401(잘못된 자격증명)은 제외해 로그인 화면 에러 표시 유지
      onError: (error, handler) {
        final path = error.requestOptions.path;
        if (error.response?.statusCode == 401 &&
            !path.contains('/auth/admin/login')) {
          clearToken();
          // 리로드 시 main.dart의 isLoggedIn 분기로 로그인 페이지 진입
          html.window.location.reload();
        }
        handler.next(error);
      },
    ));
  }

  // --- 토큰 관리 ---

  String? getToken() => html.window.localStorage[_tokenKey];

  void saveToken(String token) {
    html.window.localStorage[_tokenKey] = token;
  }

  void clearToken() {
    html.window.localStorage.remove(_tokenKey);
  }

  bool get isLoggedIn => getToken() != null;

  // --- 관리자 로그인 ---

  /// Admin 로그인 (api_contract v2: /auth/admin/login)
  Future<AdminLoginResponse> login(String username, String password) async {
    final response = await _dio.post('/auth/admin/login', data: {
      'username': username,
      'password': password,
    });
    final result =
        AdminLoginResponse.fromJson(response.data as Map<String, dynamic>);
    saveToken(result.token);
    return result;
  }

  // --- 출퇴근 기록 (Admin Web) ---

  /// 관리자용 출퇴근 기록 조회 (날짜 범위)
  Future<List<AttendanceRecord>> getAttendanceHistory(
      String from, String to) async {
    final response =
        await _dio.get('/admin/attendance/records', queryParameters: {
      'from': from,
      'to': to,
    });
    final records = (response.data['records'] as List)
        .map((r) => AttendanceRecord.fromJson(r as Map<String, dynamic>))
        .toList();
    return records;
  }

  // --- 직원 관리 ---

  /// 직원 목록 조회
  /// 응답: { users: [...], total: N }
  Future<List<Employee>> getUsers() async {
    final response = await _dio.get('/users');
    final users = (response.data['users'] as List)
        .map((u) => Employee.fromJson(u as Map<String, dynamic>))
        .toList();
    return users;
  }

  /// 직원 등록 (백엔드가 5 method row 자동 생성)
  /// [D3] 관리자는 인사정보만 사전 등록(미가입 상태) — 비밀번호는 직원이 앱 회원가입에서 직접 설정.
  /// 따라서 password 인자/바디 키 제거 (백엔드 CreateUserRequest에 password 없음).
  Future<Employee> createUser({
    required String companyCode,
    required String employeeId,
    required String name,
    String? email,
    String? department,
  }) async {
    final response = await _dio.post('/users', data: {
      'company_code': companyCode,
      'employee_id': employeeId,
      'name': name,
      if (email != null) 'email': email,
      if (department != null) 'department': department,
    });
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  // --- 기기 승인 관리 (기기 바인딩 — 계획 A ④Admin) ---

  /// 기기 요청 목록 조회 (status 생략 시 전체)
  /// - GET /admin/devices?status=PENDING|APPROVED|REJECTED
  /// - 응답은 직접 배열 (래퍼 없음) → response.data as List
  Future<List<DeviceRequest>> getDeviceRequests({String? status}) async {
    final response = await _dio.get(
      '/admin/devices',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    final list = (response.data as List)
        .map((d) => DeviceRequest.fromJson(d as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// 기기 승인 (POST /admin/devices/{id}/approve)
  /// - 기존 APPROVED 기기는 서버가 REJECTED로 강등(교체)
  /// - 응답: 갱신된 단일 DeviceRequest 객체
  Future<DeviceRequest> approveDevice(int id) async {
    final response = await _dio.post('/admin/devices/$id/approve');
    return DeviceRequest.fromJson(response.data as Map<String, dynamic>);
  }

  /// 기기 거부 (POST /admin/devices/{id}/reject)
  /// - 응답: 갱신된 단일 DeviceRequest 객체
  Future<DeviceRequest> rejectDevice(int id) async {
    final response = await _dio.post('/admin/devices/$id/reject');
    return DeviceRequest.fromJson(response.data as Map<String, dynamic>);
  }

  /// 기기 바인딩 삭제 (DELETE /admin/devices/{id})
  /// - 모든 상태(APPROVED/PENDING/REJECTED)에서 삭제 가능
  /// - 응답: 200 + {"deleted": true} (본문은 사용하지 않음)
  Future<void> deleteDevice(int id) async {
    await _dio.delete('/admin/devices/$id');
  }

  // --- 기기 등록 방식 설정 ([D4] AUTO/APPROVAL) ---

  /// 기기 등록 방식 조회 (GET /admin/settings/device-binding?companyCode=jerix)
  /// - 응답: { company_code, mode } / 반환: mode ('AUTO' | 'APPROVAL')
  Future<String> getDeviceBindingMode({String companyCode = 'jerix'}) async {
    final response = await _dio.get(
      '/admin/settings/device-binding',
      queryParameters: {'companyCode': companyCode},
    );
    return response.data['mode'] as String;
  }

  /// 기기 등록 방식 변경 (PUT /admin/settings/device-binding)
  /// - body: { company_code, mode } / 반환: 갱신된 mode
  Future<String> updateDeviceBindingMode(String mode,
      {String companyCode = 'jerix'}) async {
    final response = await _dio.put(
      '/admin/settings/device-binding',
      data: {
        'company_code': companyCode,
        'mode': mode,
      },
    );
    return response.data['mode'] as String;
  }

  // --- 유저 인증 method (5-enum) ---

  /// 유저의 5개 method 전체 조회
  /// 응답: { user_id, methods: [{ method_type, is_enabled, config_data }] }
  Future<List<VerificationMethod>> getUserMethods(int userId) async {
    final response = await _dio.get('/users/$userId/methods');
    final methods = (response.data['methods'] as List)
        .map((m) => VerificationMethod.fromJson(m as Map<String, dynamic>))
        .toList();
    return methods;
  }

  /// 유저 단일 method 갱신(upsert)
  /// - methodType: 'GPS' | 'WIFI' | 'NFC' | 'BEACON' | 'QR' (대소문자 무관)
  /// - BEACON 저장 시 서버가 distance_m+tx_power → rssi_threshold 자동 계산해 응답 포함
  Future<VerificationMethod> updateUserMethod(
    int userId, {
    required String methodType,
    required bool isEnabled,
    required Map<String, dynamic> configData,
  }) async {
    final response = await _dio.put(
      '/users/$userId/methods/$methodType',
      data: {
        'is_enabled': isEnabled,
        'config_data': configData,
      },
    );
    return VerificationMethod.fromJson(response.data as Map<String, dynamic>);
  }

  // --- 인증 프리셋 (verification-presets) ---

  /// 프리셋 목록 조회 (methodType 생략 시 전체)
  /// 백엔드 컨트롤러는 카멜케이스 ?methodType=NFC 형식 사용
  Future<List<VerificationPreset>> getPresets({String? methodType}) async {
    final response = await _dio.get(
      '/verification-presets',
      queryParameters: {
        if (methodType != null && methodType.isNotEmpty)
          'methodType': methodType,
      },
    );
    // 응답은 배열 (래퍼 없음)
    final list = (response.data as List)
        .map((p) => VerificationPreset.fromJson(p as Map<String, dynamic>))
        .toList();
    return list;
  }

  /// 프리셋 단건 조회
  Future<VerificationPreset> getPreset(int id) async {
    final response = await _dio.get('/verification-presets/$id');
    return VerificationPreset.fromJson(response.data as Map<String, dynamic>);
  }

  /// 프리셋 생성 (POST) - 응답 201 + 단일 객체
  Future<VerificationPreset> createPreset({
    required String name,
    required String methodType,
    required Map<String, dynamic> configData,
    String? memo,
  }) async {
    final response = await _dio.post('/verification-presets', data: {
      'name': name,
      'method_type': methodType,
      'config_data': configData,
      if (memo != null) 'memo': memo,
    });
    return VerificationPreset.fromJson(response.data as Map<String, dynamic>);
  }

  /// 프리셋 수정 (PUT) - 전체 덮어쓰기 (PATCH 아님)
  Future<VerificationPreset> updatePreset(
    int id, {
    required String name,
    required String methodType,
    required Map<String, dynamic> configData,
    String? memo,
  }) async {
    final response = await _dio.put('/verification-presets/$id', data: {
      'name': name,
      'method_type': methodType,
      'config_data': configData,
      if (memo != null) 'memo': memo,
    });
    return VerificationPreset.fromJson(response.data as Map<String, dynamic>);
  }

  /// 프리셋 삭제 (DELETE) - 204 No Content
  Future<void> deletePreset(int id) async {
    await _dio.delete('/verification-presets/$id');
  }
}
