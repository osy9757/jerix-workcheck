# Quick Fix: Attendance Status Card
Generated: 2026-02-19

## Change Made
- File: `attendance_app/lib/features/attendance/presentation/screens/attendance_screen.dart`

### 1. State variables (lines 17-19)
Added `_clockInTime` and `_clockOutTime` after `_isClockedIn`.

### 2. onTap handler (lines 213-232)
Updated to capture `now` before showing the dialog, then conditionally set `_clockInTime` or `_clockOutTime` depending on current clock-in state.

### 3. Column children (lines 39-41)
Added `SizedBox(height: 14.h)` and `_buildStatusCard()` call after `_buildMapSection()`.

### 4. `_buildStatusCard()` method (lines 270-397)
New method inserted before `_buildMapSection()`. Renders a white card with rounded corners and a two-column Row showing 출근/퇴근 times. Displays `-` when the respective time is null.

## Verification
- File structure: PASS (all braces balanced, 463 lines total)
- `intl` import already present for `DateFormat`
- All `screenutil` sizing conventions followed (.w, .h, .sp, .r)
- Pattern followed: existing Pretendard text style convention

## Files Modified
1. `attendance_app/lib/features/attendance/presentation/screens/attendance_screen.dart` - added status card section and time tracking state
