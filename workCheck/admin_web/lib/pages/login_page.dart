import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/admin_theme.dart';

/// 관리자 로그인 페이지
class LoginPage extends StatefulWidget {
  final ApiService apiService;
  const LoginPage({super.key, required this.apiService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController(); // 아이디 입력 컨트롤러
  final _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  bool _loading = false; // 로그인 요청 중 여부
  String? _error; // 에러 메시지

  /// 로그인 처리 - API 호출 후 대시보드로 이동
  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _error = '아이디와 비밀번호를 입력하세요');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      // 자격증명 문자열은 출력 금지 — 원인($e)만 기록
      debugPrint('[로그인] 실패: $e');
      setState(() => _error = '로그인 실패: 아이디 또는 비밀번호를 확인하세요');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 밝은 배경 + 상단에서 내려오는 미세한 브랜드 그라데이션
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AdminColors.primarySoft, AdminColors.bg],
            stops: [0.0, 0.55],
          ),
        ),
        child: Center(
          child: Container(
            width: 420,
            padding: const EdgeInsets.fromLTRB(40, 44, 40, 40),
            // 흰 카드: radius 16 + 미세 보더 + 낮은 그림자
            decoration: BoxDecoration(
              color: AdminColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdminColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14101828),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 브랜드 로고 영역 (라운드 사각 + 아이콘)
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AdminColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AdminColors.primary.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.fact_check_outlined,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'WorkCheck 관리자',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '출퇴근 관리 콘솔에 로그인하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AdminColors.textSub),
                ),
                const SizedBox(height: 32),

                // 아이디 입력 (스타일은 테마 inputDecorationTheme 의존)
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 14),

                // 비밀번호 입력
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: Icon(Icons.lock_outline, size: 20),
                  ),
                  onSubmitted: (_) => _login(),
                ),

                // 에러 메시지 (연한 danger 박스)
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AdminColors.dangerSoft, // 연한 danger 배경 토큰
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AdminColors.danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AdminColors.danger,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // 로그인 버튼 (primary FilledButton)
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('로그인', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 컨트롤러 해제
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
