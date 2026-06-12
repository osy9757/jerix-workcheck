import 'package:flutter/material.dart';

/// 글로벌 네비게이터 키 (서비스/네트워크 레이어에서 context 획득용)
///
/// dio_client 등 하위 레이어가 app_router 를 직접 import 하면 순환참조가 생기므로
/// 키만 별도 파일로 분리한다. app_router.dart 가 이 파일을 re-export 하여
/// 기존 import 경로(app_router.dart)도 그대로 동작한다.
final rootNavigatorKey = GlobalKey<NavigatorState>();
