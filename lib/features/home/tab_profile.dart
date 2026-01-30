import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app.dart';
import '../../core/widgets/update_banner.dart';
import '../auth/login_webview.dart';

import '../profile/models.dart';
import '../profile/repository.dart';

import '../notifications/notification_service.dart';

import 'package:vuz_app/core/network/eios_client.dart';

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

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'cookie_header');
    EiosClient.instance.invalidateCookieCache();
    try {
      await CookieManager.instance().deleteAllCookies();
    } catch (_) {}

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginWebViewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final p = repo.profile;

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
                tooltip: 'Обновить',
                onPressed: repo.loading ? null : () => repo.refresh(force: true),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => repo.refresh(force: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                UpdateBanner(repo: repo),
                const SizedBox(height: 12),
                _ProfileHeader(profile: p),
                const SizedBox(height: 14),

                Text('Данные',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                _ProfileInfoExpandable(profile: p),

                const SizedBox(height: 18),
                Text('Уведомления',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const _PushCard(),

                const SizedBox(height: 18),
                Text('Настройки',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: Text('Тема',
                            style: t.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        subtitle: Text(_themeLabel(themeController.mode)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showThemePicker(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text('О приложении',
                            style: t.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'ЭИОС',
                            applicationVersion: '0.1',
                            applicationLegalese: 'В разработке',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                Text('Аккаунт',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text('Выйти',
                        style: t.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    subtitle: const Text('Очистить сессию и заново войти'),
                    onTap: () => _logout(context),
                  ),
                ),

                const SizedBox(height: 18),
                Text('ЭИОС (временно через Web)',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Открыть ЭИОС (Web)'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EiosWebViewScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Светлая',
      ThemeMode.dark => 'Тёмная',
      ThemeMode.system => 'Системная',
    };
  }

  static void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Тема',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: const Text('Светлая'),
                onTap: () {
                  themeController.setMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Тёмная'),
                onTap: () {
                  themeController.setMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Системная'),
                onTap: () {
                  themeController.setMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _PushCard extends StatelessWidget {
  const _PushCard();

  @override
  Widget build(BuildContext context) {
    final ns = NotificationService.instance;
    final t = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: ns.enabled,
              builder: (context, on, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: Text('Включить пуши',
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: const Text('Уведомления об изменениях в расписании'),
                  value: on,
                  onChanged: (v) => ns.setEnabled(v),
                );
              },
            ),
            const Divider(height: 1),
            ValueListenableBuilder<String?>(
              valueListenable: ns.token,
              builder: (context, token, _) {
                final hasToken = token != null && token.trim().isNotEmpty;
                return ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: Text('FCM token',
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Text(
                    hasToken ? token! : 'Токен появится после включения пушей',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: hasToken ? const Icon(Icons.copy) : null,
                  onTap: hasToken
                      ? () async {
                          await Clipboard.setData(ClipboardData(text: token!));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Токен скопирован')),
                            );
                          }
                        }
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile? profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final name = (profile?.fullName ?? 'Студент').trim().isEmpty
        ? 'Студент'
        : profile!.fullName.trim();
    final avatarUrl = profile?.avatarUrl;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: (avatarUrl == null || avatarUrl.trim().isEmpty)
                  ? Icon(Icons.person, color: cs.onSurface)
                  : Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.person, color: cs.onSurface),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoExpandable extends StatelessWidget {
  final UserProfile? profile;
  const _ProfileInfoExpandable({required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;

    if (p == null) {
      return Card(
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text('Загрузка...'),
        ),
      );
    }

    if (p.fields.isEmpty) {
      return Card(
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Text('Нет данных (проверь, открывается ли user/edit.php)'),
        ),
      );
    }

    final email = p.email;

    final prof = p.profileEdu;
    final spec = p.specialty;

    String? profileLine;
    final parts = <String>[];
    if (prof != null && prof.trim().isNotEmpty) parts.add(prof.trim());
    if (spec != null && spec.trim().isNotEmpty) {
      if (parts.isEmpty ||
          parts.first.toLowerCase() != spec.trim().toLowerCase()) {
        parts.add(spec.trim());
      }
    }
    if (parts.isNotEmpty) profileLine = parts.join(' • ');

    final level = p.level;
    final eduForm = p.eduForm;
    final recordBook = p.recordBook;

    final primaryItems = <({String title, String value, IconData icon})>[
      if (email != null) (title: 'Почта', value: email, icon: Icons.email_outlined),
      if (profileLine != null)
        (title: 'Профиль / направление', value: profileLine, icon: Icons.school_outlined),
      if (level != null)
        (title: 'Уровень подготовки', value: level, icon: Icons.badge_outlined),
      if (eduForm != null)
        (title: 'Форма обучения', value: eduForm, icon: Icons.event_seat_outlined),
      if (recordBook != null)
        (title: '№ зачётной книжки', value: recordBook, icon: Icons.confirmation_number_outlined),
    ];

    final shownValues = primaryItems.map((e) => e.value).toSet();

    bool isJunkKey(String k) {
      final l = k.toLowerCase();
      if (l == 'фио') return true;
      if (l == 'имя' || l == 'фамилия' || l.contains('отчество')) return true;
      if (l.contains('описание')) return true;
      if (l.contains('предпочитаемая тема')) return true;
      if (l.contains('показывать адрес электронной почты')) return true;
      if (l.contains('часовой пояс')) return true;
      if (l.startsWith('id')) return true;
      return false;
    }

    bool looksLikeHtmlTrash(String v) {
      if (v.length < 40) return false;
      return v.contains('<') &&
          v.contains('>') &&
          (v.contains('div') || v.contains('object') || v.contains('http'));
    }

    final allEntries = p.fields.entries
        .where((e) => !isJunkKey(e.key))
        .where((e) => e.value.trim().isNotEmpty)
        .where((e) => !looksLikeHtmlTrash(e.value))
        .where((e) => !shownValues.contains(e.value))
        .toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return Card(
      elevation: 0,
      child: Column(
        children: [
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: const Text('Развернуть'),
            subtitle: const Text('Почта, профиль, форма и т.д.'),
            initiallyExpanded: false,
            children: [
              if (primaryItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Ключевые поля не найдены в профиле.'),
                  ),
                )
              else
                ..._buildTiles(primaryItems),
            ],
          ),
          if (allEntries.isNotEmpty) const Divider(height: 1),
          if (allEntries.isNotEmpty)
            ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              title: const Text('Все поля'),
              subtitle: Text('${allEntries.length}'),
              initiallyExpanded: false,
              children: [
                for (int i = 0; i < allEntries.length; i++) ...[
                  ListTile(
                    title: Text(allEntries[i].key),
                    subtitle: Text(allEntries[i].value),
                  ),
                  if (i != allEntries.length - 1) const Divider(height: 1),
                ],
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildTiles(List<({String title, String value, IconData icon})> items) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(
        ListTile(
          leading: Icon(items[i].icon),
          title: Text(items[i].title),
          subtitle: Text(items[i].value),
        ),
      );
      if (i != items.length - 1) out.add(const Divider(height: 1));
    }
    return out;
  }
}

class EiosWebViewScreen extends StatelessWidget {
  const EiosWebViewScreen({super.key});
  static const _url = 'https://eos.imes.su/my/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ЭИОС')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_url)),
      ),
    );
  }
}
