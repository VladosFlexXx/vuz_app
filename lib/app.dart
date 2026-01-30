import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'features/auth/login_webview.dart';
import 'features/home/home_screen.dart';
import 'theme_controller.dart';

final themeController = ThemeController();

class VuzApp extends StatefulWidget {
  const VuzApp({super.key});

  @override
  State<VuzApp> createState() => _VuzAppState();
}

class _VuzAppState extends State<VuzApp> {
  @override
  void initState() {
    super.initState();
    themeController.addListener(_onThemeChanged);
    _init();
  }

  Future<void> _init() async {
    await themeController.load();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    themeController.removeListener(_onThemeChanged);
    super.dispose();
  }

  ThemeData _lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: Colors.indigo,
    );

    final cs = base.colorScheme;

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),

      // ✅ фикс контрастности нижней навигации
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.65),
        selectedIconTheme: IconThemeData(color: cs.primary),
        unselectedIconTheme: IconThemeData(color: cs.onSurface.withOpacity(0.65)),
        showUnselectedLabels: true,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  ThemeData _darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.indigo,
    );

    final cs = base.colorScheme;

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1115),

      // ✅ фикс контрастности нижней навигации
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withOpacity(0.75),
        selectedIconTheme: IconThemeData(color: cs.primary),
        unselectedIconTheme: IconThemeData(color: cs.onSurface.withOpacity(0.75)),
        showUnselectedLabels: true,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: const Color(0xFF171A21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!themeController.loaded) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ЭИОС',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: themeController.mode,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  static const _storage = FlutterSecureStorage();
  bool? _hasCookie;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final v = await _storage.read(key: 'cookie_header');
    if (!mounted) return;
    setState(() => _hasCookie = (v != null && v.trim().isNotEmpty));
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCookie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _hasCookie! ? const HomeScreen() : const LoginWebViewScreen();
  }
}
