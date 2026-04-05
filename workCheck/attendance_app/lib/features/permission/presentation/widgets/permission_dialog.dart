import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/entities/permission_status_entity.dart';
import '../bloc/permission_bloc.dart';

/// 권한 요청 다이얼로그
///
/// 앱 실행 시 필요한 권한 목록을 보여주고 허용을 요청.
/// 모든 권한이 허용되면 자동으로 닫힘.
/// 영구 거부된 권한이 있으면 설정 앱으로 이동하는 버튼 표시.
class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  /// 기존 [PermissionBloc]을 주입하여 다이얼로그 표시
  static Future<void> show(BuildContext context, PermissionBloc bloc) {
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 불가
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const PermissionDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PermissionBloc, PermissionState>(
      // 모든 권한 허용 시에만 listen
      listenWhen: (prev, curr) =>
          curr.uiState == PermissionUiState.allGranted,
      listener: (context, state) {
        // 모든 권한 허용 시 다이얼로그 자동 닫기
        if (state.uiState == PermissionUiState.allGranted) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀: Bold 22sp, 140%, -2%
                Text(
                  '서비스 이용을 위해\n다음 권한이 필요합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    height: 1.4,
                    letterSpacing: 22.sp * -0.02,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.h),

                // 권한 목록
                ...state.permissionItems.map(
                  (item) => _PermissionItemRow(item: item),
                ),

                // 영구 거부 상태일 때 안내 문구 표시
                if (state.uiState == PermissionUiState.permanentlyDenied)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      '일부 권한이 차단되었습니다.\n설정에서 직접 허용해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),

                SizedBox(height: 24.h),

                // 확인/설정으로 이동 버튼
                SizedBox(
                  width: 295.w,
                  height: 57.h,
                  child: ElevatedButton(
                    // 요청 처리 중에는 버튼 비활성화
                    onPressed:
                        state.uiState == PermissionUiState.requesting
                            ? null
                            : () {
                                if (state.uiState ==
                                    PermissionUiState.permanentlyDenied) {
                                  // 영구 거부: 설정 앱으로 이동
                                  context.read<PermissionBloc>().add(
                                        const PermissionOpenSettingsRequested(),
                                      );
                                } else {
                                  // 일반: 권한 요청
                                  context.read<PermissionBloc>().add(
                                        const PermissionRequested(),
                                      );
                                }
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DDAA9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      state.uiState == PermissionUiState.permanentlyDenied
                          ? '설정으로 이동'
                          : '확인',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 개별 권한 항목 행 위젯
///
/// 아이콘, 권한 이름, 설명을 한 행으로 표시.
class _PermissionItemRow extends StatelessWidget {
  const _PermissionItemRow({required this.item});

  final PermissionItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          // 권한 아이콘 (38x38)
          SvgPicture.asset(
            item.iconAsset,
            width: 38.w,
            height: 38.w,
          ),
          SizedBox(width: 12.w),
          // 권한 이름 + 설명 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 권한 이름: Medium 14sp, 140%, -2%, #000000
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    height: 1.4,
                    letterSpacing: 14.sp * -0.02,
                    color: const Color(0xFF000000),
                  ),
                ),
                // 권한 설명: Medium 12sp, 140%, -2%
                Text(
                  item.description,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.4,
                    letterSpacing: 12.sp * -0.02,
                    color: const Color(0xFF8E91A3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
