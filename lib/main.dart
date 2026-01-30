import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const VuzApp());

  // ✅ стартуем сервис пушей сразу, в фоне
  unawaited(_startPushes());
}

Future<void> _startPushes() async {
  try {
    debugPrint('[BOOT] Push ensureStarted()');
    NotificationService.instance.ensureStarted();
    await NotificationService.instance.init();
    debugPrint('[BOOT] Push init finished. status=${NotificationService.instance.status.value}');
  } catch (e, st) {
    debugPrint('[BOOT] Push init failed: $e');
    debugPrint('$st');
  }
}
