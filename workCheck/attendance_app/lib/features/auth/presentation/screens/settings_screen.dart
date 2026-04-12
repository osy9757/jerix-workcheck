import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/datasources/local/auth_local_datasource.dart';

/// 설정 화면 (서버 URL 변경, 로그아웃, 앱 버전)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  /// 저장된 서버 URL 로드
  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(ApiConstants.serverUrlKey) ?? ApiConstants.defaultBaseUrl;
    _serverUrlController.text = url;
  }

  /// 서버 URL 저장
  Future<void> _saveServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.serverUrlKey, url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('서버 URL이 저장되었습니다. 앱을 재시작해주세요.'),
        backgroundColor: Color(0xFF2DDAA9),
      ),
    );
  }

  /// 로그아웃
  Future<void> _handleLogout() async {
    final authLocal = getIt<AuthLocalDatasource>();
    await authLocal.clearAll();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          '설정',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            height: 1.4,
            letterSpacing: 16.sp * -0.02,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          children: [
            // 서버 URL 설정
            _buildSectionTitle('서버 설정'),
            SizedBox(height: 8.h),
            _buildServerUrlCard(),
            SizedBox(height: 24.h),
            // 계정
            _buildSectionTitle('계정'),
            SizedBox(height: 8.h),
            _buildLogoutCard(),
            SizedBox(height: 24.h),
            // 앱 정보
            _buildSectionTitle('앱 정보'),
            SizedBox(height: 8.h),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  /// 설정 섹션 제목 텍스트
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        height: 1.4,
        letterSpacing: -0.5,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  /// 서버 URL 입력 및 저장 카드
  Widget _buildServerUrlCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '서버 URL',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _serverUrlController,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'http://서버주소:포트',
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14.sp,
                color: const Color(0xFF9CA3AF),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: Color(0xFF2DDAA9)),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: _saveServerUrl,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DDAA9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                '저장',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 로그아웃 버튼 카드
  Widget _buildLogoutCard() {
    return GestureDetector(
      onTap: _handleLogout,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.logout, size: 20.w, color: Colors.red),
            SizedBox(width: 12.w),
            Text(
              '로그아웃',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱 버전 정보 표시 카드
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '앱 버전',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
              color: const Color(0xFF374151),
            ),
          ),
          Text(
            '1.0.0',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
