import '../models.dart';

abstract class GradesRemoteSource {
  Future<List<GradeCourse>> fetchCourses();
}
