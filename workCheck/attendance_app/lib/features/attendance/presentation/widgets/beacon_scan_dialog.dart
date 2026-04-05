import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart';
import '../../../verification/data/services/bluetooth_service.dart';
import '../../../verification/domain/verification_result.dart';
import '../../../verification/domain/verification_strategy.dart';

/// 비콘 스캔 다이얼로그
///
/// 블루투스 비콘 스캔을 시작하고 결과를 기다리는 다이얼로그.
/// 스캔 완료 시 [VerificationResult]를 반환하며 닫힘.
/// 취소 또는 실패 시 null 반환.
class BeaconScanDialog extends StatefulWidget {
  const BeaconScanDialog({super.key});

  /// 다이얼로그를 표시하는 정적 메서드
  ///
  /// 반환값: 비콘 인증 결과 (취소 또는 실패 시 null)
  static Future<VerificationResult?> show(BuildContext context) {
    return showDialog<VerificationResult?>(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 불가
      builder: (_) => const BeaconScanDialog(),
    );
  }

  @override
  State<BeaconScanDialog> createState() => _BeaconScanDialogState();
}

class _BeaconScanDialogState extends State<BeaconScanDialog>
    with SingleTickerProviderStateMixin {
  /// 스캔 진행 중 여부 (dispose 시 스캔 종료에 활용)
  bool _isScanning = false;

  /// 펄스 애니메이션 컨트롤러
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // 펄스 애니메이션 초기화 (1초 주기 반복)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    // 위젯 생성 즉시 비콘 스캔 시작
    _startBeaconScan();
  }

  /// 비콘 스캔 시작
  ///
  /// BluetoothVerificationService에서 직접 스캔을 수행하고
  /// 결과를 Navigator를 통해 반환함. (순환 호출 방지)
  Future<void> _startBeaconScan() async {
    setState(() => _isScanning = true);
    try {
      // BluetoothVerificationService에서 직접 스캔 수행 (순환 호출 방지)
      final service = getIt<VerificationStrategy>(instanceName: 'bluetooth') as BluetoothVerificationService;
      final result = await service.performScan();

      _isScanning = false;
      // 스캔 완료 시 햅틱 피드백
      HapticFeedback.mediumImpact();

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      debugPrint('[Beacon] 스캔 오류: $e');
      _isScanning = false;
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // 스캔 중이면 종료
    if (_isScanning) {
      _isScanning = false;
      FlutterBluePlus.stopScan();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: 342.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: Column(
                children: [
                  // 비콘 스캔 중 펄스 애니메이션
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 0.85 + (_pulseController.value * 0.15);
                      final opacity = 0.6 + (_pulseController.value * 0.4);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/Beacon_on.svg',
                      width: 80.w,
                      height: 80.w,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 안내 문구
                  Text(
                    '비콘을 검색하고 있습니다',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      height: 1.4,
                      letterSpacing: 18.sp * -0.02,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.h),
            // 취소 버튼: 스캔 중단 후 null 반환
            SizedBox(
              width: 295.w,
              height: 57.h,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isScanning) {
                    _isScanning = false;
                    await FlutterBluePlus.stopScan();
                  }
                  if (mounted) Navigator.of(context).pop(null);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDAA9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '취소',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    height: 1.4,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
