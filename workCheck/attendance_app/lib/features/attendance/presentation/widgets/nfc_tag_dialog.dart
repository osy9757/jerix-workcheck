import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../core/utils/nfc_tag_helper.dart';

/// NFC 태그 대기 다이얼로그
///
/// NFC 세션을 시작하고 사용자가 NFC 태그를 갖다 대기를 기다림.
/// 태그 감지 성공 시 태그 ID 문자열을 반환하며 다이얼로그가 닫힘.
/// 취소 시 null 반환.
class NfcTagDialog extends StatefulWidget {
  const NfcTagDialog({super.key});

  /// 다이얼로그를 표시하는 정적 메서드
  ///
  /// 반환값: 감지된 NFC 태그 ID (취소 또는 실패 시 null)
  static Future<String?> show(BuildContext context) {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const NfcTagDialog(),
    );
  }

  @override
  State<NfcTagDialog> createState() => _NfcTagDialogState();
}

class _NfcTagDialogState extends State<NfcTagDialog> {
  bool _isSessionActive = false;

  @override
  void initState() {
    super.initState();
    _startNfcSession();
  }

  Future<void> _startNfcSession() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    debugPrint('[NFC] isAvailable: $isAvailable');
    if (!isAvailable) {
      debugPrint('[NFC] NFC를 사용할 수 없습니다');
      if (mounted) Navigator.of(context).pop(null);
      return;
    }

    setState(() => _isSessionActive = true);
    try {
      debugPrint('[NFC] 세션 시작...');
      await NfcManager.instance.startSession(
        alertMessageIos: 'NFC 태그를 iPhone 상단에 갖다 대주세요',
        invalidateAfterFirstReadIos: true,
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693, NfcPollingOption.iso18092},
        onSessionErrorIos: (error) {
          debugPrint('[NFC] 세션 에러: ${error.message}');
          _isSessionActive = false;
          if (mounted) Navigator.of(context).pop(null);
        },
        onDiscovered: (NfcTag tag) async {
          try {
            debugPrint('[NFC] 태그 발견');

            // 플랫폼별 태그 identifier 추출 (nfc_tag_helper에 격리)
            final tagInfo = extractTagInfo(tag);
            debugPrint('[NFC] tagType: ${tagInfo.tagType}');

            final tagId = tagInfo.uid;
            if (tagId == 'unknown') {
              debugPrint('[NFC] identifier가 null이거나 비어있음');
            }

            debugPrint('[NFC] Tag UID: ${tagId.toUpperCase()}');

            _isSessionActive = false;
            try {
              await NfcManager.instance.stopSession();
            } catch (e) {
              debugPrint('[NFC] stopSession 실패: $e');
            }
            HapticFeedback.mediumImpact();

            if (mounted) {
              Navigator.of(context).pop(tagId);
            }
          } catch (e, stackTrace) {
            debugPrint('[NFC] onDiscovered 예외: $e');
            debugPrint('[NFC] stackTrace: $stackTrace');

            _isSessionActive = false;
            try {
              await NfcManager.instance.stopSession();
            } catch (_) {}
            if (mounted) {
              Navigator.of(context).pop(null);
            }
          }
        },
      );
      debugPrint('[NFC] 세션 시작 완료, 태그 대기 중...');
    } catch (e) {
      debugPrint('[NFC] 세션 시작 실패: $e');
      _isSessionActive = false;
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  @override
  void dispose() {
    if (_isSessionActive) {
      _isSessionActive = false;
      try {
        NfcManager.instance.stopSession();
      } catch (e) {
        debugPrint('[NFC] dispose stopSession 실패: $e');
      }
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
                  Lottie.asset(
                    'assets/lottie/nfc_motion.json',
                    width: 80.w,
                    height: 80.w,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'NFC를 태그해주세요',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      height: 1.4,
                      letterSpacing: 18.sp * -0.02,
                      color: const Color(0xFF000000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.h),
            SizedBox(
              width: 295.w,
              height: 57.h,
              child: ElevatedButton(
                onPressed: () async {
                  if (_isSessionActive) {
                    _isSessionActive = false;
                    await NfcManager.instance.stopSession();
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
