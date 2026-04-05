import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/history_entity.dart';
import '../bloc/history_bloc.dart';
import '../widgets/attendance_detail_bottom_sheet.dart';
import '../widgets/history_list_view.dart';

/// 출퇴근 기록 화면
///
/// 월별 출퇴근 기록을 캘린더 또는 리스트 형태로 표시.
/// 우상단 버튼으로 캘린더/리스트 뷰 전환 가능.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // 현재 월 데이터를 초기 로드
      create: (_) => getIt<HistoryBloc>()
        ..add(HistoryEvent.started(
          month: DateTime(DateTime.now().year, DateTime.now().month),
        )),
      child: const _HistoryView(),
    );
  }
}

/// 출퇴근 기록 뷰 (상태 보유)
class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  /// 현재 표시 중인 월
  late DateTime _currentMonth;

  /// 리스트 뷰 여부 (false = 캘린더 뷰)
  bool _isListView = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  /// 년/월 선택 바텀시트를 표시하고 선택된 월로 데이터 갱신
  void _showYearMonthPicker() async {
    int tempYear = _currentMonth.year;
    int tempMonth = _currentMonth.month;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _YearMonthPicker(
          initialYear: tempYear,
          initialMonth: tempMonth,
          onChanged: (year, month) {
            tempYear = year;
            tempMonth = month;
          },
        );
      },
    );

    if (mounted) {
      final newMonth = DateTime(tempYear, tempMonth);
      setState(() {
        _currentMonth = newMonth;
      });
      // 월 변경 시 BLoC에 이벤트 발행
      context.read<HistoryBloc>().add(HistoryEvent.monthChanged(month: newMonth));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
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
            '출퇴근 기록',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              height: 1.4,
              letterSpacing: -0.5,
              color: const Color(0xFF000000),
            ),
          ),
          actions: [
            // 캘린더/리스트 뷰 전환 버튼
            IconButton(
              onPressed: () {
                setState(() {
                  _isListView = !_isListView;
                });
              },
              icon: SvgPicture.asset(
                _isListView
                    ? 'assets/icons/calendar.svg'
                    : 'assets/icons/menu.svg',
                width: 24.w,
                height: 24.h,
              ),
            ),
          ],
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 월 선택 셀렉터
                _buildMonthSelector(),
                SizedBox(height: 9.h),
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 월 선택 드롭다운 버튼
  Widget _buildMonthSelector() {
    return Padding(
      padding: EdgeInsets.only(left: 16.w),
      child: GestureDetector(
        onTap: _showYearMonthPicker,
        child: Container(
          height: 34.h,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.4,
                  letterSpacing: -0.5,
                  color: const Color(0xFF000000),
                ),
              ),
              SizedBox(width: 4.w),
              SvgPicture.asset(
                'assets/icons/dropdown.svg',
                width: 22.w,
                height: 22.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태에 따라 본문 위젯 빌드
  ///
  /// - 로딩: 스피너
  /// - 오류: 오류 메시지
  /// - 성공: 캘린더 또는 리스트 뷰
  Widget _buildBody(HistoryState state) {
    if (state.uiState == HistoryUiState.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2DDAA9)));
    }
    if (state.uiState == HistoryUiState.error) {
      return Center(
        child: Text(
          state.errorMessage ?? '오류가 발생했습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14.sp,
            color: const Color(0xFF374151),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: _isListView
          ? Center(
              child: HistoryListView(
                currentMonth: _currentMonth,
                records: state.records,
              ),
            )
          : Center(
              child: SizedBox(
                width: 343.w,
                child: Column(
                  children: [
                    _buildWeekdayHeader(),
                    _buildCalendarGrid(state.records),
                  ],
                ),
              ),
            ),
    );
  }

  /// 캘린더 뷰 요일 헤더 (일~토)
  Widget _buildWeekdayHeader() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final colors = [
      const Color(0xFFFF3B30), // 일 - 빨강
      const Color(0xFF000000), // 월
      const Color(0xFF000000), // 화
      const Color(0xFF000000), // 수
      const Color(0xFF000000), // 목
      const Color(0xFF000000), // 금
      const Color(0xFF007AFF), // 토 - 파랑
    ];

    return Container(
      width: 343.w,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        children: List.generate(7, (index) {
          return Expanded(
            child: Center(
              child: Text(
                weekdays[index],
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  height: 1.4,
                  letterSpacing: 0,
                  color: colors[index],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 캘린더 그리드 생성
  ///
  /// 해당 월의 모든 날짜를 7열 그리드로 배치.
  /// 첫 날의 요일에 맞게 오프셋 적용.
  Widget _buildCalendarGrid(Map<int, DailyRecordEntity> records) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    // 일요일=0 기준으로 첫 날 요일 계산
    final firstWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == _currentMonth.year && today.month == _currentMonth.month;

    // 전체 셀 수로 행 수 계산
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return SizedBox(
          width: 343.w,
          height: 94.h,
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - firstWeekday + 1;

              // 해당 월 범위 밖이면 빈 셀
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              final isToday = isCurrentMonth && dayNumber == today.day;
              final record = records[dayNumber];
              // 출퇴근 시간 포맷팅 (HH:mm)
              final clockIn = _formatTime(record?.clockIn?.timestamp);
              final clockOut = _formatTime(record?.clockOut?.timestamp);

              return Expanded(
                child: _buildDayCell(
                  day: dayNumber,
                  isToday: isToday,
                  clockIn: clockIn,
                  clockOut: clockOut,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  /// DateTime → HH:mm 포맷 변환
  String? _formatTime(DateTime? time) {
    if (time == null) return null;
    return DateFormat('HH:mm').format(time);
  }

  /// 요일 이름 목록 (1=월요일 ~ 7=일요일)
  static const _weekdayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];

  /// 날짜 셀 탭 시 상세 바텀시트 표시
  void _showDayDetail(int day, String? clockIn, String? clockOut) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    final weekdayName = _weekdayNames[date.weekday - 1];
    AttendanceDetailBottomSheet.show(
      context,
      day: day,
      weekdayName: weekdayName,
      clockIn: clockIn,
      clockOut: clockOut,
    );
  }

  /// 캘린더 개별 날짜 셀 위젯
  ///
  /// 오늘이면 원형 강조, 출퇴근 기록이 있으면 하단에 시간 표시.
  Widget _buildDayCell({
    required int day,
    required bool isToday,
    String? clockIn,
    String? clockOut,
  }) {
    return GestureDetector(
      onTap: () => _showDayDetail(day, clockIn, clockOut),
      child: SizedBox(
      height: 94.h,
      child: Column(
        children: [
          SizedBox(height: 14.h),
          // 날짜 숫자 (오늘이면 원형 강조)
          if (isToday)
            Container(
              width: 28.w,
              height: 28.w,
              decoration: const BoxDecoration(
                color: Color(0xFF2DDAA9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.4,
                  letterSpacing: 0,
                  color: Colors.white,
                ),
              ),
            )
          else
            SizedBox(
              height: 28.w,
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 1.4,
                    letterSpacing: 0,
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          // 출근 기록이 있을 때만 출퇴근 시간 표시
          if (clockIn != null) ...[
            SizedBox(height: 14.h),
            Column(
              spacing: 4.h,
              children: [
                Text(
                  clockIn,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.2,
                    letterSpacing: 0,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                // 퇴근 시간이 없으면 '-' 표시
                Text(
                  clockOut ?? '-',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    height: 1.2,
                    letterSpacing: 0,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    );
  }
}

/// 년/월 선택 바텀시트 위젯
///
/// 스크롤 휠로 연도와 월을 선택.
/// 선택 변경 시 [onChanged] 콜백 호출.
class _YearMonthPicker extends StatefulWidget {
  const _YearMonthPicker({
    required this.initialYear,
    required this.initialMonth,
    required this.onChanged,
  });

  final int initialYear;
  final int initialMonth;

  /// 연도/월 변경 콜백
  final void Function(int year, int month) onChanged;

  @override
  State<_YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<_YearMonthPicker> {
  /// 선택 가능한 연도 범위
  static const int _minYear = 2020;
  static const int _maxYear = 2030;

  /// 각 항목의 높이
  static const double _itemExtent = 49.0;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _selectedMonth = widget.initialMonth;
    // 초기 선택 위치로 스크롤 컨트롤러 초기화
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - _minYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 282.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(23.w, 42.h, 23.w, 42.h),
      child: Row(
        children: [
          // 연도 스크롤 휠
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _yearController,
              itemExtent: _itemExtent,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedYear = _minYear + index;
                });
                widget.onChanged(_selectedYear, _selectedMonth);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: _maxYear - _minYear + 1,
                builder: (context, index) {
                  final year = _minYear + index;
                  final isSelected = year == _selectedYear;
                  return _buildPickerItem(
                    '$year년',
                    isSelected: isSelected,
                    onTap: () {
                      _yearController.animateToItem(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 18.w),
          // 월 스크롤 휠
          Expanded(
            child: ListWheelScrollView.useDelegate(
              controller: _monthController,
              itemExtent: _itemExtent,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.003,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedMonth = index + 1;
                });
                widget.onChanged(_selectedYear, _selectedMonth);
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 12,
                builder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedMonth;
                  return _buildPickerItem(
                    '${month.toString().padLeft(2, '0')}월',
                    isSelected: isSelected,
                    onTap: () {
                      _monthController.animateToItem(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 스크롤 휠 개별 항목 위젯
  ///
  /// 선택된 항목은 회색 배경과 굵은 폰트로 강조.
  Widget _buildPickerItem(
    String text, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155.w,
        height: 49.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFEFEFF0),
                borderRadius: BorderRadius.circular(10.r),
              )
            : null,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 20.sp,
            height: 1.4,
            letterSpacing: 0,
            color: isSelected
                ? const Color(0xFF000000)
                : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
