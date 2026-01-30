import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/cache/cached_repository.dart';
import 'convert.dart';
import 'merge.dart';
import 'models.dart';
import 'schedule_service.dart';

const _kCacheKey = 'schedule_cache_v3';
const _kCacheUpdatedKey = 'schedule_cache_updated_v3';

const _baseUrl = 'https://eos.imes.su/mod/page/view.php?id=41428';

// ВАЖНО: эта ссылка может “умирать” (как у тебя сейчас)
const _changesUrl = 'https://eos.imes.su/mod/page/view.php?id=56446';

// compute требует top-level функцию
List<Lesson> _parseLessons(String html) => lessonsFromHtml(html);

String _normDay(String s) => s.toUpperCase().trim();

String _normTime(String s) {
  var t = s.trim();
  t = t.replaceAll('–', '-').replaceAll('—', '-');
  t = t.replaceAll(':', '.');
  t = t.replaceAll(RegExp(r'\s+'), '');
  return t;
}

class ScheduleRepository extends CachedRepository<List<Lesson>> {
  ScheduleRepository._()
      : super(
          initialData: const [],
          ttl: const Duration(minutes: 10),
        );

  static final ScheduleRepository instance = ScheduleRepository._();

  List<Lesson> get lessons => data;

  @override
  Future<List<Lesson>?> readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCacheKey);
      final updatedRaw = prefs.getString(_kCacheUpdatedKey);

      if (updatedRaw != null && updatedRaw.trim().isNotEmpty) {
        setUpdatedAtFromCache(DateTime.tryParse(updatedRaw));
      }

      if (raw == null || raw.trim().isEmpty) return null;

      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(_lessonFromJson).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeCache(List<Lesson> data, DateTime updatedAt) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(data.map(_lessonToJson).toList());
    await prefs.setString(_kCacheKey, raw);
    await prefs.setString(_kCacheUpdatedKey, updatedAt.toIso8601String());
  }

  @override
  Future<List<Lesson>> fetchRemote() async {
    final service = ScheduleService();

    // 1) БАЗУ грузим обязательно. Если база не загрузилась — это реально фейл.
    final baseHtml = await service.loadPage(_baseUrl);
    final baseLessons = await compute(_parseLessons, baseHtml);

    // 2) ИЗМЕНЕНИЯ — best effort: если не получилось, просто считаем, что изменений нет.
    List<Lesson> changeLessons = const [];
    try {
      final changesHtml = await service.loadPage(_changesUrl);
      changeLessons = await compute(_parseLessons, changesHtml);
    } catch (e) {
      // ВАЖНО: не валим весь fetchRemote
      // Можно оставить print для дебага:
      // ignore: avoid_print
      print('[ScheduleRepository] changes page failed, using base only: $e');
      changeLessons = const [];
    }

    final merged = mergeSchedule(base: baseLessons, changes: changeLessons);

    merged.sort((a, b) {
      final d = _dayRank(a.day).compareTo(_dayRank(b.day));
      if (d != 0) return d;
      return _timeRank(a.time).compareTo(_timeRank(b.time));
    });

    return merged;
  }

  static const _dayOrder = <String, int>{
    'ПОНЕДЕЛЬНИК': 1,
    'ВТОРНИК': 2,
    'СРЕДА': 3,
    'ЧЕТВЕРГ': 4,
    'ПЯТНИЦА': 5,
    'СУББОТА': 6,
    'ВОСКРЕСЕНЬЕ': 7,
  };

  int _dayRank(String day) => _dayOrder[_normDay(day)] ?? 999;

  int _timeRank(String time) {
    final t = _normTime(time);
    final start = t.split('-').first;
    final parts = start.split('.');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 99 : 99;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 99 : 99;
    return h * 100 + m;
  }

  Map<String, dynamic> _lessonToJson(Lesson l) => {
        'day': l.day,
        'time': l.time,
        'subject': l.subject,
        'place': l.place,
        'type': l.type,
        'teacher': l.teacher,
        'status': l.status.name,
      };

  Lesson _lessonFromJson(Map<String, dynamic> j) {
    LessonStatus status = LessonStatus.normal;
    final s = (j['status'] ?? '').toString();
    for (final v in LessonStatus.values) {
      if (v.name == s) {
        status = v;
        break;
      }
    }

    return Lesson(
      day: (j['day'] ?? '').toString(),
      time: (j['time'] ?? '').toString(),
      subject: (j['subject'] ?? '').toString(),
      place: (j['place'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      teacher: (j['teacher'] ?? '').toString(),
      status: status,
    );
  }
}
