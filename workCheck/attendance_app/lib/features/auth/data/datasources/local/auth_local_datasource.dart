import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 인증 데이터 저장소
///
/// JWT 토큰, 사용자 정보를 SharedPreferences에 저장/조회.
@lazySingleton
class AuthLocalDatasource {
  static const _companyCodeKey = 'saved_company_code';
  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'user_name';
  static const _employeeIdKey = 'employee_id';
  static const _enabledMethodsKey = 'enabled_methods';

  // --- 회사코드 ---

  /// 저장된 회사코드 조회
  Future<String?> getSavedCompanyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_companyCodeKey);
  }

  /// 회사코드 저장 (로그인 시 자동 입력용)
  Future<void> saveCompanyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyCodeKey, code);
  }

  // --- JWT 토큰 ---

  /// JWT 토큰 저장 (API 인증 헤더에 사용)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 저장된 JWT 토큰 조회
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// JWT 토큰 삭제
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // --- 사용자 정보 ---

  /// 사용자 이름 저장 (화면 인사말 표시용)
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  /// 저장된 사용자 이름 조회
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// 사원번호 저장
  Future<void> saveEmployeeId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeIdKey, id);
  }

  /// 저장된 사원번호 조회
  Future<String?> getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_employeeIdKey);
  }

  // --- 서버 활성 인증 방법 ---

  /// 로그인 응답의 enabled_methods 저장
  Future<void> saveEnabledMethods(List<String> methods) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_enabledMethodsKey, methods);
  }

  /// 저장된 활성 인증 방법 조회
  Future<List<String>?> getEnabledMethods() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_enabledMethodsKey);
  }

  // --- 로그아웃 ---

  /// 로그아웃 시 모든 인증 정보 삭제 (회사코드는 편의를 위해 유지)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_enabledMethodsKey);
    // companyCode는 편의를 위해 유지
  }
}
