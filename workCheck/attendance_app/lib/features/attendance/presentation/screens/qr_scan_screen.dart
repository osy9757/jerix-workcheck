import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../widgets/qr_scan_overlay.dart';

/// QR 코드 스캔 화면
///
/// 카메라를 통해 QR 코드를 인식하고 결과를 반환.
/// 스캔 성공 시 QR 원본 문자열을 pop하며 종료.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  /// MobileScanner 컨트롤러 (후면 카메라, 일반 속도)
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  /// 중복 처리 방지 플래그
  bool _isProcessing = false;

  /// QR 코드 감지 콜백
  ///
  /// 이미 처리 중이거나 바코드가 비어있으면 무시.
  /// 유효한 바코드 감지 시 원본 문자열을 반환하며 화면 종료.
  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null || barcode.rawValue!.isEmpty) return;

    _isProcessing = true;
    // 스캔된 QR 원본 문자열을 호출자에게 반환
    Navigator.of(context).pop(barcode.rawValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.chevron_left,
              color: const Color(0xFF000000),
              size: 28.w,
            ),
          ),
          title: Text(
            '출퇴근 스캔',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFF000000),
            ),
          ),
        ),
        body: Stack(
          children: [
            // 카메라 뷰
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
            // QR 스캔 영역 오버레이
            const QrScanOverlay(),
          ],
        ),
      ),
    );
  }
}
