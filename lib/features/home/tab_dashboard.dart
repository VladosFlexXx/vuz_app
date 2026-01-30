import 'package:flutter/material.dart';

import '../../core/widgets/update_banner.dart';
import '../grades/repository.dart';
import '../profile/repository.dart';
import '../schedule/models.dart';
import '../schedule/schedule_repository.dart';

class DashboardTab extends StatelessWidget {
  final void Function(int index) onNavigate;

  const DashboardTab({
    super.key,
    required this.onNavigate,
  });

  String _todayRuUpper() {
    const map = <int, String>{
      1: 'ПОНЕДЕЛЬНИК',
      2: 'ВТОРНИК',
      3: 'СРЕДА',
      4: 'ЧЕТВЕРГ',
      5: 'ПЯТНИЦА',
      6: 'СУББОТА',
      7: 'ВОСКРЕСЕНЬЕ',
    };
    return map[DateTime.now().weekday]!;
  }

  int _timeRank(String time) {
    final start = time.split('-').first.trim();
    final parts = start.split('.');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 99 : 99;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 99 : 99;
    return h * 100 + m;
  }

  DateTime? _parseStartToday(String time) {
    final start = time.split('-').first.trim();
    final parts = start.split('.');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  DateTime? _parseEndToday(String time) {
    final pieces = time.split('-');
    if (pieces.length < 2) return null;
    final end = pieces[1].trim();
    final parts = end.split('.');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  Lesson? _nextLessonToday(List<Lesson> todayLessons) {
    final now = DateTime.now();
    Lesson? best;
    DateTime? bestStart;

    for (final l in todayLessons) {
      final start = _parseStartToday(l.time);
      if (start == null) continue;

      final end = _parseEndToday(l.time);
      final isOngoing = end != null && start.isBefore(now) && end.isAfter(now);
      final isFuture = start.isAfter(now);

      if (!isOngoing && !isFuture) continue;

      if (best == null) {
        best = l;
        bestStart = start;
        continue;
      }

      final bestEnd = _parseEndToday(best.time);
      final bestOngoing =
          bestEnd != null && bestStart!.isBefore(now) && bestEnd.isAfter(now);

      if (bestOngoing) continue;
      if (isOngoing) {
        best = l;
        bestStart = start;
        continue;
      }

      if (start.isBefore(bestStart!)) {
        best = l;
        bestStart = start;
      }
    }

    return best;
  }

  String _timeToText(Lesson lesson) {
    final now = DateTime.now();
    final start = _parseStartToday(lesson.time);
    if (start == null) return '';

    final end = _parseEndToday(lesson.time);
    final isOngoing = end != null && start.isBefore(now) && end.isAfter(now);
    if (isOngoing) return 'уже идёт';

    final diff = start.difference(now);
    final mins = diff.inMinutes;

    if (mins <= 0) return 'скоро';
    if (mins < 60) return 'через $mins мин';

    final hours = diff.inHours;
    final rem = mins - hours * 60;
    if (rem == 0) return 'через $hours ч';
    return 'через $hours ч $rem мин';
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ScheduleRepository.instance.refresh(force: true),
      GradesRepository.instance.refresh(force: true),
      ProfileRepository.instance.refresh(force: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final scheduleRepo = ScheduleRepository.instance;
    final gradesRepo = GradesRepository.instance;
    final profileRepo = ProfileRepository.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([scheduleRepo, gradesRepo, profileRepo]),
      builder: (context, _) {
        final lessons = scheduleRepo.lessons;

        final today = _todayRuUpper();
        final todayLessons = lessons
            .where((l) => l.day.toUpperCase().trim() == today)
            .toList()
          ..sort((a, b) => _timeRank(a.time).compareTo(_timeRank(b.time)));

        final next = _nextLessonToday(todayLessons);

        final changed =
            lessons.where((l) => l.status == LessonStatus.changed).length;
        final cancelled =
            lessons.where((l) => l.status == LessonStatus.cancelled).length;

        final isLoading =
            scheduleRepo.loading || gradesRepo.loading || profileRepo.loading;

        return Scaffold(
          appBar: AppBar(
            title: Text(isLoading ? 'Главная (обновление...)' : 'Главная'),
            bottom: isLoading
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(minHeight: 3),
                  )
                : null,
            actions: [
              IconButton(
                tooltip: 'Обновить всё',
                onPressed: isLoading ? null : _refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _NextLessonCard(
                  lesson: next,
                  subtitle: next == null ? null : _timeToText(next),
                  onOpenSchedule: () => onNavigate(1),
                ),
                const SizedBox(height: 10),
                _StatCard(
                  title: 'Пар сегодня',
                  value: '${todayLessons.length}',
                  icon: Icons.today_outlined,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Изменения',
                        value: '$changed',
                        icon: Icons.edit_calendar_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        title: 'Отмены',
                        value: '$cancelled',
                        icon: Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => onNavigate(1),
                            icon: const Icon(Icons.view_agenda_outlined),
                            label: const Text('Расписание'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => onNavigate(2),
                            icon: const Icon(Icons.school_outlined),
                            label: const Text('Оценки'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Баннер оставляем, но уводим вниз — чтобы не забирал приоритет.
                const SizedBox(height: 12),
                UpdateBanner(
                  repo: scheduleRepo,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  final Lesson? lesson;
  final String? subtitle;
  final VoidCallback onOpenSchedule;

  const _NextLessonCard({
    required this.lesson,
    required this.subtitle,
    required this.onOpenSchedule,
  });

  @override
  Widget build(BuildContext context) {
    if (lesson == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.free_breakfast_outlined),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Сегодня пар нет или расписание не загружено'),
              ),
              TextButton(
                onPressed: onOpenSchedule,
                child: const Text('Расписание'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Следующая пара',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              lesson!.subject,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${lesson!.time}  •  ${lesson!.place}'),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onOpenSchedule,
                child: const Text('Открыть расписание'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: theme.textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
