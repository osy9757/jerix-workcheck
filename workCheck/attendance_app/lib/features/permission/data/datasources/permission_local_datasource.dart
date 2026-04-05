import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../verification/domain/verification_method.dart';
import '../../domain/entities/permission_status_entity.dart';

@lazySingleton
class PermissionLocalDataSource {
  /// 앱에서 필요한 권한 정의
  /// skipCheck: true면 UI에는 보이지만 실제 권한 체크/요청을 건너뜀 (항상 granted 처리)
  static final _allPermissions = [
    (
      permission: Permission.location,
      title: '위치 (필수)',
      description: '내 위치 정보 활용',
      iconAsset: 'assets/icons/Property_gps.svg',
      requiredBy: [VerificationMethod.gps, VerificationMethod.wifi],
      skipCheck: false,
    ),
    (
      permission: Permission.nearbyWifiDevices,
      title: 'WiFi (필수)',
      description: 'WiFi 네트워크 인증',
      iconAsset: 'assets/icons/Property_wifi.svg',
      requiredBy: [VerificationMethod.wifi],
      skipCheck: Platform.isIOS, // iOS에서는 위치 권한으로 커버
    ),
    (
      permission: Permission.camera,
      title: '카메라 (필수)',
      description: 'QR 코드 촬용',
      iconAsset: 'assets/icons/Property_camera.svg',
      requiredBy: [VerificationMethod.qr],
      skipCheck: false,
    ),
    (
      permission: Platform.isIOS ? Permission.bluetooth : Permission.bluetoothScan,
      title: '블루투스 (필수)',
      description: '비콘 기기 인증',
      iconAsset: 'assets/icons/Property_bluetooth.svg',
      requiredBy: [VerificationMethod.bluetooth],
      skipCheck: false, // 로그인 전 권한 다이얼로그에서 직접 요청
    ),
  ];

  /// 현재 권한 상태 조회
  Future<List<PermissionItem>> checkAll() async {
    final items = <PermissionItem>[];
    for (final def in _allPermissions) {
      PermissionStatus status;
      if (def.skipCheck) {
        status = PermissionStatus.granted;
      } else {
        try {
          status = await def.permission.status;
        } catch (_) {
          status = PermissionStatus.denied;
        }
      }
      items.add(PermissionItem(
        permission: def.permission,
        title: def.title,
        description: def.description,
        iconAsset: def.iconAsset,
        status: status,
        requiredBy: def.requiredBy,
      ));
    }
    return items;
  }

  /// iOS 로컬 네트워크 권한 트리거 (브로드캐스트 패킷으로 시스템 다이얼로그 유도)
  static Future<void> _requestLocalNetworkPermission() async {
    if (!Platform.isIOS) return;
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      socket.send([0], InternetAddress('255.255.255.255'), 9);
      await Future.delayed(const Duration(milliseconds: 500));
      socket.close();
    } catch (_) {}
  }

  /// 모든 권한 일괄 요청
  Future<List<PermissionItem>> requestAll() async {
    final statuses = <Permission, PermissionStatus>{};

    for (final def in _allPermissions) {
      if (def.skipCheck) continue;
      try {
        statuses[def.permission] = await def.permission.request();
      } catch (_) {
        statuses[def.permission] = PermissionStatus.denied;
      }
    }

    // iOS 로컬 네트워크 권한 요청
    await _requestLocalNetworkPermission();

    // iOS: CoreBluetooth 초기화 (로그인 후 별도 다이얼로그 방지)
    if (Platform.isIOS) {
      try {
        await FlutterBluePlus.adapterState.first;
      } catch (_) {}
    }

    final items = <PermissionItem>[];
    for (final def in _allPermissions) {
      final status = def.skipCheck
          ? PermissionStatus.granted
          : statuses[def.permission] ?? PermissionStatus.denied;
      items.add(PermissionItem(
        permission: def.permission,
        title: def.title,
        description: def.description,
        iconAsset: def.iconAsset,
        status: status,
        requiredBy: def.requiredBy,
      ));
    }
    return items;
  }

  /// 전부 granted인지 확인
  Future<bool> areAllGranted() async {
    for (final def in _allPermissions) {
      if (def.skipCheck) continue;
      try {
        if (!(await def.permission.isGranted)) return false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }
}
