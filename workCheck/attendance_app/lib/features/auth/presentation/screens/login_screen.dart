import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../../../presentation/common_widgets/app_text_field.dart';
import '../../../../presentation/common_widgets/device_access_dialog.dart';
import '../../../../presentation/common_widgets/secure_number_pad.dart';
import '../../../permission/domain/repositories/permission_repository.dart';
import '../../../permission/presentation/bloc/permission_bloc.dart';
import '../../../permission/presentation/widgets/permission_dialog.dart';

/// 로그인 화면
///
/// 회사코드, 사원번호, 비밀번호를 입력하여 로그인.
/// - 비밀번호는 보안 숫자 키패드로 입력
/// - 앱 시작 시 권한 미허용이면 권한 요청 다이얼로그 표시
/// - 설정 앱 복귀 시 권한 재확인
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _companyCodeController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final PermissionBloc _permissionBloc;

  /// 권한 다이얼로그 표시 여부 (앱 복귀 시 재확인에 사용)
  bool _dialogShown = false;

  /// 보안 키패드 표시 여부
  bool _showKeypad = false;

  final FocusNode _passwordFocusNode = FocusNode();
  final AuthLocalDatasource _authLocal = getIt<AuthLocalDatasource>();

  /// 비밀번호 필드 오류 메시지
  String? _passwordError;

  /// 모든 입력 필드가 채워진 경우에만 로그인 버튼 활성화
  bool get _isFormValid =>
      _companyCodeController.text.isNotEmpty &&
      _employeeIdController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionBloc = getIt<PermissionBloc>();
    // 권한 확인 후 필요시 다이얼로그 표시
    _checkAndShowPermissionDialog();
    // 저장된 회사코드 자동 입력
    _loadSavedCompanyCode();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 설정 앱에서 돌아왔을 때 권한 상태 재확인
    if (state == AppLifecycleState.resumed && _dialogShown && !_permissionBloc.isClosed) {
      _permissionBloc.add(const PermissionStarted());
    }
  }

  /// 권한 상태를 확인하고 미허용 시 권한 요청 다이얼로그 표시
  Future<void> _checkAndShowPermissionDialog() async {
    final repository = getIt<PermissionRepository>();
    final allGranted = await repository.areAllPermissionsGranted();

    if (!allGranted && mounted) {
      _dialogShown = true;
      _permissionBloc.add(const PermissionStarted());
      await PermissionDialog.show(context, _permissionBloc);
      _dialogShown = false;
    }
  }

  /// 오류 메시지 초기화
  void _clearErrors() {
    _passwordError = null;
  }

  /// 보안 키패드 숫자 입력 처리
  void _onKeypadInput(String digit) {
    _passwordController.text += digit;
    // 커서를 항상 끝으로 이동
    _passwordController.selection = TextSelection.fromPosition(
      TextPosition(offset: _passwordController.text.length),
    );
    setState(() {});
  }

  /// 보안 키패드 백스페이스 처리
  void _onKeypadBackspace() {
    if (_passwordController.text.isNotEmpty) {
      _passwordController.text = _passwordController.text.substring(
        0,
        _passwordController.text.length - 1,
      );
      _passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: _passwordController.text.length),
      );
    }
    setState(() {});
  }

  /// 보안 키패드 숨기기
  void _hideKeypad() {
    if (_showKeypad) {
      setState(() {
        _showKeypad = false;
      });
      _passwordFocusNode.unfocus();
    }
  }

  /// 저장된 회사코드를 불러와 입력 필드에 자동 입력
  Future<void> _loadSavedCompanyCode() async {
    final savedCode = await _authLocal.getSavedCompanyCode();
    if (savedCode != null && savedCode.isNotEmpty && mounted) {
      setState(() {
        _companyCodeController.text = savedCode;
      });
    }
  }

  /// 로그인 처리
  ///
  /// 서버에 로그인 API 요청 후:
  /// - 성공: 토큰/사용자 정보 로컬 저장 후 홈으로 이동
  /// - 401: 비밀번호 오류 메시지 표시
  /// - 403: 기기 접근 불가 다이얼로그 표시
  /// - 기타: 네트워크 오류 메시지 표시
  Future<void> _handleLogin() async {
    _clearErrors();
    final companyCode = _companyCodeController.text;
    final employeeId = _employeeIdController.text;
    final password = _passwordController.text;

    try {
      // 서버 로그인 API 호출
      final dio = getIt<Dio>();
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'company_code': companyCode,
          'employee_id': employeeId,
          'password': password,
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

      if (mounted) {
        context.go('/');
      }
    } on DioException catch (e) {
      if (!mounted) return;

      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['error'] as String?;

      if (statusCode == 403) {
        // 기기 접속 불가: 접속 허용 요청 안내 다이얼로그 표시
        await DeviceAccessDialog.show(
          context: context,
          title: '접속이 허용된 기기가 아닙니다',
          content: message ??
              '사용자의 휴대폰 기기 ID/IMEI가 접속이 허용된 기기가\n'
                  '아니거나 다시 등록해야 하는 기기입니다.\n\n'
                  '아래 접속 허용 요청을 하시면\n'
                  '인사 담당자의 확인을 거쳐 접속할 수 있습니다.',
          buttonText: '담당자에게 접속 허용 요청',
          onButtonPressed: () {
            Navigator.of(context).pop();
          },
        );
      } else if (statusCode == 401) {
        // 비밀번호 불일치
        setState(() {
          _passwordError = message ?? '비밀번호가 일치하지 않습니다';
        });
      } else {
        // 네트워크 오류 등 기타
        setState(() {
          _passwordError = '서버 연결에 실패했습니다. 네트워크를 확인해주세요.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = '로그인 중 오류가 발생했습니다.';
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_permissionBloc.isClosed) {
      _permissionBloc.close();
    }
    _companyCodeController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          // 빈 영역 탭 시 키패드 및 키보드 닫기
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
                        SizedBox(height: 87.h),
                        // 로고 영역 (임시 플레이스홀더)
                        Center(
                          child: Container(
                            width: 222.w,
                            height: 130.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '로고영역',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 33.h),
                        // 회사코드 입력 필드
                        AppTextField(
                          hintText: '회사코드를 입력하세요',
                          controller: _companyCodeController,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          onChanged: (_) => setState(() {}),
                          onTap: _hideKeypad,
                        ),
                        SizedBox(height: 14.h),
                        // 사원번호 입력 필드
                        AppTextField(
                          hintText: '사원번호를 입력하세요',
                          controller: _employeeIdController,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          onChanged: (_) => setState(() {}),
                          onTap: _hideKeypad,
                        ),
                        SizedBox(height: 14.h),
                        // 비밀번호 입력 필드 (읽기 전용, 보안 키패드 사용)
                        AppTextField(
                          hintText: '비밀번호를 입력하세요',
                          controller: _passwordController,
                          obscureText: true,
                          readOnly: true,
                          focusNode: _passwordFocusNode,
                          focusedBorderColor: const Color(0xFF2DD1DA),
                          errorText: _passwordError,
                          onTap: () {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                            setState(() {
                              _showKeypad = true;
                            });
                          },
                        ),
                        SizedBox(height: 96.h),
                        // 로그인 버튼 (SVG 이미지, 폼 유효 여부에 따라 on/off)
                        GestureDetector(
                          onTap: _isFormValid ? _handleLogin : null,
                          child: SvgPicture.asset(
                            _isFormValid
                                ? 'assets/icons/btn_on.svg'
                                : 'assets/icons/btn_off.svg',
                            width: 343.w,
                          ),
                        ),
                        SizedBox(height: 39.h),
                        // 회원가입 이동 버튼
                        Center(
                          child: TextButton(
                            onPressed: () {
                              context.push('/register');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                            ),
                            child: Text(
                              '회원가입하기',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                                height: 1.4,
                                letterSpacing: 14.sp * -0.025,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 보안 숫자 키패드 (비밀번호 입력 시 하단에 표시)
              if (_showKeypad)
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
      ),
    );
  }
}
