import 'package:flutter/foundation.dart';

import '../../../core/network/eios_endpoints.dart';
import '../convert.dart';
import '../merge.dart';
import '../models.dart';
import '../schedule_service.dart';
import 'schedule_remote_source.dart';

List<Lesson> _parseLessons(String html) => lessonsFromHtml(html);

class WebScheduleRemoteSource implements ScheduleRemoteSource {
  final ScheduleService _service;

  WebScheduleRemoteSource({ScheduleService? service})
    : _service = service ?? ScheduleService();

  @override
  Future<List<Lesson>> fetchLessons() async {
    final baseHtml = await _service.loadPage(EiosEndpoints.scheduleBase);
    final baseLessons = await compute(_parseLessons, baseHtml);

    List<Lesson> changeLessons = const [];
    try {
      final changesHtml = await _service.loadPage(
        EiosEndpoints.scheduleChanges,
      );
      changeLessons = await compute(_parseLessons, changesHtml);
    } catch (_) {}

    return mergeSchedule(base: baseLessons, changes: changeLessons);
  }
}
