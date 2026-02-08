import '../models.dart';

abstract class ScheduleRemoteSource {
  Future<List<Lesson>> fetchLessons();
}
