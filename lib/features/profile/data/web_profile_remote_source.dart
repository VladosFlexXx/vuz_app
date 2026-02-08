import 'package:flutter/foundation.dart';

import '../../../core/network/eios_endpoints.dart';
import '../../schedule/schedule_service.dart';
import '../models.dart';
import '../parser.dart';
import 'profile_remote_source.dart';

({String fullName, String? avatarUrl, String? profileUrl, String? editUrl})
_parseMy(String html) => ProfileParser.parseFromMy(html);

class WebProfileRemoteSource implements ProfileRemoteSource {
  final ScheduleService _service;

  WebProfileRemoteSource({ScheduleService? service})
    : _service = service ?? ScheduleService();

  String _absUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${EiosEndpoints.base}$url';
    return '${EiosEndpoints.base}/$url';
  }

  @override
  Future<UserProfile?> fetchProfile() async {
    final myHtml = await _service.loadPage(EiosEndpoints.my);
    final myParsed = await compute(_parseMy, myHtml);

    final fullName = myParsed.fullName;
    final avatarUrl = myParsed.avatarUrl;

    final editUrl = _absUrl(myParsed.editUrl ?? EiosEndpoints.userEdit);
    final editHtml = await _service.loadPage(editUrl);

    return ProfileParser.parseEditPage(
      editHtml,
      fallbackFullName: fullName,
      fallbackAvatarUrl: avatarUrl,
    );
  }
}
