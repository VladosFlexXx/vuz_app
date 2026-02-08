part of '../../home/tab_profile.dart';

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final v = (value ?? '').trim();
    final show = v.isNotEmpty;

    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        show ? v : '—',
        style: t.bodyMedium?.copyWith(
          color: cs.onSurface.withValues(alpha: show ? 0.85 : 0.55),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

