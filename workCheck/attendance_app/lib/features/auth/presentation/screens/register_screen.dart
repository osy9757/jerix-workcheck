import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/device_id_provider.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../../../presentation/common_widgets/app_text_field.dart';
import '../../../../presentation/common_widgets/device_access_dialog.dart';
import '../../../../presentation/common_widgets/secure_number_pad.dart';
import '../../../../presentation/navigation/app_router.dart';

/// 보안 키패드에서 현재 활성화된 입력 필드를 구분하는 enum
enum _ActiveField { none, password, confirm }

/// 회원가입 화면
///
/// 회사코드, 사원번호, 비밀번호를 입력하여 신규 사용자를 등록.
/// 비밀번호는 보안 숫자 키패드를 사용하며, 비밀번호 확인 필드로 일치 여부를 검증.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _companyCodeController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  /// 현재 활성 키패드 대상 필드
  _ActiveField _activeField = _ActiveField.none;
  String? _companyCodeError;
  String? _employeeIdError;
  String? _confirmError;
  bool _isLoading = false;

  /// 모든 필드가 입력되었는지 확인하여 확인 버튼 활성화 여부 결정
  bool get _isFormValid =>
      _companyCodeController.text.isNotEmpty &&
      _employeeIdController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty;

  /// 현재 활성 필드에 해당하는 TextEditingController 반환
  TextEditingController get _activeController {
    switch (_activeField) {
      case _ActiveField.password:
        return _passwordController;
      case _ActiveField.confirm:
        return _confirmController;
      case _ActiveField.none:
        return _passwordController;
    }
  }

  /// 보안 키패드 숫자 입력 처리
  void _onKeypadInput(String digit) {
    final controller = _activeController;
    controller.text += digit;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
    setState(() {});
  }

  /// 보안 키패드 백스페이스 처리
  void _onKeypadBackspace() {
    final controller = _activeController;
    if (controller.text.isNotEmpty) {
      controller.text = controller.text.substring(
        0,
        controller.text.length - 1,
      );
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    setState(() {});
  }

  /// 보안 키패드 숨기기
  void _hideKeypad() {
    if (_activeField != _ActiveField.none) {
      setState(() {
        _activeField = _ActiveField.none;
      });
      _passwordFocusNode.unfocus();
      _confirmFocusNode.unfocus();
    }
  }

  /// 로컬 인증 저장소 (자동 로그인 토큰 저장용)
  final AuthLocalDatasource _authLocal = getIt<AuthLocalDatasource>();

  /// 회원가입 처리
  ///
  /// 입력값 검증 후 서버에 회원가입 API를 호출.
  /// 성공 시 입력한 인사정보로 즉시 자동 로그인하여 홈으로 진입.
  Future<void> _handleRegister() async {
    setState(() {
      _companyCodeError = null;
      _employeeIdError = null;
      _confirmError = null;

      if (_companyCodeController.text.isEmpty) {
        _companyCodeError = '회사코드를 다시 확인 해주세요';
      }
      if (_employeeIdController.text.isEmpty) {
        _employeeIdError = '사원번호를 다시 확인 해주세요';
      }
      if (_passwordController.text != _confirmController.text) {
        _confirmError = '비밀번호가 일치하지 않습니다';
      }
    });

    if (_companyCodeError != null ||
        _employeeIdError != null ||
        _confirmError != null) {
      return;
    }

    setState(() => _isLoading = true);

    // 자동 로그인에 재사용할 입력값 (trim 처리)
    // 회사코드 대소문자 무시: 소문자 정규화(DB 저장 케이스와 일치)
    final companyCode = _companyCodeController.text.trim().toLowerCase();
    final employeeId = _employeeIdController.text.trim();
    final password = _passwordController.text;

    try {
      final dio = getIt<Dio>();
      // 신규 가입: 관리자가 사전 등록한 미가입 직원 row 에 비밀번호 설정 + 활성화.
      // name 은 인사정보에 등재된 기존 값을 쓰므로 보내지 않는다.
      // 인사정보 불일치/이미 가입된 사번이면 400 + PPT 문구(error)가 내려와 아래 스낵바로 노출.
      await dio.post(
        ApiConstants.register,
        data: {
          'company_code': companyCode,
          'employee_id': employeeId,
          'password': password,
        },
      );

      if (!mounted) return;
      // PPT 안내: 기기 ID 등록 안내 다이얼로그 1회 노출 (자동로그인 직전)
      // 자동 로그인 시 첫 기기로 자동 바인딩되므로, 그 전에 안내 문구만 표시
      await DeviceAccessDialog.show(
        context: context,
        title: '기기 등록 안내',
        content: '접속이 허용된 기기 여부를 확인을 위해\n사용자의 휴대폰 기기 ID를 등록합니다.',
        buttonText: '확인',
        onButtonPressed: () => Navigator.of(context).pop(),
      );

      if (!mounted) return;
      // 가입 성공 직후 입력 정보로 즉시 자동 로그인 시도 (로그인이 기기 바인딩 담당)
      await _autoLogin(
        companyCode: companyCode,
        employeeId: employeeId,
        password: password,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data?['error'] as String?
          ?? '회원가입에 실패했습니다.';
      // 진단 로그: 회원가입 실패 (상태코드/메시지만, 비밀번호 미출력)
      logW('Auth', '회원가입 실패 status=${e.response?.statusCode} msg=$message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 가입 직후 자동 로그인
  ///
  /// 입력한 인사정보 + 기기 ID로 즉시 로그인 API 호출.
  /// - 성공: 토큰/사용자 정보 저장 후 홈('/') 진입 (login_screen 저장 패턴 동일)
  /// - 실패(예외/403 등): 로그인 화면으로 복귀 + 스낵바 안내
  Future<void> _autoLogin({
    required String companyCode,
    required String employeeId,
    required String password,
  }) async {
    try {
      // 기기 식별자 조회 (기기 바인딩 검증용)
      final deviceId = await getIt<DeviceIdProvider>().getDeviceId();

      final dio = getIt<Dio>();
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'company_code': companyCode,
          'employee_id': employeeId,
          'password': password,
          'device_id': deviceId,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = data['user'] as Map<String, dynamic>?;

      // 토큰 + 사용자 정보 로컬 저장
      await _authLocal.saveToken(token);
      await _authLocal.saveCompanyCode(companyCode);
      await _authLocal.saveEmployeeId(employeeId);
      if (user != null && user['name'] != null) {
        await _authLocal.saveUserName(user['name'] as String);
      }

      // 서버 활성 인증 방법 저장
      final enabledMethods = (data['enabled_methods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();
      if (enabledMethods != null) {
        await _authLocal.saveEnabledMethods(enabledMethods);
      }

      if (!mounted) return;
      // 자동 로그인 성공 → 홈으로 진입
      context.go('/');
    } on DioException catch (e) {
      if (!mounted) return;
      // [D4] APPROVAL 모드: 가입 직후 자동 로그인이 403(기기 미승인)이면 승인 흐름으로 전환.
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      final errorCode = data is Map ? data['errorCode'] as String? : null;
      // 진단 로그: 가입 직후 자동 로그인 실패 (상태코드/에러코드만)
      logW('Auth', '가입 후 자동로그인 실패 status=$statusCode errorCode=$errorCode');
      if (statusCode == 403 && errorCode == 'DEVICE_NOT_ALLOWED') {
        final deviceStatus = data is Map ? data['deviceStatus'] as String? : null;
        await _goToDeviceWaiting(
          companyCode: companyCode,
          employeeId: employeeId,
          password: password,
          deviceStatus: deviceStatus,
        );
        return;
      }
      // 그 외 Dio 오류: 가입은 완료됐으므로 로그인 안내 후 복귀
      _showRegisterDoneAndPop();
    } catch (e) {
      // 자동 로그인 실패(비 Dio 예외): 기존처럼 로그인 화면으로 복귀
      if (!mounted) return;
      _showRegisterDoneAndPop();
    }
  }

  /// [D4] 가입 직후 403(APPROVAL 모드) → 승인 대기 흐름으로 전환.
  ///
  /// PENDING 이면 바로 대기화면, 그 외(NONE_MATCH/REJECTED)는 승인요청(PENDING 생성)
  /// 후 대기화면. 대기화면 폴링/취소용 자격증명을 extra 로 전달(D11 패턴).
  Future<void> _goToDeviceWaiting({
    required String companyCode,
    required String employeeId,
    required String password,
    required String? deviceStatus,
  }) async {
    final extra = {
      'companyCode': companyCode,
      'employeeId': employeeId,
      'password': password,
    };
    // 이미 승인 대기 중이면 요청 생략하고 바로 대기화면
    if (deviceStatus == 'PENDING') {
      if (mounted) context.go(AppRoutes.deviceWaiting, extra: extra);
      return;
    }
    // NONE_MATCH/REJECTED → 승인요청(PENDING 등록) 후 대기화면
    try {
      final deviceId = await getIt<DeviceIdProvider>().getDeviceId();
      final dio = getIt<Dio>();
      await dio.post(
        ApiConstants.deviceRequest,
        data: {
          'company_code': companyCode,
          'employee_id': employeeId,
          'password': password,
          'device_id': deviceId,
        },
      );
      if (mounted) context.go(AppRoutes.deviceWaiting, extra: extra);
    } catch (_) {
      // 승인요청 실패: 기존 폴백(가입 완료 안내 + 로그인 복귀)
      _showRegisterDoneAndPop();
    }
  }

  /// 가입 완료 안내 스낵바 + 로그인 화면 복귀 (자동로그인/승인요청 실패 시 폴백)
  void _showRegisterDoneAndPop() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
        backgroundColor: Color(0xFF2DDAA9),
      ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _companyCodeController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  /// 입력 필드 상단 레이블 위젯
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          height: 17 / 14,
          letterSpacing: -0.5,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 48.h,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          '회원가입',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            height: 1.4,
            letterSpacing: 16.sp * -0.02,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _hideKeypad();
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        // 회사 코드 라벨
                        _buildLabel('회사 코드'),
                        SizedBox(height: 10.h),
                        // 회사 코드 필드
                        AppTextField(
                          hintText: '회사코드를 입력하세요',
                          controller: _companyCodeController,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          errorText: _companyCodeError,
                          onChanged: (_) => setState(() {}),
                          onTap: _hideKeypad,
                        ),
                        SizedBox(height: 22.h),
                        // 사원번호 라벨
                        _buildLabel('사원번호'),
                        SizedBox(height: 10.h),
                        // 사원번호 필드
                        AppTextField(
                          hintText: '사원번호를 입력하세요',
                          controller: _employeeIdController,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          errorText: _employeeIdError,
                          onChanged: (_) => setState(() {}),
                          onTap: _hideKeypad,
                        ),
                        SizedBox(height: 22.h),
                        // 비밀번호 입력 라벨
                        _buildLabel('비밀번호 입력'),
                        SizedBox(height: 10.h),
                        // 비밀번호 입력 필드
                        AppTextField(
                          hintText: '사용할 비밀번호를 입력하세요',
                          controller: _passwordController,
                          obscureText: true,
                          readOnly: true,
                          focusNode: _passwordFocusNode,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          onTap: () {
                            _passwordFocusNode.requestFocus();
                            setState(() {
                              _activeField = _ActiveField.password;
                            });
                          },
                        ),
                        SizedBox(height: 22.h),
                        // 비밀번호 확인 라벨
                        _buildLabel('비밀번호 확인'),
                        SizedBox(height: 10.h),
                        // 비밀번호 확인 필드
                        AppTextField(
                          hintText: '사용할 비밀번호를 입력하세요',
                          controller: _confirmController,
                          obscureText: true,
                          readOnly: true,
                          focusNode: _confirmFocusNode,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          errorText: _confirmError,
                          onTap: () {
                            _confirmFocusNode.requestFocus();
                            setState(() {
                              _activeField = _ActiveField.confirm;
                            });
                          },
                        ),
                        SizedBox(height: 169.h),
                        // 확인 버튼
                        GestureDetector(
                          onTap: _isFormValid && !_isLoading ? _handleRegister : null,
                          child: Container(
                            width: 343.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: _isFormValid
                                  ? const Color(0xFF2DDAA9)
                                  : const Color(0xFFD1D5DB),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.sp,
                                height: 1.4,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Secure keypad at bottom
              if (_activeField != _ActiveField.none)
                SecureNumberPad(
                  onKeyPressed: _onKeypadInput,
                  onBackspace: _onKeypadBackspace,
                  onSubmit: _hideKeypad,
                  submitEnabled: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
