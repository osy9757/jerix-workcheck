import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// 네트워크 모듈 - Dio 인스턴스를 싱글톤으로 제공
@module
abstract class NetworkModule {
  /// Dio HTTP 클라이언트 설정 및 인터셉터 등록
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // 연결/응답/전송 타임아웃: 각 10초
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // baseUrl 동적 교체 → 인증 토큰 주입 → 로그 순서로 인터셉터 등록
    dio.interceptors.addAll([
      _BaseUrlInterceptor(),
      _AuthInterceptor(),
      _LogInterceptor(),
    ]);

    return dio;
  }
}

/// 저장된 서버 URL로 baseUrl 동적 교체 인터셉터
/// 관리자 웹에서 설정한 서버 주소를 매 요청마다 적용
class _BaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString(ApiConstants.serverUrlKey);
    // 저장된 URL이 있으면 기본 baseUrl 대신 사용
    if (savedUrl != null && savedUrl.isNotEmpty) {
      options.baseUrl = savedUrl;
    }
    handler.next(options);
  }
}

/// JWT 토큰 자동 주입 인터셉터
/// 저장된 토큰이 있으면 모든 요청 헤더에 Bearer 토큰을 추가
class _AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // SharedPreferences에서 JWT 토큰 읽기
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 401 응답 시 저장된 토큰 삭제 (로그인 화면으로의 리다이렉트는 UI에서 처리)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    }
    handler.next(err);
  }
}

/// 네트워크 요청/응답 로깅 인터셉터
/// 개발 디버깅용으로 요청 메서드, URL, 응답 상태코드를 출력
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[API] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[API] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[API] ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}
