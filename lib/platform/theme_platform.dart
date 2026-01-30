import 'package:flutter/services.dart';

class ThemePlatform {
  static const _channel = MethodChannel('app.theme');

  static Future<void> setThemeMode(String mode) async {
    try {
      await _channel.invokeMethod('setThemeMode', {'mode': mode});
    } catch (_) {
      // Android может быть недоступен (web, tests) — игнор
    }
  }
}
