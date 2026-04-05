import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// QR 스캔 화면의 오버레이 위젯
///
/// 반투명 어두운 배경 위에 스캔 영역(투명 사각형)과
/// 모서리 브라켓을 그려서 QR 코드 인식 영역을 안내함.
class QrScanOverlay extends StatelessWidget {
  const QrScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 스캔 영역 크기 계산
        final scanWidth = 297.w;
        final scanHeight = 286.h;
        // 화면 중앙에서 약간 위쪽에 배치
        final left = (constraints.maxWidth - scanWidth) / 2;
        final top = (constraints.maxHeight - scanHeight) / 2 - 40.h;

        final scanRect = Rect.fromLTWH(left, top, scanWidth, scanHeight);

        return Stack(
          children: [
            // 오버레이 + 스캔 영역 컷아웃 페인터
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScanOverlayPainter(scanRect: scanRect),
            ),
            // 스캔 안내 문구 (스캔 영역 아래에 표시)
            Positioned(
              left: scanRect.left,
              top: scanRect.bottom + 20.h,
              width: scanRect.width,
              child: Text(
                'QR코드를 사각형 안에 맞춰주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  height: 1.4,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// QR 스캔 오버레이를 그리는 CustomPainter
///
/// - 화면 전체에 반투명 검은 배경 적용
/// - 스캔 영역만 투명하게 컷아웃
/// - 스캔 영역 네 모서리에 초록색 브라켓 표시
class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({required this.scanRect});

  /// 투명하게 뚫릴 스캔 영역
  final Rect scanRect;

  @override
  void paint(Canvas canvas, Size size) {
    // 반투명 검은 배경 페인트
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7);

    // 전체 화면 경로에서 스캔 영역을 뺀 차집합으로 오버레이 그리기
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(4.r)));
    final combinedPath = Path.combine(PathOperation.difference, overlayPath, cutoutPath);
    canvas.drawPath(combinedPath, overlayPaint);

    // 모서리 브라켓 페인트 설정
    final cornerPaint = Paint()
      ..color = const Color(0xFF2DDAA9)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 브라켓 길이
    final cornerSize = 36.w;

    // 좌상단 모서리
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerSize),
      Offset(scanRect.left, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerSize, scanRect.top),
      cornerPaint,
    );

    // 우상단 모서리
    canvas.drawLine(
      Offset(scanRect.right - cornerSize, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerSize),
      cornerPaint,
    );

    // 좌하단 모서리
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom - cornerSize),
      Offset(scanRect.left, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left + cornerSize, scanRect.bottom),
      cornerPaint,
    );

    // 우하단 모서리
    canvas.drawLine(
      Offset(scanRect.right - cornerSize, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) {
    // 스캔 영역이 변경된 경우에만 다시 그림
    return oldDelegate.scanRect != scanRect;
  }
}
