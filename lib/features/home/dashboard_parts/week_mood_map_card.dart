part of '../tab_dashboard.dart';

class _WeekMoodMapCard extends StatelessWidget {
  final List<DateTime> days;
  final Map<int, int> lessonsByDay;

  const _WeekMoodMapCard({required this.days, required this.lessonsByDay});

  String _dayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Пн';
      case DateTime.tuesday:
        return 'Вт';
      case DateTime.wednesday:
        return 'Ср';
      case DateTime.thursday:
        return 'Чт';
      case DateTime.friday:
        return 'Пт';
      case DateTime.saturday:
        return 'Сб';
      case DateTime.sunday:
      default:
        return 'Вс';
    }
  }

  ({Color bg, Color border, Color fg}) _toneFor(
    int count,
    int weekMax,
    int peakDaysCount,
    ColorScheme cs,
  ) {
    if (count <= 0) {
      return (
        bg: const Color(0xFF262938),
        border: cs.outlineVariant.withValues(alpha: 0.30),
        fg: cs.onSurface.withValues(alpha: 0.70),
      );
    }

    if (weekMax <= 0) {
      return (
        bg: const Color(0xFF302D46),
        border: const Color(0xFF595685),
        fg: const Color(0xFFC2BDEA),
      );
    }

    final ratio = count / weekMax;
    final peakIsRare = peakDaysCount <= 2;

    if (ratio >= 0.85 && peakIsRare) {
      return (
        bg: const Color(0xFF5F4DFF),
        border: const Color(0xFFD1CAFF),
        fg: const Color(0xFFFFFFFF),
      );
    }
    if (ratio >= 0.70) {
      final isPeak = count == weekMax;
      return (
        bg: isPeak ? const Color(0xFF4E40D6) : const Color(0xFF4438BE),
        border: isPeak ? const Color(0xFFB0A6FF) : const Color(0xFF978EED),
        fg: const Color(0xFFF1EEFF),
      );
    }
    if (ratio >= 0.45) {
      return (
        bg: const Color(0xFF393162),
        border: const Color(0xFF7067B8),
        fg: const Color(0xFFD8D2FF),
      );
    }
    return (
      bg: const Color(0xFF2F2C46),
      border: const Color(0xFF5B5688),
      fg: const Color(0xFFC1BBEE),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final today = DateTime.now();

    final heaviest = days
        .map((d) => (day: d, count: lessonsByDay[d.weekday] ?? 0))
        .reduce((a, b) => b.count > a.count ? b : a);
    final weekMax = heaviest.count;
    final peakDaysCount = days
        .where((d) => (lessonsByDay[d.weekday] ?? 0) == weekMax && weekMax > 0)
        .length;

    final summary = heaviest.count == 0
        ? 'Неделя выглядит спокойно'
        : 'Пик нагрузки: ${_dayLabel(heaviest.day.weekday)} (${heaviest.count} пар)';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withValues(alpha: 0.94),
              cs.surface.withValues(alpha: 0.86),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Карта настроения недели',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                summary,
                style: t.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.64),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (int i = 0; i < days.length; i++) ...[
                    Expanded(
                      child: _MoodDayCell(
                        dayLabel: _dayLabel(days[i].weekday),
                        dayNumber: days[i].day,
                        lessonsCount: lessonsByDay[days[i].weekday] ?? 0,
                        isToday:
                            days[i].year == today.year &&
                            days[i].month == today.month &&
                            days[i].day == today.day,
                        tone: _toneFor(
                          lessonsByDay[days[i].weekday] ?? 0,
                          weekMax,
                          peakDaysCount,
                          cs,
                        ),
                      ),
                    ),
                    if (i != days.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    _MoodLegend(text: 'Нет пар', color: Color(0xFF747787)),
                    SizedBox(width: 8),
                    _MoodLegend(text: 'Легкая', color: Color(0xFF7067B8)),
                    SizedBox(width: 8),
                    _MoodLegend(text: 'Средняя', color: Color(0xFF978EED)),
                    SizedBox(width: 8),
                    _MoodLegend(text: 'Высокая', color: Color(0xFFB0A6FF)),
                    SizedBox(width: 8),
                    _MoodLegend(text: 'Пик недели', color: Color(0xFFD1CAFF)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodDayCell extends StatelessWidget {
  final String dayLabel;
  final int dayNumber;
  final int lessonsCount;
  final bool isToday;
  final ({Color bg, Color border, Color fg}) tone;

  const _MoodDayCell({
    required this.dayLabel,
    required this.dayNumber,
    required this.lessonsCount,
    required this.isToday,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday ? tone.fg : tone.border,
          width: isToday ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            dayLabel,
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: tone.fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$dayNumber',
            style: t.labelSmall?.copyWith(
              color: tone.fg.withValues(alpha: 0.88),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$lessonsCount',
            style: t.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: tone.fg,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            lessonsCount == 1 ? 'пара' : 'пар',
            style: t.labelSmall?.copyWith(
              color: tone.fg.withValues(alpha: 0.88),
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodLegend extends StatelessWidget {
  final String text;
  final Color color;

  const _MoodLegend({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        style: t.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
