import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// 🔴 НАСТРОЙ ЗДЕСЬ
const _pushServerBaseUrl = 'http://10.0.2.2:8080';
const _registerSecret = 'super-secret-123-456';

/// Куда навигируемся после тапа по пушу.
enum AppNavTarget { schedule }

class NotificationAction {
  final AppNavTarget target;
  final Map<String, String> data;
  const NotificationAction(this.target, this.data);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _prefsKeyEnabled = 'push_enabled';
  static const _prefsKeyToken = 'push_fcm_token';

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _fcm;

  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  final ValueNotifier<String?> token = ValueNotifier<String?>(null);
  final ValueNotifier<String> status =
      ValueNotifier<String>('Пуши: не запущены');
  final ValueNotifier<String?> lastError = ValueNotifier<String?>(null);
  final ValueNotifier<NotificationAction?> action =
      ValueNotifier<NotificationAction?>(null);

  bool _started = false;
  bool _ready = false;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'schedule_changes',
    'Изменения расписания',
    description: 'Уведомления об изменениях в расписании',
    importance: Importance.high,
  );

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {}

  bool get isReady => _ready;

  void ensureStarted() {
    if (_started) return;
    _started = true;
    _start();
  }

  Future<void> init() async {
    ensureStarted();
    for (int i = 0; i < 200; i++) {
      if (_ready) return;
      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  Future<void> _start() async {
    try {
      await Firebase.initializeApp();
      _fcm = FirebaseMessaging.instance;

      FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler);

      await _initLocalNotifications();
      await _restoreState();

      FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteTap);
      final initial = await _fcm!.getInitialMessage();
      if (initial != null) _handleRemoteTap(initial);

      FirebaseMessaging.onMessage.listen(_showLocalFromRemote);

      _fcm!.onTokenRefresh.listen((t) async {
        token.value = t;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKeyToken, t);
        await _registerTokenOnServer(t);
      });

      _ready = true;

      if (enabled.value) {
        await _enableInternal();
      }
    } catch (e) {
      lastError.value = e.toString();
      status.value = 'Ошибка пушей';
    }
  }

  Future<void> _restoreState() async {
    final prefs = await SharedPreferences.getInstance();
    enabled.value = prefs.getBool(_prefsKeyEnabled) ?? false;
    token.value = prefs.getString(_prefsKeyToken);
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        if (resp.payload != null) {
          _handlePayloadString(resp.payload!);
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _fcm!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> setEnabled(bool value) async {
    ensureStarted();

    enabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyEnabled, value);

    if (!value) {
      final t = token.value;
      if (t != null) {
        await _unregisterTokenOnServer(t);
      }
      await _fcm?.deleteToken();
      token.value = null;
      await prefs.remove(_prefsKeyToken);
      status.value = 'Пуши: выключены';
      return;
    }

    if (_ready) {
      await _enableInternal();
    }
  }

  Future<void> _enableInternal() async {
    final settings = await _fcm!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus ==
        AuthorizationStatus.denied) {
      lastError.value = 'Нет разрешения на уведомления';
      return;
    }

    final t = await _fcm!.getToken();
    if (t == null) return;

    token.value = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyToken, t);

    await _registerTokenOnServer(t);

    status.value = 'Пуши: включены';
  }

  Future<void> _registerTokenOnServer(String token) async {
    try {
      await http.post(
        Uri.parse('$_pushServerBaseUrl/register'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Register-Secret': _registerSecret,
        },
        body: jsonEncode({'token': token}),
      );
    } catch (e) {
      debugPrint('[PUSH] register error: $e');
    }
  }

  Future<void> _unregisterTokenOnServer(String token) async {
    try {
      await http.post(
        Uri.parse('$_pushServerBaseUrl/unregister'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          'X-Register-Secret': _registerSecret,
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
  }

  Future<void> _showLocalFromRemote(RemoteMessage message) async {
    final title = message.notification?.title ?? 'ЭИОС';
    final body = message.notification?.body ?? '';
    final payload =
        message.data.isNotEmpty ? jsonEncode(message.data) : '';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.high,
      priority: Priority.high,
    );

    final details =
        NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void _handleRemoteTap(RemoteMessage message) {
    final data = <String, String>{};
    message.data.forEach((k, v) => data[k] = v.toString());
    action.value = NotificationAction(AppNavTarget.schedule, data);
  }

  void _handlePayloadString(String payload) {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      final data = <String, String>{};
      decoded.forEach((k, v) => data[k.toString()] = v.toString());
      action.value = NotificationAction(AppNavTarget.schedule, data);
    }
  }
}
