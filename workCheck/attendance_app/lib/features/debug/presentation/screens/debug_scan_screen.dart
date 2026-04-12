import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:dchs_flutter_beacon/dchs_flutter_beacon.dart' as beacon;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/nfc_tag_helper.dart';
import '../../../auth/data/datasources/local/auth_local_datasource.dart';

/// 디버그 스캔 화면
///
/// 메인 화면 이름 5초 롱프레스로 진입.
/// NFC 태그 ID, 주변 Beacon, WiFi 정보를 스캔하여 확인할 수 있다.
/// 로그아웃 기능도 포함.
class DebugScanScreen extends StatefulWidget {
  const DebugScanScreen({super.key});

  @override
  State<DebugScanScreen> createState() => _DebugScanScreenState();
}

class _DebugScanScreenState extends State<DebugScanScreen> {
  /// 현재 선택된 스캔 모드
  _ScanMode _currentMode = _ScanMode.none;

  /// 스캔 진행 중 여부
  bool _isScanning = false;

  /// 스캔 결과 목록
  final List<String> _results = [];

  /// NFC 세션 활성 여부
  bool _nfcSessionActive = false;

  /// BLE 스캔 구독 (Android)
  StreamSubscription? _bleSubscription;

  /// Beacon ranging 구독 (iOS)
  StreamSubscription? _beaconSubscription;

  @override
  void dispose() {
    _stopAllScans();
    super.dispose();
  }

  /// 모든 스캔 중지
  void _stopAllScans() {
    if (_nfcSessionActive) {
      NfcManager.instance.stopSession();
      _nfcSessionActive = false;
    }
    _beaconSubscription?.cancel();
    _beaconSubscription = null;
    _bleSubscription?.cancel();
    _bleSubscription = null;
    FlutterBluePlus.stopScan();
  }

  /// 로그아웃 처리
  Future<void> _handleLogout() async {
    final authLocal = getIt<AuthLocalDatasource>();
    await authLocal.clearAll();
    if (!mounted) return;
    context.go('/login');
  }

  /// NFC 스캔 시작
  Future<void> _startNfcScan() async {
    _stopAllScans();
    setState(() {
      _currentMode = _ScanMode.nfc;
      _isScanning = true;
      _results.clear();
      _results.add('📱 NFC 태그를 기기 뒷면에 대주세요...');
    });

    final availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      setState(() {
        _results.clear();
        _results.add('❌ NFC를 사용할 수 없습니다. 설정에서 NFC를 활성화해주세요.');
        _isScanning = false;
      });
      return;
    }

    _nfcSessionActive = true;
    // startSession은 await하지 않음 — 세션이 열린 상태로 태그 대기
    // onDiscovered 콜백에서 결과를 처리하고 세션을 종료
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        final tagInfo = extractTagInfo(tag);
        if (mounted) {
          setState(() {
            _results.clear();
            _results.add('✅ NFC 태그 감지됨');
            _results.add('');
            _results.add('태그 타입: ${tagInfo.tagType}');
            _results.add('태그 ID:  ${tagInfo.uid}');
            _results.add('');
            _results.add('Raw bytes: ${tagInfo.identifier}');
            _isScanning = false;
          });
        }
        await NfcManager.instance.stopSession();
        _nfcSessionActive = false;
      },
    ).catchError((e) {
      if (mounted) {
        setState(() {
          _results.clear();
          _results.add('❌ NFC 오류: $e');
          _isScanning = false;
        });
      }
      _nfcSessionActive = false;
    });
  }

  /// Beacon 스캔 시작
  Future<void> _startBeaconScan() async {
    _stopAllScans();
    setState(() {
      _currentMode = _ScanMode.beacon;
      _isScanning = true;
      _results.clear();
      _results.add('🔍 주변 비콘 스캔 중... (5초)');
    });

    // iOS: 블루투스 + 위치, Android: 블루투스 스캔
    if (Platform.isIOS) {
      await Permission.bluetooth.request();
      await Permission.locationWhenInUse.request();
    } else {
      await Permission.bluetoothScan.request();
      await Permission.locationWhenInUse.request();
    }

    final detectedBeacons = <String, Map<String, dynamic>>{};

    if (Platform.isIOS) {
      // iOS: CoreBluetooth는 iBeacon 광고 데이터를 숨기므로
      // dchs_flutter_beacon (CoreLocation ranging)을 사용
      // 반드시 initializeScanning 호출 후 ranging 가능
      const knownUuids = [
        'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0',
        '99999999-9999-9999-9999-999999999999',
        '22222222-2222-2222-2222-222222222222',
      ];
      final regions = knownUuids
          .map((uuid) => beacon.Region(identifier: 'debug-$uuid', proximityUUID: uuid))
          .toList();
      try {
        // 출근 로직(bluetooth_service)과 동일한 초기화 — 이 없으면 iOS에서 ranging 불가
        await beacon.flutterBeacon.initializeScanning;
        _beaconSubscription = beacon.flutterBeacon.ranging(regions).listen((result) {
          for (final b in result.beacons) {
            final key = '${b.proximityUUID}-${b.major}-${b.minor}';
            detectedBeacons[key] = {
              'uuid': b.proximityUUID,
              'major': b.major,
              'minor': b.minor,
              'rssi': b.rssi,
              'accuracy': b.accuracy.toStringAsFixed(2),
            };
          }
        });
      } catch (e) {
        debugPrint('[DebugScan] iOS beacon ranging 오류: $e');
      }
    } else {
      // Android: flutter_blue_plus BLE 스캔으로 iBeacon manufacturer data 파싱
      _bleSubscription = FlutterBluePlus.onScanResults.listen((results) {
        for (final r in results) {
          final mfData = r.advertisementData.manufacturerData;
          final appleData = mfData[0x004C];
          if (appleData != null && appleData.length >= 23 &&
              appleData[0] == 0x02 && appleData[1] == 0x15) {
            final uuid = _parseUuid(appleData.sublist(2, 18));
            final major = (appleData[18] << 8) + appleData[19];
            final minor = (appleData[20] << 8) + appleData[21];
            final key = '$uuid-$major-$minor';
            detectedBeacons[key] = {
              'uuid': uuid,
              'major': major,
              'minor': minor,
              'rssi': r.rssi,
            };
          }
        }
      });
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    }

    // 6초 대기 후 결과 수집
    await Future.delayed(const Duration(seconds: 6));
    _beaconSubscription?.cancel();
    _beaconSubscription = null;
    _bleSubscription?.cancel();
    _bleSubscription = null;

    if (!mounted) return;
    setState(() {
      _results.clear();
      if (detectedBeacons.isEmpty) {
        _results.add('❌ 주변에 비콘이 감지되지 않았습니다.');
      } else {
        _results.add('✅ ${detectedBeacons.length}개 비콘 감지됨');
        _results.add('');
        var i = 1;
        for (final entry in detectedBeacons.values) {
          _results.add('── 비콘 $i ──');
          _results.add('UUID:  ${entry['uuid']}');
          _results.add('Major: ${entry['major']}');
          _results.add('Minor: ${entry['minor']}');
          _results.add('RSSI:  ${entry['rssi']} dBm');
          if (entry.containsKey('accuracy')) {
            _results.add('거리:  ~${entry['accuracy']}m');
          }
          _results.add('');
          i++;
        }
      }
      _isScanning = false;
    });
  }

  /// UUID 바이트 배열을 문자열로 변환
  String _parseUuid(List<int> bytes) {
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}'.toUpperCase();
  }

  /// WiFi 스캔 시작
  Future<void> _startWifiScan() async {
    _stopAllScans();
    setState(() {
      _currentMode = _ScanMode.wifi;
      _isScanning = true;
      _results.clear();
      _results.add('🔍 WiFi 정보 조회 중...');
    });

    await Permission.locationWhenInUse.request();

    try {
      final networkInfo = NetworkInfo();
      final ssid = await networkInfo.getWifiName();
      final bssid = await networkInfo.getWifiBSSID();
      final ip = await networkInfo.getWifiIP();
      final gateway = await networkInfo.getWifiGatewayIP();
      final subnet = await networkInfo.getWifiSubmask();

      if (!mounted) return;
      setState(() {
        _results.clear();
        if (ssid == null && bssid == null) {
          _results.add('❌ WiFi에 연결되어 있지 않습니다.');
        } else {
          _results.add('✅ WiFi 연결 정보');
          _results.add('');
          _results.add('SSID:    ${ssid?.replaceAll('"', '') ?? "알 수 없음"}');
          _results.add('BSSID:   ${bssid ?? "알 수 없음"}');
          _results.add('IP:      ${ip ?? "알 수 없음"}');
          _results.add('게이트웨이: ${gateway ?? "알 수 없음"}');
          _results.add('서브넷:   ${subnet ?? "알 수 없음"}');
        }
        _isScanning = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _results.clear();
        _results.add('❌ WiFi 정보 조회 실패: $e');
        _isScanning = false;
      });
    }
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
          '디버그 스캔',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),

            // 스캔 모드 버튼들
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildModeButton('NFC', Icons.nfc, _ScanMode.nfc, _startNfcScan),
                  SizedBox(width: 8.w),
                  _buildModeButton('Beacon', Icons.bluetooth_searching, _ScanMode.beacon, _startBeaconScan),
                  SizedBox(width: 8.w),
                  _buildModeButton('WiFi', Icons.wifi, _ScanMode.wifi, _startWifiScan),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // 결과 영역
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '스캔 결과',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                        if (_isScanning)
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2DDAA9),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: _results.isEmpty
                          ? Center(
                              child: Text(
                                '위 버튼을 눌러 스캔을 시작하세요',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 14.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final line = _results[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  child: SelectableText(
                                    line,
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontSize: 14.sp,
                                      height: 1.5,
                                      fontWeight: line.startsWith('✅') || line.startsWith('❌') || line.startsWith('──')
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: line.startsWith('❌')
                                          ? const Color(0xFFEF4444)
                                          : line.startsWith('✅')
                                              ? const Color(0xFF2DDAA9)
                                              : const Color(0xFF374151),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // 로그아웃 버튼
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// 스캔 모드 선택 버튼
  Widget _buildModeButton(String label, IconData icon, _ScanMode mode, VoidCallback onTap) {
    final isActive = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: _isScanning ? null : onTap,
        child: Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2DDAA9) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isActive ? const Color(0xFF2DDAA9) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28.w,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 스캔 모드 구분
enum _ScanMode { none, nfc, beacon, wifi }
