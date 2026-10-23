import 'dart:async';

import 'package:flutter/widgets.dart';

/// Auto-lock lifecycle: locks on background event and on inactivity timeout.
/// `touch()` resets the timer — the app wires it to any user interaction
/// (a Listener in the MaterialApp builder).
class AutoLockService with WidgetsBindingObserver {
  final Duration inactivity;
  final VoidCallback onLock;

  Timer? _timer;
  AppLifecycleState? _lastState;

  AutoLockService({required this.inactivity, required this.onLock}) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void touch() {
    _timer?.cancel();
    _timer = Timer(inactivity, () {
      onLock();
    });
  }

  void disarm() {
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_lastState == AppLifecycleState.resumed) {
        onLock();
      }
    }
    _lastState = state;
  }
}
