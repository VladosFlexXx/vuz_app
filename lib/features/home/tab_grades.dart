import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/widgets/update_banner.dart';
import '../grades/models.dart';
import '../grades/repository.dart';

class GradesTab extends StatefulWidget {
  const GradesTab({super.key});

  @override
  State<GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<GradesTab> {
  final repo = GradesRepository.instance;

  @override
  void initState() {
    super.initState();
    repo.initAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repo,
      builder: (context, _) {
        final courses = repo.courses;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Оценки'),
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
                if (courses.isEmpty && !repo.loading) ...const [
                  SizedBox(height: 120),
                  Center(child: Text('Пока нет данных по оценкам')),
                ] else ...[
                  for (final c in courses) _GradeCard(course: c),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GradeCard extends StatelessWidget {
  final GradeCourse course;

  const _GradeCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final grade = course.grade;
    final percent = course.percent;
    final range = course.range;

    final hasGrade = grade != null && grade.trim().isNotEmpty;
    final hasLink = course.courseUrl != null && course.courseUrl!.trim().isNotEmpty;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: hasLink
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _GradeDetailsWeb(
                      url: course.courseUrl!,
                      title: course.courseName,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ ШАПКА: название слева, оценка справа
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course.courseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  if (hasGrade) ...[
                    const SizedBox(width: 10),
                    _GradeBadge(value: grade!.trim()),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // ✅ Под названием больше НЕ показываем "Оценка", чтобы не было каши.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (percent != null && percent.isNotEmpty)
                    _Pill(label: 'Процент', value: percent),
                  if (range != null && range.isNotEmpty)
                    _Pill(label: 'Диапазон', value: range),
                ],
              ),

              // если вообще нечего показать — покажем fallback
              if (!hasGrade &&
                  (percent == null || percent.isEmpty) &&
                  (range == null || range.isEmpty)) ...[
                const SizedBox(height: 8),
                Text(
                  _fallbackPreview(course.columns),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],

              if (hasLink) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Подробнее',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _fallbackPreview(Map<String, String> cols) {
    // берём первые 2 непустые колонки кроме "Курс/Course"
    final entries = cols.entries
        .where((e) => e.key.toLowerCase() != 'курс' && e.key.toLowerCase() != 'course')
        .where((e) => e.value.trim().isNotEmpty)
        .take(2)
        .toList();

    if (entries.isEmpty) return 'Нет данных';
    return entries.map((e) => '${e.key}: ${e.value}').join(' • ');
  }
}

class _GradeBadge extends StatelessWidget {
  final String value;

  const _GradeBadge({required this.value});

  bool _looksNumeric(String s) {
    // 5, 4, 3, 2 или типа 85%, 7.5
    final v = s.replaceAll(',', '.').trim();
    final n = double.tryParse(v.replaceAll('%', '').trim());
    return n != null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isNumeric = _looksNumeric(value);

    final bg = isNumeric ? cs.primaryContainer : cs.secondaryContainer;
    final fg = isNumeric ? cs.onPrimaryContainer : cs.onSecondaryContainer;

    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withOpacity(0.12)),
      ),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: fg,
              height: 1.0,
            ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;

  const _Pill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.secondaryContainer,
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSecondaryContainer,
            ),
      ),
    );
  }
}

class _GradeDetailsWeb extends StatelessWidget {
  final String url;
  final String title;

  const _GradeDetailsWeb({
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
