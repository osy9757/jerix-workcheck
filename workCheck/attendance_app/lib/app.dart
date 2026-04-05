import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';

/// 앱 루트 위젯
/// ScreenUtil 초기화 및 MaterialApp 설정을 담당
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 디자인 기준 해상도: 375x812 (iPhone SE 기준)
      designSize: const Size(375, 812),
      // 텍스트 크기가 디바이스 폰트 크기 설정에 영향받지 않도록 적응
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '출퇴근',
          // 디버그 배너 숨김
          debugShowCheckedModeBanner: false,
          // 라이트/다크 테마 설정
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // 시스템 설정에 따라 테마 자동 전환
          themeMode: ThemeMode.system,
          // GoRouter 기반 라우터 설정
          routerConfig: appRouter,
        );
      },
    );
  }
}
