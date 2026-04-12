import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 보안 숫자 키패드 위젯
///
/// 비밀번호 입력 시 사용하는 보안 강화 키패드.
/// 숫자 0~9를 매 입력마다 무작위로 섞어 화면 터치 패턴 추적을 방지.
/// 4열 3행 + 하단 행 (백스페이스 / 빈칸 / 빈칸 / 입력완료) 구성.
class SecureNumberPad extends StatefulWidget {
  const SecureNumberPad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.submitEnabled = false,
  });

  /// 숫자 키 클릭 콜백 (눌린 숫자 문자열 전달)
  final ValueChanged<String> onKeyPressed;

  /// 백스페이스 키 클릭 콜백
  final VoidCallback onBackspace;

  /// 입력완료 키 클릭 콜백
  final VoidCallback onSubmit;

  /// 입력완료 버튼 활성화 여부
  final bool submitEnabled;

  @override
  State<SecureNumberPad> createState() => _SecureNumberPadState();
}

class _SecureNumberPadState extends State<SecureNumberPad> {
  /// 현재 키패드에 표시된 숫자 배열 (null = 빈 셀)
  List<int?> _keypadNumbers = [];

  @override
  void initState() {
    super.initState();
    _shuffleKeypad();
  }

  /// 키패드 숫자를 무작위로 섞음 (0~9 + 빈칸 2개, 총 12칸)
  void _shuffleKeypad() {
    _keypadNumbers = <int?>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, null, null]
      ..shuffle();
  }

  /// 숫자 키 클릭 처리
  void _onNumberTap(int number) {
    widget.onKeyPressed('$number');
  }

  /// 백스페이스 클릭 처리
  void _onBackspaceTap() {
    widget.onBackspace();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 구분선
          Container(
            height: 1,
            color: const Color(0xFFE9EBF1),
          ),
          // 숫자 키 3행 (각 행 4열)
          for (int row = 0; row < 3; row++)
            SizedBox(
              height: 56.h,
              child: Row(
                children: List.generate(4, (col) {
                  final index = row * 4 + col;
                  final number = _keypadNumbers[index];
                  return _buildNumberCell(number);
                }),
              ),
            ),
          // 하단 행: 백스페이스 / 빈칸 / 빈칸 / 입력완료
          SizedBox(
            height: 56.h,
            child: Row(
              children: [
                _buildBackspaceCell(),
                _buildEmptyCell(),
                _buildEmptyCell(),
                _buildSubmitCell(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 숫자 셀 위젯 (null이면 빈 셀 반환)
  Widget _buildNumberCell(int? number) {
    if (number == null) {
      return _buildEmptyCell();
    }
    return Expanded(
      child: InkWell(
        onTap: () => _onNumberTap(number),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 22.sp,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// 빈 셀 위젯 (터치 이벤트만 흡수, 시각적으로 비어있음)
  Widget _buildEmptyCell() {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  /// 백스페이스 셀 위젯
  Widget _buildBackspaceCell() {
    return Expanded(
      child: InkWell(
        onTap: _onBackspaceTap,
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 22.sp,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  /// 입력완료 셀 위젯
  ///
  /// [submitEnabled]가 false이면 회색으로 비활성화 표시.
  Widget _buildSubmitCell() {
    return Expanded(
      child: InkWell(
        onTap: widget.submitEnabled ? widget.onSubmit : null,
        child: Center(
          child: Text(
            '입력완료',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: widget.submitEnabled
                  ? const Color(0xFF2DDAA9)
                  : const Color(0xFFB0B3C0),
            ),
          ),
        ),
      ),
    );
  }
}
