# Codebase Report: Permission Flow Crash Investigation
Generated: 2026-02-22

## Summary
The crash ~4.7 seconds after `allGranted: true` is caused by a use-after-close
error on PermissionBloc. The bloc is closed by LoginScreen.dispose() while the
PermissionDialog's BlocConsumer is still alive (mid-navigation / async frame).

---

## Full Navigation Flow (Step-by-Step)

### Step 1 — LoginScreen.initState (login_screen.dart:41-47)
```dart
_permissionBloc = getIt<PermissionBloc>();   // factory → new instance each time
_checkAndShowPermissionDialog();
```
`PermissionBloc` is registered as `gh.factory<>` (injection.config.dart:106-109),
meaning `getIt<PermissionBloc>()` creates a **brand-new bloc instance** every time
LoginScreen is created.

### Step 2 — _checkAndShowPermissionDialog (login_screen.dart:57-67)
```dart
_permissionBloc.add(const PermissionStarted());
await PermissionDialog.show(context, _permissionBloc);
_dialogShown = false;
```
`PermissionDialog.show()` calls `showDialog(...)` — this returns a `Future<void>`
that resolves only when `Navigator.of(context).pop()` is called inside the dialog.

### Step 3 — PermissionDialog BlocConsumer (permission_dialog.dart:25-32)
```dart
listenWhen: (prev, curr) => curr.uiState == PermissionUiState.allGranted,
listener: (context, state) {
  if (state.uiState == PermissionUiState.allGranted) {
    Navigator.of(context).pop();   // <-- pops the dialog
  }
},
```
When `allGranted` state arrives, `Navigator.of(context).pop()` is called.
This resolves the `showDialog` future back in `_checkAndShowPermissionDialog`.

### Step 4 — After dialog pop, _checkAndShowPermissionDialog resumes
```dart
// showDialog future resolved
_dialogShown = false;
// method returns, nothing else happens
```
Control returns to `_checkAndShowPermissionDialog`. The method finishes.
LoginScreen is now fully visible, waiting for user input.

### Step 5 — No automatic navigation after permission grant
**CRITICAL FINDING:** There is NO code in LoginScreen that navigates away after
allGranted. The only navigation in LoginScreen is:
- `context.go('/')` at login_screen.dart:140 — triggered by successful login form
- `context.push('/register')` at line 254 — register button

The user must still fill in the form and press login. LoginScreen stays alive.

### Step 6 — LoginScreen.dispose (login_screen.dart:154-162)
```dart
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _permissionBloc.close();    // <-- bloc closed here
  ...
}
```
`_permissionBloc.close()` is called when LoginScreen is disposed — i.e., when
`context.go('/')` navigates to AttendanceScreen.

---

## The Crash: Use-After-Close Race Condition

### Timeline of the Bug

```
T+0.0s   PermissionBloc emits allGranted: true
T+0.0s   BlocConsumer.listener fires → Navigator.of(context).pop()
T+0.0s   showDialog Future resolves → _checkAndShowPermissionDialog returns
T+0.0s   LoginScreen is now displayed, user enters credentials
T+?s     User submits login → context.go('/') called
T+?s     LoginScreen widget starts disposing
T+?s     LoginScreen.dispose() → _permissionBloc.close()
T+?s     PermissionBloc stream is now closed
T+?s     BlocConsumer (inside already-popped dialog) OR any listener
         that still holds a reference to the stream gets a StreamError
```

The **~4.7 second delay** suggests the user or test automation fills in the form
and submits in about 4-5 seconds. This is NOT a timer — it is the time between
allGranted and form submission + navigation.

### Why use-after-close happens

The PermissionDialog was shown with `BlocProvider.value(value: bloc, ...)`.
When the dialog is popped, Flutter disposes the dialog widget tree, but there can
be lingering async frame callbacks from BlocConsumer's StreamSubscription that
fire after the bloc is closed.

More importantly: `_permissionBloc` is a local field on `_LoginScreenState`.
LoginScreen.dispose() calls `_permissionBloc.close()`. If anything in Flutter's
widget pipeline (including the `WidgetsBindingObserver.didChangeAppLifecycleState`
at line 50-54) tries to add an event to the closed bloc, it throws:

```
Bad state: Cannot add new events after calling close
```

### The WidgetsBindingObserver Risk (login_screen.dart:50-54)
```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed && _dialogShown) {
    _permissionBloc.add(const PermissionStarted());  // <-- fires on resume
  }
}
```
If the app goes to background (OS permission prompt) and comes back at nearly the
same time as disposal, `_permissionBloc.add(...)` is called on a closed bloc.

---

## Root Cause

`PermissionBloc` is owned (and closed) by `_LoginScreenState.dispose()`.
But the bloc was also provided to `PermissionDialog` via `BlocProvider.value`.
This creates a shared ownership problem:
- LoginScreen owns and closes the bloc
- PermissionDialog holds a value reference (does NOT close it)
- The timing of dialog pop vs. screen disposal can create use-after-close

---

## Fix Recommendation

**Option A (Simplest):** Do NOT close the PermissionBloc in LoginScreen.dispose().
Since it is registered as `factory` in GetIt, the GC will collect it. Remove line 156.

```dart
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  // _permissionBloc.close();  <-- REMOVE THIS
  _companyCodeController.dispose();
  ...
}
```

**Option B:** Guard the close with a mounted/disposed check and delay:
```dart
Future.delayed(Duration.zero, () {
  if (!_permissionBloc.isClosed) _permissionBloc.close();
});
```

**Option C:** Register PermissionBloc as a singleton in GetIt and let GetIt manage
its lifecycle (call `getIt.reset()` on logout).

---

## Key Files

| File | Relevant Lines | Issue |
|------|---------------|-------|
| `lib/features/auth/presentation/screens/login_screen.dart` | 156 | `_permissionBloc.close()` in dispose |
| `lib/features/auth/presentation/screens/login_screen.dart` | 44 | `getIt<PermissionBloc>()` (factory) |
| `lib/features/auth/presentation/screens/login_screen.dart` | 50-54 | `didChangeAppLifecycleState` adds to bloc |
| `lib/features/permission/presentation/widgets/permission_dialog.dart` | 29-31 | BlocConsumer pops dialog on allGranted |
| `lib/core/di/injection.config.dart` | 106-109 | PermissionBloc registered as `factory` |

