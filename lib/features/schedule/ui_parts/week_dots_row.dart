part of '../../home/tab_schedule.dart';

class _WeekDotsRow extends StatelessWidget {
  final DateTime weekStart;
  final int? filledSelectedIndex;
  final int? todayIndex;
  final List<String> labels;
  final ValueChanged<int> onTap;

  const _WeekDotsRow({
    super.key,
    required this.weekStart,
    required this.filledSelectedIndex,
    required this.todayIndex,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final raw = (constraints.maxWidth - gap * 6) / 7;
        final size = raw.clamp(40.0, 54.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(labels.length, (i) {
            final isSelected =
                filledSelectedIndex != null && i == filledSelectedIndex;
            final isToday = todayIndex != null && i == todayIndex;

            final date = weekStart.add(Duration(days: i));
            final dayNum = date.day;

            final bg = isSelected
                ? cs.primary.withValues(alpha: 0.95)
                : cs.surfaceContainerHighest.withValues(alpha: 0.30);

            // сегодня обводим только если НЕ выбран (иначе будет “обводка + заливка”)
            final showTodayOutline = isToday && !isSelected;

            final borderColor = isSelected
                ? cs.primary
                : (showTodayOutline
                      ? cs.primary.withValues(alpha: 0.75)
                      : cs.outlineVariant.withValues(alpha: 0.35));

            final borderWidth = showTodayOutline
                ? 1.6
                : (isSelected ? 0.0 : 1.0);

            final fgMain = isSelected
                ? cs.onPrimary
                : cs.onSurface.withValues(alpha: 0.82);
            final fgSub = isSelected
                ? cs.onPrimary.withValues(alpha: 0.85)
                : cs.onSurface.withValues(alpha: 0.45);

            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onTap(i),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bg,
                  border: borderWidth == 0.0
                      ? null
                      : Border.all(color: borderColor, width: borderWidth),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: fgMain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: fgSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

