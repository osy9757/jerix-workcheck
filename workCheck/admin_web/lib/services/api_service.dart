import 'package:dio/dio.dart';
import 'dart:html' as html;
import '../models/models.dart';

/// API 통신 서비스
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

  Future<AdminLoginResponse> login(String username, String password) async {
    final response = await _dio.post('/admin/login', data: {
      'username': username,
      'password': password,
    });
    final result = AdminLoginResponse.fromJson(response.data);
    saveToken(result.token);
    return result;
  }

  // --- 인증 방법 관리 ---

  /// 인증 방법 목록 조회
  Future<List<VerificationMethod>> getVerificationMethods() async {
    final response = await _dio.get('/verification/methods');
    final methods = (response.data['methods'] as List)
        .map((m) => VerificationMethod.fromJson(m))
        .toList();
    return methods;
  }

  /// 인증 방법 상세 조회
  Future<VerificationMethod> getVerificationMethod(int id) async {
    final response = await _dio.get('/verification/methods/$id');
    return VerificationMethod.fromJson(response.data);
  }

  /// 인증 방법 수정 (ON/OFF + 설정)
  Future<VerificationMethod> updateVerificationMethod(
    int id, {
    required bool enabled,
    required Map<String, dynamic> config,
  }) async {
    final response = await _dio.put('/verification/methods/$id', data: {
      'enabled': enabled,
      'config': config,
    });
    return VerificationMethod.fromJson(response.data);
  }

  // --- 출퇴근 기록 ---

  /// 출퇴근 기록 조회
  Future<List<AttendanceRecord>> getAttendanceHistory(
      String from, String to) async {
    final response = await _dio.get('/admin/attendance/records', queryParameters: {
      'from': from,
      'to': to,
    });
    final records = (response.data['records'] as List)
        .map((r) => AttendanceRecord.fromJson(r))
        .toList();
    return records;
  }

  // --- 직원 관리 ---

  /// 직원 목록 조회
  Future<List<Employee>> getUsers() async {
    final response = await _dio.get('/users');
    final users = (response.data['users'] as List)
        .map((u) => Employee.fromJson(u))
        .toList();
    return users;
  }

  /// 직원 등록
  Future<Employee> createUser({
    required String companyCode,
    required String employeeId,
    required String name,
    required String password,
  }) async {
    final response = await _dio.post('/users', data: {
      'company_code': companyCode,
      'employee_id': employeeId,
      'name': name,
      'password': password,
    });
    return Employee.fromJson(response.data);
  }

  // --- 근무지 관리 ---

  /// 근무지 목록 조회
  Future<List<Workplace>> getWorkplaces() async {
    final response = await _dio.get('/workplaces');
    final list = (response.data['workplaces'] as List)
        .map((w) => Workplace.fromJson(w))
        .toList();
    return list;
  }

  /// 근무지 생성
  Future<Workplace> createWorkplace(String name, String? address, {double? latitude, double? longitude}) async {
    final response = await _dio.post('/workplaces', data: {
      'name': name,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    return Workplace.fromJson(response.data);
  }

  /// 근무지 수정
  Future<Workplace> updateWorkplace(int id, String name, String? address, {double? latitude, double? longitude}) async {
    final response = await _dio.put('/workplaces/$id', data: {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    });
    return Workplace.fromJson(response.data);
  }

  /// 근무지 삭제
  Future<void> deleteWorkplace(int id) async {
    await _dio.delete('/workplaces/$id');
  }

  // --- 근무지별 인증 방법 ---

  /// 근무지의 인증 방법 목록 조회
  Future<List<VerificationMethod>> getWorkplaceVerificationMethods(int workplaceId) async {
    final response = await _dio.get('/workplaces/$workplaceId/verification-methods');
    final methods = (response.data['methods'] as List)
        .map((m) => VerificationMethod.fromJson(m))
        .toList();
    return methods;
  }

  /// 근무지 인증 방법 수정
  Future<VerificationMethod> updateWorkplaceVerificationMethod(
    int workplaceId,
    int methodId, {
    required bool enabled,
    required Map<String, dynamic> config,
  }) async {
    final response = await _dio.put(
      '/workplaces/$workplaceId/verification-methods/$methodId',
      data: {'enabled': enabled, 'config': config},
    );
    return VerificationMethod.fromJson(response.data);
  }

  // --- 유저별 인증 오버라이드 ---

  /// 유저의 실제 인증 방법 조회 (근무지 기본 + 오버라이드 머지)
  Future<List<VerificationMethod>> getUserVerificationMethods(int userId) async {
    final response = await _dio.get('/users/$userId/verification-methods');
    final methods = (response.data['methods'] as List)
        .map((m) => VerificationMethod.fromJson(m))
        .toList();
    return methods;
  }

  /// 유저 인증 오버라이드 설정
  Future<void> updateUserVerificationOverride(
    int userId, {
    required String methodType,
    required bool isEnabled,
    required Map<String, dynamic> config,
  }) async {
    await _dio.put('/users/$userId/verification-overrides', data: {
      'method_type': methodType,
      'is_enabled': isEnabled,
      'config_data': config,
    });
  }

  /// 유저 오버라이드 제거 (근무지 기본으로 복귀)
  Future<void> deleteUserVerificationOverride(int userId, String methodType) async {
    await _dio.delete('/users/$userId/verification-overrides/$methodType');
  }

  // --- 유저 근무지 배정 ---

  /// 유저를 근무지에 배정
  Future<void> assignUserWorkplace(int userId, int workplaceId) async {
    await _dio.put('/users/$userId/workplace', data: {
      'workplace_id': workplaceId,
    });
  }

  // --- QR 코드 ---

  /// 근무지 QR 코드 조회
  Future<String> getWorkplaceQrCode(int workplaceId) async {
    final response = await _dio.get('/workplaces/$workplaceId/qr-code');
    return response.data['qr_code'] as String;
  }

  /// 근무지 QR 코드 재생성
  Future<String> regenerateWorkplaceQrCode(int workplaceId) async {
    final response = await _dio.put('/workplaces/$workplaceId/qr-code');
    return response.data['qr_code'] as String;
  }
}
