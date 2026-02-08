import 'package:flutter/foundation.dart';

import '../../../core/network/eios_endpoints.dart';
import '../../schedule/schedule_service.dart';
import '../models.dart';
import '../parser.dart';
import 'grades_remote_source.dart';

List<GradeCourse> _parseOverview(String html) =>
    GradesParser.parseOverview(html);

class WebGradesRemoteSource implements GradesRemoteSource {
  final ScheduleService _service;

  WebGradesRemoteSource({ScheduleService? service})
    : _service = service ?? ScheduleService();

  @override
  Future<List<GradeCourse>> fetchCourses() async {
    final html = await _service.loadPage(EiosEndpoints.gradesOverview);
    final parsed = await compute(_parseOverview, html);
    parsed.sort(
      (a, b) =>
          a.courseName.toLowerCase().compareTo(b.courseName.toLowerCase()),
    );
    return parsed;
  }
}
