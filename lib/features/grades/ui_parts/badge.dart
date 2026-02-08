part of '../../home/tab_grades.dart';

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  double? _scoreRaw(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  double? _scorePercent(String value) {
    final raw = _scoreRaw(value);
    if (raw == null) return null;
    if (raw <= 5.0) return (raw / 5.0) * 100.0;
    if (raw <= 100.0) return raw;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = _scorePercent(text);

    final bool hasScore = p != null;
    final bool low = hasScore && p < 45;
    final bool mid = hasScore && p >= 45 && p < 75;

    final bg = !hasScore
        ? cs.primaryContainer
        : (low
              ? cs.primary.withValues(alpha: 0.16)
              : (mid
                    ? cs.primary.withValues(alpha: 0.24)
                    : cs.primary.withValues(alpha: 0.34)));
    final fg = !hasScore ? cs.onPrimaryContainer : cs.primary;
    final borderColor = !hasScore
        ? cs.onPrimaryContainer.withValues(alpha: 0.12)
        : cs.primary.withValues(alpha: 0.45);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }
}

