part of '../../home/tab_schedule.dart';

class _LessonCard extends StatelessWidget {
  final Lesson lesson;

  final bool isToday;
  final bool isOngoing;
  final bool isNext;
  final bool isPast;

  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.isToday,
    required this.isOngoing,
    required this.isNext,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final isCancelled = lesson.status == LessonStatus.cancelled;

    Color bg;
    Color border;
    IconData? badgeIcon;
    String? badgeText;

    if (isOngoing) {
      bg = cs.tertiaryContainer.withValues(alpha: 0.75);
      border = cs.tertiary.withValues(alpha: 0.55);
      badgeIcon = Icons.play_circle_outline;
      badgeText = 'идёт';
    } else if (isNext) {
      bg = cs.primaryContainer.withValues(alpha: 0.55);
      border = cs.primary.withValues(alpha: 0.45);
      badgeIcon = Icons.skip_next_outlined;
      badgeText = 'следующая';
    } else if (lesson.status == LessonStatus.changed) {
      bg = cs.primaryContainer.withValues(alpha: 0.42);
      border = cs.primary.withValues(alpha: 0.40);
      badgeIcon = Icons.edit_calendar_outlined;
      badgeText = 'изменение';
    } else if (lesson.status == LessonStatus.cancelled) {
      bg = cs.errorContainer.withValues(alpha: 0.55);
      border = cs.error.withValues(alpha: 0.45);
      badgeIcon = Icons.cancel_outlined;
      badgeText = 'отмена';
    } else {
      bg = cs.surfaceContainerHighest.withValues(alpha: 0.22);
      border = cs.outlineVariant.withValues(alpha: 0.35);
      badgeIcon = null;
      badgeText = null;
    }

    final faded = isPast && isToday;
    final opacity = faded ? 0.72 : 1.0;

    final titleStyle = t.bodyLarge?.copyWith(
      fontWeight: FontWeight.w900,
      decoration: isCancelled ? TextDecoration.lineThrough : null,
    );

    final timeStyle = t.bodySmall?.copyWith(
      fontWeight: FontWeight.w900,
      color: cs.onSurface.withValues(alpha: 0.80),
      decoration: isCancelled ? TextDecoration.lineThrough : null,
    );

    return Opacity(
      opacity: opacity,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(lesson.time, style: timeStyle),
                  const Spacer(),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (badgeIcon != null) ...[
                            Icon(
                              badgeIcon,
                              size: 16,
                              color: cs.onSurface.withValues(alpha: 0.80),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            badgeText,
                            style: t.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(lesson.subject, style: titleStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (lesson.type.trim().isNotEmpty)
                    _InfoChip(icon: Icons.info_outline, text: lesson.type),
                  if (lesson.place.trim().isNotEmpty)
                    _InfoChip(icon: Icons.place_outlined, text: lesson.place),
                  if (lesson.teacher.trim().isNotEmpty)
                    _InfoChip(icon: Icons.person_outline, text: lesson.teacher),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

