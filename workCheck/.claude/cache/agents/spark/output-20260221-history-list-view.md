# Quick Fix: Create HistoryListView Widget
Generated: 2026-02-21

## Change Made
- File: `lib/features/attendance/presentation/widgets/history_list_view.dart`
- Line(s): 1-54
- Change: 신규 파일 생성 - 특정 월의 모든 날짜를 HistoryDayRow 리스트로 렌더링하는 위젯

## Verification
- Pattern followed: 기존 위젯(today_status_card.dart) 패턴 참고, StatelessWidget + const 생성자
- screenutil: `.w` 사용 (343.w)
- Dart Record 타입: `(String, String?)` positional record 사용

## Files Modified
1. `lib/features/attendance/presentation/widgets/history_list_view.dart` - 신규 생성

## Notes
- `HistoryDayRow`는 아직 존재하지 않음. 이 파일과 함께 생성 필요
- mockData 타입에 Dart Record `(String, String?)` 사용 - Dart 3.0+ 필요
- totalHours는 mock이므로 출퇴근 모두 있을 때 "00시간" 고정값 반환
- days 리스트는 lastDay.day 기반으로 생성하여 월별 날짜 수 자동 처리
