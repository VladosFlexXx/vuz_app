part of '../tab_dashboard.dart';

class _WeekProgressStrip extends StatelessWidget {
  final int completed;
  final int total;

  const _WeekProgressStrip({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final safeTotal = total <= 0 ? 1 : total;
    final value = (completed / safeTotal).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Прогресс недели',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  '$completed / $total',
                  style: t.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 9,
                value: value,
                backgroundColor: cs.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
