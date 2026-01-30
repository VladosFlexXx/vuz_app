import 'package:flutter/foundation.dart';

/// Глобальный флажок "сессия умерла".
/// Если любой запрос увидел страницу логина — ставим expired=true.
/// UI (HomeScreen) это ловит и переводит на LoginWebViewScreen.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  /// true = надо разлогинить и отправить на WebView входа
  final ValueNotifier<bool> expired = ValueNotifier<bool>(false);

  void markExpired() {
    if (expired.value) return; // уже помечено
    expired.value = true;
  }

  void reset() {
    expired.value = false;
  }
}
