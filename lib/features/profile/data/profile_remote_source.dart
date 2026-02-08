import '../models.dart';

abstract class ProfileRemoteSource {
  Future<UserProfile?> fetchProfile();
}
