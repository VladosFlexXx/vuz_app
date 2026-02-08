import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../profile/models.dart';
import '../profile/repository.dart';
import '../settings/settings_screen.dart';

import 'package:vuz_app/core/network/eios_client.dart';

part '../profile/ui_parts/profile_header.dart';
part '../profile/ui_parts/profile_info_card.dart';
part '../profile/ui_parts/info_tile.dart';
part '../profile/ui_parts/copy_tile.dart';
part '../profile/ui_parts/skeleton_tile.dart';
part '../profile/ui_parts/skeleton_circle.dart';
part '../profile/ui_parts/skeleton_line.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final repo = ProfileRepository.instance;
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    repo.initAndRefresh();
  }

  static bool _isAuthExpiredError(Object? err) {
    if (err == null) return false;
    final s = err.toString().toLowerCase();
    // Moodle обычно редиректит на login/index.php?loginredirect=1
    return s.contains('loginredirect=1') ||
        s.contains('/login/index.php') ||
        s.contains('redirect loop detected');
  }

  Future<void> _logoutCookieOnly() async {
    // На экране профиля мы просто чистим куки/кэш.
    // Переход на экран логина делается глобально (HomeScreen ловит SessionManager),
    // но если пользователь нажмёт «Войти заново» — это отработает через WebView входа там же.
    await _storage.delete(key: 'cookie_header');
    EiosClient.instance.invalidateCookieCache();
  }

  String _fmtTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final p = repo.profile;
        final authExpired = _isAuthExpiredError(repo.lastError);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Профиль'),
            bottom: repo.loading
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(minHeight: 3),
                  )
                : null,
            actions: [
              IconButton(
                tooltip: 'Настройки',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                tooltip: 'Обновить',
                onPressed: (repo.loading || authExpired)
                    ? null
                    : () => repo.refresh(force: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              if (authExpired) return;
              await repo.refresh(force: true);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
              children: [
                if (authExpired) ...[
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Сессия истекла',
                            style: t.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Похоже, ЭИОС разлогинила тебя. Поэтому данные не обновляются и показывается старый кэш.',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              FilledButton.icon(
                                onPressed: () async {
                                  await _logoutCookieOnly();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Куки очищены. Открой вход и залогинься заново.',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.login),
                                label: const Text('Очистить куки'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ✅ Хедер профиля + тонкая строка "обновлено" (без жирного баннера)
                _ProfileHeader(
                  profile: p,
                  updatedAt: repo.updatedAt,
                  hasError: repo.lastError != null,
                  loading: repo.loading,
                  fmtTime: _fmtTime,
                ),
                const SizedBox(height: 14),

                Text(
                  'Данные',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                _ProfileInfoCard(
                  profile: p,
                  onCopyRecordBook: (text) async {
                    await Clipboard.setData(ClipboardData(text: text));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('№ зачётной скопирован'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),

                // ✅ оставляем место внизу под будущие штуки
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}
