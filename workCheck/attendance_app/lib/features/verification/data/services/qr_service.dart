import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// QR코드 스캔 기반 출퇴근 인증 서비스
///
/// mobile_scanner 패키지를 사용하여 카메라로 QR코드를 인식한다.
/// UI 레이어에서 [createController]로 컨트롤러를 받아 위젯에 연결하고,
/// 스캔 성공 시 [onDetect]를 호출하면 [verify]의 Future가 완료된다.
@Named('qr')
@LazySingleton(as: VerificationStrategy)
class QrVerificationService implements VerificationStrategy {
  /// 카메라 스캔 컨트롤러 (UI 위젯과 공유)
  MobileScannerController? _controller;

  /// 스캔 결과를 비동기로 전달하기 위한 Completer
  Completer<VerificationResult>? _completer;

  @override
  VerificationMethod get method => VerificationMethod.qr;

  /// QR 스캔은 기기 카메라가 있으면 항상 가능
  @override
  Future<bool> isAvailable() async => true;

  /// 카메라 권한은 mobile_scanner 라이브러리가 내부적으로 처리
  @override
  Future<bool> requestPermissions() async => true;

  /// QR 스캔 컨트롤러 생성 후 UI에 반환
  ///
  /// UI 위젯의 MobileScanner에 이 컨트롤러를 넘겨 카메라 프리뷰를 표시한다.
  MobileScannerController createController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,  // 후면 카메라 사용
    );
    return _controller!;
  }

  /// QR 코드 감지 콜백 (UI에서 onDetect 이벤트 수신 시 호출)
  ///
  /// 유효한 바코드 데이터가 있을 때만 Completer를 완료시키고 스캔을 멈춘다.
  void onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null || _completer == null || _completer!.isCompleted) return;

    _completer!.complete(VerificationResult(
      method: method,
      isVerified: true,
      data: {
        'qr_data': barcode!.rawValue!,        // QR에 인코딩된 원본 데이터
        'format': barcode.format.name,         // 바코드 포맷 (qrCode 등)
        'timestamp': DateTime.now().toIso8601String(),
      },
    ));

    // 결과를 얻었으므로 스캔 중단
    _controller?.stop();
  }

  /// QR 인증 실행
  ///
  /// Completer를 생성하고 [onDetect]가 완료시킬 때까지 대기한다.
  /// 30초 내에 스캔되지 않으면 타임아웃 실패 결과를 반환한다.
  @override
  Future<VerificationResult> verify() async {
    _completer = Completer<VerificationResult>();

    // 타임아웃 30초
    return _completer!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _controller?.stop();
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: 'QR코드 스캔 시간이 초과되었습니다.',
        );
      },
    );
  }

  /// 컨트롤러 및 카메라 리소스 해제
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
