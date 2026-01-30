import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'platform/theme_platform.dart';

class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode'; // light | dark | system

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key) ?? 'system';

    _mode = switch (v) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    // 🔥 синхронизируем Android night mode сразу при старте
    await _syncPlatform(_mode);

    _loaded = true;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final v = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_key, v);

    // 🔥 синхронизируем Android night mode при переключении в профиле
    await _syncPlatform(mode);
  }

  Future<void> _syncPlatform(ThemeMode mode) async {
    final v = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await ThemePlatform.setThemeMode(v);
  }
}
