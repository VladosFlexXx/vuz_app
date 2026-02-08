part of '../../home/tab_schedule.dart';

class _UnifiedHeaderCard extends StatelessWidget {
  final String parityText;
  final String rangeText;
  final String updatedText;

  final int weekChangesTotal;
  final int dayChanges;

  final String dayTitle;

  final String todayLabel;
  final VoidCallback onTodayTap;

  final bool changesOnly;
  final VoidCallback onToggleChangesOnly;

  const _UnifiedHeaderCard({
    required this.parityText,
    required this.rangeText,
    required this.updatedText,
    required this.weekChangesTotal,
    required this.dayChanges,
    required this.dayTitle,
    required this.todayLabel,
    required this.onTodayTap,
    required this.changesOnly,
    required this.onToggleChangesOnly,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final titleStyle = t.titleMedium?.copyWith(fontWeight: FontWeight.w900);
    final subStyle = t.bodySmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: cs.onSurface.withValues(alpha: 0.78),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Pill(icon: Icons.swap_vert_circle_outlined, text: parityText),
                _Pill(icon: Icons.date_range_outlined, text: rangeText),
                if (weekChangesTotal > 0)
                  _Pill(
                    icon: Icons.edit_calendar_outlined,
                    text: 'Изм.: $weekChangesTotal',
                    tone: _PillTone.warn,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.sync,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.75),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Обновлено: $updatedText',
                    style: subStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dayChanges > 0
                  ? 'В выбранный день изменений: $dayChanges'
                  : 'Сегодня изменений нет',
              style: t.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              color: cs.outlineVariant.withValues(alpha: 0.35),
              height: 1,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayTitle,
                    style: titleStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                _TapPill(
                  icon: Icons.today,
                  text: todayLabel,
                  active: true,
                  onTap: onTodayTap,
                ),
                const SizedBox(width: 8),
                _TapPill(
                  icon: Icons.edit_calendar_outlined,
                  text: 'Изм.',
                  active: changesOnly,
                  onTap: onToggleChangesOnly,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

