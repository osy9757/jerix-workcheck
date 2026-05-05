import 'dart:async';
import 'dart:io';

import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart' as dchs;
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../presentation/navigation/app_router.dart';
import '../../../attendance/presentation/widgets/beacon_scan_dialog.dart';
import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// BLE 비콘 인증 서비스
///
/// - iOS: dchs_flutter_beacon (CoreLocation CLBeaconRegion) 사용
/// - Android: flutter_blue_plus (CoreBluetooth) 사용
@Named('bluetooth')
@LazySingleton(as: VerificationStrategy)
class BluetoothVerificationService implements VerificationStrategy {
  // RSSI 기본 임계값 (이 값보다 약하면 무시)
  static const int defaultRssiThreshold = -80;

  /// iOS CoreLocation ranging에 사용하는 기본 iBeacon UUID
  ///
  /// iOS는 Region 단위로만 ranging이 가능하므로 광범위 스캔용 기본 UUID가 필요하다.
  /// 발견된 비콘의 매칭 판정은 서버에서 수행한다.
  static const String _defaultIBeaconUuid =
      'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0';

  @override
  VerificationMethod get method => VerificationMethod.bluetooth;

  @override
  Future<bool> isAvailable() async {
    if (Platform.isIOS) {
      // iOS: dchs_flutter_beacon 블루투스 상태 확인
      try {
        final state = await dchs.flutterBeacon.bluetoothState;
        return state == dchs.BluetoothState.stateOn;
      } catch (e) {
        debugPrint('[Beacon] iOS 블루투스 상태 확인 실패: $e');
        return false;
      }
    } else {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      // iOS: 블루투스 + 위치 권한 필요 (CoreLocation 기반)
      final btStatus = await Permission.bluetooth.request();
      final locStatus = await Permission.locationWhenInUse.request();
      debugPrint('[Beacon] iOS 권한 - BT: $btStatus, Location: $locStatus');
      return btStatus.isGranted && locStatus.isGranted;
    } else {
      // Android 12+: BLUETOOTH_SCAN + BLUETOOTH_CONNECT 둘 다 필요
      // (adapterState 조회와 BLE 스캔 양쪽에서 사용)
      final scanStatus = await Permission.bluetoothScan.request();
      final connectStatus = await Permission.bluetoothConnect.request();
      debugPrint('[Beacon] Android 권한 - Scan: $scanStatus, Connect: $connectStatus');
      return scanStatus.isGranted && connectStatus.isGranted;
    }
  }

  @override
  Future<VerificationResult> verify() async {
    // NFC 패턴: rootNavigatorKey에서 context 획득
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '비콘 인증 화면을 표시할 수 없습니다.',
      );
    }

    // 권한 확인
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '블루투스 권한이 필요합니다.',
      );
    }

    // 블루투스 상태 확인
    final isOn = await isAvailable();
    if (!isOn) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '블루투스를 켜주세요.',
      );
    }

    // 비콘 스캔 다이얼로그 표시
    final result = await BeaconScanDialog.show(context);

    // 사용자 취소 또는 스캔 실패
    if (result == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '비콘 스캔이 취소되었습니다.',
      );
    }

    return result;
  }

  /// 실제 BLE 스캔 수행 (다이얼로그 내부에서 호출)
  /// UI 로직 없이 순수 스캔만 실행
  Future<VerificationResult> performScan() async {
    try {
      if (Platform.isIOS) {
        return _verifyIos();
      } else {
        return _verifyAndroid();
      }
    } catch (e) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '비콘 스캔 실패: ${e.toString()}',
      );
    }
  }

  // ─── iOS: CoreLocation 기반 iBeacon ranging ───

  Future<VerificationResult> _verifyIos() async {
    try {
      // dchs_flutter_beacon 초기화
      await dchs.flutterBeacon.initializeScanning;
      debugPrint('[Beacon/iOS] 스캔 초기화 완료');

      // 스캔할 Region 설정 (기본 iBeacon UUID 1개로 ranging)
      // 클라이언트 사전 필터링 없이 광범위 스캔 후 결과를 서버 매칭에 위임한다.
      debugPrint('[Beacon/iOS] 기본 UUID로 ranging: $_defaultIBeaconUuid');

      final regions = <dchs.Region>[
        dchs.Region(
          identifier: 'workcheck-beacon-0',
          proximityUUID: _defaultIBeaconUuid,
        ),
      ];

      // 5초간 ranging (다중 Region 동시)
      final detectedBeacons = <Map<String, dynamic>>[];
      final completer = Completer<void>();

      debugPrint('[Beacon/iOS] ranging 시작 (5초, region=${regions.length}개)...');
      final subscription = dchs.flutterBeacon.ranging(regions).listen((result) {
        for (final beacon in result.beacons) {
          debugPrint('[Beacon/iOS] 발견 - UUID: ${beacon.proximityUUID}, '
              'Major: ${beacon.major}, Minor: ${beacon.minor}, '
              'RSSI: ${beacon.rssi}, accuracy: ${beacon.accuracy}m, '
              'proximity: ${beacon.proximity}');

          if (beacon.rssi >= defaultRssiThreshold || beacon.rssi == 0) {
            final exists = detectedBeacons.any((b) =>
                b['major'] == beacon.major && b['minor'] == beacon.minor);
            if (!exists) {
              detectedBeacons.add({
                'uuid': beacon.proximityUUID,
                'major': beacon.major,
                'minor': beacon.minor,
                'rssi': beacon.rssi,
                'accuracy': beacon.accuracy,
                'proximity': beacon.proximity.toString(),
              });
            }
          }
        }
      });

      // 5초 대기 후 종료
      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future;
      await subscription.cancel();

      debugPrint('[Beacon/iOS] ranging 완료 - 발견된 비콘: ${detectedBeacons.length}개');

      if (detectedBeacons.isEmpty) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: '주변에서 비콘을 찾을 수 없습니다.',
        );
      }

      return VerificationResult(
        method: method,
        isVerified: true,
        data: {
          'detected_devices': detectedBeacons,
          'device_count': detectedBeacons.length,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('[Beacon/iOS] 스캔 실패: $e');
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '비콘 스캔 실패: ${e.toString()}',
      );
    }
  }

  // ─── Android: flutter_blue_plus 기반 BLE 스캔 ───

  Future<VerificationResult> _verifyAndroid() async {
    final detectedBeacons = <Map<String, dynamic>>[];
    int totalDeviceCount = 0;
    final seenDeviceIds = <String>{};

    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final deviceId = result.device.remoteId.str;

        // 새로 발견된 디바이스 로깅
        if (!seenDeviceIds.contains(deviceId)) {
          seenDeviceIds.add(deviceId);
          totalDeviceCount++;
          final mfData = result.advertisementData.manufacturerData;
          debugPrint('[BLE/Android] 디바이스 #$totalDeviceCount: $deviceId, '
              'name: ${result.advertisementData.advName}, '
              'RSSI: ${result.rssi}, '
              'mfData keys: ${mfData.keys.map((k) => "0x${k.toRadixString(16)}").toList()}');
        }

        final beacon = parseIBeacon(result);
        if (beacon != null) {
          debugPrint('[Beacon/Android] iBeacon 파싱 - UUID: ${beacon['uuid']}, '
              'Major: ${beacon['major']}, Minor: ${beacon['minor']}, RSSI: ${result.rssi}');
          if (result.rssi >= defaultRssiThreshold) {
            final exists = detectedBeacons.any((b) =>
                b['uuid'] == beacon['uuid'] &&
                b['major'] == beacon['major'] &&
                b['minor'] == beacon['minor']);
            if (!exists) {
              detectedBeacons.add(beacon);
            }
          }
        }
      }
    });

    // 5초간 BLE 스캔
    debugPrint('[BLE/Android] 스캔 시작 (5초)...');
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    await subscription.cancel();

    debugPrint('[BLE/Android] 스캔 완료 - BLE: $totalDeviceCount개, iBeacon: ${detectedBeacons.length}개');

    if (detectedBeacons.isEmpty) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '주변에서 비콘을 찾을 수 없습니다.',
      );
    }

    return VerificationResult(
      method: method,
      isVerified: true,
      data: {
        'detected_devices': detectedBeacons,
        'device_count': detectedBeacons.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ─── Android용 iBeacon 파싱 (Apple manufacturerData) ───

  /// iBeacon 광고 데이터 파싱 (Android 전용)
  ///
  /// Apple iBeacon 프로토콜:
  /// - Company ID: 0x004C (Apple)
  /// - manufacturerData 구조 (23 bytes):
  ///   [0]    = 0x02 (iBeacon type)
  ///   [1]    = 0x15 (data length = 21)
  ///   [2-17] = UUID (16 bytes)
  ///   [18-19]= Major (2 bytes, big endian)
  ///   [20-21]= Minor (2 bytes, big endian)
  ///   [22]   = TX Power (1 byte, signed)
  static Map<String, dynamic>? parseIBeacon(ScanResult result) {
    final manufacturerData = result.advertisementData.manufacturerData;

    // Apple Company ID = 0x004C (76)
    final appleData = manufacturerData[0x004C];
    if (appleData == null || appleData.length < 23) return null;

    // iBeacon prefix 확인
    if (appleData[0] != 0x02 || appleData[1] != 0x15) return null;

    // UUID 추출 (bytes 2-17)
    final uuidBytes = appleData.sublist(2, 18);
    final uuid = _bytesToUuid(uuidBytes);

    // Major 추출 (bytes 18-19, big endian)
    final major = (appleData[18] << 8) | appleData[19];

    // Minor 추출 (bytes 20-21, big endian)
    final minor = (appleData[20] << 8) | appleData[21];

    // TX Power 추출 (byte 22, signed)
    final txPower = appleData[22].toSigned(8);

    return {
      'device_id': result.device.remoteId.str,
      'uuid': uuid,
      'major': major,
      'minor': minor,
      'rssi': result.rssi,
      'tx_power': txPower,
    };
  }

  /// 바이트 배열을 UUID 문자열로 변환
  /// 예: E2C56DB5-DFFB-48D2-B060-D0F5A71096E0
  static String _bytesToUuid(List<int> bytes) {
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-').toUpperCase();
  }
}
