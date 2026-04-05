# Quick Fix: Replace "기기 ID" with "회사 코드" and "사원번호" fields
Generated: 2026-02-18

## Change Made
- File: `attendance_app/lib/features/auth/presentation/screens/register_screen.dart`
- Lines changed: 18-19, 28-32, 96-97, 157-181

## Changes Summary

1. **Controllers** (lines 18-19): Removed `_deviceIdController`, added `_companyCodeController` and `_employeeIdController`

2. **`_isFormValid`** (lines 28-32): Now also checks company code and employee ID are non-empty

3. **`dispose()`** (lines 96-97): Replaced `_deviceIdController.dispose()` with both new controller dispose calls

4. **Build method** (lines 157-181): Replaced the "기기 ID" section (label + field + 52.h gap) with two new sections:
   - 회사 코드: label + 10.h + AppTextField (system keyboard, hides keypad on tap) + 22.h
   - 사원번호: label + 10.h + AppTextField (system keyboard, hides keypad on tap) + 22.h

## Verification
- Syntax check: PASS (verified by reading final file)
- Pattern followed: Uniform 22.h spacing between field groups, matching existing password fields
- Both new fields use system keyboard (no `readOnly: true`), `onTap: _hideKeypad` to dismiss secure keypad

## Files Modified
1. `attendance_app/lib/features/auth/presentation/screens/register_screen.dart` - replaced 기기 ID section with 회사 코드 + 사원번호 fields
