part of '../../home/tab_profile.dart';

class _CopyTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onCopy;

  const _CopyTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final v = (value ?? '').trim();
    final show = v.isNotEmpty && onCopy != null;

    return InkWell(
      onTap: show ? onCopy : null,
      child: ListTile(
        leading: Icon(icon),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            if (show)
              Icon(
                Icons.copy_rounded,
                size: 18,
                color: cs.onSurface.withValues(alpha: 0.65),
              ),
          ],
        ),
        subtitle: Text(
          (v.isNotEmpty) ? v : '—',
          style: t.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: v.isNotEmpty ? 0.85 : 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

