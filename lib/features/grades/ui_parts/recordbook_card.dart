part of '../../home/tab_grades.dart';

class _RecordbookCard extends StatelessWidget {
  final RecordbookRow row;

  const _RecordbookCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final chips = <Widget>[];
    if (row.controlType.trim().isNotEmpty) {
      chips.add(_Chip(text: row.controlType.trim()));
    }
    if (row.date.trim().isNotEmpty) chips.add(_Chip(text: row.date.trim()));
    if (row.mark.trim().isNotEmpty) chips.add(_Chip(text: row.mark.trim()));
    if (row.retake.trim().isNotEmpty) {
      chips.add(_Chip(text: 'Пересдача: ${row.retake.trim()}'));
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.discipline,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              if (chips.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: chips),
              if (row.teacher.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  row.teacher.trim(),
                  style: t.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// UI helpers
// =========================

